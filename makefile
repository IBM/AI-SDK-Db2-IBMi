
SCHEMA=dbsdk_v1
OBJS =  $(shell getmaketargets.sh)

all: buildts.txt

/qsys.lib/$(SCHEMA).lib:
	-system -s "RUNSQL SQL('CREATE SCHEMA $(SCHEMA)') COMMIT(*NONE)" && echo created schema $(SCHEMA)

buildts.txt: /qsys.lib/$(SCHEMA).lib  $(OBJS)
	date > buildts.txt
	
clean:
	rm -r .build

.build/%.done: %
	runsql.sh $(SCHEMA) $<