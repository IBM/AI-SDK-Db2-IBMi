
create or replace function watsonx.ollama_getserver(hostname varchar(1000) ccsid 1208 default NULL) 
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call watsonx.conf_initialize();
  set returnval = hostname;
  if (returnval is not null) then return returnval;end if;
  set returnval = watsonx.ollama_server;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select ollama_server from watsonx.conf where USRPRF = CURRENT_USER);
  if (returnval is not null) then return returnval;end if;
  set returnval = (select ollama_server from watsonx.conf where USRPRF = '*DEFAULT');
  return returnval;
end;

create or replace procedure watsonx.ollama_setserverforjob(hostname varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set watsonx.ollama_server= hostname;
end;
create or replace procedure watsonx.ollama_setserverforme(hostname varchar(1000) ccsid 1208 default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO watsonx.conf tt USING (
    SELECT CURRENT_USER AS usrprf, hostname AS ollama_server
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, ollama_server) VALUES (live.usrprf,
      live.ollama_server)
  WHEN MATCHED THEN UPDATE SET (usrprf, ollama_server) = (live.usrprf, live.ollama_server);
end;

create or replace function watsonx.ollama_getport(port INT default NULL) 
  returns INT
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call watsonx.conf_initialize();
  set returnval = port;
  if (returnval is not null) then return returnval;end if;
  set returnval = watsonx.ollama_port;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select ollama_port from watsonx.conf where USRPRF = CURRENT_USER);
  if (returnval is not null) then return returnval;end if;
  set returnval = (select ollama_port from watsonx.conf where USRPRF = '*DEFAULT');
  return returnval;
end;

create or replace procedure watsonx.ollama_setportforjob(port INT default NULL) 
  modifies SQL DATA
begin
  set watsonx.ollama_port= port;
end;
create or replace procedure watsonx.ollama_setportforme(port INT default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO watsonx.conf tt USING (
    SELECT CURRENT_USER AS usrprf, port AS ollama_port
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, ollama_port) VALUES (live.usrprf,
      live.ollama_port)
  WHEN MATCHED THEN UPDATE SET (usrprf, ollama_port) = (live.usrprf, live.ollama_port);
end;


create or replace function watsonx.ollama_getmodel(model varchar(1000) ccsid 1208 default NULL) 
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call watsonx.conf_initialize();
  set returnval = model;
  if (returnval is not null) then return returnval;end if;
  set returnval = watsonx.ollama_model;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select ollama_model from watsonx.conf where USRPRF = CURRENT_USER);
  if (returnval is not null) then return returnval;end if;
  set returnval = (select ollama_model from watsonx.conf where USRPRF = '*DEFAULT');
  return returnval;
end;

create or replace procedure watsonx.ollama_setmodelforjob(model varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set watsonx.ollama_model= model;
end;
create or replace procedure watsonx.ollama_setmodelforme(model varchar(1000) ccsid 1208 default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO watsonx.conf tt USING (
    SELECT CURRENT_USER AS usrprf, model AS ollama_model
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, ollama_model) VALUES (live.usrprf,
      live.ollama_model)
  WHEN MATCHED THEN UPDATE SET (usrprf, ollama_model) = (live.usrprf, live.ollama_model);
end;