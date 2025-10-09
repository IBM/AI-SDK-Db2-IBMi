-- ## Anthropic endpoints utility functions

create or replace function dbsdk_v1.anthropic_getserver(hostname varchar(1000) ccsid 1208 default NULL) 
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call dbsdk_v1.conf_initialize();
  set returnval = hostname;
  if (returnval is not null) then return returnval;end if;
  set returnval = dbsdk_v1.anthropic_server;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select anthropic_server from dbsdk_v1.conf where USRPRF = CURRENT_USER);
  return returnval;
end;

-- ### procedure: `anthropic_setserverforjob`

-- **Description:** sets the Anthropic server to be used for this job

-- **Input parameters:**
-- - `HOSTNAME` (required): The IP address or hostname of the Anthropic server.
create or replace procedure dbsdk_v1.anthropic_setserverforjob(hostname varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set dbsdk_v1.anthropic_server = hostname;
end;

-- ### procedure: `anthropic_setserverforme`

-- **Description:** sets the Anthropic server to be used for this user profile (persists across jobs)

-- **Input parameters:**
-- - `HOSTNAME` (required): The IP address or hostname of the Anthropic server.
create or replace procedure dbsdk_v1.anthropic_setserverforme(hostname varchar(1000) ccsid 1208 default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO dbsdk_v1.conf tt USING (
    SELECT CURRENT_USER AS usrprf, hostname AS anthropic_server
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, anthropic_server) VALUES (live.usrprf,
      live.anthropic_server)
  WHEN MATCHED THEN UPDATE SET anthropic_server = live.anthropic_server;
end;

create or replace function dbsdk_v1.anthropic_getport(port INT default NULL) 
  returns INT
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call dbsdk_v1.conf_initialize();
  set returnval = port;
  if (returnval is not null) then return returnval;end if;
  set returnval = dbsdk_v1.anthropic_port;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select anthropic_port from dbsdk_v1.conf where USRPRF = CURRENT_USER);
  return returnval;
end;

-- ### procedure: `anthropic_setportforjob`

-- **Description:** sets the Anthropic server port to be used for this job

-- **Input parameters:**
-- - `PORT` (required): The Anthropic server port.
create or replace procedure dbsdk_v1.anthropic_setportforjob(port INT default NULL) 
  modifies SQL DATA
begin
  set dbsdk_v1.anthropic_port = port;
end;

-- ### procedure: `anthropic_setportforme`

-- **Description:** sets the Anthropic server port to be used for this user profile (persists across jobs).

-- **Input parameters:**
-- - `PORT` (required): The Anthropic server port.
create or replace procedure dbsdk_v1.anthropic_setportforme(port INT default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO dbsdk_v1.conf tt USING (
    SELECT CURRENT_USER AS usrprf, port AS anthropic_port
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, anthropic_port) VALUES (live.usrprf,
      live.anthropic_port)
  WHEN MATCHED THEN UPDATE SET anthropic_port = live.anthropic_port;
end;

create or replace function dbsdk_v1.anthropic_getmodel(model varchar(1000) ccsid 1208 default NULL) 
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call dbsdk_v1.conf_initialize();
  set returnval = model;
  if (returnval is not null) then return returnval;end if;
  set returnval = dbsdk_v1.anthropic_model;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select anthropic_model from dbsdk_v1.conf where USRPRF = CURRENT_USER);
  return returnval;
end;

-- ### procedure: `anthropic_setmodelforjob`

-- **Description:** sets the large language model (LLM) to be used for this job

-- **Input parameters:**
-- - `MODEL` (required): The model identifier to use.
create or replace procedure dbsdk_v1.anthropic_setmodelforjob(model varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set dbsdk_v1.anthropic_model = model;
end;

-- ### procedure: `anthropic_setmodelforme`

-- **Description:** sets the large language model (LLM) to be used for this user profile (persists across jobs)

-- **Input parameters:**
-- - `MODEL` (required): The model identifier to use.
create or replace procedure dbsdk_v1.anthropic_setmodelforme(model varchar(1000) ccsid 1208 default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO dbsdk_v1.conf tt USING (
    SELECT CURRENT_USER AS usrprf, model AS anthropic_model
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, anthropic_model) VALUES (live.usrprf,
      live.anthropic_model)
  WHEN MATCHED THEN UPDATE SET anthropic_model = live.anthropic_model;
end;

create or replace function dbsdk_v1.anthropic_getprotocol(protocol varchar(1000) ccsid 1208 default NULL) 
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call dbsdk_v1.conf_initialize();
  set returnval = protocol;
  if (returnval is not null) then return returnval;end if;
  set returnval = dbsdk_v1.anthropic_protocol;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select anthropic_protocol from dbsdk_v1.conf where USRPRF = CURRENT_USER);
  return returnval;
end;

-- ### procedure: `anthropic_setprotocolforjob`

-- **Description:** sets the protocol to be used for this job

-- **Input parameters:**
-- - `PROTOCOL` (required): `http`/`https`
create or replace procedure dbsdk_v1.anthropic_setprotocolforjob(protocol varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set dbsdk_v1.anthropic_protocol = protocol;
end;

-- ### procedure: `anthropic_setprotocolforme`
-- 
-- **Description:** sets the protocol to be used for this user profile (persists across jobs)
-- 
-- **Input parameters:**
-- - `PROTOCOL` (required): `http`/`https`
create or replace procedure dbsdk_v1.anthropic_setprotocolforme(protocol varchar(1000) ccsid 1208 default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO dbsdk_v1.conf tt USING (
    SELECT CURRENT_USER AS usrprf, protocol AS anthropic_protocol
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, anthropic_protocol) VALUES (live.usrprf,
      live.anthropic_protocol)
  WHEN MATCHED THEN UPDATE SET anthropic_protocol = live.anthropic_protocol;
end;

-- Function for API key management
create or replace function dbsdk_v1.anthropic_getapikey(api_key varchar(8000) ccsid 1208 default NULL) 
  returns varchar(8000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(8000) ccsid 1208;
  call dbsdk_v1.conf_initialize();
  set returnval = api_key;
  if (returnval is not null) then return returnval;end if;
  set returnval = dbsdk_v1.anthropic_apikey;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select anthropic_apikey from dbsdk_v1.conf where USRPRF = CURRENT_USER);
  return returnval;
end;

-- ### procedure: `anthropic_setapikeyforjob`

-- **Description:** sets the API key to be used for this job

-- **Input parameters:**
-- - `API_KEY` (required): The API key for authentication.
create or replace procedure dbsdk_v1.anthropic_setapikeyforjob(api_key varchar(8000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set dbsdk_v1.anthropic_apikey = api_key;
end;

-- ### procedure: `anthropic_setapikeyforme`
-- 
-- **Description:** sets the API key to be used for this user profile (persists across jobs)
-- 
-- **Input parameters:**
-- - `API_KEY` (required): The API key for authentication.
create or replace procedure dbsdk_v1.anthropic_setapikeyforme(api_key varchar(8000) ccsid 1208 default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO dbsdk_v1.conf tt USING (
    SELECT CURRENT_USER AS usrprf, api_key AS anthropic_apikey
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, anthropic_apikey) VALUES (live.usrprf,
      live.anthropic_apikey)
  WHEN MATCHED THEN UPDATE SET anthropic_apikey = live.anthropic_apikey;
end;

-- Function for base path configuration (for servers with non-standard API paths)
create or replace function dbsdk_v1.anthropic_getbasepath(base_path varchar(1000) ccsid 1208 default NULL) 
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call dbsdk_v1.conf_initialize();
  set returnval = base_path;
  if (returnval is not null) then return returnval;end if;
  set returnval = dbsdk_v1.anthropic_basepath;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select anthropic_basepath from dbsdk_v1.conf where USRPRF = CURRENT_USER);
  return coalesce(returnval, '/v1'); -- Default to standard Anthropic path if not set
end;

-- ### procedure: `anthropic_setbasepathforjob`

-- **Description:** sets the API base path to be used for this job

-- **Input parameters:**
-- - `BASE_PATH` (required): The base path for API endpoints.
create or replace procedure dbsdk_v1.anthropic_setbasepathforjob(base_path varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set dbsdk_v1.anthropic_basepath = base_path;
end;

-- ### procedure: `anthropic_setbasepathforme`
-- 
-- **Description:** sets the API base path to be used for this user profile (persists across jobs)
-- 
-- **Input parameters:**
-- - `BASE_PATH` (required): The base path for API endpoints.
create or replace procedure dbsdk_v1.anthropic_setbasepathforme(base_path varchar(1000) ccsid 1208 default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO dbsdk_v1.conf tt USING (
    SELECT CURRENT_USER AS usrprf, base_path AS anthropic_basepath
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, anthropic_basepath) VALUES (live.usrprf,
      live.anthropic_basepath)
  WHEN MATCHED THEN UPDATE SET anthropic_basepath = live.anthropic_basepath;
end;

-- Function for version configuration (Anthropic API version)
create or replace function dbsdk_v1.anthropic_getversion(version varchar(100) ccsid 1208 default NULL) 
  returns varchar(100) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(100) ccsid 1208;
  call dbsdk_v1.conf_initialize();
  set returnval = version;
  if (returnval is not null) then return returnval;end if;
  set returnval = dbsdk_v1.anthropic_version;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select anthropic_version from dbsdk_v1.conf where USRPRF = CURRENT_USER);
  return coalesce(returnval, '2023-06-01'); -- Default to a standard Anthropic API version
end;

-- ### procedure: `anthropic_setversionforjob`

-- **Description:** sets the API version to be used for this job

-- **Input parameters:**
-- - `VERSION` (required): The Anthropic API version.
create or replace procedure dbsdk_v1.anthropic_setversionforjob(version varchar(100) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set dbsdk_v1.anthropic_version = version;
end;

-- ### procedure: `anthropic_setversionforme`
-- 
-- **Description:** sets the API version to be used for this user profile (persists across jobs)
-- 
-- **Input parameters:**
-- - `VERSION` (required): The Anthropic API version.
create or replace procedure dbsdk_v1.anthropic_setversionforme(version varchar(100) ccsid 1208 default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO dbsdk_v1.conf tt USING (
    SELECT CURRENT_USER AS usrprf, version AS anthropic_version
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, anthropic_version) VALUES (live.usrprf,
      live.anthropic_version)
  WHEN MATCHED THEN UPDATE SET anthropic_version = live.anthropic_version;
end;

-- Made with Bob
