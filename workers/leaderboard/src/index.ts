interface Env {
  DB: D1Database;
  ALLOWED_ORIGINS: string;
}

interface ScoreSubmission {
  sessionId: string;
  nickname: string;
  age: number;
  score: number;
  completionTimeMs: number;
  correctAnswers: number;
  bestStreak: number;
}

interface ScoreRow {
  nickname: string;
  age: number;
  score: number;
  completion_time_ms: number;
  correct_answers: number;
  best_streak: number;
  created_at: number;
}

const jsonHeaders = {
  "Content-Type": "application/json; charset=utf-8",
  "X-Content-Type-Options": "nosniff",
  "Cache-Control": "no-store",
};

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const corsHeaders = createCorsHeaders(request, env);

    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: corsHeaders });
    }

    if (!isOriginAllowed(request, env)) {
      return json({ error: "Origin is not allowed." }, 403, corsHeaders);
    }

    try {
      if (request.method === "GET" && url.pathname === "/health") {
        return json({ status: "ok" }, 200, corsHeaders);
      }
      if (request.method === "POST" && url.pathname === "/api/v1/scores") {
        return submitScore(request, env, corsHeaders);
      }
      if (request.method === "GET" && url.pathname === "/api/v1/leaderboard") {
        return getLeaderboard(url, env, corsHeaders);
      }
      return json({ error: "Not found." }, 404, corsHeaders);
    } catch (error) {
      console.error("Unhandled leaderboard error", error);
      return json({ error: "Service temporarily unavailable." }, 500, corsHeaders);
    }
  },
};

async function submitScore(
  request: Request,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const contentLength = Number(request.headers.get("content-length") ?? "0");
  if (contentLength > 2048) {
    return json({ error: "Request is too large." }, 413, corsHeaders);
  }

  let raw: unknown;
  try {
    raw = await request.json();
  } catch {
    return json({ error: "Invalid JSON." }, 400, corsHeaders);
  }

  const validation = validateSubmission(raw);
  if (!validation.ok) {
    return json({ error: validation.error }, 400, corsHeaders);
  }

  const score = validation.value;
  const result = await env.DB.prepare(
    `INSERT INTO scores (
      session_id, nickname, age, score, completion_time_ms,
      correct_answers, best_streak, created_at
    ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)
    ON CONFLICT(session_id) DO NOTHING`,
  )
    .bind(
      score.sessionId,
      score.nickname,
      score.age,
      score.score,
      score.completionTimeMs,
      score.correctAnswers,
      score.bestStreak,
      Date.now(),
    )
    .run();

  return json({ accepted: result.meta.changes > 0 }, 202, corsHeaders);
}

async function getLeaderboard(
  url: URL,
  env: Env,
  corsHeaders: Headers,
): Promise<Response> {
  const age = Number(url.searchParams.get("age"));
  const period = url.searchParams.get("period") ?? "today";
  const requestedLimit = Number(url.searchParams.get("limit") ?? "50");
  const limit = Number.isInteger(requestedLimit)
    ? Math.min(Math.max(requestedLimit, 1), 100)
    : 50;

  if (![5, 6, 7].includes(age) || !["today", "week", "all"].includes(period)) {
    return json({ error: "Invalid leaderboard filters." }, 400, corsHeaders);
  }

  const since = periodStart(period);
  const result = await env.DB.prepare(
    `WITH player_best AS (
      SELECT
        nickname, age, score, completion_time_ms, correct_answers,
        best_streak, created_at,
        ROW_NUMBER() OVER (
          PARTITION BY lower(nickname), age
          ORDER BY score DESC, completion_time_ms ASC, created_at ASC
        ) AS attempt_rank
      FROM scores
      WHERE age = ?1 AND created_at >= ?2
    )
    SELECT nickname, age, score, completion_time_ms, correct_answers,
           best_streak, created_at
    FROM player_best
    WHERE attempt_rank = 1
    ORDER BY score DESC, completion_time_ms ASC, created_at ASC
    LIMIT ?3`,
  )
    .bind(age, since, limit)
    .all<ScoreRow>();

  const entries = result.results.map((row, index) => ({
    rank: index + 1,
    nickname: row.nickname,
    age: row.age,
    score: row.score,
    completionTimeMs: row.completion_time_ms,
    correctAnswers: row.correct_answers,
    bestStreak: row.best_streak,
    completedAt: new Date(row.created_at).toISOString(),
  }));

  return json({ age, period, entries }, 200, corsHeaders);
}

function validateSubmission(
  raw: unknown,
): { ok: true; value: ScoreSubmission } | { ok: false; error: string } {
  if (typeof raw !== "object" || raw === null || Array.isArray(raw)) {
    return { ok: false, error: "Body must be an object." };
  }
  const value = raw as Record<string, unknown>;
  const nickname = typeof value.nickname === "string" ? value.nickname.trim() : "";
  const sessionId = typeof value.sessionId === "string" ? value.sessionId : "";

  if (!/^[\p{L}\p{N}_ -]{1,16}$/u.test(nickname)) {
    return { ok: false, error: "Nickname must be 1–16 safe characters." };
  }
  if (!/^[A-Za-z0-9-]{16,64}$/.test(sessionId)) {
    return { ok: false, error: "Invalid session identifier." };
  }

  const fields: Array<[keyof ScoreSubmission, number, number]> = [
    ["age", 5, 7],
    ["score", 0, 2000],
    ["completionTimeMs", 10000, 3600000],
    ["correctAnswers", 0, 10],
    ["bestStreak", 0, 10],
  ];
  for (const [field, minimum, maximum] of fields) {
    const fieldValue = value[field];
    if (!Number.isInteger(fieldValue) || (fieldValue as number) < minimum || (fieldValue as number) > maximum) {
      return { ok: false, error: `Invalid ${field}.` };
    }
  }

  return {
    ok: true,
    value: {
      sessionId,
      nickname,
      age: value.age as number,
      score: value.score as number,
      completionTimeMs: value.completionTimeMs as number,
      correctAnswers: value.correctAnswers as number,
      bestStreak: value.bestStreak as number,
    },
  };
}

function periodStart(period: string): number {
  const now = new Date();
  if (period === "all") return 0;
  if (period === "week") return now.getTime() - 7 * 24 * 60 * 60 * 1000;
  return new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();
}

function isOriginAllowed(request: Request, env: Env): boolean {
  const origin = request.headers.get("Origin");
  if (!origin) return true;
  return allowedOrigins(env).has(origin);
}

function createCorsHeaders(request: Request, env: Env): Headers {
  const headers = new Headers({
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Max-Age": "86400",
    Vary: "Origin",
  });
  const origin = request.headers.get("Origin");
  if (origin && allowedOrigins(env).has(origin)) {
    headers.set("Access-Control-Allow-Origin", origin);
  }
  return headers;
}

function allowedOrigins(env: Env): Set<string> {
  return new Set(env.ALLOWED_ORIGINS.split(",").map((item) => item.trim()));
}

function json(body: unknown, status: number, corsHeaders: Headers): Response {
  const headers = new Headers(corsHeaders);
  for (const [key, value] of Object.entries(jsonHeaders)) headers.set(key, value);
  return new Response(JSON.stringify(body), { status, headers });
}
