**FREE
//==============================================================================
// DBSDK Configuration Administration - Ollama Configuration Program
//==============================================================================
// Purpose: Ollama configuration screen for editing user settings
//
// Compilation:
//   CRTBNDRPG PGM(DBSDK_V1/CFGOLLAMA) +
//             SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGOLLAMA.rpgle') +
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
Dcl-F CFGOLLAMD WorkStn IndDs(Indicators);

// Indicator data structure
Dcl-Ds Indicators;
  Exit Ind Pos(3);
  Cancel Ind Pos(12);
End-Ds;

// Screen fields
Dcl-Ds OlConfig ExtName('OLCONFIG':*All) Qualified End-Ds;

// Program variables
Dcl-S FirstTime Ind Inz(*On);
Dcl-S FullServer Varchar(1000);
Dcl-S FullModel Varchar(1000);

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
  Exfmt OlConfig;
  
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
  OlConfig.UsrPrf = *Blanks;
  OlConfig.ErrMsg = 'Enter user profile to configure';
  
  Dow OlConfig.UsrPrf = *Blanks;
    Exfmt OlConfig;
    
    If Exit Or Cancel;
      Leave;
    EndIf;
    
    If OlConfig.UsrPrf <> *Blanks;
      // Verify user exists in configuration table
      Exec SQL
        SELECT USRPRF
        INTO :OlConfig.UsrPrf
        FROM DBSDK_V1.CONF
        WHERE USRPRF = :OlConfig.UsrPrf;
      
      If SQLCODE <> 0;
        OlConfig.ErrMsg = 'User not found. Add user first.';
        OlConfig.UsrPrf = *Blanks;
      Else;
        OlConfig.ErrMsg = *Blanks;
      EndIf;
    EndIf;
  EndDo;
End-Proc;

//==============================================================================
// Load Current Configuration
//==============================================================================
Dcl-Proc LoadConfiguration;
  // Clear messages
  OlConfig.ErrMsg = *Blanks;
  OlConfig.StsMsg = *Blanks;
  
  // Load configuration from database
  Exec SQL
    SELECT ollama_protocol,
           ollama_server,
           ollama_port,
           ollama_model
    INTO :OlConfig.OlProtoc,
         :FullServer,
         :OlConfig.OlPort,
         :FullModel
    FROM DBSDK_V1.CONF
    WHERE USRPRF = :OlConfig.UsrPrf;
  
  If SQLCODE = 0;
    // Split server into two 50-char fields
    OlConfig.OlServer = %Subst(FullServer:1:50);
    If %Len(FullServer) > 50;
      OlConfig.OlSrvr2 = %Subst(FullServer:51);
    Else;
      OlConfig.OlSrvr2 = *Blanks;
    EndIf;
    
    // Split model into two 50-char fields
    OlConfig.OlModel = %Subst(FullModel:1:50);
    If %Len(FullModel) > 50;
      OlConfig.OlModl2 = %Subst(FullModel:51);
    Else;
      OlConfig.OlModl2 = *Blanks;
    EndIf;
  Else;
    OlConfig.ErrMsg = 'Error loading configuration: ' + %Char(SQLCODE);
  EndIf;
End-Proc;

//==============================================================================
// Save Configuration
//==============================================================================
Dcl-Proc SaveConfiguration;
  // Combine split fields
  FullServer = %Trim(OlConfig.OlServer) + %Trim(OlConfig.OlSrvr2);
  FullModel = %Trim(OlConfig.OlModel) + %Trim(OlConfig.OlModl2);
  
  // Call SQL procedure to update configuration
  Exec SQL
    CALL DBSDK_V1.CONF_UPDATE_OLLAMA(
      :OlConfig.UsrPrf,
      :OlConfig.OlProtoc,
      :FullServer,
      :OlConfig.OlPort,
      :FullModel
    );
  
  If SQLCODE = 0;
    OlConfig.StsMsg = 'Configuration saved successfully';
  Else;
    OlConfig.ErrMsg = 'Error saving configuration: ' + %Char(SQLCODE);
  EndIf;
End-Proc;