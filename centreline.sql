DROP TABLE IF EXISTS feature;
CREATE TABLE feature (
    centreline_id TEXT NOT NULL PRIMARY KEY,
    name AS (geojson->>'$.properties.LINEAR_NAME'),
    name_type AS (
      CASE geojson->>'$.properties.LINEAR_NAME_TYPE'
        WHEN 'None' THEN ''
        ELSE geojson->>'$.properties.LINEAR_NAME_TYPE'
      END
    ),
    name_dir AS (
      CASE geojson->>'$.properties.LINEAR_NAME_DIR'
        WHEN 'None' THEN ''
        ELSE geojson->>'$.properties.LINEAR_NAME_DIR'
      END
    ),
    name_full AS (geojson->>'$.properties.LINEAR_NAME_FULL'),
    name_full_legal AS (geojson->>'$.properties.LINEAR_NAME_FULL_LEGAL'),
    type AS (geojson->>'$.properties.FEATURE_CODE_DESC'),
    oneway AS (geojson->>'$.properties.ONEWAY_DIR_CODE_DESC'),
    jurisdiction AS (geojson->>'$.properties.JURISDICTION'),
    number_low_odd AS (geojson->>'$.properties.LOW_NUM_ODD'),
    number_low_even AS (geojson->>'$.properties.LOW_NUM_EVEN'),
    number_high_odd AS (geojson->>'$.properties.HIGH_NUM_ODD'),
    number_high_even AS (geojson->>'$.properties.HIGH_NUM_EVEN'),
    geometry AS (geojson->>'$.geometry'),
    geojson TEXT NOT NULL
);
CREATE INDEX idx_feature_type ON feature (type);
CREATE INDEX idx_feature_oneway ON feature (oneway);
CREATE INDEX idx_feature_jurisdiction ON feature (jurisdiction);
CREATE VIRTUAL TABLE IF NOT EXISTS feature_fts USING fts5 (name_full, name_full_legal, content="feature");
