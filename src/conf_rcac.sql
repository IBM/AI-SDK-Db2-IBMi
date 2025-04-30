alter table dbsdk_v1.CONF activate row access control;
CREATE or replace PERMISSION dbsdk_v1.MYROWONLY ON dbsdk_v1.CONF FOR ROWS WHERE USRPRF = CURRENT_USER ENFORCED
FOR ALL ACCESS ENABLE;