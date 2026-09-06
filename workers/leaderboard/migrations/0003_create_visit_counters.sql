CREATE TABLE IF NOT EXISTS visit_counters (
  scope TEXT PRIMARY KEY CHECK(
    scope IN ('site', 'qibla', 'number-adventure', 'memory-quest')
  ),
  visit_count INTEGER NOT NULL DEFAULT 0 CHECK(visit_count >= 0),
  updated_at INTEGER NOT NULL
);

INSERT OR IGNORE INTO visit_counters(scope, visit_count, updated_at) VALUES
  ('site', 0, 0),
  ('qibla', 0, 0),
  ('number-adventure', 0, 0),
  ('memory-quest', 0, 0);
