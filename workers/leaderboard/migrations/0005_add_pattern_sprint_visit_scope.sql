CREATE TABLE visit_counters_next (
  scope TEXT PRIMARY KEY CHECK(
    scope IN (
      'site',
      'qibla',
      'ble-packet-lab',
      'number-adventure',
      'memory-quest',
      'pattern-sprint'
    )
  ),
  visit_count INTEGER NOT NULL DEFAULT 0 CHECK(visit_count >= 0),
  updated_at INTEGER NOT NULL
);

INSERT INTO visit_counters_next(scope, visit_count, updated_at)
  SELECT scope, visit_count, updated_at FROM visit_counters;

INSERT INTO visit_counters_next(scope, visit_count, updated_at)
  VALUES ('pattern-sprint', 0, 0);

DROP TABLE visit_counters;

ALTER TABLE visit_counters_next RENAME TO visit_counters;
