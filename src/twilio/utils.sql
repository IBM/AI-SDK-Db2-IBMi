-- ## Twilio SMS utility functions
-- 
create or replace function watsonx.twilio_getnumber(phnum varchar(1000) ccsid 1208 default NULL) 
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call watsonx.conf_initialize();
  set returnval = phnum;
  if (returnval is not null) then return returnval;end if;
  set returnval = watsonx.twilio_number;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select twilio_number from watsonx.conf where USRPRF = CURRENT_USER);
  if (returnval is not null) then return returnval;end if;
  set returnval = (select twilio_number from watsonx.conf where USRPRF = '*DEFAULT');
  return returnval;
end;

create or replace procedure watsonx.twilio_setnumberforjob(phnum varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set watsonx.twilio_number= phnum;
end;
create or replace procedure watsonx.twilio_setnumberforme(phnum varchar(1000) ccsid 1208 default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO watsonx.conf tt USING (
    SELECT CURRENT_USER AS usrprf, phnum AS twilio_number
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, twilio_number) VALUES (live.usrprf,
      live.twilio_number)
  WHEN MATCHED THEN UPDATE SET (usrprf, twilio_number) = (live.usrprf, live.twilio_number);
end;

create or replace function watsonx.twilio_getsid(account_sid varchar(1000) ccsid 1208 default NULL) 
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call watsonx.conf_initialize();
  set returnval = account_sid;
  if (returnval is not null) then return returnval;end if;
  set returnval = watsonx.twilio_sid;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select twilio_sid from watsonx.conf where USRPRF = CURRENT_USER);
  if (returnval is not null) then return returnval;end if;
  set returnval = (select twilio_sid from watsonx.conf where USRPRF = '*DEFAULT');
  return returnval;
end;

-- ### function: `twilio_setsidforjob`
-- 
-- Description: Sets the Twilio Account SID for the current job
-- 
-- Input parameters:
-- - `ACCOUNT_SID` (required): The Twilio Account SID.
create or replace procedure watsonx.twilio_setsidforjob(account_sid varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set watsonx.twilio_sid= account_sid;
end;


-- ### function: `twilio_setsidforme`
-- 
-- Description: Sets the Twilio Account SID for the current user profile (persists across jobs)
-- 
-- Input parameters:
-- - `ACCOUNT_SID` (required): The Twilio Account SID.
create or replace procedure watsonx.twilio_setsidforme(account_sid varchar(1000) ccsid 1208 default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO watsonx.conf tt USING (
    SELECT CURRENT_USER AS usrprf, account_sid AS twilio_sid
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, twilio_sid) VALUES (live.usrprf,
      live.twilio_sid)
  WHEN MATCHED THEN UPDATE SET (usrprf, twilio_sid) = (live.usrprf, live.twilio_sid);
end;







create or replace function watsonx.twilio_getauthtoken(authtoken varchar(1000) ccsid 1208 default NULL) 
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call watsonx.conf_initialize();
  set returnval = authtoken;
  if (returnval is not null) then return returnval;end if;
  set returnval = watsonx.twilio_authtoken;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select twilio_authtoken from watsonx.conf where USRPRF = CURRENT_USER);
  if (returnval is not null) then return returnval;end if;
  set returnval = (select twilio_authtoken from watsonx.conf where USRPRF = '*DEFAULT');
  return returnval;
end;

-- ### function: `twilio_setauthtokenforjob`
-- 
-- Description: Sets the Twilio authentication token for the current job
-- 
-- Input parameters:
-- - `AUTHTOKEN` (required): The Twilio authentication token.
create or replace procedure watsonx.twilio_setauthtokenforjob(authtoken varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set watsonx.twilio_authtoken= authtoken;
end;


-- ### function: `twilio_setauthtokenforme`
-- 
-- Description: Sets the Twilio authentication token for the current user profile (persists across jobs)
-- 
-- Input parameters:
-- - `AUTHTOKEN` (required): The Twilio authentication token.
create or replace procedure watsonx.twilio_setauthtokenforme(authtoken varchar(1000) ccsid 1208 default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO watsonx.conf tt USING (
    SELECT CURRENT_USER AS usrprf, authtoken AS twilio_authtoken
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, twilio_authtoken) VALUES (live.usrprf,
      live.twilio_authtoken)
  WHEN MATCHED THEN UPDATE SET (usrprf, twilio_authtoken) = (live.usrprf, live.twilio_authtoken);
end;