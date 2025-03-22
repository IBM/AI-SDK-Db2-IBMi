create or replace function watsonx.generate(
  text varchar(1000) ccsid 1208,
  model_id varchar(128) ccsid 1208 default 'meta-llama/llama-2-13b-chat',
  parameters varchar(1000) ccsid 1208 default null
)
  returns varchar(10000) ccsid 1208
  not deterministic
  no external action
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin

  -- https://cloud.ibm.com/apidocs/watsonx-ai#text-generation
  declare response_header Varchar(10000) CCSID 1208;
  declare response_message Varchar(10000) CCSID 1208;
  declare watsonx_response Varchar(10000) CCSID 1208;
  declare response_code int default 0;
  declare needsNewToken char(1) default 'Y';

  set needsNewToken = watsonx.ShouldGetNewToken();
  if (needsNewToken = 'Y') then
    signal sqlstate '38001' set message_text = 'Please authenticate first.';
    return '*ERROR';
  end if;

  if parameters is null then
    set parameters = watsonx.parameters(max_new_tokens => 100, time_limit => 1000);
  end if;

  -- todo: support this url:
  -- watsonx.geturl('/' concat id_or_name concat '/text/generation'),

  select RESPONSE_MESSAGE, RESPONSE_HTTP_HEADER
  into response_message, response_header
  from table(HTTP_POST_VERBOSE(
    watsonx.geturl('/text/generation'),
    json_object('model_id': model_id, 'input': text, 'parameters': parameters format json, 'project_id': watsonx.projectid),
    json_object('headers': json_object('Authorization': 'Bearer ' concat watsonx.JobBearerToken, 'Content-Type': 'application/json', 'Accept': 'application/json'))
  )) x;
  
  set response_code = json_value(response_header, '$.HTTP_STATUS_CODE');

  if (response_code = 200) then
    set watsonx_response = json_value(response_message, '$.results[0].generated_text');

    if (watsonx_response is not null) then
      return watsonx_response;
    end if;
  end if;

  signal sqlstate '38002' set message_text = 'Add error has occured. Check the job log.';
  call qsys2.lprintf(json_object('response_message': response_message format json, 'response_header': response_header format json));
  
  return '*ERROR';
end;