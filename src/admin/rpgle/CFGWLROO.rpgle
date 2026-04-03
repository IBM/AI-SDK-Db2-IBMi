**FREE
//==============================================================================
// DBSDK Configuration Administration - Wallaroo Configuration Program
//==============================================================================
// Purpose: Wallaroo configuration screen for editing user settings
//
// Compilation:
//   CRTBNDRPG PGM(DBSDK_V1/CFGWLROO) +
//             SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGWLROO.rpgle') +
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
Dcl-F CFGWLROOD WorkStn IndDs(Indicators);

// Indicator data structure
Dcl-Ds Indicators;
  Exit Ind Pos(3);
  Cancel Ind Pos(12);
End-Ds;

// Screen fields

// Program variables
Dcl-S FirstTime Ind Inz(*On);
Dcl-S FullTokenUrl Varchar(1000);
Dcl-S FullClient Varchar(1000);
Dcl-S FullSecret Varchar(8000);

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
  Exfmt WLCONFIG;
  
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
  UsrPrf = *Blanks;
  ErrMsg = 'Enter user profile to configure';
  
  Dow UsrPrf = *Blanks;
    Exfmt WLCONFIG;
    
    If Exit Or Cancel;
      Leave;
    EndIf;
    
    If UsrPrf <> *Blanks;
      // Verify user exists in configuration table
      Exec SQL
        SELECT USRPRF
        INTO :UsrPrf
        FROM DBSDK_V1.CONF
        WHERE USRPRF = :UsrPrf;
      
      If SQLCODE <> 0;
        ErrMsg = 'User not found. Add user first.';
        UsrPrf = *Blanks;
      Else;
        ErrMsg = *Blanks;
      EndIf;
    EndIf;
  EndDo;
End-Proc;

//==============================================================================
// Load Current Configuration
//==============================================================================
Dcl-Proc LoadConfiguration;
  // Clear messages
  ErrMsg = *Blanks;
  StsMsg = *Blanks;
  
  // Load configuration from database
  Exec SQL
    SELECT wallaroo_tokenurl,
           wallaroo_confidential_client,
           wallaroo_confidential_client_secret
    INTO :FullTokenUrl,
         :FullClient,
         :FullSecret
    FROM DBSDK_V1.CONF
    WHERE USRPRF = :UsrPrf;
  
  If SQLCODE = 0;
    // Split token URL into two 50-char fields
    WlTknUrl = %Subst(FullTokenUrl:1:50);
    If %Len(FullTokenUrl) > 50;
      WlTkUrl2 = %Subst(FullTokenUrl:51:50);
    Else;
      WlTkUrl2 = *Blanks;
    EndIf;
    
    // Split client into two 50-char fields
    WlClient = %Subst(FullClient:1:50);
    If %Len(FullClient) > 50;
      WlClint2 = %Subst(FullClient:51:50);
    Else;
      WlClint2 = *Blanks;
    EndIf;
    
    // Split secret into two 50-char fields
    WlSecret = %Subst(FullSecret:1:50);
    If %Len(FullSecret) > 50;
      WlSecr2 = %Subst(FullSecret:51:50);
    Else;
      WlSecr2 = *Blanks;
    EndIf;
  Else;
    ErrMsg = 'Error loading configuration: ' + %Char(SQLCODE);
  EndIf;
End-Proc;

//==============================================================================
// Save Configuration
//==============================================================================
Dcl-Proc SaveConfiguration;
  // Combine split fields
  FullTokenUrl = %Trim(WlTknUrl) + %Trim(WlTkUrl2);
  FullClient = %Trim(WlClient) + %Trim(WlClint2);
  FullSecret = %Trim(WlSecret) + %Trim(WlSecr2);
  
  // Call SQL procedure to update configuration
  Exec SQL
    CALL DBSDK_V1.CONF_UPDATE_WALLAROO(
      :UsrPrf,
      :FullTokenUrl,
      :FullClient,
      :FullSecret
    );
  
  If SQLCODE = 0;
    StsMsg = 'Configuration saved successfully';
  Else;
    ErrMsg = 'Error saving configuration: ' + %Char(SQLCODE);
  EndIf;
End-Proc;