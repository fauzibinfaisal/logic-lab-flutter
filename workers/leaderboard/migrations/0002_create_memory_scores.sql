CREATE TABLE IF NOT EXISTS memory_scores (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id TEXT NOT NULL UNIQUE CHECK(length(session_id) BETWEEN 16 AND 64),
  nickname TEXT NOT NULL CHECK(length(nickname) BETWEEN 1 AND 16),
  score INTEGER NOT NULL CHECK(score BETWEEN 0 AND 100000000),
  stage_reached INTEGER NOT NULL CHECK(stage_reached BETWEEN 1 AND 999),
  pairs_found INTEGER NOT NULL CHECK(pairs_found BETWEEN 0 AND 10000),
  accuracy_permille INTEGER NOT NULL CHECK(accuracy_permille BETWEEN 0 AND 1000),
  remaining_time_ms INTEGER NOT NULL CHECK(remaining_time_ms BETWEEN 0 AND 3600000),
  fastest_stage_ms INTEGER NOT NULL CHECK(fastest_stage_ms BETWEEN 0 AND 3600000),
  duration_ms INTEGER NOT NULL CHECK(duration_ms BETWEEN 1000 AND 86400000),
  created_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_memory_scores_leaderboard
  ON memory_scores(
    created_at,
    score DESC,
    stage_reached DESC,
    pairs_found DESC,
    accuracy_permille DESC,
    remaining_time_ms DESC,
    fastest_stage_ms ASC
  );

CREATE INDEX IF NOT EXISTS idx_memory_scores_player_best
  ON memory_scores(
    nickname COLLATE NOCASE,
    score DESC,
    stage_reached DESC,
    created_at ASC
  );
