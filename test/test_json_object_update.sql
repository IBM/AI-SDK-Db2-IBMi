-- ## Test Script for json_object_update Function
-- This test script verifies the json_object_update function works as expected

-- Test 1: Basic Merging
SELECT watsonx.json_object_update(
  '{"name": "John", "age": 30}',
  '{"city": "New York", "country": "USA"}'
) AS result1 FROM sysibm.sysdummy1;
-- Expected result: {"name": "John", "age": 30, "city": "New York", "country": "USA"}

-- Test 2: Overwriting Properties
SELECT watsonx.json_object_update(
  '{"name": "John", "age": 30}',
  '{"age": 31, "occupation": "Developer"}'
) AS result2 FROM sysibm.sysdummy1;
-- Expected result: {"name": "John", "age": 31, "occupation": "Developer"}

-- Test 3: Empty Base Object
SELECT watsonx.json_object_update(
  '{}',
  '{"name": "John", "age": 30}'
) AS result3 FROM sysibm.sysdummy1;
-- Expected result: {"name": "John", "age": 30}

-- Test 4: Empty Update Object
SELECT watsonx.json_object_update(
  '{"name": "John", "age": 30}',
  '{}'
) AS result4 FROM sysibm.sysdummy1;
-- Expected result: {"name": "John", "age": 30}

-- Test 5: Null Base Object
SELECT watsonx.json_object_update(
  NULL,
  '{"name": "John", "age": 30}'
) AS result5 FROM sysibm.sysdummy1;
-- Expected result: {"name": "John", "age": 30}

-- Test 6: Null Update Object
SELECT watsonx.json_object_update(
  '{"name": "John", "age": 30}',
  NULL
) AS result6 FROM sysibm.sysdummy1;
-- Expected result: {"name": "John", "age": 30}

-- Test 7: Both Objects Null
SELECT watsonx.json_object_update(
  NULL,
  NULL
) AS result7 FROM sysibm.sysdummy1;
-- Expected result: {}

-- Test 8: Nested Objects
SELECT watsonx.json_object_update(
  '{"person": {"name": "John", "age": 30}}',
  '{"address": {"city": "New York", "country": "USA"}}'
) AS result8 FROM sysibm.sysdummy1;
-- Expected result: {"person": {"name": "John", "age": 30}, "address": {"city": "New York", "country": "USA"}}

-- Test 9: JSON with Arrays
SELECT watsonx.json_object_update(
  '{"numbers": [1, 2, 3]}',
  '{"letters": ["a", "b", "c"]}'
) AS result9 FROM sysibm.sysdummy1;
-- Expected result: {"numbers": [1, 2, 3], "letters": ["a", "b", "c"]}

-- Test 10: Whitespace Handling
SELECT watsonx.json_object_update(
  '  {  "name"  :  "John"  }  ',
  '  {  "age"  :  30  }  '
) AS result10 FROM sysibm.sysdummy1;
-- Expected result: {"name": "John", "age": 30}

-- Test 11: Basic Merging json_object (inline)
SELECT watsonx.json_object_update(
  '{"name": "John", "age": 30}',
  JSON_OBJECT('occupation': 'Dev')
) AS result11
FROM sysibm.sysdummy1;

-- Test 11: Basic Merging json_object (inline)
SELECT watsonx.json_object_update(
  JSON_OBJECT('occupation': 'Dev'),
  '{"name": "John", "age": 30}'
) AS result11
FROM sysibm.sysdummy1;

-- Test JSON boolean handling
SELECT JSON_OBJECT(
  'string_true': 'true',
  'boolean_true': CAST('true' AS Boolean),
  'string_false': 'false',
  'boolean_false': CAST('false' AS boolean)
) AS json_test
FROM sysibm.sysdummy1;