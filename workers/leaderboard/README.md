# Logic Lab Leaderboard Worker

Cloudflare Worker + D1 backend for the Number Adventure leaderboard. It stores
only a nickname, age category, score, completion duration, game stats, and the
server-generated completion timestamp. It never accepts or stores location,
email, birth date, or other child-identifying data.

## Setup

```bash
cd workers/leaderboard
npm install
npx wrangler d1 create logic-lab-leaderboard
```

Copy the returned database ID into `wrangler.toml`, then configure
`ALLOWED_ORIGINS` with the exact GitHub Pages origin.

```bash
npm run db:migrate:remote
npm run deploy
```

Build Flutter Web with the public Worker URL (this is not a secret):

```bash
flutter build web --release \
  --dart-define=LEADERBOARD_API_URL=https://logic-lab-leaderboard.<account>.workers.dev
```

For local development, run `npm run db:migrate:local && npm run dev`, then use:

```bash
flutter run -d chrome \
  --dart-define=LEADERBOARD_API_URL=http://127.0.0.1:8787
```

## API

- `POST /api/v1/scores` — validates and submits one completed session.
- `GET /api/v1/leaderboard?age=6&period=today&limit=50` — returns ranked player bests.
- `GET /health` — health check.

Ranking order is score descending, completion time ascending, then the earlier
server timestamp. All D1 queries use bound prepared-statement parameters.
