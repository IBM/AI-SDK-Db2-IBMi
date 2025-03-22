
SCHEMA=watsonx

all: $(SCHEMA).schema conf.sql ollama/utils.sql watsonx/utils.sql watsonx/auth.sql watsonx/models.sql watsonx/generate.sql

%.schema:
	-system -s "RUNSQL SQL('CREATE SCHEMA $*') COMMIT(*NONE)"

%.sql: src/%.sql
	system "RUNSQLSTM SRCSTMF('$<') COMMIT(*NONE) NAMING(*SQL) DFTRDBCOL($(SCHEMA))"

watsonx/%.sql: src/watsonx/%.sql
	system "RUNSQLSTM SRCSTMF('$<') COMMIT(*NONE) NAMING(*SQL) DFTRDBCOL($(SCHEMA))"

ollama/%.sql: src/ollama/%.sql
	system "RUNSQLSTM SRCSTMF('$<') COMMIT(*NONE) NAMING(*SQL) DFTRDBCOL($(SCHEMA))"