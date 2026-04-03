**FREE
//==============================================================================
// DBSDK Configuration Administration - OpenAI Compatible Configuration Program
//==============================================================================
// Purpose: OpenAI Compatible configuration screen for editing user settings
//
// Compilation:
//   CRTBNDRPG PGM(DBSDK_V1/CFGOPENAI) +
//             SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGOPENAI.rpgle') +
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
Dcl-F CFGOPENAID WorkStn IndDs(Indicators);

// Indicator data structure
Dcl-Ds Indicators;
  Exit Ind Pos(3);
  Cancel Ind Pos(12);
End-Ds;

// Screen fields

// Program variables
Dcl-S FirstTime Ind Inz(*On);
Dcl-S FullApiKey Varchar(8000);
Dcl-S FullBasePath Varchar(1000);

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
  Exfmt OACONFG;
  
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
    Exfmt OACONFG;
    
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
    SELECT openai_compatible_protocol,
           openai_compatible_server,
           openai_compatible_port,
           openai_compatible_model,
           openai_compatible_apikey,
           openai_compatible_basepath
    INTO :OaProtoc,
         :OaServer,
         :OaPort,
         :OaModel,
         :FullApiKey,
         :FullBasePath
    FROM DBSDK_V1.CONF
    WHERE USRPRF = :UsrPrf;
  
  If SQLCODE = 0;
    // Split API key into two 50-char fields
    OaApiKey = %Subst(FullApiKey:1:50);
    If %Len(FullApiKey) > 50;
      OaApiKy2 = %Subst(FullApiKey:51:50);
    Else;
      OaApiKy2 = *Blanks;
    EndIf;
    
    // Base path fits in one field
    OaBasePt = FullBasePath;
  Else;
    ErrMsg = 'Error loading configuration: ' + %Char(SQLCODE);
  EndIf;
End-Proc;

//==============================================================================
// Save Configuration
//==============================================================================
Dcl-Proc SaveConfiguration;
  // Combine split API key fields
  FullApiKey = %Trim(OaApiKey) + %Trim(OaApiKy2);
  FullBasePath = OaBasePt;
  
  // Call SQL procedure to update configuration
  Exec SQL
    CALL DBSDK_V1.CONF_UPDATE_OPENAI(
      :UsrPrf,
      :OaProtoc,
      :OaServer,
      :OaPort,
      :OaModel,
      :FullApiKey,
      :FullBasePath
    );
  
  If SQLCODE = 0;
    StsMsg = 'Configuration saved successfully';
  Else;
    ErrMsg = 'Error saving configuration: ' + %Char(SQLCODE);
  EndIf;
End-Proc;