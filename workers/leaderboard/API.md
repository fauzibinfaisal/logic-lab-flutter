# Logic Lab API Contract

Dokumen ini adalah referensi utama untuk seluruh endpoint Cloudflare Worker
Logic Lab. Setiap penambahan, penghapusan, perubahan path, payload, respons,
validasi, atau aturan ranking endpoint wajib diperbarui di dokumen ini dalam
perubahan yang sama.

## Base URL dan konfigurasi client

- Production: `https://logic-lab-leaderboard.logic-lab-leaderboard.workers.dev`
- Local development: `http://127.0.0.1:8787`
- Flutter membaca base URL dari compile-time variable `LEADERBOARD_API_URL`.
- URL Worker bersifat publik dan bukan secret. Jangan menaruh API token atau
  credential Cloudflare di Flutter Web.
- Semua respons API menggunakan JSON, kecuali preflight `OPTIONS` yang tidak
  memiliki body.

Contoh build Flutter Web:

```bash
flutter build web --release \
  --dart-define=LEADERBOARD_API_URL=https://logic-lab-leaderboard.logic-lab-leaderboard.workers.dev
```

## Ringkasan endpoint

| Method | Path | Kegunaan |
| --- | --- | --- |
| `GET` | `/health` | Memeriksa apakah Worker aktif. |
| `POST` | `/api/v1/scores` | Mengirim hasil Number Adventure. |
| `GET` | `/api/v1/leaderboard` | Mengambil leaderboard Number Adventure. |
| `POST` | `/api/v1/memory/scores` | Mengirim hasil Memory Quest. |
| `GET` | `/api/v1/memory/leaderboard` | Mengambil leaderboard Memory Quest. |
| `POST` | `/api/v1/visits` | Menaikkan satu aggregate visit counter. |
| `GET` | `/api/v1/visits` | Mengambil seluruh aggregate visit counter. |

## Konvensi umum

Request dengan body harus menggunakan `Content-Type: application/json`.
Timestamp hasil game dibuat oleh server dalam Unix milliseconds, lalu dikirim
ke client sebagai ISO 8601 pada field `completedAt`.

Header respons penting:

- `Content-Type: application/json; charset=utf-8`
- `Cache-Control: no-store`
- `X-Content-Type-Options: nosniff`

CORS hanya mengizinkan origin yang tercantum persis di `ALLOWED_ORIGINS` pada
`wrangler.toml`. Request tanpa header `Origin`, seperti health check server,
tetap diizinkan. Preflight `OPTIONS` menghasilkan status `204`.

## Health check

### `GET /health`

Response `200`:

```json
{
  "status": "ok"
}
```

## Number Adventure

### `POST /api/v1/scores`

Menyimpan satu hasil sesi Number Adventure. Body maksimal 2,048 bytes.

Request:

```json
{
  "sessionId": "session-1234567890",
  "nickname": "Alya",
  "age": 6,
  "score": 850,
  "completionTimeMs": 92500,
  "correctAnswers": 9,
  "bestStreak": 5
}
```

Validasi:

| Field | Aturan |
| --- | --- |
| `sessionId` | 16–64 karakter; hanya huruf ASCII, angka, dan tanda hubung. |
| `nickname` | 1–16 karakter; huruf Unicode, angka, spasi, `_`, atau `-`. Spasi tepi dihapus. |
| `age` | Integer `5`, `6`, atau `7`. |
| `score` | Integer `0`–`2000`. |
| `completionTimeMs` | Integer `10000`–`3600000`. |
| `correctAnswers` | Integer `0`–`10`. |
| `bestStreak` | Integer `0`–`10`. |

Response `202` untuk sesi baru:

```json
{
  "accepted": true
}
```

`sessionId` bersifat idempotent. Pengiriman ulang ID yang sama tetap mendapat
status `202`, tetapi menghasilkan `{"accepted":false}` dan tidak membuat row
baru.

### `GET /api/v1/leaderboard`

Query parameters:

| Parameter | Wajib | Aturan |
| --- | --- | --- |
| `age` | Ya | `5`, `6`, atau `7`. |
| `period` | Tidak | `today`, `week`, atau `all`; default `today`. |
| `limit` | Tidak | Integer; dinormalisasi ke rentang `1`–`100`; default `50` bila tidak valid. |

Contoh:

```text
GET /api/v1/leaderboard?age=6&period=all&limit=50
```

Response `200`:

```json
{
  "age": 6,
  "period": "all",
  "entries": [
    {
      "rank": 1,
      "nickname": "Alya",
      "age": 6,
      "score": 850,
      "completionTimeMs": 92500,
      "correctAnswers": 9,
      "bestStreak": 5,
      "completedAt": "2026-09-05T08:15:30.000Z"
    }
  ]
}
```

Hanya percobaan terbaik untuk kombinasi `lower(nickname)` dan `age` yang
ditampilkan. Urutan ranking:

1. `score` tertinggi.
2. `completionTimeMs` tercepat.
3. timestamp server paling awal.

## Memory Quest

### `POST /api/v1/memory/scores`

Menyimpan satu hasil sesi Memory Quest Solo. Body maksimal 2,048 bytes.

Request:

```json
{
  "sessionId": "memory-1234567890",
  "nickname": "Raka",
  "score": 12800,
  "stageReached": 12,
  "pairsFound": 46,
  "accuracyPermille": 925,
  "remainingTimeMs": 14000,
  "fastestStageMs": 6200,
  "durationMs": 245000
}
```

Validasi:

| Field | Aturan |
| --- | --- |
| `sessionId` | 16–64 karakter; hanya huruf ASCII, angka, dan tanda hubung. |
| `nickname` | 1–16 karakter; huruf Unicode, angka, spasi, `_`, atau `-`. Spasi tepi dihapus. |
| `score` | Integer `0`–`100000000`. |
| `stageReached` | Integer `1`–`999`. |
| `pairsFound` | Integer `0`–`10000`. |
| `accuracyPermille` | Integer `0`–`1000`; `1000` berarti 100%. |
| `remainingTimeMs` | Integer `0`–`3600000`. |
| `fastestStageMs` | Integer `0`–`3600000`; `0` berarti belum ada catatan. |
| `durationMs` | Integer `1000`–`86400000`. |

Response `202`:

```json
{
  "accepted": true
}
```

Seperti Number Adventure, pengiriman ulang `sessionId` menghasilkan
`{"accepted":false}` tanpa membuat row baru.

### `GET /api/v1/memory/leaderboard`

Query parameters:

| Parameter | Wajib | Aturan |
| --- | --- | --- |
| `period` | Tidak | `today`, `week`, atau `all`; default `today`. |
| `limit` | Tidak | Integer; dinormalisasi ke rentang `1`–`100`; default `50` bila tidak valid. |

Contoh:

```text
GET /api/v1/memory/leaderboard?period=week&limit=50
```

Response `200`:

```json
{
  "period": "week",
  "entries": [
    {
      "rank": 1,
      "nickname": "Raka",
      "score": 12800,
      "stageReached": 12,
      "pairsFound": 46,
      "accuracyPermille": 925,
      "remainingTimeMs": 14000,
      "fastestStageMs": 6200,
      "durationMs": 245000,
      "completedAt": "2026-09-05T08:15:30.000Z"
    }
  ]
}
```

Hanya percobaan terbaik per `lower(nickname)` yang ditampilkan. Urutan ranking:

1. `score` tertinggi.
2. `stageReached` tertinggi.
3. `pairsFound` terbanyak.
4. `accuracyPermille` tertinggi.
5. `remainingTimeMs` terbanyak.
6. `fastestStageMs` tercepat; nilai `0` ditempatkan paling akhir.
7. timestamp server paling awal.

## Visit counters

Counter adalah jumlah kunjungan halaman, bukan unique visitor. `site` bertambah
setiap portfolio dimuat, sedangkan counter mini app bertambah setiap app dibuka.

Scope yang didukung:

- `site`
- `qibla`
- `number-adventure`
- `memory-quest`

### `POST /api/v1/visits`

Menaikkan counter scope secara atomik. Body maksimal 256 bytes.

Request:

```json
{
  "scope": "number-adventure"
}
```

Response `200` berisi seluruh counter setelah increment:

```json
{
  "counts": {
    "site": 120,
    "qibla": 31,
    "number-adventure": 54,
    "memory-quest": 28
  }
}
```

### `GET /api/v1/visits`

Mengambil seluruh counter tanpa melakukan increment.

Response `200` memiliki format yang sama dengan response `POST
/api/v1/visits`. Scope yang belum memiliki kunjungan tetap dikembalikan dengan
nilai `0`.

## Error responses

Semua error menggunakan bentuk:

```json
{
  "error": "Pesan error."
}
```

| Status | Arti |
| --- | --- |
| `400` | JSON, field, filter, atau scope tidak valid. |
| `403` | Header `Origin` tidak termasuk dalam `ALLOWED_ORIGINS`. |
| `404` | Kombinasi method dan path tidak dikenal. |
| `413` | Body request melewati batas endpoint. |
| `500` | D1 atau Worker sementara tidak tersedia. |

Flutter client menggunakan timeout 10 detik dan menangani loading, empty, dan
error state di UI. Timeout client tidak menghasilkan status HTTP dari Worker.

## Privasi dan keamanan

- API tidak menerima atau menyimpan lokasi presisi anak, alamat IP, user agent,
  email, tanggal lahir, visitor ID, maupun riwayat kunjungan per orang.
- Visit counter hanya menyimpan fixed scope, total agregat, dan waktu update.
- Nickname dan metrik hasil game disimpan untuk leaderboard; timestamp dibuat
  oleh server dan tidak dipercaya dari client.
- Seluruh query D1 memakai prepared statement dan bound parameters untuk
  mencegah SQL injection.
- Endpoint publik tidak memiliki API secret di Flutter Web. CORS membatasi
  browser origin, tetapi bukan mekanisme autentikasi atau anti-abuse penuh.

## Database dan migrations

| Migration | Tabel | Kegunaan |
| --- | --- | --- |
| `0001_create_scores.sql` | `scores` | Hasil Number Adventure dan index ranking. |
| `0002_create_memory_scores.sql` | `memory_scores` | Hasil Memory Quest dan index ranking. |
| `0003_create_visit_counters.sql` | `visit_counters` | Aggregate site dan mini-app visits. |

Jalankan migration dan deploy dari direktori Worker:

```bash
cd workers/leaderboard
npm install
npm run verify
npm run db:migrate:remote
npm run deploy
```

Untuk development lokal:

```bash
npm run db:migrate:local
npm run dev
```

## Integrasi Flutter

- Number Adventure:
  `lib/mini_apps/edu_fun/data/leaderboard_api_service.dart`
- Memory Quest:
  `lib/mini_apps/memory_quest/data/memory_leaderboard_api.dart`
- Visit counters: `lib/visit_counter/data/visit_counter_api.dart`

## Checklist perubahan endpoint

Jika endpoint berubah:

1. Perbarui implementasi dan validasi di `src/index.ts`.
2. Perbarui path, request, response, status code, dan aturan terkait di
   `API.md` ini.
3. Tambahkan migration D1 baru bila schema berubah; jangan mengedit migration
   yang sudah pernah diterapkan di production.
4. Perbarui Flutter service/repository dan test yang relevan.
5. Jalankan `npm run verify`, Flutter analyze, dan test terkait sebelum deploy.

`npm run verify` akan gagal apabila route `GET` atau `POST` yang terdaftar di
router Worker belum dicantumkan di dokumen ini.
