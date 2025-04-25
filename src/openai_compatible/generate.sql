-- ## OpenAI-compatible endpoints main functionality

-- #### **Function:** `openai_compatible_generate`

-- **Description:** Uses OpenAI-compatible API to generate a reply to the given prompt
-- 
-- **Input parameters:**
-- - `PROMPT` (required): The input prompt for the LLM.
-- - `model_id` (optional): The model identifier to use for generation.
-- 
-- **Return type:** 
-- - `clob(2G) ccsid 1208`
-- 
-- **Return value:**
-- - The generated reply.

create or replace function watsonx.openai_compatible_generate(
  prompt varchar(32000) ccsid 1208, 
  model_id varchar(1000) ccsid 1208 default NULL
) 
  returns clob(2G) ccsid 1208
  modifies sql data
  not deterministic
  no external action
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  declare fullUrl varchar(32500) ccsid 1208 default NULL;
  declare apierr varchar(32500) ccsid 1208 default NULL;
  declare response_header varchar(10000) ccsid 1208;
  declare response_message varchar(32500) ccsid 1208;
  declare response_code int default 500;
  declare api_key varchar(1000) ccsid 1208;
  declare http_options varchar(32400) ccsid 1208;
  
  -- Get API key for authentication
  set api_key = watsonx.openai_compatible_getapikey();
  
  -- Build the URL for the OpenAI compatible API endpoint
  set fullUrl = watsonx.openai_compatible_getprotocol() concat '://' 
              concat watsonx.openai_compatible_getserver() 
              concat ':' concat watsonx.openai_compatible_getport() 
              concat watsonx.openai_compatible_getbasepath() 
              concat '/completions';
  
  -- Set HTTP options including headers
  if (api_key is not null and trim(api_key) <> '') then
    set http_options = json_object(
      'ioTimeout': 2000000,
      'headers': json_object(
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' concat api_key
      )
    );
  else 
    set http_options = json_object(
      'ioTimeout': 2000000,
      'headers': json_object(
        'Content-Type': 'application/json'
      )
    );
  end if;
  
  -- Make the API call
  select response_message, response_http_header
  into response_message, response_header
  from table(qsys2.http_post_verbose(
                fullUrl,
                json_object(
                  'model': coalesce(model_id, watsonx.openai_compatible_getmodel()),
                  'prompt': prompt,
                  'max_tokens': 2048
                ),
                http_options));
  
  -- Log the response for debugging
  call systools.lprintf('OpenAI compatible response: ' concat response_message);
  
  -- Get HTTP status code
  set response_code = json_value(response_header, '$.HTTP_STATUS_CODE');
  
  -- Process the response based on the schema in oai.json
  if (response_code >= 200 and response_code < 300) then
    declare response_text clob(2G) ccsid 1208;
    
    -- Extract the content from the choices[0].text field as shown in oai.json
    set response_text = json_value(response_message, '$.choices[0].text' returning clob(2G) ccsid 1208);
    
    -- If parse fails, return the entire JSON response as a fallback
    if (response_text is null) then
      call systools.lprintf('OpenAI compatible parsing failed, returning full response');
      return response_message;
    end if;
    
    return response_text;
  end if;
  
  -- Log error for debugging
  call systools.lprintf('OpenAI compatible request returned error: ' concat response_message);
  signal sqlstate '38002' set message_text = 'An error has occurred. Check the job log.';
  return null;
end;

-- #### **Function:** `openai_compatible_generate_json`

-- **Description:** Uses OpenAI-compatible API to process a prompt and return structured JSON
-- 
-- **Input parameters:**
-- - `PROMPT` (required): The input prompt for the LLM.
-- - `model_id` (optional): The model identifier to use for generation.
-- 
-- **Return type:** 
-- - `clob(2G) ccsid 1208`
-- 
-- **Return value:**
-- - The complete JSON response from the API.

create or replace function watsonx.openai_compatible_generate_json(
  prompt varchar(32000) ccsid 1208, 
  model_id varchar(1000) ccsid 1208 default NULL
) 
  returns clob(2G) ccsid 1208
  modifies sql data
  not deterministic
  no external action
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  declare fullUrl varchar(32500) ccsid 1208 default NULL;
  declare apierr varchar(32500) ccsid 1208 default NULL;
  declare response_header varchar(10000) ccsid 1208;
  declare response_message varchar(32500) ccsid 1208;
  declare response_code int default 500;
  declare api_key varchar(1000) ccsid 1208;
  declare http_options varchar(32400) ccsid 1208;
  
  -- Get API key for authentication
  set api_key = watsonx.openai_compatible_getapikey();
  
  -- Build the URL for the OpenAI compatible API endpoint
  set fullUrl = watsonx.openai_compatible_getprotocol() concat '://' 
              concat watsonx.openai_compatible_getserver() 
              concat ':' concat watsonx.openai_compatible_getport() 
              concat watsonx.openai_compatible_getbasepath() 
              concat '/completions';
  
  -- Set HTTP options including headers
  if (api_key is not null and trim(api_key) <> '') then
    set http_options = json_object(
      'headers': json_object(
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' concat api_key
      )
    );
  else 
    set http_options = json_object(
      'headers': json_object(
        'Content-Type': 'application/json'
      )
    );
  end if;
  
  -- Make the API call
  select response_message, response_http_header
  into response_message, response_header
  from table(qsys2.http_post_verbose(
                fullUrl,
                json_object(
                  'model': coalesce(model_id, watsonx.openai_compatible_getmodel()),
                  'prompt': prompt,
                  'max_tokens': 2048
                ),
                http_options));
  
  -- Log the response for debugging
  call systools.lprintf('OpenAI compatible JSON response: ' concat response_message);
  
  -- Get HTTP status code
  set response_code = json_value(response_header, '$.HTTP_STATUS_CODE');
  
  -- Process the response
  if (response_code >= 200 and response_code < 300) then
    -- Return the complete JSON response
    return response_message;
  end if;
  
  -- Log error for debugging
  call systools.lprintf('OpenAI compatible JSON request returned error: ' concat response_message);
  signal sqlstate '38002' set message_text = 'An error has occurred. Check the job log.';
  return null;
end;