
create or replace function watsonx.kafka_getbroker(hostname varchar(1000) ccsid 1208 default NULL) 
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call watsonx.conf_initialize();
  set returnval = hostname;
  if (returnval is not null) then return returnval;end if;
  set returnval = watsonx.kafka_broker;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select kafka_broker from watsonx.conf where USRPRF = CURRENT_USER);
  if (returnval is not null) then return returnval;end if;
  set returnval = (select kafka_broker from watsonx.conf where USRPRF = '*DEFAULT');
  return returnval;
end;

create or replace procedure watsonx.kafka_setbrokerforjob(hostname varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set watsonx.kafka_broker= hostname;
end;
create or replace procedure watsonx.kafka_setbrokerforme(hostname varchar(1000) ccsid 1208 default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO watsonx.conf tt USING (
    SELECT CURRENT_USER AS usrprf, hostname AS kafka_broker
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, kafka_broker) VALUES (live.usrprf,
      live.kafka_broker)
  WHEN MATCHED THEN UPDATE SET (usrprf, kafka_broker) = (live.usrprf, live.kafka_broker);
end;

create or replace function watsonx.kafka_getport(port INT default NULL) 
  returns INT
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call watsonx.conf_initialize();
  set returnval = port;
  if (returnval is not null) then return returnval;end if;
  set returnval = watsonx.kafka_port;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select kafka_port from watsonx.conf where USRPRF = CURRENT_USER);
  if (returnval is not null) then return returnval;end if;
  set returnval = (select kafka_port from watsonx.conf where USRPRF = '*DEFAULT');
  return returnval;
end;

create or replace procedure watsonx.kafka_setportforjob(port INT default NULL) 
  modifies SQL DATA
begin
  set watsonx.kafka_port= port;
end;
create or replace procedure watsonx.kafka_setportforme(port INT default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO watsonx.conf tt USING (
    SELECT CURRENT_USER AS usrprf, port AS kafka_port
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, kafka_port) VALUES (live.usrprf,
      live.kafka_port)
  WHEN MATCHED THEN UPDATE SET (usrprf, kafka_port) = (live.usrprf, live.kafka_port);
end;


create or replace function watsonx.kafka_gettopic(topic varchar(1000) ccsid 1208 default NULL) 
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call watsonx.conf_initialize();
  set returnval = topic;
  if (returnval is not null) then return returnval;end if;
  set returnval = watsonx.kafka_topic;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select kafka_topic from watsonx.conf where USRPRF = CURRENT_USER);
  if (returnval is not null) then return returnval;end if;
  set returnval = (select kafka_topic from watsonx.conf where USRPRF = '*DEFAULT');
  return returnval;
end;

create or replace procedure watsonx.kafka_settopicforjob(topic varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set watsonx.kafka_topic= topic;
end;
create or replace procedure watsonx.kafka_settopicforme(topic varchar(1000) ccsid 1208 default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO watsonx.conf tt USING (
    SELECT CURRENT_USER AS usrprf, topic AS kafka_topic
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, kafka_topic) VALUES (live.usrprf,
      live.kafka_topic)
  WHEN MATCHED THEN UPDATE SET (usrprf, kafka_topic) = (live.usrprf, live.kafka_topic);
end;

create or replace function watsonx.kafka_getprotocol(protocol varchar(1000) ccsid 1208 default NULL) 
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call watsonx.conf_initialize();
  set returnval = protocol;
  if (returnval is not null) then return returnval;end if;
  set returnval = watsonx.kafka_protocol;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select kafka_protocol from watsonx.conf where USRPRF = CURRENT_USER);
  if (returnval is not null) then return returnval;end if;
  set returnval = (select kafka_protocol from watsonx.conf where USRPRF = '*DEFAULT');
  return returnval;
end;

create or replace procedure watsonx.kafka_setprotocolforjob(protocol varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set watsonx.kafka_protocol= protocol;
end;
create or replace procedure watsonx.kafka_setprotocolforme(protocol varchar(1000) ccsid 1208 default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO watsonx.conf tt USING (
    SELECT CURRENT_USER AS usrprf, protocol AS kafka_protocol
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, kafka_protocol) VALUES (live.usrprf,
      live.kafka_protocol)
  WHEN MATCHED THEN UPDATE SET (usrprf, kafka_protocol) = (live.usrprf, live.kafka_protocol);
end;