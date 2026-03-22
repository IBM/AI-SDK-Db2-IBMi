**FREE
//==============================================================================
// DBSDK Configuration Administration - Slack Configuration Program
//==============================================================================
// Purpose: Slack configuration screen for editing user settings
//
// Compilation:
//   CRTBNDRPG PGM(DBSDK_V1/CFGSLACK) +
//             SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGSLACK.rpgle') +
//             DFTACTGRP(*NO) +
//             ACTGRP(*NEW) +
//             DBGVIEW(*SOURCE) +
//             OPTION(*EVENTF) +
//             USRPRF(*OWNER)
//
// Author: AI-SDK-Db2-IBMi Project
// Date: 2026-03-22
//==============================================================================

Ctl-Opt DftActGrp(*No) ActGrp(*New) Option(*SrcStmt:*NoDebugIO);

// Display file
Dcl-F CFGSLACKD WorkStn IndDs(Indicators);

// Indicator data structure
Dcl-Ds Indicators;
  Exit Ind Pos(3);
  Cancel Ind Pos(12);
End-Ds;

// Screen fields
Dcl-Ds SlConfig ExtName('SLCONFIG':*All) Qualified End-Ds;

// Program variables
Dcl-S FirstTime Ind Inz(*On);
Dcl-S FullWebhook Varchar(1000);

//==============================================================================
// Main Processing
//==============================================================================

Dow Not Exit;
  // Get user profile on first time
  If FirstTime;
    GetUserProfile();
    FirstTime = *Off;
  EndIf;
  
  // Load current configuration
  LoadConfiguration();
  
  // Display screen
  Exfmt SlConfig;
  
  // Check for exit or cancel
  If Exit Or Cancel;
    Leave;
  EndIf;
  
  // Save configuration
  SaveConfiguration();
EndDo;

*InLR = *On;
Return;

//==============================================================================
// Get User Profile to Configure
//==============================================================================
Dcl-Proc GetUserProfile;
  SlConfig.UsrPrf = *Blanks;
  SlConfig.ErrMsg = 'Enter user profile to configure';
  
  Dow SlConfig.UsrPrf = *Blanks;
    Exfmt SlConfig;
    
    If Exit Or Cancel;
      Leave;
    EndIf;
    
    If SlConfig.UsrPrf <> *Blanks;
      // Verify user exists in configuration table
      Exec SQL
        SELECT USRPRF
        INTO :SlConfig.UsrPrf
        FROM DBSDK_V1.CONF
        WHERE USRPRF = :SlConfig.UsrPrf;
      
      If SQLCODE <> 0;
        SlConfig.ErrMsg = 'User not found. Add user first.';
        SlConfig.UsrPrf = *Blanks;
      Else;
        SlConfig.ErrMsg = *Blanks;
      EndIf;
    EndIf;
  EndDo;
End-Proc;

//==============================================================================
// Load Current Configuration
//==============================================================================
Dcl-Proc LoadConfiguration;
  // Clear messages
  SlConfig.ErrMsg = *Blanks;
  SlConfig.StsMsg = *Blanks;
  
  // Load configuration from database
  Exec SQL
    SELECT slack_webhook
    INTO :FullWebhook
    FROM DBSDK_V1.CONF
    WHERE USRPRF = :SlConfig.UsrPrf;
  
  If SQLCODE = 0;
    // Split webhook into two 50-char fields
    SlConfig.SlWebHok = %Subst(FullWebhook:1:50);
    If %Len(FullWebhook) > 50;
      SlConfig.SlWebHk2 = %Subst(FullWebhook:51:50);
    Else;
      SlConfig.SlWebHk2 = *Blanks;
    EndIf;
  Else;
    SlConfig.ErrMsg = 'Error loading configuration: ' + %Char(SQLCODE);
  EndIf;
End-Proc;

//==============================================================================
// Save Configuration
//==============================================================================
Dcl-Proc SaveConfiguration;
  // Combine split fields
  FullWebhook = %Trim(SlConfig.SlWebHok) + %Trim(SlConfig.SlWebHk2);
  
  // Call SQL procedure to update configuration
  Exec SQL
    CALL DBSDK_V1.CONF_UPDATE_SLACK(
      :SlConfig.UsrPrf,
      :FullWebhook
    );
  
  If SQLCODE = 0;
    SlConfig.StsMsg = 'Configuration saved successfully';
  Else;
    SlConfig.ErrMsg = 'Error saving configuration: ' + %Char(SQLCODE);
  EndIf;
End-Proc;