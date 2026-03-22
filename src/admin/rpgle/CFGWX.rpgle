**FREE
//==============================================================================
// DBSDK Configuration Administration - WatsonX Configuration Program
//==============================================================================
// Purpose: WatsonX configuration screen for editing user settings
//
// Compilation:
//   CRTBNDRPG PGM(DBSDK_V1/CFGWX) +
//             SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGWX.rpgle') +
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
Dcl-F CFGWXD WorkStn IndDs(Indicators);

// Indicator data structure
Dcl-Ds Indicators;
  Exit Ind Pos(3);
  Cancel Ind Pos(12);
End-Ds;

// Screen fields
Dcl-Ds WxConfig ExtName('WXCONFIG':*All) Qualified End-Ds;

// Program variables
Dcl-S FirstTime Ind Inz(*On);

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
  Exfmt WxConfig;
  
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
  Dcl-S UserList Char(10) Dim(100);
  Dcl-S UserCount Int(10);
  Dcl-S I Int(10);
  
  // For now, prompt for user profile
  // In a full implementation, this would show a selection list
  WxConfig.UsrPrf = *Blanks;
  WxConfig.ErrMsg = 'Enter user profile to configure';
  
  Dow WxConfig.UsrPrf = *Blanks;
    Exfmt WxConfig;
    
    If Exit Or Cancel;
      Leave;
    EndIf;
    
    If WxConfig.UsrPrf <> *Blanks;
      // Verify user exists in configuration table
      Exec SQL
        SELECT USRPRF
        INTO :WxConfig.UsrPrf
        FROM DBSDK_V1.CONF
        WHERE USRPRF = :WxConfig.UsrPrf;
      
      If SQLCODE <> 0;
        WxConfig.ErrMsg = 'User not found. Add user first.';
        WxConfig.UsrPrf = *Blanks;
      Else;
        WxConfig.ErrMsg = *Blanks;
      EndIf;
    EndIf;
  EndDo;
End-Proc;

//==============================================================================
// Load Current Configuration
//==============================================================================
Dcl-Proc LoadConfiguration;
  // Clear messages
  WxConfig.ErrMsg = *Blanks;
  WxConfig.StsMsg = *Blanks;
  
  // Load configuration from database
  Exec SQL
    SELECT watsonx_region,
           watsonx_apiVersion,
           watsonx_apikey,
           watsonx_projectid
    INTO :WxConfig.WxRegion,
         :WxConfig.WxApiVer,
         :WxConfig.WxApiKey,
         :WxConfig.WxProjId
    FROM DBSDK_V1.CONF
    WHERE USRPRF = :WxConfig.UsrPrf;
  
  If SQLCODE <> 0;
    WxConfig.ErrMsg = 'Error loading configuration: ' + %Char(SQLCODE);
  EndIf;
End-Proc;

//==============================================================================
// Save Configuration
//==============================================================================
Dcl-Proc SaveConfiguration;
  // Call SQL procedure to update configuration
  Exec SQL
    CALL DBSDK_V1.CONF_UPDATE_WATSONX(
      :WxConfig.UsrPrf,
      :WxConfig.WxRegion,
      :WxConfig.WxApiVer,
      :WxConfig.WxApiKey,
      :WxConfig.WxProjId
    );
  
  If SQLCODE = 0;
    WxConfig.StsMsg = 'Configuration saved successfully';
  Else;
    WxConfig.ErrMsg = 'Error saving configuration: ' + %Char(SQLCODE);
  EndIf;
End-Proc;