**FREE
//==============================================================================
// DBSDK Configuration Administration - Twilio Configuration Program
//==============================================================================
// Purpose: Twilio configuration screen for editing user settings
//
// Compilation:
//   CRTBNDRPG PGM(DBSDK_V1/CFGTWILIO) +
//             SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGTWILIO.rpgle') +
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
Dcl-F CFGTWILIOD WorkStn IndDs(Indicators);

// Indicator data structure
Dcl-Ds Indicators;
  Exit Ind Pos(3);
  Cancel Ind Pos(12);
End-Ds;

// Screen fields
Dcl-Ds TwConfig ExtName('TWCONFIG':*All) Qualified End-Ds;

// Program variables
Dcl-S FirstTime Ind Inz(*On);
Dcl-S FullNumber Varchar(1000);
Dcl-S FullSid Varchar(1000);
Dcl-S FullAuthToken Varchar(1000);

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
  Exfmt TwConfig;
  
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
  TwConfig.UsrPrf = *Blanks;
  TwConfig.ErrMsg = 'Enter user profile to configure';
  
  Dow TwConfig.UsrPrf = *Blanks;
    Exfmt TwConfig;
    
    If Exit Or Cancel;
      Leave;
    EndIf;
    
    If TwConfig.UsrPrf <> *Blanks;
      // Verify user exists in configuration table
      Exec SQL
        SELECT USRPRF
        INTO :TwConfig.UsrPrf
        FROM DBSDK_V1.CONF
        WHERE USRPRF = :TwConfig.UsrPrf;
      
      If SQLCODE <> 0;
        TwConfig.ErrMsg = 'User not found. Add user first.';
        TwConfig.UsrPrf = *Blanks;
      Else;
        TwConfig.ErrMsg = *Blanks;
      EndIf;
    EndIf;
  EndDo;
End-Proc;

//==============================================================================
// Load Current Configuration
//==============================================================================
Dcl-Proc LoadConfiguration;
  // Clear messages
  TwConfig.ErrMsg = *Blanks;
  TwConfig.StsMsg = *Blanks;
  
  // Load configuration from database
  Exec SQL
    SELECT twilio_number,
           twilio_sid,
           twilio_authtoken
    INTO :FullNumber,
         :FullSid,
         :FullAuthToken
    FROM DBSDK_V1.CONF
    WHERE USRPRF = :TwConfig.UsrPrf;
  
  If SQLCODE = 0;
    // Split number into two 50-char fields
    TwConfig.TwNumber = %Subst(FullNumber:1:50);
    If %Len(FullNumber) > 50;
      TwConfig.TwNumbr2 = %Subst(FullNumber:51:50);
    Else;
      TwConfig.TwNumbr2 = *Blanks;
    EndIf;
    
    // Split SID into two 50-char fields
    TwConfig.TwSid = %Subst(FullSid:1:50);
    If %Len(FullSid) > 50;
      TwConfig.TwSid2 = %Subst(FullSid:51:50);
    Else;
      TwConfig.TwSid2 = *Blanks;
    EndIf;
    
    // Split auth token into two 50-char fields
    TwConfig.TwAuthTn = %Subst(FullAuthToken:1:50);
    If %Len(FullAuthToken) > 50;
      TwConfig.TwAuthK2 = %Subst(FullAuthToken:51:50);
    Else;
      TwConfig.TwAuthK2 = *Blanks;
    EndIf;
  Else;
    TwConfig.ErrMsg = 'Error loading configuration: ' + %Char(SQLCODE);
  EndIf;
End-Proc;

//==============================================================================
// Save Configuration
//==============================================================================
Dcl-Proc SaveConfiguration;
  // Combine split fields
  FullNumber = %Trim(TwConfig.TwNumber) + %Trim(TwConfig.TwNumbr2);
  FullSid = %Trim(TwConfig.TwSid) + %Trim(TwConfig.TwSid2);
  FullAuthToken = %Trim(TwConfig.TwAuthTn) + %Trim(TwConfig.TwAuthK2);
  
  // Call SQL procedure to update configuration
  Exec SQL
    CALL DBSDK_V1.CONF_UPDATE_TWILIO(
      :TwConfig.UsrPrf,
      :FullNumber,
      :FullSid,
      :FullAuthToken
    );
  
  If SQLCODE = 0;
    TwConfig.StsMsg = 'Configuration saved successfully';
  Else;
    TwConfig.ErrMsg = 'Error saving configuration: ' + %Char(SQLCODE);
  EndIf;
End-Proc;