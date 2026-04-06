# DBSDK Configuration Administration Application

## Overview

This is a 5250 green-screen application for administering the DBSDK_V1 configuration system. It provides a menu-driven interface for managing user configurations across multiple AI and integration services including WatsonX, Ollama, OpenAI Compatible, Wallaroo, Kafka, Slack, and Twilio.

## Features

- **User Management**: Add, modify, delete, and list users in the configuration system
- **Service Configuration**: Configure settings for 7 different AI/integration services
- **Administrator-Only Access**: Secure access with *OWNER authority to bypass RCAC
- **Menu-Driven Interface**: Easy navigation through intuitive 5250 screens
- **Field Validation**: Input validation and error handling
- **Database Integration**: Direct updates to DBSDK_V1.CONF table

## Prerequisites

### System Requirements

- IBM i operating system (V7R3 or later recommended)
- DBSDK_V1 library must exist
- DBSDK_V1.CONF table must be created (run `src/conf.sql` first)
- Authority to create objects in DBSDK_V1 library

### User Requirements

- A user profile named `DBSDK_V1` must exist on the system.
- The administrator running this application must either:
  - Run the application directly as the `DBSDK_V1` user
  - Have the ability to adopt the program owner's authority (if the programs are owned by `DBSDK_V1`)
- This specific user profile (`DBSDK_V1`) is required by the Row and Column Access Control (RCAC) rules to bypass row-level security and manage configurations for all users.
- Administrator must have:
  - Authority to DBSDK_V1 library
  - Authority to read/write DBSDK_V1.CONF table
  - QIBM_DB_SECADM function usage.
  - Note that RCAC won't work at all if LPP option 47 (IBM Advanced Data Security for i) is not installed.

## Installation

### Quick Start

1. **Navigate to the admin directory:**

   ```bash
   cd /home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin
   ```

2. **Build using Make (recommended):**

   ```bash
   make
   ```

   Or with verbose output to see compilation details:

   ```bash
   make VERBOSE=1
   ```

   **Alternative: Use the build script:**

   ```bash
   ./build.sh
   ```

3. **Start the application:**

   ```cl
   CALL PGM(DBSDK_V1/CFGMENU)
   ```

### Build Options

The Makefile provides several build targets:

- `make` or `make all` - Build all components (default)
- `make sql` - Build SQL procedures only
- `make dspf` - Build display files only
- `make rpgle` - Build RPGLE programs only
- `make clean` - Remove all compiled objects
- `make help` - Show available targets and options

**Verbose Mode:**

By default, compilation output is suppressed for cleaner output. To see full compilation details (useful for debugging):

```bash
make VERBOSE=1
make rpgle VERBOSE=1  # Verbose output for RPGLE only
```

### Manual Installation

If you prefer to build components individually, follow these steps (note that I've used my own user profile and own name in the examples, change to match your installation):

#### Step 1: Create SQL Procedures

The SQL procedures have been modularized into separate files for better maintainability:

```bash
# User management procedures
RUNSQLSTM SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/sql/conf_get_user.sql') +
          COMMIT(*NONE) +
          ERRLVL(21)

RUNSQLSTM SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/sql/conf_list_users.sql') +
          COMMIT(*NONE) +
          ERRLVL(21)

# Service configuration procedures
RUNSQLSTM SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/sql/conf_update_watsonx.sql') +
          COMMIT(*NONE) +
          ERRLVL(21)

RUNSQLSTM SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/sql/conf_update_ollama.sql') +
          COMMIT(*NONE) +
          ERRLVL(21)

RUNSQLSTM SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/sql/conf_update_openai.sql') +
          COMMIT(*NONE) +
          ERRLVL(21)

RUNSQLSTM SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/sql/conf_update_wallaroo.sql') +
          COMMIT(*NONE) +
          ERRLVL(21)

RUNSQLSTM SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/sql/conf_update_kafka.sql') +
          COMMIT(*NONE) +
          ERRLVL(21)

RUNSQLSTM SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/sql/conf_update_slack.sql') +
          COMMIT(*NONE) +
          ERRLVL(21)

RUNSQLSTM SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/sql/conf_update_twilio.sql') +
          COMMIT(*NONE) +
          ERRLVL(21)
```

#### Step 2: Compile Display Files

**Note:** Display files use the JWOEHR/QDDSSRC source file. Ensure QDDSSRC exists in library JWOEHR.

If QDDSSRC doesn't exist in JWOEHR, create it:

```bash
CRTSRCPF FILE(JWOEHR/QDDSSRC) RCDLEN(112)
```

Compile each display file (with GENLVL(30) to allow warnings):

```bash
# Main Menu
CPYFRMSTMF FROMSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/dspf/CFGMENUD.dspf') +
           TOMBR('/QSYS.LIB/JWOEHR.LIB/QDDSSRC.FILE/CFGMENUD.MBR') +
           MBROPT(*REPLACE)
CRTDSPF FILE(DBSDK_V1/CFGMENUD) SRCFILE(JWOEHR/QDDSSRC) SRCMBR(CFGMENUD) GENLVL(30)

# User Management
CPYFRMSTMF FROMSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/dspf/CFGUSERD.dspf') +
           TOMBR('/QSYS.LIB/JWOEHR.LIB/QDDSSRC.FILE/CFGUSERD.MBR') +
           MBROPT(*REPLACE)
CRTDSPF FILE(DBSDK_V1/CFGUSERD) SRCFILE(JWOEHR/QDDSSRC) SRCMBR(CFGUSERD) GENLVL(30)

# Repeat for all other display files...
```

#### Step 3: Compile RPGLE Programs

**Important:** RPGLE programs contain embedded SQL and must be compiled with CRTSQLRPGI. The library list must include DBSDK_V1 to find display files.

```bash
# Add DBSDK_V1 to library list
ADDLIBLE DBSDK_V1

# Main Menu
CRTSQLRPGI OBJ(DBSDK_V1/CFGMENU) +
           SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGMENU.rpgle') +
           COMMIT(*NONE) +
           DBGVIEW(*SOURCE) +
           COMPILEOPT('DFTACTGRP(*NO) ACTGRP(*NEW) TGTCCSID(*JOB)') +
           USRPRF(*OWNER) +
           RDB(*LOCAL) +
           DFTRDBCOL(DBSDK_V1) +
           CVTCCSID(*JOB) +
           SQLPATH(*LIBL)

# User Management
CRTSQLRPGI OBJ(DBSDK_V1/CFGUSER) +
           SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGUSER.rpgle') +
           COMMIT(*NONE) +
           DBGVIEW(*SOURCE) +
           COMPILEOPT('DFTACTGRP(*NO) ACTGRP(*NEW) TGTCCSID(*JOB)') +
           USRPRF(*OWNER) +
           RDB(*LOCAL) +
           DFTRDBCOL(DBSDK_V1) +
           CVTCCSID(*JOB) +
           SQLPATH(*LIBL)

# Repeat for all other programs...
```

**Compilation Notes:**
- `CRTSQLRPGI` is required for programs with embedded SQL
- `CVTCCSID(*JOB)` handles UTF-8 (1208) source files
- `SQLPATH(*LIBL)` uses library list to find SQL procedures
- `DFTRDBCOL(DBSDK_V1)` sets default collection for unqualified SQL names
- `USRPRF(*OWNER)` allows programs to bypass RCAC for administration

## Usage

### Starting the Application

From a 5250 session:

```cl
CALL PGM(DBSDK_V1/CFGMENU)
```

Or add to your library list and call directly:

```cl
ADDLIBLE DBSDK_V1
CALL CFGMENU
```

### Main Menu

The main menu provides access to all configuration areas:

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DBSDK Configuration Administration                       │
│                                                                             │
│  Select an option:                                                          │
│                                                                             │
│    1. User Management                                                       │
│    2. WatsonX Configuration                                                 │
│    3. Ollama Configuration                                                  │
│    4. OpenAI Compatible Configuration                                       │
│    5. Wallaroo Configuration                                                │
│    6. Kafka Configuration                                                   │
│    7. Slack Configuration                                                   │
│    8. Twilio Configuration                                                  │
│                                                                             │
│   90. Exit                                                                  │
│                                                                             │
│  Selection: __                                                              │
│                                                                             │
│  F3=Exit                                                                    │
└─────────────────────────────────────────────────────────────────────────────┘
```

### User Management

Option 1 from the main menu provides user management functions:

- **Action 1 (Add)**: Create a new user configuration
- **Action 2 (Change)**: Modify existing user configuration
- **Action 4 (Delete)**: Remove a user from the configuration system
- **Action 5 (Display)**: View user configuration (read-only)

### Service Configuration

Options 2-8 allow you to configure specific services for a selected user:

1. Enter the user profile name
2. Fill in the configuration fields
3. Press Enter to save
4. Press F12 to cancel without saving

## Configuration Fields

### WatsonX (Option 2)

- **Region**: WatsonX region (e.g., us-south)
- **API Version**: API version (e.g., 2023-07-07)
- **API Key**: WatsonX API key (password protected)
- **Project ID**: WatsonX project identifier

### Ollama (Option 3)

- **Protocol**: http or https
- **Server**: Server hostname or IP address
- **Port**: Port number (default: 11434)
- **Model**: Model name (e.g., granite3.2:8b)

### OpenAI Compatible (Option 4)

- **Protocol**: http or https
- **Server**: Server hostname or IP address
- **Port**: Port number (default: 8000)
- **Model**: Model name
- **API Key**: API key (password protected)
- **Base Path**: API base path (default: /v1)

### Wallaroo (Option 5)

- **Token URL**: OAuth token URL
- **Confidential Client**: Client identifier
- **Client Secret**: Client secret (password protected)

### Kafka (Option 6)

- **Protocol**: http or https
- **Broker**: Kafka broker address
- **Port**: Port number (default: 8082)
- **Topic**: Kafka topic name

### Slack (Option 7)

- **Webhook URL**: Slack webhook URL (password protected)

### Twilio (Option 8)

- **Phone Number**: Twilio phone number
- **Account SID**: Twilio account SID
- **Auth Token**: Authentication token (password protected)

## Function Keys

- **F3**: Exit the application
- **F5**: Refresh screen (where applicable)
- **F12**: Cancel and return to previous screen

## Security

### Administrator Access

- Only authorized administrators should run this application
- Programs use `USRPRF(*OWNER)` to bypass RCAC row-level security
- This allows administrators to manage configurations for all users

### Password Fields

Sensitive fields (API keys, secrets, tokens) are displayed as password fields:

- Input is not echoed to the screen
- Values are stored securely in the database

### Audit Trail

Consider implementing an audit trail to track:

- Who made configuration changes
- When changes were made
- What values were changed

## Troubleshooting

### Common Issues

**Problem**: "Object CFGMENU not found"

- **Solution**: Ensure all programs are compiled to DBSDK_V1 library
- **Check**: `SELECT * FROM QSYS2.PROGRAM_INFO WHERE PROGRAM_LIBRARY = 'DBSDK_V1' AND PROGRAM_NAME = 'CFGMENU';`

**Problem**: "Authority violation"

- **Solution**: Verify programs have `USRPRF(*OWNER)` attribute
- **Check**: `SELECT USER_PROFILE FROM QSYS2.PROGRAM_INFO WHERE PROGRAM_LIBRARY = 'DBSDK_V1' AND PROGRAM_NAME = 'CFGMENU';`

**Problem**: "SQL error when saving"

- **Solution**: Check job log for specific SQL error
- **Check**: `DSPJOBLOG` and look for SQL messages

**Problem**: "Display file not found"

- **Solution**: Ensure all display files are compiled
- **Check**: `WRKOBJ OBJ(DBSDK_V1/CFGMENUD) OBJTYPE(*FILE)`

### Debug Mode

To debug programs:

1. Start debug session: `STRDBG PGM(DBSDK_V1/CFGMENU)`
2. Set breakpoints as needed
3. Run the program: `CALL CFGMENU`
4. Step through code with F10/F22

### Checking Logs

View job log for errors:

```sql
SELECT * FROM TABLE(QSYS2.JOBLOG_INFO('*')) X
```

View SQL messages:

```sql
SELECT * FROM TABLE(QSYS2.MESSAGE_QUEUE_INFO(QUEUE_LIBRARY => 'QSYS', QUEUE_NAME => 'QSYSOPR')) X
```

## File Structure

```text
src/admin/
├── README.md                      # This file
├── DESIGN.md                      # Architecture documentation
├── IMPLEMENTATION_PLAN.md         # Detailed implementation plan
├── build.sh                       # Build script (bash)
├── Makefile                       # Build automation (make)
│
├── dspf/                          # Display file sources
│   ├── CFGMENUD.dspf             # Main menu
│   ├── CFGUSERD.dspf             # User management
│   ├── CFGWXD.dspf               # WatsonX config
│   ├── CFGOLLAMD.dspf            # Ollama config
│   ├── CFGOPENAID.dspf           # OpenAI config
│   ├── CFGWLROOD.dspf            # Wallaroo config
│   ├── CFGKAFKAD.dspf            # Kafka config
│   ├── CFGSLACKD.dspf            # Slack config
│   └── CFGTWILIOD.dspf           # Twilio config
│
├── rpgle/                         # RPGLE program sources
│   ├── CFGMENU.rpgle             # Main menu controller
│   ├── CFGUSER.rpgle             # User management
│   ├── CFGWX.rpgle               # WatsonX config
│   ├── CFGOLLAMA.rpgle           # Ollama config
│   ├── CFGOPENAI.rpgle           # OpenAI config
│   ├── CFGWLROO.rpgle            # Wallaroo config
│   ├── CFGKAFKA.rpgle            # Kafka config
│   ├── CFGSLACK.rpgle            # Slack config
│   └── CFGTWILIO.rpgle           # Twilio config
│
└── sql/                           # SQL procedure sources
    ├── conf_get_user.sql         # Get user configuration
    ├── conf_list_users.sql       # List all users
    ├── conf_update_watsonx.sql   # Update WatsonX config
    ├── conf_update_ollama.sql    # Update Ollama config
    ├── conf_update_openai.sql    # Update OpenAI config
    ├── conf_update_wallaroo.sql  # Update Wallaroo config
    ├── conf_update_kafka.sql     # Update Kafka config
    ├── conf_update_slack.sql     # Update Slack config
    └── conf_update_twilio.sql    # Update Twilio config
```

## Maintenance

### Adding New Configuration Fields

1. Update the database schema in `src/conf.sql`
2. Update the appropriate display file in `dspf/`
3. Update the corresponding RPGLE program in `rpgle/`
4. Update the corresponding SQL procedure in `sql/conf_update_*.sql`
5. Recompile affected components using `make` or `build.sh`

### Modifying Screen Layouts

1. Edit the display file source in `dspf/`
2. Recompile the display file
3. Update the RPGLE program if field names changed
4. Recompile the RPGLE program

## Support

For issues or questions:

1. Check the troubleshooting section above
2. Review the DESIGN.md for architecture details
3. Review the IMPLEMENTATION_PLAN.md for technical details
4. Check job logs for specific error messages

## License

This application is part of the DBSDK project. See the main LICENSE file for details.

## Version History

- **v1.1** (2026-04-06): Build system improvements
  - Added Makefile for automated builds
  - Modularized SQL procedures into separate files
  - Added VERBOSE mode for debugging compilation issues
  - Updated RPGLE compilation to use CRTSQLRPGI
  - Improved build documentation

- **v1.0** (2026-04-04): Initial release
  - User management functionality
  - Configuration screens for 7 services
  - Menu-driven interface
  - Administrator-only access model
