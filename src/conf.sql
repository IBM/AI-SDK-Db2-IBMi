
--variables for watsonx
create or replace variable watsonx.region varchar(16) ccsid 1208 default NULL;
create or replace variable watsonx.apiVersion varchar(10) ccsid 1208 default NULL;
create or replace variable watsonx.apikey varchar(100) ccsid 1208 default NULL;
create or replace variable watsonx.projectid varchar(100) ccsid 1208 default NULL;
create or replace variable watsonx.JobBearerToken varchar(10000) ccsid 1208 default null;
create or replace variable watsonx.JobTokenExpires timestamp;

-- variables for ollama
create or replace variable watsonx.ollama_protocol varchar(16)   ccsid 1208 default null;
create or replace variable watsonx.ollama_server   varchar(1000) ccsid 1208 default null;
create or replace variable watsonx.ollama_port     INT                      default NULL;
create or replace variable watsonx.ollama_model    varchar(1000) ccsid 1208 default NULL;


-- variables for kafka
create or replace variable watsonx.kafka_protocol varchar(16)   ccsid 1208 default null;
create or replace variable watsonx.kafka_broker   varchar(1000) ccsid 1208 default null;
create or replace variable watsonx.kafka_port     INT                      default NULL;
create or replace variable watsonx.kafka_topic    varchar(1000) ccsid 1208 default NULL;

-- variables for Slack
create or replace variable watsonx.slack_clientsecret    varchar(1000) ccsid 1208 default NULL;
create or replace variable watsonx.slack_clientid    varchar(1000) ccsid 1208 default NULL;

create or replace table watsonx.conf
      (
          USRPRF varchar(10),
          watsonx_region varchar(16) ccsid 1208 default 'us-south',
          watsonx_apiVersion varchar(10) ccsid 1208 default '2023-07-07',
          watsonx_apikey varchar(100) ccsid 1208 default NULL,
          watsonx_projectid varchar(100) ccsid 1208 default NULL,
          ollama_protocol varchar(16) ccsid 1208 default 'http',
          ollama_server varchar(1000) ccsid 1208 default 'localhost',
          ollama_port INT default 11434,
          ollama_model varchar(1000) ccsid 1208 default 'granite3.2:8b',
          openai_server varchar(1000) ccsid 1208 default 'localhost',
          openai_port INT default 443,
          kafka_protocol varchar(16) ccsid 1208 default 'http',
          kafka_broker varchar(1000) ccsid 1208 default 'localhost',
          kafka_port int default 992,
          kafka_topic varchar(1000) ccsid 1208 default NULL,
          slack_clientsecret varchar(1000) ccsid 1208 default NULL,
          slack_clientid varchar(1000) ccsid 1208 default NULL,
        PRIMARY KEY(USRPRF)
      )
      on replace preserve rows;
create or replace procedure watsonx.conf_register_user(usrprf varchar(10) ccsid 1208 default current_user) 
  program type sub
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  MERGE INTO watsonx.conf tt USING (
      SELECT usrprf AS usrprf
        FROM sysibm.sysdummy1
    ) live
    ON tt.usrprf = live.usrprf
    WHEN NOT MATCHED THEN INSERT (usrprf) VALUES (live.usrprf)
    WHEN MATCHED THEN UPDATE SET (usrprf) = (live.usrprf);
end;
create or replace procedure watsonx.conf_initialize() 
  modifies SQL DATA
begin
  call watsonx.conf_register_user('*DEFAULT');
end;

  call watsonx.conf_initialize();