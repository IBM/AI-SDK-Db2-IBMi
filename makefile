
SCHEMA=watsonx

all: $(SCHEMA).schema conf.sql auth.sql models.sql generate.sql

%.schema:
	-system -s "RUNSQL SQL('CREATE SCHEMA $*') COMMIT(*NONE)"

%.sql: src/%.sql
	system "RUNSQLSTM SRCSTMF('$<') COMMIT(*NONE) NAMING(*SQL) DFTRDBCOL($(SCHEMA))"