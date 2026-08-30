CREATE TABLE IF NOT EXISTS scores (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id TEXT NOT NULL UNIQUE CHECK(length(session_id) BETWEEN 16 AND 64),
  nickname TEXT NOT NULL CHECK(length(nickname) BETWEEN 1 AND 16),
  age INTEGER NOT NULL CHECK(age BETWEEN 5 AND 7),
  score INTEGER NOT NULL CHECK(score BETWEEN 0 AND 2000),
  completion_time_ms INTEGER NOT NULL CHECK(completion_time_ms BETWEEN 10000 AND 3600000),
  correct_answers INTEGER NOT NULL CHECK(correct_answers BETWEEN 0 AND 10),
  best_streak INTEGER NOT NULL CHECK(best_streak BETWEEN 0 AND 10),
  created_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_scores_leaderboard
  ON scores(age, created_at, score DESC, completion_time_ms ASC);

CREATE INDEX IF NOT EXISTS idx_scores_player_best
  ON scores(age, nickname COLLATE NOCASE, score DESC, completion_time_ms ASC, created_at ASC);
