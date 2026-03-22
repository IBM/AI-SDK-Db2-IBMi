# DBSDK Configuration Administration - Implementation Plan

## File Structure

```
src/admin/
├── DESIGN.md                      # Architecture and design documentation
├── IMPLEMENTATION_PLAN.md         # This file - detailed implementation plan
├── README.md                      # User guide and compilation instructions
├── build.sh                       # Build script for all components
│
├── dspf/                          # Display file sources
│   ├── CFGMENUD.dspf             # Main menu display
│   ├── CFGUSERD.dspf             # User management display
│   ├── CFGWXD.dspf               # WatsonX configuration display
│   ├── CFGOLLAMD.dspf            # Ollama configuration display
│   ├── CFGOPENAID.dspf           # OpenAI configuration display
│   ├── CFGWLROOD.dspf            # Wallaroo configuration display
│   ├── CFGKAFKAD.dspf            # Kafka configuration display
│   ├── CFGSLACKD.dspf            # Slack configuration display
│   └── CFGTWILIOD.dspf           # Twilio configuration display
│
├── rpgle/                         # RPGLE program sources
│   ├── CFGMENU.rpgle             # Main menu controller
│   ├── CFGUSER.rpgle             # User management program
│   ├── CFGWX.rpgle               # WatsonX configuration program
│   ├── CFGOLLAMA.rpgle           # Ollama configuration program
│   ├── CFGOPENAI.rpgle           # OpenAI configuration program
│   ├── CFGWLROO.rpgle            # Wallaroo configuration program
│   ├── CFGKAFKA.rpgle            # Kafka configuration program
│   ├── CFGSLACK.rpgle            # Slack configuration program
│   └── CFGTWILIO.rpgle           # Twilio configuration program
│
└── sql/                           # SQL procedure sources
    └── conf_admin.sql            # Administrative SQL procedures
```

## Component Details

### 1. Display Files (DSPF)

#### CFGMENUD.dspf - Main Menu
**Purpose:** Display main menu with options for all configuration areas
**Fields:**
- OPTION (2A) - Menu selection input
- ERRMSG (78A) - Error message display

**Compilation:**
```bash
CRTSRCPF FILE(QTEMP/QDDSSRC) RCDLEN(112)
CPYFRMSTMF FROMSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/dspf/CFGMENUD.dspf') +
           TOMBR('/QSYS.LIB/QTEMP.LIB/QDDSSRC.FILE/CFGMENUD.MBR') +
           MBROPT(*REPLACE)
CRTDSPF FILE(DBSDK_V1/CFGMENUD) SRCFILE(QTEMP/QDDSSRC) SRCMBR(CFGMENUD)
```

#### CFGUSERD.dspf - User Management
**Purpose:** Display user list and provide add/change/delete functionality
**Fields:**
- ACTION (1A) - Action code (1=Add, 2=Change, 4=Delete, 5=Display)
- USRPRF (10A) - User profile name
- SFLRRN (4S 0) - Subfile relative record number
- SEL (1A) - Selection field in subfile
- LSTMOD (26A) - Last modified timestamp

**Compilation:**
```bash
CPYFRMSTMF FROMSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/dspf/CFGUSERD.dspf') +
           TOMBR('/QSYS.LIB/QTEMP.LIB/QDDSSRC.FILE/CFGUSERD.MBR') +
           MBROPT(*REPLACE)
CRTDSPF FILE(DBSDK_V1/CFGUSERD) SRCFILE(QTEMP/QDDSSRC) SRCMBR(CFGUSERD)
```

#### CFGWXD.dspf - WatsonX Configuration
**Purpose:** Edit WatsonX configuration for a user
**Fields:**
- USRPRF (10A) - User profile (display only)
- WXREGION (16A) - WatsonX region
- WXAPIVER (10A) - API version
- WXAPIKEY (100A) - API key (password field)
- WXPROJID (100A) - Project ID

**Compilation:**
```bash
CPYFRMSTMF FROMSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/dspf/CFGWXD.dspf') +
           TOMBR('/QSYS.LIB/QTEMP.LIB/QDDSSRC.FILE/CFGWXD.MBR') +
           MBROPT(*REPLACE)
CRTDSPF FILE(DBSDK_V1/CFGWXD) SRCFILE(QTEMP/QDDSSRC) SRCMBR(CFGWXD)
```

#### CFGOLLAMD.dspf - Ollama Configuration
**Purpose:** Edit Ollama configuration for a user
**Fields:**
- USRPRF (10A) - User profile (display only)
- OLPROTOC (16A) - Protocol (http/https)
- OLSERVER (1000A) - Server address
- OLPORT (5S 0) - Port number
- OLMODEL (1000A) - Model name

**Compilation:**
```bash
CPYFRMSTMF FROMSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/dspf/CFGOLLAMD.dspf') +
           TOMBR('/QSYS.LIB/QTEMP.LIB/QDDSSRC.FILE/CFGOLLAMD.MBR') +
           MBROPT(*REPLACE)
CRTDSPF FILE(DBSDK_V1/CFGOLLAMD) SRCFILE(QTEMP/QDDSSRC) SRCMBR(CFGOLLAMD)
```

#### CFGOPENAID.dspf - OpenAI Compatible Configuration
**Purpose:** Edit OpenAI compatible configuration for a user
**Fields:**
- USRPRF (10A) - User profile (display only)
- OAPROTOC (16A) - Protocol
- OASERVER (1000A) - Server address
- OAPORT (5S 0) - Port number
- OAMODEL (1000A) - Model name
- OAAPIKEY (8000A) - API key (password field)
- OABASEPT (1000A) - Base path

**Compilation:**
```bash
CPYFRMSTMF FROMSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/dspf/CFGOPENAID.dspf') +
           TOMBR('/QSYS.LIB/QTEMP.LIB/QDDSSRC.FILE/CFGOPENAID.MBR') +
           MBROPT(*REPLACE)
CRTDSPF FILE(DBSDK_V1/CFGOPENAID) SRCFILE(QTEMP/QDDSSRC) SRCMBR(CFGOPENAID)
```

#### CFGWLROOD.dspf - Wallaroo Configuration
**Purpose:** Edit Wallaroo configuration for a user
**Fields:**
- USRPRF (10A) - User profile (display only)
- WLTKNURL (1000A) - Token URL
- WLCLIENT (1000A) - Confidential client
- WLSECRET (8000A) - Client secret (password field)

**Compilation:**
```bash
CPYFRMSTMF FROMSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/dspf/CFGWLROOD.dspf') +
           TOMBR('/QSYS.LIB/QTEMP.LIB/QDDSSRC.FILE/CFGWLROOD.MBR') +
           MBROPT(*REPLACE)
CRTDSPF FILE(DBSDK_V1/CFGWLROOD) SRCFILE(QTEMP/QDDSSRC) SRCMBR(CFGWLROOD)
```

#### CFGKAFKAD.dspf - Kafka Configuration
**Purpose:** Edit Kafka configuration for a user
**Fields:**
- USRPRF (10A) - User profile (display only)
- KFPROTOC (16A) - Protocol
- KFBROKER (1000A) - Broker address
- KFPORT (5S 0) - Port number
- KFTOPIC (1000A) - Topic name

**Compilation:**
```bash
CPYFRMSTMF FROMSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/dspf/CFGKAFKAD.dspf') +
           TOMBR('/QSYS.LIB/QTEMP.LIB/QDDSSRC.FILE/CFGKAFKAD.MBR') +
           MBROPT(*REPLACE)
CRTDSPF FILE(DBSDK_V1/CFGKAFKAD) SRCFILE(QTEMP/QDDSSRC) SRCMBR(CFGKAFKAD)
```

#### CFGSLACKD.dspf - Slack Configuration
**Purpose:** Edit Slack configuration for a user
**Fields:**
- USRPRF (10A) - User profile (display only)
- SLWEBHOK (1000A) - Webhook URL (password field)

**Compilation:**
```bash
CPYFRMSTMF FROMSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/dspf/CFGSLACKD.dspf') +
           TOMBR('/QSYS.LIB/QTEMP.LIB/QDDSSRC.FILE/CFGSLACKD.MBR') +
           MBROPT(*REPLACE)
CRTDSPF FILE(DBSDK_V1/CFGSLACKD) SRCFILE(QTEMP/QDDSSRC) SRCMBR(CFGSLACKD)
```

#### CFGTWILIOD.dspf - Twilio Configuration
**Purpose:** Edit Twilio configuration for a user
**Fields:**
- USRPRF (10A) - User profile (display only)
- TWNUMBER (1000A) - Phone number
- TWSID (1000A) - Account SID
- TWAUTHTN (1000A) - Auth token (password field)

**Compilation:**
```bash
CPYFRMSTMF FROMSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/dspf/CFGTWILIOD.dspf') +
           TOMBR('/QSYS.LIB/QTEMP.LIB/QDDSSRC.FILE/CFGTWILIOD.MBR') +
           MBROPT(*REPLACE)
CRTDSPF FILE(DBSDK_V1/CFGTWILIOD) SRCFILE(QTEMP/QDDSSRC) SRCMBR(CFGTWILIOD)
```

### 2. RPGLE Programs

All RPGLE programs use:
- **USRPRF(*OWNER)** - To bypass RCAC for administrative access
- **DBGVIEW(*SOURCE)** - For debugging
- **OPTION(*EVENTF)** - For event file generation

#### CFGMENU.rpgle - Main Menu Controller
**Purpose:** Display main menu and route to appropriate configuration program
**Compilation:**
```bash
CRTBNDRPG PGM(DBSDK_V1/CFGMENU) +
          SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGMENU.rpgle') +
          DFTACTGRP(*NO) +
          ACTGRP(*NEW) +
          DBGVIEW(*SOURCE) +
          OPTION(*EVENTF) +
          USRPRF(*OWNER)
```

#### CFGUSER.rpgle - User Management
**Purpose:** Add, change, delete, and list users in configuration table
**Compilation:**
```bash
CRTBNDRPG PGM(DBSDK_V1/CFGUSER) +
          SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGUSER.rpgle') +
          DFTACTGRP(*NO) +
          ACTGRP(*NEW) +
          DBGVIEW(*SOURCE) +
          OPTION(*EVENTF) +
          USRPRF(*OWNER)
```

#### Service Configuration Programs
Each service configuration program follows the same pattern:

**CFGWX.rpgle:**
```bash
CRTBNDRPG PGM(DBSDK_V1/CFGWX) +
          SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGWX.rpgle') +
          DFTACTGRP(*NO) +
          ACTGRP(*NEW) +
          DBGVIEW(*SOURCE) +
          OPTION(*EVENTF) +
          USRPRF(*OWNER)
```

**CFGOLLAMA.rpgle:**
```bash
CRTBNDRPG PGM(DBSDK_V1/CFGOLLAMA) +
          SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGOLLAMA.rpgle') +
          DFTACTGRP(*NO) +
          ACTGRP(*NEW) +
          DBGVIEW(*SOURCE) +
          OPTION(*EVENTF) +
          USRPRF(*OWNER)
```

**CFGOPENAI.rpgle:**
```bash
CRTBNDRPG PGM(DBSDK_V1/CFGOPENAI) +
          SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGOPENAI.rpgle') +
          DFTACTGRP(*NO) +
          ACTGRP(*NEW) +
          DBGVIEW(*SOURCE) +
          OPTION(*EVENTF) +
          USRPRF(*OWNER)
```

**CFGWLROO.rpgle:**
```bash
CRTBNDRPG PGM(DBSDK_V1/CFGWLROO) +
          SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGWLROO.rpgle') +
          DFTACTGRP(*NO) +
          ACTGRP(*NEW) +
          DBGVIEW(*SOURCE) +
          OPTION(*EVENTF) +
          USRPRF(*OWNER)
```

**CFGKAFKA.rpgle:**
```bash
CRTBNDRPG PGM(DBSDK_V1/CFGKAFKA) +
          SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGKAFKA.rpgle') +
          DFTACTGRP(*NO) +
          ACTGRP(*NEW) +
          DBGVIEW(*SOURCE) +
          OPTION(*EVENTF) +
          USRPRF(*OWNER)
```

**CFGSLACK.rpgle:**
```bash
CRTBNDRPG PGM(DBSDK_V1/CFGSLACK) +
          SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGSLACK.rpgle') +
          DFTACTGRP(*NO) +
          ACTGRP(*NEW) +
          DBGVIEW(*SOURCE) +
          OPTION(*EVENTF) +
          USRPRF(*OWNER)
```

**CFGTWILIO.rpgle:**
```bash
CRTBNDRPG PGM(DBSDK_V1/CFGTWILIO) +
          SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/rpgle/CFGTWILIO.rpgle') +
          DFTACTGRP(*NO) +
          ACTGRP(*NEW) +
          DBGVIEW(*SOURCE) +
          OPTION(*EVENTF) +
          USRPRF(*OWNER)
```

### 3. SQL Procedures

#### conf_admin.sql
**Purpose:** Administrative SQL procedures for configuration management
**Procedures:**
- `CONF_GET_USER(usrprf)` - Retrieve user configuration
- `CONF_UPDATE_WATSONX(usrprf, region, apiversion, apikey, projectid)` - Update WatsonX config
- `CONF_UPDATE_OLLAMA(usrprf, protocol, server, port, model)` - Update Ollama config
- `CONF_UPDATE_OPENAI(usrprf, protocol, server, port, model, apikey, basepath)` - Update OpenAI config
- `CONF_UPDATE_WALLAROO(usrprf, tokenurl, client, secret)` - Update Wallaroo config
- `CONF_UPDATE_KAFKA(usrprf, protocol, broker, port, topic)` - Update Kafka config
- `CONF_UPDATE_SLACK(usrprf, webhook)` - Update Slack config
- `CONF_UPDATE_TWILIO(usrprf, number, sid, authtoken)` - Update Twilio config
- `CONF_LIST_USERS()` - List all users

**Compilation:**
```bash
RUNSQLSTM SRCSTMF('/home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin/sql/conf_admin.sql') +
          COMMIT(*NONE) +
          ERRLVL(21)
```

## Build Process

### Prerequisites
1. DBSDK_V1 library must exist
2. DBSDK_V1.CONF table must exist (created by src/conf.sql)
3. User must have authority to create objects in DBSDK_V1

### Build Order
1. **SQL Procedures** - Create administrative procedures
2. **Display Files** - Compile all display files
3. **RPGLE Programs** - Compile all programs (service programs first, menu last)

### Automated Build Script
The `build.sh` script will automate the entire build process:

```bash
#!/bin/bash
# Build all components in correct order
cd /home/jwoehr/work/AI/DbToo/AI-SDK-Db2-IBMi/src/admin

# 1. Create SQL procedures
echo "Creating SQL procedures..."
system "RUNSQLSTM SRCSTMF('sql/conf_admin.sql') COMMIT(*NONE) ERRLVL(21)"

# 2. Compile display files
echo "Compiling display files..."
system "CRTSRCPF FILE(QTEMP/QDDSSRC) RCDLEN(112)"

for dspf in dspf/*.dspf; do
    name=$(basename "$dspf" .dspf)
    echo "  Compiling $name..."
    system "CPYFRMSTMF FROMSTMF('$dspf') TOMBR('/QSYS.LIB/QTEMP.LIB/QDDSSRC.FILE/$name.MBR') MBROPT(*REPLACE)"
    system "CRTDSPF FILE(DBSDK_V1/$name) SRCFILE(QTEMP/QDDSSRC) SRCMBR($name)"
done

# 3. Compile RPGLE programs
echo "Compiling RPGLE programs..."
for rpgle in rpgle/*.rpgle; do
    name=$(basename "$rpgle" .rpgle)
    echo "  Compiling $name..."
    system "CRTBNDRPG PGM(DBSDK_V1/$name) SRCSTMF('$rpgle') DFTACTGRP(*NO) ACTGRP(*NEW) DBGVIEW(*SOURCE) OPTION(*EVENTF) USRPRF(*OWNER)"
done

echo "Build complete!"
```

## Testing Plan

### Unit Testing
1. Test each display file individually
2. Test each program with valid and invalid inputs
3. Test SQL procedures with various scenarios

### Integration Testing
1. Test complete workflow: Add user → Configure services → Verify in database
2. Test navigation between screens
3. Test error handling and rollback scenarios

### User Acceptance Testing
1. Administrator performs typical configuration tasks
2. Verify configurations are correctly saved
3. Verify RCAC bypass works correctly for admin

## Deployment Checklist

- [ ] DBSDK_V1 library exists
- [ ] DBSDK_V1.CONF table exists
- [ ] SQL procedures created successfully
- [ ] All display files compiled
- [ ] All RPGLE programs compiled
- [ ] Programs have *OWNER authority
- [ ] Administrator has authority to DBSDK_V1 library
- [ ] Test user configuration workflow
- [ ] Document any custom setup requirements

## Maintenance Notes

### Adding New Configuration Fields
1. Update DBSDK_V1.CONF table schema
2. Update appropriate display file
3. Update corresponding RPGLE program
4. Update SQL procedure
5. Recompile affected components

### Troubleshooting
- Check job log for SQL errors
- Verify USRPRF(*OWNER) is set on programs
- Ensure DBSDK_V1 library is in library list
- Check authority to DBSDK_V1.CONF table