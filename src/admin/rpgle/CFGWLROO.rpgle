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
Dcl-S OldUsrPrf Varchar(10) Inz(*Blanks);
Dcl-S FullTokenUrl Varchar(1000);
Dcl-S FullClient Varchar(1000);
Dcl-S FullSecret Varchar(8000);

//==============================================================================
// Main Processing
//==============================================================================

Dow Not Exit;
  // If no user profile, prompt for it
  If UsrPrf = *Blanks;
    ErrMsg = 'Enter user profile to configure';
  EndIf;
  
  // Display screen
  Exfmt WLCONFIG;
  
  // Check for exit or cancel
  If Exit Or Cancel;
    Leave;
  EndIf;
  
  If UsrPrf = *Blanks;
    Iter;
  EndIf;
  
  // Clear error message if we have a user profile
  If ErrMsg = 'Enter user profile to configure';
    ErrMsg = *Blanks;
  EndIf;
  
  // If user profile changed
  If UsrPrf <> OldUsrPrf;
    // Verify user exists in configuration table
    Exec SQL
      SELECT USRPRF
      INTO :UsrPrf
      FROM DBSDK_V1.CONF
      WHERE USRPRF = :UsrPrf;
    
    If SQLCODE <> 0;
      ErrMsg = 'User not found. Add user first.';
      UsrPrf = *Blanks;
      Iter;
    EndIf;
    
    // Check if they entered configuration data along with the new profile
    If WlTknUrl <> *Blanks Or WlClient <> *Blanks Or WlSecret <> *Blanks;
      // They entered data, save it
      SaveConfiguration();
    EndIf;
    
    OldUsrPrf = UsrPrf;
    LoadConfiguration();
  Else;
    // Save configuration
    SaveConfiguration();
    LoadConfiguration();
  EndIf;
EndDo;

*InLR = *On;
Return;

//==============================================================================
// Load Current Configuration
//==============================================================================
Dcl-Proc LoadConfiguration;
  // Clear messages
  ErrMsg = *Blanks;
  StsMsg = *Blanks;
  
  // Load configuration from database
  Exec SQL
    SELECT IFNULL(wallaroo_tokenurl, ''),
           IFNULL(wallaroo_confidential_client, ''),
           IFNULL(wallaroo_confidential_client_secret, '')
    INTO :FullTokenUrl,
         :FullClient,
         :FullSecret
    FROM DBSDK_V1.CONF
    WHERE USRPRF = :UsrPrf;
  
  If SQLCODE = 0;
    // Split token URL into two 50-char fields
    If %Len(FullTokenUrl) > 50;
      WlTknUrl = %Subst(FullTokenUrl:1:50);
      WlTkUrl2 = %Subst(FullTokenUrl:51:50);
    ElseIf %Len(FullTokenUrl) > 0;
      WlTknUrl = FullTokenUrl;
      WlTkUrl2 = *Blanks;
    Else;
      WlTknUrl = *Blanks;
      WlTkUrl2 = *Blanks;
    EndIf;
    
    // Split client into two 50-char fields
    If %Len(FullClient) > 50;
      WlClient = %Subst(FullClient:1:50);
      WlClint2 = %Subst(FullClient:51:50);
    ElseIf %Len(FullClient) > 0;
      WlClient = FullClient;
      WlClint2 = *Blanks;
    Else;
      WlClient = *Blanks;
      WlClint2 = *Blanks;
    EndIf;
    
    // Split secret into two 50-char fields
    If %Len(FullSecret) > 50;
      WlSecret = %Subst(FullSecret:1:50);
      WlSecr2 = %Subst(FullSecret:51:50);
    ElseIf %Len(FullSecret) > 0;
      WlSecret = FullSecret;
      WlSecr2 = *Blanks;
    Else;
      WlSecret = *Blanks;
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