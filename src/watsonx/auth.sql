
-- ## Authorization functions
--
-- ### function: `watsonx_authenticate`

-- Description: authenticates to the watsonx service and acquires an access token.
-- 
-- Return type: 
-- - `char(1) ccsid 1208`
-- 
-- Return value:
-- - Either `Y` or `N`, depending on whether the authentication was successful.
create or replace function watsonx.wx_authenticate() 
  returns char(1) ccsid 1208
  modifies sql data
  not deterministic
  no external action
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  declare expiration_seconds integer;
  declare needsNewToken char(1) default 'Y';
  declare successful char(1) ccsid 1208 default 'N';
  declare bearer_token varchar(8192) ccsid 1208;

  set needsNewToken = watsonx.wx_ShouldGetNewToken();

  if (needsNewToken = 'Y') then 
    --
    -- Acquire the Watsonx "Bearer" token, that allows us to ask Watsonx questions for a period of time
    --    
    select "expires_in", "access_token" into expiration_seconds, bearer_token
      from json_table(QSYS2.HTTP_POST(
        'https://iam.cloud.ibm.com/identity/token',
        'grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=' concat watsonx.wx_apikey,
        json_object('headers': json_object('Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json'))
      ), 'lax $'
      columns(
        "expires_in" integer,
        "access_token" varchar(8192) ccsid 1208
      ));
      
    call watsonx.wx_setBearerTokenForJob(bearer_token, expiration_seconds);
    if (bearer_token is not null) then
      set successful = 'Y';
    end if;
  else
    -- We already have a valid token
    set successful = 'Y';
  end if;

  return successful;
end;