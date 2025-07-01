DROP TABLE IF EXISTS feature;
CREATE TABLE feature (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  name_type TEXT NOT NULL,
  name_dir TEXT NOT NULL,
  name_full TEXT NOT NULL,
  name_full_legal TEXT NOT NULL,
  type TEXT NOT NULL
);
INSERT OR IGNORE INTO feature (
  id,
  name,
  name_dir,
  name_type,
  name_full,
  name_full_legal,
  type
)
WITH data_cte AS (
  SELECT
    geojson->>'$.properties' AS p,
    geojson->>'$.geometry' AS g
  FROM
    data.data
)
SELECT
  p->>'$.LINEAR_NAME_ID',
  p->>'$.LINEAR_NAME',
  iif(p->>'$.LINEAR_NAME_DIR' = 'None', '', p->>'$.LINEAR_NAME_DIR'),
  p->>'$.LINEAR_NAME_TYPE',
  p->>'$.LINEAR_NAME_FULL',
  p->>'$.LINEAR_NAME_FULL_LEGAL',
  p->>'$.FEATURE_CODE_DESC'
FROM
  data_cte
;
CREATE INDEX idx_feature_name_type ON feature (name_type);
CREATE INDEX idx_feature_type ON feature (type);
CREATE VIRTUAL TABLE IF NOT EXISTS feature_fts USING fts5 (name_full, name_full_legal, content="feature");
INSERT INTO feature_fts (rowid, name_full, name_full_legal) SELECT rowid, name_full, name_full_legal FROM feature;

DROP TABLE IF EXISTS segment;
CREATE TABLE segment (
  id TEXT NOT NULL PRIMARY KEY,
  feature_id TEXT NOT NULL,
  jurisdiction TEXT NOT NULL,
  intersection1_id TEXT NOT NULL,
  intersection2_id TEXT NOT NULL,
  oneway TEXT NOT NULL,
  num_odd_low INTEGER NULL,
  num_even_low INTEGER NULL,
  num_odd_high INTEGER NULL,
  num_even_high INTEGER NULL,
  geometry TEXT NOT NULL,
  FOREIGN KEY (feature_id) REFERENCES feature (id)
);
INSERT OR IGNORE INTO segment (
  id,
  feature_id,
  intersection1_id,
  intersection2_id,
  jurisdiction,
  oneway,
  num_odd_low,
  num_even_low,
  num_odd_high,
  num_even_high,
  geometry
)
WITH data_cte AS (
  SELECT
    geojson->>'$.properties' AS p,
    geojson->>'$.geometry' AS g
  FROM
    data.data
)
SELECT
  p->>'$.CENTRELINE_ID',
  p->>'$.LINEAR_NAME_ID',
  p->>'$.FROM_INTERSECTION_ID',
  p->>'$.TO_INTERSECTION_ID',
  p->>'$.JURISDICTION',
  iif(p->>'$.ONEWAY_DIR_CODE_DESC' = 'None', '', p->>'$.ONEWAY_DIR_CODE_DESC'),
  p->>'$.LOW_NUM_ODD',
  p->>'$.LOW_NUM_EVEN',
  p->>'$.HIGH_NUM_ODD',
  p->>'$.HIGH_NUM_EVEN',
  g
FROM
  data_cte
;
CREATE INDEX idx_segment_feature_id ON segment (feature_id);
CREATE INDEX idx_segment_jurisdiction ON segment (jurisdiction);
CREATE INDEX idx_segment_oneway ON segment (oneway);

DROP TABLE IF EXISTS point;
CREATE TABLE point (
  feature_id TEXT NOT NULL,
  segment_id TEXT NOT NULL,
  lat REAL NOT NULL,
  lon REAL NOT NULL,
  pos INTEGER NOT NULL,
  intersection_id TEXT NULL,
  geometry AS (
    json_object(
      'type', 'Point',
      'coordinates', json_array(lon, lat)
    )
  ),
  FOREIGN KEY (feature_id) REFERENCES feature (id),
  FOREIGN KEY (segment_id) REFERENCES segment (id),
  PRIMARY KEY (feature_id, segment_id, pos)
);
INSERT INTO point (
  feature_id,
  segment_id,
  lat,
  lon,
  pos
)
WITH data_cte AS (
  SELECT
    geojson->>'$.properties' AS p,
    geojson->>'$.geometry' AS g
  FROM
    data.data
)
SELECT
  p->>'$.LINEAR_NAME_ID',
  p->>'$.CENTRELINE_ID',
  json_each.value->>'$[1]',
  json_each.value->>'$[0]',
  json_each.key
FROM
  data_cte,
  json_each(g, '$.coordinates[0]')
;
CREATE INDEX idx_point_lat_lon ON point (lat, lon);

UPDATE point
SET
  intersection_id = t.intersection_id
FROM (
  SELECT
    feature_id,
    id AS segment_id,
    0 AS pos,
    intersection1_id AS intersection_id
  FROM
    segment
  UNION
  SELECT
    feature_id,
    id AS segment_id,
    json_array_length(geometry->>'$.coordinates[0]') - 1 AS pos,
    intersection2_id AS intersection_id
  FROM
    segment
) t
WHERE
  point.feature_id = t.feature_id
  AND point.segment_id = t.segment_id
  AND point.pos = t.pos
;
CREATE INDEX idx_point_intersection_id ON point (intersection_id);
