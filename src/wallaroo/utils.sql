-- ## Wallaroo Utilities

-- ### function: `wallaroo_get_token_url`

-- **Description:** gets the Wallaroo token URL to be used for authentication

-- **Input parameters:**
-- - `TOKEN_URL` (optional): The token URL for Wallaroo authentication. If not provided, will use job-level or user-level configuration.

-- **Return type:** 
-- - `varchar(1000) ccsid 1208`

-- **Return value:**
-- - The token URL to use for Wallaroo authentication
create or replace function dbsdk_v1.wallaroo_get_token_url(token_url varchar(1000) ccsid 1208 default NULL)
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(8000) ccsid 1208;
  call dbsdk_v1.conf_initialize();
  set returnval = token_url;
  if (returnval is not null) then return returnval;end if;
  set returnval = dbsdk_v1.wallaroo_tokenurl;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select wallaroo_tokenurl from dbsdk_v1.conf where USRPRF = CURRENT_USER);
  return returnval;
end;

-- ### function: `wallaroo_get_confidential_client`

-- **Description:** gets the Wallaroo confidential client identifier to be used for authentication

-- **Input parameters:**
-- - `CLIENT` (optional): The confidential client identifier for Wallaroo authentication. If not provided, will use job-level or user-level configuration.

-- **Return type:** 
-- - `varchar(1000) ccsid 1208`

-- **Return value:**
-- - The confidential client identifier to use for Wallaroo authentication
create or replace function dbsdk_v1.wallaroo_get_confidential_client(client varchar(1000) ccsid 1208 default NULL)
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(8000) ccsid 1208;
  call dbsdk_v1.conf_initialize();
  set returnval = client;
  if (returnval is not null) then return returnval;end if;
  set returnval = dbsdk_v1.wallaroo_confidential_client;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select wallaroo_confidential_client from dbsdk_v1.conf where USRPRF = CURRENT_USER);
  return returnval;
end;

-- ### function: `wallaroo_get_confidential_client_secret`

-- **Description:** gets the Wallaroo confidential client secret to be used for authentication

-- **Input parameters:**
-- - `CONF_SECRET` (optional): The confidential client secret for Wallaroo authentication. If not provided, will use job-level or user-level configuration.

-- **Return type:** 
-- - `varchar(8000) ccsid 1208`

-- **Return value:**
-- - The confidential client secret to use for Wallaroo authentication
create or replace function dbsdk_v1.wallaroo_get_confidential_client_secret(conf_secret varchar(8000) ccsid 1208 default NULL)
  returns varchar(8000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(8000) ccsid 1208;
  call dbsdk_v1.conf_initialize();
  set returnval = conf_secret;
  if (returnval is not null) then return returnval;end if;
  set returnval = dbsdk_v1.wallaroo_confidential_client_secret;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select wallaroo_confidential_client_secret from dbsdk_v1.conf where USRPRF = CURRENT_USER);
  return returnval;
end;


-- ### procedure: `wallaroo_set_token_url_for_job`

-- **Description:** sets the Wallaroo token URL to be used for this job

-- **Input parameters:**
-- - `TOKEN_URL` (required): The token URL for Wallaroo authentication.
create or replace procedure dbsdk_v1.wallaroo_set_token_url_for_job(token_url varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set dbsdk_v1.wallaroo_tokenurl = token_url;
end;

-- ### procedure: `wallaroo_set_token_url_forme`

-- **Description:** sets the Wallaroo token URL to be used for this user profile (persists across jobs)

-- **Input parameters:**
-- - `TOKEN_URL` (required): The token URL for Wallaroo authentication.
create or replace procedure dbsdk_v1.wallaroo_set_token_url_forme(token_url varchar(1000) ccsid 1208 default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO dbsdk_v1.conf tt USING (
    SELECT CURRENT_USER AS usrprf, token_url AS wallaroo_tokenurl
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, wallaroo_tokenurl) VALUES (live.usrprf,
      live.wallaroo_tokenurl)
  WHEN MATCHED THEN UPDATE SET (usrprf, wallaroo_tokenurl) = (live.usrprf, live.wallaroo_tokenurl);
end;

-- ### procedure: `wallaroo_set_confidential_client_for_job`

-- **Description:** sets the Wallaroo confidential client to be used for this job

-- **Input parameters:**
-- - `CLIENT` (required): The confidential client identifier for Wallaroo authentication.
create or replace procedure dbsdk_v1.wallaroo_set_confidential_client_for_job(client varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set dbsdk_v1.wallaroo_confidential_client = client;
end;

-- ### procedure: `wallaroo_set_confidential_client_forme`

-- **Description:** sets the Wallaroo confidential client to be used for this user profile (persists across jobs)

-- **Input parameters:**
-- - `CLIENT` (required): The confidential client identifier for Wallaroo authentication.
create or replace procedure dbsdk_v1.wallaroo_set_confidential_client_forme(client varchar(1000) ccsid 1208 default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO dbsdk_v1.conf tt USING (
    SELECT CURRENT_USER AS usrprf, client AS wallaroo_confidential_client
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, wallaroo_confidential_client) VALUES (live.usrprf,
      live.wallaroo_confidential_client)
  WHEN MATCHED THEN UPDATE SET (usrprf, wallaroo_confidential_client) = (live.usrprf, live.wallaroo_confidential_client);
end;

-- ### procedure: `wallaroo_set_confidential_client_secret_for_job`

-- **Description:** sets the Wallaroo confidential client secret to be used for this job

-- **Input parameters:**
-- - `CONF_SECRET` (required): The confidential client secret for Wallaroo authentication.
create or replace procedure dbsdk_v1.wallaroo_set_confidential_client_secret_for_job(conf_secret varchar(8000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set dbsdk_v1.wallaroo_confidential_client_secret = conf_secret;
end;

-- ### procedure: `wallaroo_set_confidential_client_secret_forme`

-- **Description:** sets the Wallaroo confidential client secret to be used for this user profile (persists across jobs)

-- **Input parameters:**
-- - `CONF_SECRET` (required): The confidential client secret for Wallaroo authentication.
create or replace procedure dbsdk_v1.wallaroo_set_confidential_client_secret_forme(conf_secret varchar(8000) ccsid 1208 default NULL) 
  MODIFIES SQL DATA
begin
  MERGE INTO dbsdk_v1.conf tt USING (
    SELECT CURRENT_USER AS usrprf, conf_secret AS wallaroo_confidential_client_secret
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, wallaroo_confidential_client_secret) VALUES (live.usrprf,
      live.wallaroo_confidential_client_secret)
  WHEN MATCHED THEN UPDATE SET (usrprf, wallaroo_confidential_client_secret) = (live.usrprf, live.wallaroo_confidential_client_secret);
end;

-- ### function: `wallaroo_get_access_token`

-- **Description:** gets an access token from Wallaroo using OAuth2 client credentials flow

-- **Input parameters:**
-- - `TOKEN_URL` (optional): The token URL for Wallaroo authentication. If not provided, will use configured value.
-- - `CLIENT` (optional): The confidential client identifier. If not provided, will use configured value.
-- - `CLIENT_SECRET` (optional): The confidential client secret. If not provided, will use configured value.

-- **Return type:** 
-- - `varchar(8000) ccsid 1208`

-- **Return value:**
-- - The access token for Wallaroo authentication
create or replace function dbsdk_v1.wallaroo_get_access_token(
  token_url varchar(1000) ccsid 1208 default NULL,
  client varchar(1000) ccsid 1208 default NULL,
  client_secret varchar(8000) ccsid 1208 default NULL
)
  returns varchar(8000) ccsid 1208
  modifies sql data
  not deterministic
  no external action
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  declare fullUrl varchar(1000) ccsid 1208;
  declare confidential_client varchar(1000) ccsid 1208;
  declare confidential_client_secret varchar(8000) ccsid 1208;
  declare response_header clob(32K) ccsid 1208;
  declare response_message clob(2G) ccsid 1208;
  declare response_code int default 500;
  declare http_options varchar(32400) ccsid 1208;
  declare req_body varchar(1000) ccsid 1208;
  declare access_token varchar(8000) ccsid 1208;
  declare basic_auth varchar(8000) ccsid 1208;
  
  -- Get configuration values using the utility functions
  set fullUrl = dbsdk_v1.wallaroo_get_token_url(token_url);
  set confidential_client = dbsdk_v1.wallaroo_get_confidential_client(client);
  set confidential_client_secret = dbsdk_v1.wallaroo_get_confidential_client_secret(client_secret);
  
  -- Validate required parameters
  if (fullUrl is null or confidential_client is null or confidential_client_secret is null) then
    return null;
  end if;
  
  -- Create Basic Auth header (Base64 encoding of client:secret)
  set basic_auth = systools.base64encode(confidential_client concat ':' concat confidential_client_secret);
  
  -- Set HTTP options with Basic Authentication and SSL options
  set http_options = json_object(
    'ioTimeout': 2000000,
    'sslTolerate': 'true',
    'headers': json_object(
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Basic ' concat basic_auth
    )
  );
  
  -- Build the request body for OAuth2 client credentials grant
  set req_body = 'grant_type=client_credentials';
  
  -- Make the API call
  select response_message, response_http_header
  into response_message, response_header
  from table(qsys2.http_post_verbose(
                fullUrl,
                req_body,
                http_options));
  
  -- Get HTTP status code
  set response_code = json_value(response_header, '$.HTTP_STATUS_CODE');
  
  -- Process the response
  if (response_code >= 200 and response_code < 300) then
    -- Extract the access_token from the JSON response
    set access_token = json_value(response_message, '$.access_token' returning varchar(8000) ccsid 1208);
    return access_token;
  end if;
  
  return null;
end;














