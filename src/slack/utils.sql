create or replace function watsonx.slack_getclientsecret(bearer varchar(1000) ccsid 1208 default NULL) 
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  set returnval = bearer;
  if (returnval is not null) then return returnval;end if;
  set returnval = watsonx.slack_clientsecret;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select slack_clientsecret from watsonx.conf where USRPRF = CURRENT_USER);
  if (returnval is not null) then return returnval;end if;
  set returnval = (select slack_clientsecret from watsonx.conf where USRPRF = '*DEFAULT');
  return returnval;
end;

create or replace procedure watsonx.slack_setclientsecretforjob(bearer varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set watsonx.slack_clientsecret= bearer;
end;
create or replace procedure watsonx.slack_setclientsecretforme(bearer varchar(1000) ccsid 1208 default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO watsonx.conf tt USING (
    SELECT CURRENT_USER AS usrprf, bearer AS slack_clientsecret
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, slack_clientsecret) VALUES (live.usrprf,
      live.slack_clientsecret)
  WHEN MATCHED THEN UPDATE SET (usrprf, slack_clientsecret) = (live.usrprf, live.slack_clientsecret);
end;



create or replace function watsonx.slack_getclientid(bearer varchar(1000) ccsid 1208 default NULL) 
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  set returnval = bearer;
  if (returnval is not null) then return returnval;end if;
  set returnval = watsonx.slack_clientid;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select slack_clientid from watsonx.conf where USRPRF = CURRENT_USER);
  if (returnval is not null) then return returnval;end if;
  set returnval = (select slack_clientid from watsonx.conf where USRPRF = '*DEFAULT');
  return returnval;
end;

create or replace procedure watsonx.slack_setclientidforjob(bearer varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set watsonx.slack_clientid= bearer;
end;
create or replace procedure watsonx.slack_setclientidforme(bearer varchar(1000) ccsid 1208 default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO watsonx.conf tt USING (
    SELECT CURRENT_USER AS usrprf, bearer AS slack_clientid
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, slack_clientid) VALUES (live.usrprf,
      live.slack_clientid)
  WHEN MATCHED THEN UPDATE SET (usrprf, slack_clientid) = (live.usrprf, live.slack_clientid);
end;