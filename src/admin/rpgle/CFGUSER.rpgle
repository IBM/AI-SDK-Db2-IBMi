**FREE
//==============================================================================
// DBSDK Configuration Administration - User Management Program
//==============================================================================
// Purpose: User management program with add, change, delete, and display
//          Simple list display (no subfile)
//
// Compilation:
//   CRTSQLRPGI PGM(DBSDK_V1/CFGUSER) +
//             SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGUSER.rpgle') +
//             COMMIT(*NONE) +
//             DBGVIEW(*SOURCE) +
//             COMPILEOPT('DFTACTGRP(*NO) ACTGRP(*NEW) TGTCCSID(*JOB)') +
//             USRPRF(*OWNER) +
//             CVTCCSID(*JOB)
//
// Author: AI-SDK-Db2-IBMi Project
// Date: 2026-03-22
//==============================================================================

Ctl-Opt DftActGrp(*No) ActGrp(*New) Option(*SrcStmt:*NoDebugIO);

// Display file
Dcl-F CFGUSERD WorkStn IndDs(Indicators);

// Indicator data structure
Dcl-Ds Indicators;
  Exit Ind Pos(3);
  Cancel Ind Pos(12);
End-Ds;

// Screen record
Dcl-Ds UserMain ExtName('USERMAIN':*All) Qualified End-Ds;

// SQL communication area
Dcl-Ds SQLCA Qualified;
  SQLCODE Int(10);
  SQLSTATE Char(5);
End-Ds;

//==============================================================================
// Main Processing
//==============================================================================

Dow Not Exit;
  
  // Clear screen fields
  Clear UserMain;
  
  // Display screen and get user input
  Write UserMain;
  Read UserMain;
  
  If Exit;
    Leave;
  EndIf;
  
  // Process action
  Select;
    When UserMain.Action = '1' // Add user
      ;
      AddUser();
    When UserMain.Action = '2' // Change user
      ;
      ChangeUser();
    When UserMain.Action = '4' // Delete user
      ;
      DeleteUser();
    When UserMain.Action = '5' // Display user
      ;
      DisplayUser();
    When UserMain.Action = '9' // List users
      ;
      ListUsers();
  EndSl;
  
EndDo;

*InLR = *On;
Return;

//==============================================================================
// Add User
//==============================================================================
Dcl-Proc AddUser;
  
  If UserMain.UsrPrfI = *Blanks;
    UserMain.ErrMsg = 'User profile required';
    Return;
  EndIf;
  
  Exec SQL
    INSERT INTO CONF (USRPRF) VALUES (:UserMain.UsrPrfI);
  
  If SQLCA.SQLCODE = 0;
    UserMain.StsMsg = 'User added successfully';
    Clear UserMain.ErrMsg;
  Else;
    UserMain.ErrMsg = 'Error adding user: ' + %Char(SQLCA.SQLCODE);
    Clear UserMain.StsMsg;
  EndIf;
  
End-Proc;

//==============================================================================
// Change User (placeholder - no additional fields to change)
//==============================================================================
Dcl-Proc ChangeUser;
  
  UserMain.StsMsg = 'Change not implemented - users have no additional fields';
  Clear UserMain.ErrMsg;
  
End-Proc;

//==============================================================================
// Delete User
//==============================================================================
Dcl-Proc DeleteUser;
  
  If UserMain.UsrPrfI = *Blanks;
    UserMain.ErrMsg = 'User profile required';
    Return;
  EndIf;
  
  Exec SQL
    DELETE FROM CONF WHERE USRPRF = :UserMain.UsrPrfI;
  
  If SQLCA.SQLCODE = 0;
    UserMain.StsMsg = 'User deleted successfully';
    Clear UserMain.ErrMsg;
  Else;
    UserMain.ErrMsg = 'Error deleting user: ' + %Char(SQLCA.SQLCODE);
    Clear UserMain.StsMsg;
  EndIf;
  
End-Proc;

//==============================================================================
// Display User
//==============================================================================
Dcl-Proc DisplayUser;
  
  Dcl-S FoundUser Char(10);
  
  If UserMain.UsrPrfI = *Blanks;
    UserMain.ErrMsg = 'User profile required';
    Return;
  EndIf;
  
  Exec SQL
    SELECT USRPRF INTO :FoundUser
    FROM CONF
    WHERE USRPRF = :UserMain.UsrPrfI;
  
  If SQLCA.SQLCODE = 0;
    UserMain.StsMsg = 'User found: ' + %Trim(FoundUser);
    Clear UserMain.ErrMsg;
  Else;
    UserMain.ErrMsg = 'User not found';
    Clear UserMain.StsMsg;
  EndIf;
  
End-Proc;

//==============================================================================
// List Users
//==============================================================================
Dcl-Proc ListUsers;
  
  Dcl-S i Int(10);
  Dcl-S UsrPrf Char(10);
  
  // Clear user list fields
  UserMain.User01 = *Blanks;
  UserMain.User02 = *Blanks;
  UserMain.User03 = *Blanks;
  UserMain.User04 = *Blanks;
  UserMain.User05 = *Blanks;
  UserMain.User06 = *Blanks;
  UserMain.User07 = *Blanks;
  UserMain.User08 = *Blanks;
  UserMain.User09 = *Blanks;
  UserMain.User10 = *Blanks;
  
  i = 0;
  
  Exec SQL
    DECLARE C2 CURSOR FOR
      SELECT USRPRF FROM CONF ORDER BY USRPRF;
  
  Exec SQL OPEN C2;
  
  Exec SQL FETCH C2 INTO :UsrPrf;
  
  Dow SQLCA.SQLCODE = 0 And i < 10;
    i += 1;
    Select;
      When i = 1
        ;
        UserMain.User01 = UsrPrf;
      When i = 2
        ;
        UserMain.User02 = UsrPrf;
      When i = 3
        ;
        UserMain.User03 = UsrPrf;
      When i = 4
        ;
        UserMain.User04 = UsrPrf;
      When i = 5
        ;
        UserMain.User05 = UsrPrf;
      When i = 6
        ;
        UserMain.User06 = UsrPrf;
      When i = 7
        ;
        UserMain.User07 = UsrPrf;
      When i = 8
        ;
        UserMain.User08 = UsrPrf;
      When i = 9
        ;
        UserMain.User09 = UsrPrf;
      When i = 10
        ;
        UserMain.User10 = UsrPrf;
    EndSl;
    Exec SQL FETCH C2 INTO :UsrPrf;
  EndDo;
  
  Exec SQL CLOSE C2;
  
  If i = 0;
    UserMain.StsMsg = 'No users found';
  Else;
    UserMain.StsMsg = %Char(i) + ' user(s) listed';
  EndIf;
  
  Clear UserMain.ErrMsg;
  
End-Proc;