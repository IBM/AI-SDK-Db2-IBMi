
create or replace procedure watsonx.GetModels()
  DYNAMIC RESULT SETS 1
  program type sub
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  declare apiResult clob(50000) ccsid 1208;

  DECLARE ResultSet CURSOR FOR
    select * from JSON_TABLE(QSYS2.HTTP_GET(
      watsonx.geturl('/foundation_model_specs')
    ), '$.resources[*]'
        COLUMNS(
          model_id VARCHAR(128) PATH '$.model_id',
          label VARCHAR(128) PATH '$.label',
          provider VARCHAR(128) PATH '$.provider',
          short_description VARCHAR(512) PATH '$.short_description'
        )
      ) x;

  OPEN ResultSet;
  SET RESULT SETS CURSOR ResultSet;
end;