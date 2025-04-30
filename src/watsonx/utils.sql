
-- ## Utility functions

create or replace function dbsdk_v1.GetUrl(route varchar(1000))
  returns varchar(256) ccsid 1208
begin
  declare finalUrl varchar(256) ccsid 1208;

  set finalUrl = 'https://' concat dbsdk_v1.wx_region concat '.ml.cloud.ibm.com/ml/v1' concat route;

  if (dbsdk_v1.wx_apiVersion is not null and dbsdk_v1.wx_apiVersion != '') then
    set finalUrl = finalUrl concat '?version=' concat dbsdk_v1.wx_apiVersion;
  end if;

  return finalUrl;
end;

-- #### **Function:** `watsonx_SetApiKeyForJob`
-- 
-- **Description:** Sets the watsonx API key to be used for the current job
-- 
-- **Input parameters:**
-- - `APIKEY` (required): The API key.
create or replace procedure dbsdk_v1.wx_SetApiKeyForJob(apikey varchar(100))
  program type sub
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  set dbsdk_v1.wx_apikey = apikey;
end;

-- #### **Function:** `watsonx_SetProjectIdForJob`
-- 
-- **Description:** Sets the watsonx project ID to be used for the current job
-- 
-- **Input parameters:**
-- - `PROJECTID` (required): The project ID.
create or replace procedure dbsdk_v1.wx_SetProjectIdForJob(projectid varchar(100))
  program type sub
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  set dbsdk_v1.wx_projectid = projectid;
end;

create or replace procedure dbsdk_v1.wx_SetBearerTokenForJob(bearer_token varchar(10000), expires integer)
  modifies sql data
  program type sub
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  set dbsdk_v1.wx_JobBearerToken = bearer_token;
  -- We subtract 60 seconds from the expiration time to ensure we don't cut it too close
  set dbsdk_v1.wx_JobTokenExpires = current timestamp + expires seconds - 60 seconds;
end;

create or replace function dbsdk_v1.wx_ShouldGetNewToken() 
  returns char(1)
begin
  if (dbsdk_v1.wx_JobBearerToken is null) then
    return 'Y';
  end if;
  if (dbsdk_v1.wx_JobTokenExpires is null) then
    return 'Y';
  end if;
  if (current timestamp > dbsdk_v1.wx_JobTokenExpires) then
    return 'Y';
  end if;
  return 'N';
end;

-- #### **Function:** `watsonx_logoutJob`
-- 
-- **Description:** Log out from teh current job.
-- 
create or replace procedure dbsdk_v1.wx_logoutJob()
  program type sub
  modifies sql data
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  set dbsdk_v1.wx_JobBearerToken = null;
  set dbsdk_v1.wx_JobTokenExpires = null;
end;

create or replace function dbsdk_v1.parameters(
  decoding_method varchar(20) default null,
  temperature numeric(1, 1) default null,
  time_limit integer default null,
  top_p numeric(1, 1) default null,
  top_k integer default null,
  random_seed integer default null,
  repetition_penalty numeric(1, 1) default null,
  truncate_input_tokens integer default null,
  min_new_tokens integer default null,
  max_new_tokens integer default null,
  typical_p numeric(1, 1) default null
) 
  returns varchar(1000) ccsid 1208
begin
  return json_object(
    'decoding_method': decoding_method,
    'temperature': temperature format json,
    'time_limit': time_limit format json,
    'top_p': top_p format json, 
    'top_k': top_k format json, 
    'random_seed': random_seed format json, 
    'repetition_penalty': repetition_penalty format json, 
    'truncate_input_tokens': truncate_input_tokens format json,
    'min_new_tokens': min_new_tokens format json, 
    'max_new_tokens': max_new_tokens format json, 
    'typical_p': typical_p format json
    ABSENT ON NULL
  );
end;