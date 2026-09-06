# Logic Lab Leaderboard Worker

Cloudflare Worker + D1 backend for the Number Adventure and Memory Quest
leaderboards. It stores only nickname and game-result metrics together with a
server-generated timestamp. It never accepts or stores location, email, birth
date, or other child-identifying data.

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

The complete API contract, payload validation, response examples, ranking rules,
privacy notes, and endpoint maintenance checklist live in [`API.md`](API.md).
Whenever an endpoint changes, update that document in the same change and run:

```bash
npm run verify
```

Visitor counters contain only a fixed scope and an aggregate count. No visitor
identifier, IP address, location, user agent, or event history is stored in D1.
The `site` counter increments once per portfolio load, and a mini-app counter
increments whenever that app is opened.

Ranking order is score descending, completion time ascending, then the earlier
server timestamp. All D1 queries use bound prepared-statement parameters.
