-- ## OpenAI-compatible endpoints main functionality

-- #### **Function:** `openai_compatible_generate`

-- **Description:** Uses OpenAI-compatible API to generate a reply to the given prompt
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
-- - The generated reply.
--
-- Unsupported options:
--  - set best_of = coalesce(json_value(options, '$.best_of'), 1);

create or replace function dbsdk_v1.openai_compatible_generate(
  prompt varchar(32000) ccsid 1208,
  options varchar(32000) ccsid 1208 default '{}'
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
  
  -- Get API key for authentication
  set api_key = dbsdk_v1.openai_compatible_getapikey();
  
  -- Build the URL for the OpenAI compatible API endpoint
  set fullUrl = dbsdk_v1.openai_compatible_getprotocol() concat '://' 
              concat dbsdk_v1.openai_compatible_getserver() 
              concat ':' concat dbsdk_v1.openai_compatible_getport() 
              concat dbsdk_v1.openai_compatible_getbasepath() 
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
  
  -- Build the request body with required parameters
  set req_body = json_object(
    'model': coalesce(model_id, dbsdk_v1.openai_compatible_getmodel()),
    'prompt': prompt,
    'max_tokens': max_tokens,
    'temperature': temperature,
    'top_p': top_p,
    'n': n,
    'stream': CAST(stream as boolean),
    'echo': CAST(echo as boolean),
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
  
  -- Make the API call
  select response_message, response_http_header
  into response_message, response_header
  from table(qsys2.http_post_verbose(
                fullUrl,
                req_body,
                http_options));
  
  
  -- Get HTTP status code
  set response_code = json_value(response_header, '$.HTTP_STATUS_CODE');
  
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
  
  return null;
end;

-- #### **Function:** `openai_compatible_generate_json`

-- **Description:** Uses OpenAI-compatible API to process a prompt and return structured JSON
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
-- - The complete JSON response from the API.
--
-- Unsupported options:
--  - set best_of = coalesce(json_value(options, '$.best_of'), 1);

create or replace function dbsdk_v1.openai_compatible_generate_json(
  prompt varchar(32000) ccsid 1208,
  options varchar(32000) ccsid 1208 default '{}'
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
  
  -- Get API key for authentication
  set api_key = dbsdk_v1.openai_compatible_getapikey();
  
  -- Build the URL for the OpenAI compatible API endpoint
  set fullUrl = dbsdk_v1.openai_compatible_getprotocol() concat '://' 
              concat dbsdk_v1.openai_compatible_getserver() 
              concat ':' concat dbsdk_v1.openai_compatible_getport() 
              concat dbsdk_v1.openai_compatible_getbasepath() 
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
  
  -- Build the request body with required parameters
  set req_body = json_object(
    'model': coalesce(model_id, dbsdk_v1.openai_compatible_getmodel()),
    'prompt': prompt,
    'temperature': temperature,
    'top_p': top_p,
    'n': n,
    'stream': CAST(stream as boolean),
    'echo': CAST(echo as boolean),
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