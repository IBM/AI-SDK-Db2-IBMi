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
Dcl-Ds OaConfg ExtName('OACONFG':*All) Qualified End-Ds;

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
  Exfmt OaConfg;
  
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
  OaConfg.UsrPrf = *Blanks;
  OaConfg.ErrMsg = 'Enter user profile to configure';
  
  Dow OaConfg.UsrPrf = *Blanks;
    Exfmt OaConfg;
    
    If Exit Or Cancel;
      Leave;
    EndIf;
    
    If OaConfg.UsrPrf <> *Blanks;
      // Verify user exists in configuration table
      Exec SQL
        SELECT USRPRF
        INTO :OaConfg.UsrPrf
        FROM DBSDK_V1.CONF
        WHERE USRPRF = :OaConfg.UsrPrf;
      
      If SQLCODE <> 0;
        OaConfg.ErrMsg = 'User not found. Add user first.';
        OaConfg.UsrPrf = *Blanks;
      Else;
        OaConfg.ErrMsg = *Blanks;
      EndIf;
    EndIf;
  EndDo;
End-Proc;

//==============================================================================
// Load Current Configuration
//==============================================================================
Dcl-Proc LoadConfiguration;
  // Clear messages
  OaConfg.ErrMsg = *Blanks;
  OaConfg.StsMsg = *Blanks;
  
  // Load configuration from database
  Exec SQL
    SELECT openai_compatible_protocol,
           openai_compatible_server,
           openai_compatible_port,
           openai_compatible_model,
           openai_compatible_apikey,
           openai_compatible_basepath
    INTO :OaConfg.OaProtoc,
         :OaConfg.OaServer,
         :OaConfg.OaPort,
         :OaConfg.OaModel,
         :FullApiKey,
         :FullBasePath
    FROM DBSDK_V1.CONF
    WHERE USRPRF = :OaConfg.UsrPrf;
  
  If SQLCODE = 0;
    // Split API key into two 50-char fields
    OaConfg.OaApiKey = %Subst(FullApiKey:1:50);
    If %Len(FullApiKey) > 50;
      OaConfg.OaApiKy2 = %Subst(FullApiKey:51:50);
    Else;
      OaConfg.OaApiKy2 = *Blanks;
    EndIf;
    
    // Base path fits in one field
    OaConfg.OaBasePt = FullBasePath;
  Else;
    OaConfg.ErrMsg = 'Error loading configuration: ' + %Char(SQLCODE);
  EndIf;
End-Proc;

//==============================================================================
// Save Configuration
//==============================================================================
Dcl-Proc SaveConfiguration;
  // Combine split API key fields
  FullApiKey = %Trim(OaConfg.OaApiKey) + %Trim(OaConfg.OaApiKy2);
  FullBasePath = OaConfg.OaBasePt;
  
  // Call SQL procedure to update configuration
  Exec SQL
    CALL DBSDK_V1.CONF_UPDATE_OPENAI(
      :OaConfg.UsrPrf,
      :OaConfg.OaProtoc,
      :OaConfg.OaServer,
      :OaConfg.OaPort,
      :OaConfg.OaModel,
      :FullApiKey,
      :FullBasePath
    );
  
  If SQLCODE = 0;
    OaConfg.StsMsg = 'Configuration saved successfully';
  Else;
    OaConfg.ErrMsg = 'Error saving configuration: ' + %Char(SQLCODE);
  EndIf;
End-Proc;