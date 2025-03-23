
-- WIP
create or replace function watsonx.kafka_publish(msgdata varchar(32000) ccsid 1208 default NULL, topic varchar(1000) ccsid 1208 default NULL, key varchar(1000) ccsid 1208 default NULL)
  RETURNS TABLE(output VARCHAR(32000) ccsid 1208 )
  modifies sql data
  not deterministic
  no external action
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  declare fullUrl varchar(32500) ccsid 1208 default NULL;
  declare http_options varchar(32400) ccsid 1208 default '{"header":"Content-Type,application/vnd.kafka.json.v2+json" ,
                         "header":"Accept,application/vnd.kafka.v2+json" 
                         }';
  set fullUrl = watsonx.kafka_getprotocol() concat '://' concat watsonx.kafka_getbroker() concat ':' concat watsonx.kafka_getport() concat '/topics/' concat topic;
  


  return SELECT ELEMENT as response
    FROM TABLE (
            SYSTOOLS.SPLIT(
                    JSON_VALUE(QSYS2.HTTP_POST(
                        fullUrl,
                        json_object('records': json_array(json_object('key': key, 'value':msgdata))),
                        http_options), 
                    '$.response'),'
'));
end;