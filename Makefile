DATA := $(shell find data -type f)

centreline.db: $(DATA)
	sqlite3 $@ <centreline.sql
	./bin/load $@ data/

centreline.db.gz: centreline.db
	gzip --keep $<

.PHONY: clean
clean:
	$(RM) centreline.db
