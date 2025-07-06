DATA := $(shell find data -type f)
DB := centreline.db

.DEFAULT_GOAL := dist

$(DB): data.db sql/centreline.sql
	sqlite3 $@ -cmd "ATTACH 'data.db' AS data" <sql/centreline.sql

data.db: sql/data.sql $(DATA)
	./bin/load $@ sql/data.sql data/

%.gz: $(DB)
	gzip --force --keep --stdout $< >$@

requirements.txt:
	uv pip compile pyproject.toml >requirements.txt

.PHONY: clean
clean:
	$(RM) -r $(DB) dist/

.PHONY: dist
dist:
	mkdir -p dist
	make dist/$(DB).gz
	cd dist && sha256sum *.gz >SHA256SUMS

.PHONY: fetch
fetch:
	./bin/fetch
