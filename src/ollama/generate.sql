
-- ## Ollama main functionality

-- ### function: `ollama_generate`

-- Description: Uses ollama to generate a reply to the given prompt
-- 
-- Input parameters:
-- - `PROMPT` (required): The input prompt for the LLM.
-- - `model_id` (optional): The ollama identifier of the model to use for generation.
-- 
-- Return type: 
-- - `clob(2G) ccsid 1208`
-- 
-- Return value:
-- - The generated reply.

create or replace function watsonx.ollama_generate(prompt varchar(1000) ccsid 1208, model_id varchar(1000) ccsid 1208 default NULL) 
  RETURNS clob(2G) ccsid 1208
  modifies sql data
  not deterministic
  no external action
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  declare fullUrl varchar(32500) ccsid 1208 default NULL;
  declare apierr  varchar(32500) CCSID 1208 default NULL;
  declare response_header Varchar(10000) CCSID 1208;
  declare response_message Varchar(10000) CCSID 1208;
  declare response_code int default 500;
  
  declare http_options varchar(32400) ccsid 1208 default '{"ioTimeout":2000000}';
  set fullUrl = watsonx.ollama_getprotocol() concat '://' concat watsonx.ollama_getserver() concat ':' concat watsonx.ollama_getport() concat '/api/generate';
  
  select RESPONSE_MESSAGE, RESPONSE_HTTP_HEADER
  into response_message, response_header
  from table(QSYS2.HTTP_POST_VERBOSE(
                        fullUrl,
                        json_object('model': watsonx.ollama_getmodel(), 'prompt': prompt, 'stream': false),
                        http_options));
  call systools.lprintf('r: ' concat response_message);
  set response_code = json_value(response_header, '$.HTTP_STATUS_CODE');
   
  if (response_code >= 200 and response_code < 300) then
    return JSON_VALUE(response_message,'$.response' returning CLOB(2G) ccsid 1208);
  end if;
  
  call systools.lprintf('Ollama generation request returned error: ' concat response_message);
  signal sqlstate '38002' set message_text = 'Add error has occured. Check the job log.';
  return null;
end;