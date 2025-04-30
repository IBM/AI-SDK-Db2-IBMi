-- Test file for OpenAI-compatible endpoints
-- This test demonstrates the integration with OpenAI-compatible endpoints
-- The expected response matches the format in oai.json

-- First, set up the connection details for this test
CALL dbsdk_v1.openai_compatible_setserverforjob('localhost');
CALL dbsdk_v1.openai_compatible_setportforjob(8080);
CALL dbsdk_v1.openai_compatible_setprotocolforjob('http');
CALL dbsdk_v1.openai_compatible_setbasepathforjob('/v1'); -- Standard OpenAI API path

-- Basic usage with just the prompt and model parameters
SELECT dbsdk_v1.openai_compatible_generate(
  'why are armadillo so cute?',
  NULL  -- Use default model 
) FROM sysibm.sysdummy1;

-- Test using the JSON generation function
SELECT dbsdk_v1.openai_compatible_generate_json(
  'Generate a JSON with 3 names and ages of fictional people',
  NULL
) FROM sysibm.sysdummy1;

-- Basic call with defaults
SELECT dbsdk_v1.openai_compatible_generate('Tell me a story about a dragon.') 
FROM sysibm.sysdummy1;

-- With specific options
SELECT dbsdk_v1.openai_compatible_generate(
  'why are armadillos so cute?',
  '{"max_tokens": 128, "temperature": 0.7}'
) 
FROM sysibm.sysdummy1;

SELECT dbsdk_v1.openai_compatible_generate(
  'why are armadillos so cute?',
  '{"temperature": 0.7}'
) 
FROM sysibm.sysdummy1;

-- JSON generation with options
SELECT dbsdk_v1.openai_compatible_generate_json(
  'List the top 5 programming languages as a JSON array.',
  '{"temperature": 0.5, "max_tokens": 100}'
) 
FROM sysibm.sysdummy1;

-- Clean up after the test
SET dbsdk_v1.openai_compatible_server = NULL;
SET dbsdk_v1.openai_compatible_port = NULL;
SET dbsdk_v1.openai_compatible_protocol = NULL;
SET dbsdk_v1.openai_compatible_basepath = NULL;
SET dbsdk_v1.openai_compatible_model = NULL;