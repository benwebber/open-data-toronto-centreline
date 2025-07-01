# Toronto Centreline

This is a [Git scraping](https://simonwillison.net/series/git-scraping/) mirror of Toronto's [Centreline](https://open.toronto.ca/dataset/toronto-centreline-tcl/) data set.

> The Toronto Centreline is a data set of linear features representing streets, walkways, rivers, railways, highways and administrative boundaries within the City of Toronto.

## Database

You can download the [latest version](https://github.com/benwebber/open-data-toronto-centreline/releases/latest) of this data as an SQLite database from the [releases](https://github.com/benwebber/open-data-toronto-centreline/releases) page.

You can explore the database using a pre-built [Datasette](https://datasette.io/) instance.
Run the latest published image with Docker:

```
docker run -p 8000:8000 ghcr.io/benwebber/open-data-toronto-centreline:latest
```

Or build the database locally and run it with Docker Compose:

```
make centreline.db
docker compose up
```

## Licence

The City of Toronto makes this data available under the terms of [Open Government Licence – Toronto](https://open.toronto.ca/open-data-license/).
