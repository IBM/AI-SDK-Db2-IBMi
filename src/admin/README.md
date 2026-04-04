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

## Installation

### Quick Start

1. **Navigate to the admin directory:**

   ```bash
   cd /home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin
   ```

2. **Run the build script:**

   ```bash
   ./build.sh
   ```

3. **Start the application:**

   ```cl
   CALL PGM(DBSDK_V1/CFGMENU)
   ```

### Manual Installation

If you prefer to build components individually, follow these steps:

#### Step 1: Create SQL Procedures

```bash
RUNSQLSTM SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/sql/conf_admin.sql') +
          COMMIT(*NONE) +
          ERRLVL(21)
```

#### Step 2: Compile Display Files

**Note:** Display files use the JWOEHR/QDDSSRC source file. Ensure QDDSSRC exists in library JWOEHR.

Compile each display file:

```bash
# Main Menu
CPYFRMSTMF FROMSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/dspf/CFGMENUD.dspf') +
           TOMBR('/QSYS.LIB/JWOEHR.LIB/QDDSSRC.FILE/CFGMENUD.MBR') +
           MBROPT(*REPLACE)
CRTDSPF FILE(DBSDK_V1/CFGMENUD) SRCFILE(JWOEHR/QDDSSRC) SRCMBR(CFGMENUD)

# User Management
CPYFRMSTMF FROMSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/dspf/CFGUSERD.dspf') +
           TOMBR('/QSYS.LIB/JWOEHR.LIB/QDDSSRC.FILE/CFGUSERD.MBR') +
           MBROPT(*REPLACE)
CRTDSPF FILE(DBSDK_V1/CFGUSERD) SRCFILE(JWOEHR/QDDSSRC) SRCMBR(CFGUSERD)

# Repeat for all other display files...
```

If QDDSSRC doesn't exist in JWOEHR, create it:

```bash
CRTSRCPF FILE(JWOEHR/QDDSSRC) RCDLEN(112)
```

#### Step 3: Compile RPGLE Programs

```bash
# Main Menu
CRTBNDRPG PGM(DBSDK_V1/CFGMENU) +
          SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGMENU.rpgle') +
          DFTACTGRP(*NO) +
          ACTGRP(*NEW) +
          DBGVIEW(*SOURCE) +
          OPTION(*EVENTF) +
          USRPRF(*OWNER)

# User Management
CRTBNDRPG PGM(DBSDK_V1/CFGUSER) +
          SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGUSER.rpgle') +
          DFTACTGRP(*NO) +
          ACTGRP(*NEW) +
          DBGVIEW(*SOURCE) +
          OPTION(*EVENTF) +
          USRPRF(*OWNER)

# Repeat for all other programs...
```

## Usage

### Starting the Application

From a 5250 session:

```
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
- **Check**: `WRKOBJ OBJ(DBSDK_V1/CFGMENU) OBJTYPE(*PGM)`

**Problem**: "Authority violation"

- **Solution**: Verify programs have `USRPRF(*OWNER)` attribute
- **Check**: `DSPPGM PGM(DBSDK_V1/CFGMENU)` and look for "User profile"

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

```cl
DSPJOBLOG
```

View SQL messages:

```cl
DSPMSG MSGQ(QSYSOPR)
```

## File Structure

```text
src/admin/
├── README.md                      # This file
├── DESIGN.md                      # Architecture documentation
├── IMPLEMENTATION_PLAN.md         # Detailed implementation plan
├── build.sh                       # Build script
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
    └── conf_admin.sql            # Admin procedures
```

## Maintenance

### Adding New Configuration Fields

1. Update the database schema in `src/conf.sql`
2. Update the appropriate display file in `dspf/`
3. Update the corresponding RPGLE program in `rpgle/`
4. Update the SQL procedure in `sql/conf_admin.sql`
5. Recompile affected components

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

- **v1.0** (2026-03-22): Initial release
  - User management functionality
  - Configuration screens for 7 services
  - Menu-driven interface
  - Administrator-only access model
