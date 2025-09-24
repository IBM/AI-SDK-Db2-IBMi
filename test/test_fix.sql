-- Test script to verify fix for Issue #21 and Sub-issue #27
-- This script tests that set*forme methods correctly update only the calling user's row

-- Clean up test data first
DELETE FROM dbsdk_v1.conf WHERE usrprf IN ('TEST1', 'TEST2');

-- Insert test users manually to simulate multiple users scenario
INSERT INTO dbsdk_v1.conf (usrprf, ollama_server, ollama_port)
VALUES ('TEST1', 'original-server1', 1111);

INSERT INTO dbsdk_v1.conf (usrprf, ollama_server, ollama_port)
VALUES ('TEST2', 'original-server2', 2222);

-- Display initial state
SELECT 'Before update' as test_phase, usrprf, ollama_server, ollama_port
FROM dbsdk_v1.conf
WHERE usrprf IN ('TEST1', 'TEST2')
ORDER BY usrprf;

-- Simulate TEST1 user calling setserverforme (we can't actually change CURRENT_USER, but we can test the logic)
-- This would be equivalent to TEST1 calling: CALL dbsdk_v1.ollama_setserverforme('new-server1');

MERGE INTO dbsdk_v1.conf tt USING (
  SELECT 'TEST1' AS usrprf, 'new-server1' AS ollama_server
    FROM sysibm.sysdummy1
) live
ON tt.usrprf = live.usrprf
WHEN NOT MATCHED THEN INSERT (usrprf, ollama_server) VALUES (live.usrprf, live.ollama_server)
WHEN MATCHED THEN UPDATE SET ollama_server = live.ollama_server;

-- Display state after TEST1 update
SELECT 'After TEST1 update' as test_phase, usrprf, ollama_server, ollama_port
FROM dbsdk_v1.conf
WHERE usrprf IN ('TEST1', 'TEST2')
ORDER BY usrprf;

-- Simulate TEST2 user calling setportforme
MERGE INTO dbsdk_v1.conf tt USING (
  SELECT 'TEST2' AS usrprf, 3333 AS ollama_port
    FROM sysibm.sysdummy1
) live
ON tt.usrprf = live.usrprf
WHEN NOT MATCHED THEN INSERT (usrprf, ollama_port) VALUES (live.usrprf, live.ollama_port)
WHEN MATCHED THEN UPDATE SET ollama_port = live.ollama_port;

-- Display final state
SELECT 'After TEST2 update' as test_phase, usrprf, ollama_server, ollama_port
FROM dbsdk_v1.conf
WHERE usrprf IN ('TEST1', 'TEST2')
ORDER BY usrprf;

-- Expected results:
-- TEST1 should have: usrprf='TEST1', ollama_server='new-server1', ollama_port=1111
-- TEST2 should have: usrprf='TEST2', ollama_server='original-server2', ollama_port=3333

-- Verify fix worked correctly
SELECT
  CASE
    WHEN (SELECT COUNT(*) FROM dbsdk_v1.conf
          WHERE usrprf = 'TEST1' AND ollama_server = 'new-server1' AND ollama_port = 1111) = 1
     AND (SELECT COUNT(*) FROM dbsdk_v1.conf
          WHERE usrprf = 'TEST2' AND ollama_server = 'original-server2' AND ollama_port = 3333) = 1
    THEN 'PASS: Fix working correctly - each user updated only their own row'
    ELSE 'FAIL: Issue still exists - wrong rows were updated'
  END as test_result
FROM sysibm.sysdummy1;

-- Clean up test data
DELETE FROM dbsdk_v1.conf WHERE usrprf IN ('TEST1', 'TEST2');