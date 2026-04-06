-- ============================================================================
-- DBSDK Configuration Administration - CONF_UPDATE_WALLAROO Procedure
-- ============================================================================
-- Purpose: Update Wallaroo AI configuration for a specific user in the
--          DBSDK_V1.CONF table. Modifies token URL, confidential client,
--          and client secret settings.
--
-- Compilation:
--   RUNSQLSTM SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/sql/conf_update_wallaroo.sql') +
--             COMMIT(*NONE) +
--             ERRLVL(21)
--
-- Author: AI-SDK-Db2-IBMi Project
-- Date: 2026-03-22
-- ============================================================================

-- ============================================================================
-- Procedure: CONF_UPDATE_WALLAROO
-- Purpose: Update Wallaroo configuration for a user
-- Parameters:
--   IN p_usrprf VARCHAR(10) - User profile
--   IN p_tokenurl VARCHAR(1000) - Token URL
--   IN p_client VARCHAR(1000) - Confidential client
--   IN p_secret VARCHAR(8000) - Client secret
-- ============================================================================
CREATE OR REPLACE PROCEDURE DBSDK_V1.CONF_UPDATE_WALLAROO(
    IN p_usrprf VARCHAR(10),
    IN p_tokenurl VARCHAR(1000),
    IN p_client VARCHAR(1000),
    IN p_secret VARCHAR(8000)
)
LANGUAGE SQL
SPECIFIC CONF_UPD_WL
NOT DETERMINISTIC
MODIFIES SQL DATA
CALLED ON NULL INPUT
SET OPTION USRPRF = *OWNER, DYNUSRPRF = *OWNER, COMMIT = *NONE
BEGIN
    UPDATE DBSDK_V1.CONF
    SET wallaroo_tokenurl = p_tokenurl,
        wallaroo_confidential_client = p_client,
        wallaroo_confidential_client_secret = p_secret
    WHERE USRPRF = p_usrprf;
END;

-- Made with Bob