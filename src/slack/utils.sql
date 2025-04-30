-- ## Slack utility functions


create or replace function dbsdk_v1.slack_getwebhook(webhook varchar(1000) ccsid 1208 default NULL) 
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call dbsdk_v1.conf_initialize();
  set returnval = webhook;
  if (returnval is not null) then return returnval;end if;
  set returnval = dbsdk_v1.slack_webhook;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select slack_webhook from dbsdk_v1.conf where USRPRF = CURRENT_USER);
  return returnval;
end;

-- ### procedure: `slack_setwebhookforjob`

-- **Description:** sets the Slack webhook to be used for this job

-- **Input parameters:**
-- - `webhook` (required): the Slack webhook URL.
create or replace procedure dbsdk_v1.slack_setwebhookforjob(webhook varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set dbsdk_v1.slack_webhook= webhook;
end;

-- ### procedure: `slack_setwebhookforme`

-- **Description:** sets the Slack webhook to be used for the current user profile (persists across jobs).

-- **Input parameters:**
-- - `webhook` (required): the Slack webhook URL.
create or replace procedure dbsdk_v1.slack_setwebhookforme(webhook varchar(1000) ccsid 1208 default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO dbsdk_v1.conf tt USING (
    SELECT CURRENT_USER AS usrprf, webhook AS slack_webhook
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, slack_webhook) VALUES (live.usrprf,
      live.slack_webhook)
  WHEN MATCHED THEN UPDATE SET (usrprf, slack_webhook) = (live.usrprf, live.slack_webhook);
end;