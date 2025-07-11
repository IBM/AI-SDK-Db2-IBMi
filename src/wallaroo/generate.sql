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

create or replace function dbsdk_v1.wallaroo_generate(
  prompt varchar(32000) ccsid 1208,
  options varchar(32000) ccsid 1208 default '{}'
) 
  returns clob(2G) ccsid 1208
  modifies sql data
  not deterministic
  no external action
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  declare access_token varchar(8000) ccsid 1208;
  declare response_text clob(2G) ccsid 1208;
  
  -- Step 1: Get access token using Wallaroo OAuth2 client credentials flow
  set access_token = dbsdk_v1.wallaroo_get_access_token();
  
  -- Check if we got a valid access token
  if (access_token is null or trim(access_token) = '') then
    call systools.lprintf('Wallaroo authentication failed - no access token received');
    return null;
  end if;
  
  -- Step 2: Call OpenAI compatible generate function with the access token
  -- Make sure we pass the parameters in the correct order and types
set response_text = dbsdk_v1.openai_compatible_generate(
    prompt,
    options,
    access_token
);
  
  return response_text;
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
  options varchar(32000) ccsid 1208 default '{}'
) 
  returns clob(2G) ccsid 1208
  modifies sql data
  not deterministic
  no external action
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  declare access_token varchar(8000) ccsid 1208;
  declare response_json clob(2G) ccsid 1208;
  
  -- Step 1: Get access token using Wallaroo OAuth2 client credentials flow
  set access_token = dbsdk_v1.wallaroo_get_access_token();
  
  -- Check if we got a valid access token
  if (access_token is null or trim(access_token) = '') then
    call systools.lprintf('Wallaroo authentication failed - no access token received');
    return null;
  end if;
  
  -- Step 2: Call OpenAI compatible generate_json function with the access token
  set response_json = dbsdk_v1.openai_compatible_generate_json(
    prompt,
    options,
    access_token
  );
  
  return response_json;
end;
