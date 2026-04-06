-- ============================================================================
-- DBSDK Configuration Administration - CONF_LIST_USERS Procedure
-- ============================================================================
-- Purpose: List all users in the DBSDK_V1.CONF configuration table.
--          Returns a result set containing all user profiles that have
--          configuration entries.
--
-- Compilation:
--   RUNSQLSTM SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/sql/conf_list_users.sql') +
--             COMMIT(*NONE) +
--             ERRLVL(21)
--
-- Author: AI-SDK-Db2-IBMi Project
-- Date: 2026-03-22
-- ============================================================================

-- ============================================================================
-- Procedure: CONF_LIST_USERS
-- Purpose: List all users in the configuration table
-- Returns: Result set with user profiles
-- ============================================================================
CREATE OR REPLACE PROCEDURE DBSDK_V1.CONF_LIST_USERS()
LANGUAGE SQL
SPECIFIC CONF_LIST_USERS
NOT DETERMINISTIC
READS SQL DATA
CALLED ON NULL INPUT
DYNAMIC RESULT SETS 1
SET OPTION USRPRF = *OWNER, DYNUSRPRF = *OWNER, COMMIT = *NONE
BEGIN
    DECLARE LIST_USER_CSR CURSOR WITH RETURN FOR
        SELECT USRPRF
        FROM DBSDK_V1.CONF
        ORDER BY USRPRF;
    
    OPEN LIST_USER_CSR;
END;

-- Made with Bob