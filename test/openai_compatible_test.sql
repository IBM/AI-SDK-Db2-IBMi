-- Test file for OpenAI-compatible endpoints
-- This test demonstrates the integration with OpenAI-compatible endpoints
-- The expected response matches the format in oai.json

-- First, set up the connection details for this test
CALL watsonx.openai_compatible_setserverforjob('localhost');
CALL watsonx.openai_compatible_setportforjob(8080);
CALL watsonx.openai_compatible_setprotocolforjob('http');
CALL watsonx.openai_compatible_setbasepathforjob('/v1'); -- Standard OpenAI API path

-- Test a direct completion call (raw HTTP)
CREATE OR REPLACE PROCEDURE watsonx.test_openai_compatible_completion()
  RETURNS VARCHAR(32000) CCSID 1208
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  SET OPTION USRPRF = *USER, DYNUSRPRF = *USER, COMMIT = *NONE
BEGIN
  DECLARE fullUrl VARCHAR(32500) CCSID 1208 DEFAULT NULL;
  DECLARE response_header VARCHAR(10000) CCSID 1208;
  DECLARE response_message VARCHAR(32500) CCSID 1208;
  DECLARE http_options VARCHAR(32400) CCSID 1208;
  
  -- Build the URL to match the completions API
  SET fullUrl = watsonx.openai_compatible_getprotocol() 
              CONCAT '://' 
              CONCAT watsonx.openai_compatible_getserver() 
              CONCAT ':' 
              CONCAT watsonx.openai_compatible_getport() 
              CONCAT '/v1/completions';
  
  -- Set HTTP options
  SET http_options = JSON_OBJECT(
    'ioTimeout': 2000000,
    'headers': JSON_OBJECT(
      'Content-Type': 'application/json'
    )
  );
  
  -- Make the API call using the standard JSON structure
  SELECT RESPONSE_MESSAGE, RESPONSE_HTTP_HEADER
  INTO response_message, response_header
  FROM TABLE(QSYS2.HTTP_POST_VERBOSE(
                fullUrl,
                JSON_OBJECT(
                  'prompt': 'Building a website can be done in 10 simple steps:',
                  'max_tokens': 128
                ),
                http_options));
  
  -- Log the response for debugging
  CALL systools.lprintf('Test response: ' CONCAT response_message);
  
  RETURN response_message;
END;

-- Execute the test procedure to see raw response
VALUES watsonx.test_openai_compatible_completion();

-- Test using the simplified generate function
CALL watsonx.openai_compatible_setmodelforjob('gpt-3.5-turbo'); -- Set some model name

-- Basic usage with just the prompt and model parameters
SELECT watsonx.openai_compatible_generate(
  'why are armadillo so cute?',
  NULL  -- Use default model 
) FROM sysibm.sysdummy1;

-- Test using the JSON generation function
SELECT watsonx.openai_compatible_generate_json(
  'Generate a JSON with 3 names and ages of fictional people',
  NULL
) FROM sysibm.sysdummy1;

-- Basic call with defaults
SELECT watsonx.openai_compatible_generate('Tell me a story about a dragon.') 
FROM sysibm.sysdummy1;

-- With specific options
SELECT watsonx.openai_compatible_generate(
  'why are armadillos so cute?',
  '{"max_tokens": 128, "temperature": 0.7}'
) 
FROM sysibm.sysdummy1;

-- JSON generation with options
SELECT watsonx.openai_compatible_generate_json(
  'List the top 5 programming languages as a JSON array.',
  '{"temperature": 0.5, "max_tokens": 100}'
) 
FROM sysibm.sysdummy1;

-- Clean up after the test
SET watsonx.openai_compatible_server = NULL;
SET watsonx.openai_compatible_port = NULL;
SET watsonx.openai_compatible_protocol = NULL;
SET watsonx.openai_compatible_basepath = NULL;
SET watsonx.openai_compatible_model = NULL;