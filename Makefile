DATA := $(shell find data -type f)

centreline.db: $(DATA)
	sqlite3 $@ <centreline.sql
	./bin/load $@ data/

centreline.db.gz: centreline.db
	gzip --force --keep $<

SHA256SUMS: centreline.db.gz
	sha256sum $< >SHA256SUMS

requirements.txt: pyproject.toml
	uv pip compile $< >$@

.PHONY: clean
clean:
	$(RM) centreline.db
