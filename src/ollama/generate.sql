create or replace function watsonx.ollama_generate(prompt varchar(1000) ccsid 1208, model_id varchar(1000) ccsid 1208 default NULL) 
  RETURNS TABLE(output VARCHAR(32000) ccsid 1208 )
  modifies sql data
  not deterministic
  no external action
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  declare fullUrl varchar(32500) ccsid 1208 default NULL;
  declare http_options varchar(32400) ccsid 1208 default '{"ioTimeout":2000000}';
  set fullUrl = watsonx.ollama_getprotocol() concat '://' concat watsonx.ollama_getserver() concat ':' concat watsonx.ollama_getport() concat '/api/generate';
  
  return SELECT ELEMENT as response
    FROM TABLE (
            SYSTOOLS.SPLIT(
                    JSON_VALUE(QSYS2.HTTP_POST(
                        fullUrl,
                        json_object('model': watsonx.ollama_getmodel(), 'prompt': prompt, 'stream': false),
                        http_options), 
                    '$.response'),'
'));
end;