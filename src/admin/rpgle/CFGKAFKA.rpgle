**FREE
//==============================================================================
// DBSDK Configuration Administration - Kafka Configuration Program
//==============================================================================
// Purpose: Kafka configuration screen for editing user settings
//
// Compilation:
//   CRTBNDRPG PGM(DBSDK_V1/CFGKAFKA) +
//             SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGKAFKA.rpgle') +
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
Dcl-F CFGKAFKAD WorkStn IndDs(Indicators);

// Indicator data structure
Dcl-Ds Indicators;
  Exit Ind Pos(3);
  Cancel Ind Pos(12);
End-Ds;

// Screen fields
Dcl-Ds KfConfig ExtName('KFCONFIG':*All) Qualified End-Ds;

// Program variables
Dcl-S FirstTime Ind Inz(*On);
Dcl-S FullBroker Varchar(1000);
Dcl-S FullTopic Varchar(1000);

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
  Exfmt KfConfig;
  
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
  KfConfig.UsrPrf = *Blanks;
  KfConfig.ErrMsg = 'Enter user profile to configure';
  
  Dow KfConfig.UsrPrf = *Blanks;
    Exfmt KfConfig;
    
    If Exit Or Cancel;
      Leave;
    EndIf;
    
    If KfConfig.UsrPrf <> *Blanks;
      // Verify user exists in configuration table
      Exec SQL
        SELECT USRPRF
        INTO :KfConfig.UsrPrf
        FROM DBSDK_V1.CONF
        WHERE USRPRF = :KfConfig.UsrPrf;
      
      If SQLCODE <> 0;
        KfConfig.ErrMsg = 'User not found. Add user first.';
        KfConfig.UsrPrf = *Blanks;
      Else;
        KfConfig.ErrMsg = *Blanks;
      EndIf;
    EndIf;
  EndDo;
End-Proc;

//==============================================================================
// Load Current Configuration
//==============================================================================
Dcl-Proc LoadConfiguration;
  // Clear messages
  KfConfig.ErrMsg = *Blanks;
  KfConfig.StsMsg = *Blanks;
  
  // Load configuration from database
  Exec SQL
    SELECT kafka_protocol,
           kafka_broker,
           kafka_port,
           kafka_topic
    INTO :KfConfig.KfProtoc,
         :FullBroker,
         :KfConfig.KfPort,
         :FullTopic
    FROM DBSDK_V1.CONF
    WHERE USRPRF = :KfConfig.UsrPrf;
  
  If SQLCODE = 0;
    // Split broker into two 50-char fields
    KfConfig.KfBroker = %Subst(FullBroker:1:50);
    If %Len(FullBroker) > 50;
      KfConfig.KfBrokr2 = %Subst(FullBroker:51:50);
    Else;
      KfConfig.KfBrokr2 = *Blanks;
    EndIf;
    
    // Split topic into two 50-char fields
    KfConfig.KfTopic = %Subst(FullTopic:1:50);
    If %Len(FullTopic) > 50;
      KfConfig.KfTopic2 = %Subst(FullTopic:51:50);
    Else;
      KfConfig.KfTopic2 = *Blanks;
    EndIf;
  Else;
    KfConfig.ErrMsg = 'Error loading configuration: ' + %Char(SQLCODE);
  EndIf;
End-Proc;

//==============================================================================
// Save Configuration
//==============================================================================
Dcl-Proc SaveConfiguration;
  // Combine split fields
  FullBroker = %Trim(KfConfig.KfBroker) + %Trim(KfConfig.KfBrokr2);
  FullTopic = %Trim(KfConfig.KfTopic) + %Trim(KfConfig.KfTopic2);
  
  // Call SQL procedure to update configuration
  Exec SQL
    CALL DBSDK_V1.CONF_UPDATE_KAFKA(
      :KfConfig.UsrPrf,
      :KfConfig.KfProtoc,
      :FullBroker,
      :KfConfig.KfPort,
      :FullTopic
    );
  
  If SQLCODE = 0;
    KfConfig.StsMsg = 'Configuration saved successfully';
  Else;
    KfConfig.ErrMsg = 'Error saving configuration: ' + %Char(SQLCODE);
  EndIf;
End-Proc;