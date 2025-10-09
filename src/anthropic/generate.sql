-- ## Anthropic API main functionality

-- #### **Function:** `anthropic_generate`

-- **Description:** Uses Anthropic API to generate a reply to the given prompt
-- 
-- **Input parameters:**
-- - `PROMPT` (required): The input prompt for the LLM.
-- - `options` (optional): JSON object containing optional parameters:
--   - `model_id`: The model identifier to use for generation (e.g., claude-3-opus-20240229).
--   - `max_tokens`: Maximum number of tokens to generate. Default 256.
--   - `temperature`: Sampling temperature between 0 and 1. Default 1.
--   - `top_p`: Nucleus sampling probability mass. Default 1.
--   - `top_k`: Number of tokens to consider for sampling. Default null.
--   - `stop_sequences`: Array of sequences where generation should stop.
--   - `system`: System instructions to guide Claude's behavior.
-- - `apikey` (optional): API key for authentication. If not provided, uses configured key.
-- - `base_url` (optional): Base URL for the API endpoint. If not provided, uses configured endpoint settings.
-- 
-- **Return type:** 
-- - `clob(2G) ccsid 1208`
-- 
-- **Return value:**
-- - The generated reply.

create or replace function dbsdk_v1.anthropic_generate(
  prompt varchar(32000) ccsid 1208,
  options varchar(32000) ccsid 1208 default '{}',
  api_key_  varchar(8000) ccsid 1208 default NULL,
  base_url varchar(1000) ccsid 1208 default NULL
) 
  returns clob(2G) ccsid 1208
  modifies sql data
  not deterministic
  no external action
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  declare fullUrl varchar(32500) ccsid 1208 default NULL;
  declare apierr varchar(32500) ccsid 1208 default NULL;
  declare response_header clob(32K) ccsid 1208;
  declare response_message clob(2G) ccsid 1208;
  declare response_code int default 500;
  declare api_key varchar(8000) ccsid 1208;
  declare http_options varchar(32400) ccsid 1208;
  declare response_text clob(2G) ccsid 1208;
  declare req_body clob(64K) ccsid 1208;
  
  -- Extract parameters from options
  declare model_id varchar(1000) ccsid 1208;
  declare max_tokens integer default 256;
  declare temperature decimal(3,1);
  declare top_p decimal(3,1);
  declare top_k integer;
  declare stop_sequences varchar(32000) ccsid 1208;
  declare system_prompt varchar(32000) ccsid 1208;
  declare api_version varchar(100) ccsid 1208;
  
  -- Get parameters from options JSON
  set model_id = json_value(options, '$.model_id');
  set max_tokens = coalesce(json_value(options, '$.max_tokens'), 256);
  set temperature = coalesce(json_value(options, '$.temperature'), 1);
  set top_p = coalesce(json_value(options, '$.top_p'), 1);
  set top_k = json_value(options, '$.top_k');
  set stop_sequences = json_value(options, '$.stop_sequences');
  set system_prompt = json_value(options, '$.system');
  
  -- Get API key for authentication
  if (api_key_ is null) then
    set api_key = dbsdk_v1.anthropic_getapikey();
  else
    set api_key = api_key_;
  end if;
  
  -- Get API version
  set api_version = dbsdk_v1.anthropic_getversion();
  
  -- Build the URL for the Anthropic API endpoint
  if (base_url is not null and trim(base_url) <> '') then
    -- Use provided base URL
    set fullUrl = base_url concat '/messages';
  else
    -- Use configured endpoint settings
    set fullUrl = dbsdk_v1.anthropic_getprotocol() concat '://' 
                concat dbsdk_v1.anthropic_getserver() 
                concat ':' concat dbsdk_v1.anthropic_getport() 
                concat dbsdk_v1.anthropic_getbasepath() 
                concat '/messages';
  end if;
  
  -- Set HTTP options including headers
  if (api_key is not null and trim(api_key) <> '') then
    set http_options = json_object(
      'ioTimeout': 2000000,
      'headers': json_object(
        'Content-Type': 'application/json',
        'x-api-key': api_key,
        'anthropic-version': api_version
      )
    );
  else 
    set http_options = json_object(
      'ioTimeout': 2000000,
      'headers': json_object(
        'Content-Type': 'application/json',
        'anthropic-version': api_version
      )
    );
  end if;
  
  -- Build the request body with required parameters
  set req_body = json_object(
    'model': coalesce(model_id, dbsdk_v1.anthropic_getmodel()),
    'messages': json_array(
      json_object(
        'role': 'user',
        'content': prompt
      )
    ),
    'max_tokens': max_tokens
  );

  -- Add optional parameters only if they are not null
  if (temperature is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.temperature', temperature);
  end if;

  if (top_p is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.top_p', top_p);
  end if;

  if (top_k is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.top_k', top_k);
  end if;

  if (stop_sequences is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.stop_sequences', stop_sequences);
  end if;

  if (system_prompt is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.system', system_prompt);
  end if;
  
  -- Make the API call
  select response_message, response_http_header
  into response_message, response_header
  from table(qsys2.http_post_verbose(
                fullUrl,
                req_body,
                http_options));
  
  -- Get HTTP status code
  set response_code = json_value(response_header, '$.HTTP_STATUS_CODE');
  
  -- Process the response
  if (response_code >= 200 and response_code < 300) then
    -- Extract the content from the content field
    set response_text = json_value(response_message, '$.content[0].text' returning clob(2G) ccsid 1208);
    
    -- If parse fails, return the entire JSON response as a fallback
    if (response_text is null) then
      call systools.lprintf('Anthropic parsing failed, returning full response');
      return response_message;
    end if;
    
    return response_text;
  end if;
  
  set response_text = 'An error has occured. Check the job log. HTTP response code was ' concat response_code concat ' from ' concat fullUrl;
  signal sqlstate '38002' set message_text = response_text;
  return null;
end;

-- #### **Function:** `anthropic_generate_json`

-- **Description:** Uses Anthropic API to process a prompt and return structured JSON
-- 
-- **Input parameters:**
-- - `PROMPT` (required): The input prompt for the LLM.
-- - `options` (optional): JSON object containing optional parameters:
--   - `model_id`: The model identifier to use for generation.
--   - `max_tokens`: Maximum number of tokens to generate. Default 256.
--   - `temperature`: Sampling temperature between 0 and 1. Default 1.
--   - `top_p`: Nucleus sampling probability mass. Default 1.
--   - `top_k`: Number of tokens to consider for sampling. Default null.
--   - `stop_sequences`: Array of sequences where generation should stop.
--   - `system`: System instructions to guide Claude's behavior.
-- - `api_key_` (optional): API key for authentication. If not provided, uses configured key.
-- - `base_url` (optional): Base URL for the API endpoint. If not provided, uses configured endpoint settings.
-- 
-- **Return type:** 
-- - `clob(2G) ccsid 1208`
-- 
-- **Return value:**
-- - The complete JSON response from the API.

create or replace function dbsdk_v1.anthropic_generate_json(
  prompt varchar(32000) ccsid 1208,
  options varchar(32000) ccsid 1208 default '{}',
  api_key_  varchar(8000) ccsid 1208 default NULL,
  base_url varchar(1000) ccsid 1208 default NULL
) 
  returns clob(2G) ccsid 1208
  modifies sql data
  not deterministic
  no external action
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  declare fullUrl varchar(32500) ccsid 1208 default NULL;
  declare apierr varchar(32500) ccsid 1208 default NULL;
  declare response_header clob(32K) ccsid 1208;
  declare response_message clob(2G) ccsid 1208;
  declare response_code int default 500;
  declare api_key varchar(8000) ccsid 1208;
  declare http_options varchar(32400) ccsid 1208;
  declare req_body clob(64K) ccsid 1208;
  
  -- Extract parameters from options
  declare model_id varchar(1000) ccsid 1208;
  declare max_tokens integer default 256;
  declare temperature decimal(3,1);
  declare top_p decimal(3,1);
  declare top_k integer;
  declare stop_sequences varchar(32000) ccsid 1208;
  declare system_prompt varchar(32000) ccsid 1208;
  declare api_version varchar(100) ccsid 1208;
  
  -- Get parameters from options JSON
  set model_id = json_value(options, '$.model_id');
  set max_tokens = coalesce(json_value(options, '$.max_tokens'), 256);
  set temperature = coalesce(json_value(options, '$.temperature'), 1);
  set top_p = coalesce(json_value(options, '$.top_p'), 1);
  set top_k = json_value(options, '$.top_k');
  set stop_sequences = json_value(options, '$.stop_sequences');
  set system_prompt = json_value(options, '$.system');
  
  -- Get API key for authentication
  if (api_key_ is null) then
    set api_key = dbsdk_v1.anthropic_getapikey();
  else
    set api_key = api_key_;
  end if;
  
  -- Get API version
  set api_version = dbsdk_v1.anthropic_getversion();
  
  -- Build the URL for the Anthropic API endpoint
  if (base_url is not null and trim(base_url) <> '') then
    -- Use provided base URL
    set fullUrl = base_url concat '/messages';
  else
    -- Use configured endpoint settings
    set fullUrl = dbsdk_v1.anthropic_getprotocol() concat '://' 
                concat dbsdk_v1.anthropic_getserver() 
                concat ':' concat dbsdk_v1.anthropic_getport() 
                concat dbsdk_v1.anthropic_getbasepath() 
                concat '/messages';
  end if;
  
  -- Set HTTP options including headers
  if (api_key is not null and trim(api_key) <> '') then
    set http_options = json_object(
      'ioTimeout': 2000000,
      'headers': json_object(
        'Content-Type': 'application/json',
        'x-api-key': api_key,
        'anthropic-version': api_version
      )
    );
  else 
    set http_options = json_object(
      'ioTimeout': 2000000,
      'headers': json_object(
        'Content-Type': 'application/json',
        'anthropic-version': api_version
      )
    );
  end if;
  
  -- Build the request body with required parameters
  set req_body = json_object(
    'model': coalesce(model_id, dbsdk_v1.anthropic_getmodel()),
    'messages': json_array(
      json_object(
        'role': 'user',
        'content': prompt
      )
    ),
    'max_tokens': max_tokens
  );

  -- Add optional parameters only if they are not null
  if (temperature is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.temperature', temperature);
  end if;

  if (top_p is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.top_p', top_p);
  end if;

  if (top_k is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.top_k', top_k);
  end if;

  if (stop_sequences is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.stop_sequences', stop_sequences);
  end if;

  if (system_prompt is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.system', system_prompt);
  end if;
  
  -- Make the API call
  select response_message, response_http_header
  into response_message, response_header
  from table(qsys2.http_post_verbose(
                fullUrl,
                req_body,
                http_options));
  
  -- Get HTTP status code
  set response_code = json_value(response_header, '$.HTTP_STATUS_CODE');
  
  -- Process the response
  if (response_code >= 200 and response_code < 300) then
    -- Return the complete JSON response
    return response_message;
  end if;

  return null;
end;

-- Made with Bob
