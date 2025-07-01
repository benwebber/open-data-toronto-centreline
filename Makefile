DATA := $(shell find data -type f)

centreline.db: data.db centreline.sql
	sqlite3 $@ -cmd "ATTACH 'data.db' AS data" <centreline.sql

centreline.db.gz: centreline.db
	gzip --force --keep $<

data.db: data.sql $(DATA)
	./bin/load $@ $< data/

SHA256SUMS: centreline.db.gz
	sha256sum $< >SHA256SUMS

requirements.txt: pyproject.toml
	uv pip compile $< >$@

.PHONY: clean
clean:
	$(RM) centreline.db
