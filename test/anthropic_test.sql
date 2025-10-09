-- Test file for Anthropic integration

-- Set up the connection parameters
CALL dbsdk_v1.anthropic_setserverforjob('api.anthropic.com');
CALL dbsdk_v1.anthropic_setportforjob(443);
CALL dbsdk_v1.anthropic_setprotocolforjob('https');
CALL dbsdk_v1.anthropic_setmodelforjob('claude-3-haiku-20240307');

-- Replace with your actual API key
CALL dbsdk_v1.anthropic_setapikeyforjob('your-anthropic-api-key');

-- Basic test: Generate a simple response
SELECT 'Basic test' as test_name, 
       dbsdk_v1.anthropic_generate(
         'What is IBM i in one sentence?',
         '{"max_tokens": 100, "temperature": 0.7}'
       ) as result
FROM sysibm.sysdummy1;

-- Test with system prompt
SELECT 'System prompt test' as test_name,
       dbsdk_v1.anthropic_generate(
         'Write a haiku about programming',
         '{
           "max_tokens": 100,
           "temperature": 0.7,
           "system": "You are a poet who specializes in haiku."
         }'
       ) as result
FROM sysibm.sysdummy1;

-- Test JSON response
SELECT 'JSON response test' as test_name,
       dbsdk_v1.anthropic_generate_json(
         'Create a JSON with 3 fictional product names and prices',
         '{
           "max_tokens": 200,
           "temperature": 0.5,
           "system": "You are a helpful assistant that always returns valid JSON."
         }'
       ) as result
FROM sysibm.sysdummy1;

-- Note: To run this test, replace 'your-anthropic-api-key' with a valid Anthropic API key

-- Made with Bob
