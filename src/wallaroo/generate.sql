-- ## Wallaroo Main Functionality

-- #### **Function:** `wallaroo_generate`

-- **Description:** Uses Wallaroo AI to generate a reply to the given prompt
-- 
-- **Input parameters:**
-- - `PROMPT` (required): The input prompt for the LLM.
-- - `options` (optional): JSON object containing optional parameters:
--   - `model_id`: The model identifier to use for generation.
--   - `max_tokens`: Maximum number of tokens to generate. Default 16.
--   - `temperature`: Sampling temperature between 0 and 2. Default 1.
--   - `top_p`: Nucleus sampling probability mass. Default 1.
--   - `n`: Number of completions to generate. Default 1.
--   - `stream`: Whether to stream back partial progress. Default false.
--   - `logprobs`: Include log probabilities on most likely tokens, max 5.
--   - `echo`: Echo back the prompt in the completion. Default false.
--   - `stop`: Up to 4 sequences where generation should stop.
--   - `presence_penalty`: Penalty between -2.0 and 2.0 for tokens based on presence. Default 0.
--   - `frequency_penalty`: Penalty between -2.0 and 2.0 for tokens based on frequency. Default 0.
--   - `best_of`: Generate best_of completions server-side. Default 1.
--   - `logit_bias`: JSON object mapping tokens to bias values.
--   - `user`: Unique identifier for the end user.
--   - `seed`: Seed for deterministic sampling.
--   - `suffix`: Suffix after completion insertion (for compatible models only).
-- 
-- **Return type:** 
-- - `clob(2G) ccsid 1208`
-- 
-- **Return value:**
-- - The generated reply from Wallaroo AI.

-- create or replace function dbsdk_v1.wallaroo_generate(
--   prompt varchar(32000) ccsid 1208,
--   options varchar(32000) ccsid 1208 default '{}'
-- ) 
--   returns clob(2G) ccsid 1208
--   modifies sql data
--   not deterministic
--   no external action
--   set option usrprf = *user, dynusrprf = *user, commit = *none
-- begin
--   declare access_token varchar(8000) ccsid 1208;
--   declare response_text clob(2G) ccsid 1208;
  
--   -- Step 1: Get access token using Wallaroo OAuth2 client credentials flow
--   set access_token = dbsdk_v1.wallaroo_get_access_token();
  
--   -- Check if we got a valid access token
--   if (access_token is null or trim(access_token) = '') then
--     call systools.lprintf('Wallaroo authentication failed - no access token received');
--     return null;
--   end if;
  
--   -- Step 2: Call OpenAI compatible generate function with the access token
--   -- Make sure we pass the parameters in the correct order and types
--   call systools.lprintf('this is a cool test message');
-- set response_text = dbsdk_v1.openai_compatible_generate(
--     prompt,
--     options,
--     access_token
-- );
  
--   return response_text;
-- end;




-- #### **Function:** `wallaroo_generate`

-- **Description:** Uses Wallaroo AI to generate a reply to the given prompt with improved authentication and URL handling
-- 
-- **Input parameters:**
-- - `PROMPT` (required): The input prompt for the LLM.
-- - `options` (optional): JSON object containing optional parameters:
--   - `model_id`: The model identifier to use for generation.
--   - `max_tokens`: Maximum number of tokens to generate. Default 256.
--   - `temperature`: Sampling temperature between 0 and 2. Default 1.
--   - `top_p`: Nucleus sampling probability mass. Default 1.
--   - `n`: Number of completions to generate. Default 1.
--   - `stream`: Whether to stream back partial progress. Default false.
--   - `logprobs`: Include log probabilities on most likely tokens, max 5.
--   - `echo`: Echo back the prompt in the completion. Default false.
--   - `stop`: Up to 4 sequences where generation should stop.
--   - `presence_penalty`: Penalty between -2.0 and 2.0 for tokens based on presence. Default 0.
--   - `frequency_penalty`: Penalty between -2.0 and 2.0 for tokens based on frequency. Default 0.
--   - `logit_bias`: JSON object mapping tokens to bias values.
--   - `user`: Unique identifier for the end user.
--   - `seed`: Seed for deterministic sampling.
--   - `suffix`: Suffix after completion insertion (for compatible models only).
-- - `base_url` (optional): Custom base URL for the API endpoint. If not provided, uses configured endpoint settings.
-- 
-- **Return type:** 
-- - `clob(2G) ccsid 1208`
-- 
-- **Return value:**
-- - The generated reply from Wallaroo AI.
-- 
-- **Features:**
-- - Automatic OAuth2 client credentials authentication
-- - Configurable endpoint URL support
-- - Comprehensive parameter validation
-- - Detailed error logging and handling
-- - OpenAI-compatible API interface

create or replace function dbsdk_v1.wallaroo_generate(
  prompt varchar(32000) ccsid 1208,
  options varchar(32000) ccsid 1208 default '{}',
  base_url varchar(1000) ccsid 1208 default NULL
) 
  returns clob(2G) ccsid 1208
  modifies sql data
  not deterministic
  no external action
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  declare tokenUrl varchar(1000) ccsid 1208;
  declare confidential_client varchar(1000) ccsid 1208;
  declare confidential_client_secret varchar(8000) ccsid 1208;
  declare t_response_header clob(32K) ccsid 1208;
  declare t_response_message clob(2G) ccsid 1208;
  declare t_response_code int default 500;
  declare t_http_options varchar(32400) ccsid 1208;
  declare t_req_body varchar(1000) ccsid 1208;
  declare access_token varchar(8000) ccsid 1208;
  declare t_basic_auth varchar(8000) ccsid 1208;

  declare fullUrl varchar(32500) ccsid 1208 default NULL;
  declare apierr varchar(32500) ccsid 1208 default NULL;
  declare response_header clob(32K) ccsid 1208;
  declare response_message clob(2G) ccsid 1208;
  declare response_code int default 500;
  declare http_options varchar(32400) ccsid 1208;
  declare response_text clob(2G) ccsid 1208;
  declare req_body clob(64K) ccsid 1208;
  
  -- Extract parameters from options
  declare model_id varchar(1000) ccsid 1208;
  declare max_tokens integer default 256;
  declare temperature decimal(3,1);
  declare top_p decimal(3,1);
  declare n integer;
  declare stream varchar(5) ccsid 1208;
  declare logprobs integer;
  declare echo varchar(5) ccsid 1208;
  declare stop_token varchar(32000) ccsid 1208;
  declare presence_penalty decimal(3,1);
  declare frequency_penalty decimal(3,1);
  declare logit_bias varchar(32000) ccsid 1208;
  declare user_id varchar(1000) ccsid 1208;
  declare seed integer;
  declare suffix varchar(32000) ccsid 1208;
  
  
  -- Get configuration values using the utility functions
  set tokenUrl = dbsdk_v1.wallaroo_get_token_url();
  set confidential_client = dbsdk_v1.wallaroo_get_confidential_client();
  set confidential_client_secret = dbsdk_v1.wallaroo_get_confidential_client_secret();
  
  -- Validate required parameters
  if (tokenUrl is null or confidential_client is null or confidential_client_secret is null) then
    return null;
  end if;
  
  -- Create Basic Auth header (Base64 encoding of client:secret)
  set t_basic_auth = systools.base64encode(confidential_client concat ':' concat confidential_client_secret);
  
  -- Set HTTP options with Basic Authentication and SSL options
  set t_http_options = json_object(
    'ioTimeout': 2000000,
    'sslTolerate': 'true',
    'headers': json_object(
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Basic ' concat t_basic_auth
    )
  );
  
  -- Build the request body for OAuth2 client credentials grant
  set t_req_body = 'grant_type=client_credentials';
  
  -- Make the API call
  select response_message, response_http_header
  into t_response_message, t_response_header
  from table(qsys2.http_post_verbose(
                tokenUrl,
                t_req_body,
                t_http_options));
  
  -- Get HTTP status code
  set t_response_code = json_value(t_response_header, '$.HTTP_STATUS_CODE');
  
  -- Process the response
  if (t_response_code >= 200 and t_response_code < 300) then
    -- Extract the access_token from the JSON response
    set access_token = json_value(t_response_message, '$.access_token' returning varchar(8000) ccsid 1208);
  end if;


  -- Get parameters from options JSON
  set model_id = json_value(options, '$.model_id');
  set max_tokens = coalesce(json_value(options, '$.max_tokens'), 256);
  set temperature = coalesce(json_value(options, '$.temperature'), 1);
  set top_p = coalesce(json_value(options, '$.top_p'), 1);
  set n = coalesce(json_value(options, '$.n'), 1);
  set stream = coalesce(json_value(options, '$.stream'), 'false');
  set logprobs = json_value(options, '$.logprobs');
  set echo = coalesce(json_value(options, '$.echo'), 'false');
  set stop_token = json_value(options, '$.stop');
  set presence_penalty = coalesce(json_value(options, '$.presence_penalty'), 0);
  set frequency_penalty = coalesce(json_value(options, '$.frequency_penalty'), 0);
  set logit_bias = json_value(options, '$.logit_bias');
  set user_id = json_value(options, '$.user');
  set seed = json_value(options, '$.seed');
  set suffix = json_value(options, '$.suffix');

  -- unsupported options
  call systools.lprintf('OpenAI generate...');
  
  
  -- Build the URL for the OpenAI compatible API endpoint
  if (base_url is not null and trim(base_url) <> '') then
    -- Use provided base URL
    set fullUrl = base_url;
  else
    -- Use the hardcoded working URL as fallback for now
    -- set fullUrl = 'https://ibm-demo.pov.wallaroo.io/v1/api/pipelines/infer/llama-3dot1-8b-pipe-2/llama-3dot1-8b-pipe/openai/v1/completions';
    
    set fullUrl = dbsdk_v1.openai_compatible_getprotocol() concat '://' 
                concat dbsdk_v1.openai_compatible_getserver()
                concat dbsdk_v1.openai_compatible_getbasepath() 
                concat '/completions';
  end if;
  
  -- Build the request body with required parameters
  set req_body = json_object(
    'model': '',
    'prompt': prompt,
    'max_tokens': max_tokens,
    'temperature': temperature,
    'top_p': top_p,
    'n': n,
    'presence_penalty': presence_penalty,
    'frequency_penalty': frequency_penalty
  );

  -- Add optional parameters only if they are not null
  if (max_tokens > 0) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.max_tokens', max_tokens);
  end if;

  if (logprobs is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.logprobs', logprobs);
  end if;

  if (stop_token is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.stop', stop_token);
  end if;

  if (logit_bias is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.logit_bias', logit_bias);
  end if;

  if (user_id is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.user', user_id);
  end if;

  if (seed is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.seed', seed);
  end if;

  if (suffix is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.suffix', suffix);
  end if;
  
  
  call systools.lprintf('Full URL being called: ' concat fullUrl);
  call systools.lprintf('req_body: " ' concat req_body concat ' http_opts: ' concat http_options);

  -- Make the API call using the new table-based approach
  WITH api_key_call(key_value) AS (
    VALUES(access_token)
  )
  SELECT 
    JSON_VALUE(response_http_header, '$.HTTP_STATUS_CODE'),
    JSON_VALUE(response_message, '$.choices[0].text'),
    response_message
  INTO response_code, response_text, response_message
  FROM api_key_call, TABLE(QSYS2.HTTP_POST_VERBOSE(
    fullUrl,
    req_body,
    JSON_OBJECT(
      'ioTimeout': 120000,
      'headers': JSON_OBJECT(
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' concat key_value
      )
    )
  ));
  
  -- Process the response based on the schema in oai.json
  if (response_code >= 200 and response_code < 300) then
    -- Extract the content from the choices[0].text field as shown in oai.json
    set response_text = json_value(response_message, '$.choices[0].text' returning clob(2G) ccsid 1208);
    
    -- If parse fails, return the entire JSON response as a fallback
    if (response_text is null) then
      call systools.lprintf('OpenAI compatible parsing failed, returning full response');
      return response_message;
    end if;
    
    return response_text;
  end if;
  set response_text = 'An error has occured. Check the job log. HTTP response code was ' concat response_code concat ' from ' concat fullUrl;
  signal sqlstate '38002' set message_text = response_text;
  return null;
end;


-- #### **Function:** `wallaroo_generate_json`

-- **Description:** Uses Wallaroo AI to process a prompt and return structured JSON
-- 
-- **Input parameters:**
-- - `PROMPT` (required): The input prompt for the LLM.
-- - `options` (optional): JSON object containing optional parameters (same as wallaroo_generate)
-- 
-- **Return type:** 
-- - `clob(2G) ccsid 1208`
-- 
-- **Return value:**
-- - The complete JSON response from Wallaroo AI.

create or replace function dbsdk_v1.wallaroo_generate_json(
  prompt varchar(32000) ccsid 1208,
  options varchar(32000) ccsid 1208 default '{}',
  base_url varchar(1000) ccsid 1208 default NULL
)
  returns clob(2G) ccsid 1208
  modifies sql data
  not deterministic
  no external action
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  declare tokenUrl varchar(1000) ccsid 1208;
  declare confidential_client varchar(1000) ccsid 1208;
  declare confidential_client_secret varchar(8000) ccsid 1208;
  declare t_response_header clob(32K) ccsid 1208;
  declare t_response_message clob(2G) ccsid 1208;
  declare t_response_code int default 500;
  declare t_http_options varchar(32400) ccsid 1208;
  declare t_req_body varchar(1000) ccsid 1208;
  declare access_token varchar(8000) ccsid 1208;
  declare t_basic_auth varchar(8000) ccsid 1208;

  declare fullUrl varchar(32500) ccsid 1208 default NULL;
  declare apierr varchar(32500) ccsid 1208 default NULL;
  declare response_header clob(32K) ccsid 1208;
  declare response_message clob(2G) ccsid 1208;
  declare response_code int default 500;
  declare http_options varchar(32400) ccsid 1208;
  declare response_json clob(2G) ccsid 1208;
  declare req_body clob(64K) ccsid 1208;

  -- Extract parameters from options
  declare model_id varchar(1000) ccsid 1208;
  declare max_tokens integer default 256;
  declare temperature decimal(3,1);
  declare top_p decimal(3,1);
  declare n integer;
  declare stream varchar(5) ccsid 1208;
  declare logprobs integer;
  declare echo varchar(5) ccsid 1208;
  declare stop_token varchar(32000) ccsid 1208;
  declare presence_penalty decimal(3,1);
  declare frequency_penalty decimal(3,1);
  declare logit_bias varchar(32000) ccsid 1208;
  declare user_id varchar(1000) ccsid 1208;
  declare seed integer;
  declare suffix varchar(32000) ccsid 1208;


  -- Get configuration values using the utility functions
  set tokenUrl = dbsdk_v1.wallaroo_get_token_url();
  set confidential_client = dbsdk_v1.wallaroo_get_confidential_client();
  set confidential_client_secret = dbsdk_v1.wallaroo_get_confidential_client_secret();

  -- Validate required parameters
  if (tokenUrl is null or confidential_client is null or confidential_client_secret is null) then
    return null;
  end if;

  -- Create Basic Auth header (Base64 encoding of client:secret)
  set t_basic_auth = systools.base64encode(confidential_client concat ':' concat confidential_client_secret);

  -- Set HTTP options with Basic Authentication and SSL options
  set t_http_options = json_object(
    'ioTimeout': 2000000,
    'sslTolerate': 'true',
    'headers': json_object(
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Basic ' concat t_basic_auth
    )
  );

  -- Build the request body for OAuth2 client credentials grant
  set t_req_body = 'grant_type=client_credentials';

  -- Make the API call
  select response_message, response_http_header
  into t_response_message, t_response_header
  from table(qsys2.http_post_verbose(
                tokenUrl,
                t_req_body,
                t_http_options));

  -- Get HTTP status code
  set t_response_code = json_value(t_response_header, '$.HTTP_STATUS_CODE');

  -- Process the response
  if (t_response_code >= 200 and t_response_code < 300) then
    -- Extract the access_token from the JSON response
    set access_token = json_value(t_response_message, '$.access_token' returning varchar(8000) ccsid 1208);
  end if;


  -- Get parameters from options JSON
  set model_id = json_value(options, '$.model_id');
  set max_tokens = coalesce(json_value(options, '$.max_tokens'), 256);
  set temperature = coalesce(json_value(options, '$.temperature'), 1);
  set top_p = coalesce(json_value(options, '$.top_p'), 1);
  set n = coalesce(json_value(options, '$.n'), 1);
  set stream = coalesce(json_value(options, '$.stream'), 'false');
  set logprobs = json_value(options, '$.logprobs');
  set echo = coalesce(json_value(options, '$.echo'), 'false');
  set stop_token = json_value(options, '$.stop');
  set presence_penalty = coalesce(json_value(options, '$.presence_penalty'), 0);
  set frequency_penalty = coalesce(json_value(options, '$.frequency_penalty'), 0);
  set logit_bias = json_value(options, '$.logit_bias');
  set user_id = json_value(options, '$.user');
  set seed = json_value(options, '$.seed');
  set suffix = json_value(options, '$.suffix');

  -- unsupported options
  call systools.lprintf('OpenAI generate...');


  -- Build the URL for the OpenAI compatible API endpoint
  if (base_url is not null and trim(base_url) <> '') then
    -- Use provided base URL
    set fullUrl = base_url;
  else
    -- Use the hardcoded working URL as fallback for now
    -- set fullUrl = 'https://ibm-demo.pov.wallaroo.io/v1/api/pipelines/infer/llama-3dot1-8b-pipe-2/llama-3dot1-8b-pipe/openai/v1/completions';

    set fullUrl = dbsdk_v1.openai_compatible_getprotocol() concat '://'
                concat dbsdk_v1.openai_compatible_getserver()
                concat dbsdk_v1.openai_compatible_getbasepath()
                concat '/completions';
  end if;

  -- Build the request body with required parameters
  set req_body = json_object(
    'model': '',
    'prompt': prompt,
    'max_tokens': max_tokens,
    'temperature': temperature,
    'top_p': top_p,
    'n': n,
    'presence_penalty': presence_penalty,
    'frequency_penalty': frequency_penalty
  );

  -- Add optional parameters only if they are not null
  if (max_tokens > 0) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.max_tokens', max_tokens);
  end if;

  if (logprobs is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.logprobs', logprobs);
  end if;

  if (stop_token is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.stop', stop_token);
  end if;

  if (logit_bias is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.logit_bias', logit_bias);
  end if;

  if (user_id is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.user', user_id);
  end if;

  if (seed is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.seed', seed);
  end if;

  if (suffix is not null) then
    set req_body = JSON_UPDATE(req_body, 'SET', '$.suffix', suffix);
  end if;


  call systools.lprintf('Full URL being called: ' concat fullUrl);
  call systools.lprintf('req_body: " ' concat req_body concat ' http_opts: ' concat http_options);

  -- Make the API call using the new table-based approach
  WITH api_key_call(key_value) AS (
    VALUES(access_token)
  )
  SELECT
    JSON_VALUE(response_http_header, '$.HTTP_STATUS_CODE'),
    response_message
  INTO response_code, response_json
  FROM api_key_call, TABLE(QSYS2.HTTP_POST_VERBOSE(
    fullUrl,
    req_body,
    JSON_OBJECT(
      'ioTimeout': 120000,
      'headers': JSON_OBJECT(
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' concat key_value
      )
    )
  ));

  -- Process the response based on the schema in oai.json
  if (response_code >= 200 and response_code < 300) then
    -- Return the full JSON response
    return response_json;
  end if;
  set response_json = 'An error has occured. Check the job log. HTTP response code was ' concat response_code concat ' from ' concat fullUrl;
  signal sqlstate '38002' set message_text = response_json;
  return null;
end;
