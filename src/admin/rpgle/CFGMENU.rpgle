**FREE
//==============================================================================
// DBSDK Configuration Administration - Main Menu Program
//==============================================================================
// Purpose: Main menu controller for DBSDK configuration administration
//          Routes user to appropriate configuration programs
//
// Compilation:
//   CRTBNDRPG PGM(DBSDK_V1/CFGMENU) +
//             SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGMENU.rpgle') +
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
Dcl-F CFGMENUD WorkStn IndDs(Indicators);

// Indicator data structure
Dcl-Ds Indicators;
  Exit Ind Pos(3);
End-Ds;

// Screen fields
Dcl-Ds Menu ExtName('MENU':*All) Qualified End-Ds;

// Program variables
Dcl-S ValidOption Ind;

//==============================================================================
// Main Processing
//==============================================================================

Dow Not Exit;
  // Clear error message
  Menu.ErrMsg = *Blanks;
  
  // Display menu
  Exfmt Menu;
  
  // Check for exit
  If Exit;
    Leave;
  EndIf;
  
  // Validate and process option
  ValidOption = *On;
  
  Select;
    // User Management
    When Menu.Option = '1';
      CallP CFGUSER();
      
    // WatsonX Configuration
    When Menu.Option = '2';
      CallP CFGWX();
      
    // Ollama Configuration
    When Menu.Option = '3';
      CallP CFGOLLAMA();
      
    // OpenAI Compatible Configuration
    When Menu.Option = '4';
      CallP CFGOPENAI();
      
    // Wallaroo Configuration
    When Menu.Option = '5';
      CallP CFGWLROO();
      
    // Kafka Configuration
    When Menu.Option = '6';
      CallP CFGKAFKA();
      
    // Slack Configuration
    When Menu.Option = '7';
      CallP CFGSLACK();
      
    // Twilio Configuration
    When Menu.Option = '8';
      CallP CFGTWILIO();
      
    // Exit
    When Menu.Option = '90';
      Leave;
      
    // Invalid option
    Other;
      ValidOption = *Off;
      Menu.ErrMsg = 'Invalid option. Please select 1-8 or 90.';
  EndSl;
  
  // Clear option field after processing
  If ValidOption;
    Menu.Option = *Blanks;
  EndIf;
EndDo;

*InLR = *On;
Return;

//==============================================================================
// External Program Prototypes
//==============================================================================

// User Management
Dcl-PR CFGUSER ExtPgm('CFGUSER');
End-PR;

// WatsonX Configuration
Dcl-PR CFGWX ExtPgm('CFGWX');
End-PR;

// Ollama Configuration
Dcl-PR CFGOLLAMA ExtPgm('CFGOLLAMA');
End-PR;

// OpenAI Compatible Configuration
Dcl-PR CFGOPENAI ExtPgm('CFGOPENAI');
End-PR;

// Wallaroo Configuration
Dcl-PR CFGWLROO ExtPgm('CFGWLROO');
End-PR;

// Kafka Configuration
Dcl-PR CFGKAFKA ExtPgm('CFGKAFKA');
End-PR;

// Slack Configuration
Dcl-PR CFGSLACK ExtPgm('CFGSLACK');
End-PR;

// Twilio Configuration
Dcl-PR CFGTWILIO ExtPgm('CFGTWILIO');
End-PR;