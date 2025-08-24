# TOTEM — Social Strength Totems (Technical Product Spec)

## 0) One‑liner

TOTEM is a gym logging app wired to social status. Users join clans, log real workouts, and collectively level up “Totems” (muscle‑group tallies). No avatars, no RPG combat. Pure numbers → public rankings.

---

## 1) Product Overview

**Goal:** Make training volume socially visible and competitive without battles. Every log contributes to the user’s **Personal Portfolio** and the clan’s **Totem Board**. Weekly seasons determine global rankings.

**Platforms:** iOS, Android.

**MVP Pillars:**

1. Workout logging → points by muscle group.
2. Clans → pooled weekly totals → ranked leaderboard.
3. Personal leaderboards and streaks.
4. Shareable summaries (images/text) for social.
5. Premium analytics + clan customization.

---

## 2) Core Concepts & Terminology

**Muscle Groups (canonical):** chest, back, shoulders, arms, legs, core, cardio (engine). Extensible via config.

**Points:** normalized metric derived from sets × reps × weight (strength) and duration × intensity (cardio). See §6.

**Personal Portfolio:** a 7‑vector of cumulative points (rolling 7d, 30d, lifetime).

**Clan:** a team with members, roles, and “Totems” per muscle group.

**Totem:** clan‑level weekly point total per muscle group. Visualized as levels.

**Season:** 1 week default (Mon 00:00 → Sun 23:59 server time), configurable. Resets scoreboards, issues awards, persists history.

---

## 3) User Stories (MVP)

• As a user, I can create an account, create/join a clan, and start logging workouts in under 60 seconds.
• As a user, I can log sets/reps/weight or cardio sessions and see my portfolio update instantly.
• As a user, I can see my rank inside my clan and my clan’s rank globally this week.
• As a clan admin, I can approve requests, set clan description/emblem, and invite users.
• As a user, I keep a streak; streak boosts apply only while consecutive days > 2.
• As a user, I can share a weekly summary image with my Totem contributions and ranks.
• As a subscriber, I get advanced analytics and export (CSV/PDF).

---

## 4) Non‑Goals (MVP)

• No RPG avatars, weapons, or 1v1 battles.
• No complex exercise library recommendation engine (simple tags only).
• No in‑app DM at launch; clan chat is optional v1.1.

---

## 5) System Architecture (High‑Level)

**Mobile:** React Native (Expo) or Flutter.
**Backend:** Node.js (NestJS/Express) or Go (Fiber) with Firebase Auth or Cognito; Postgres for relational core; Redis for leaderboards; Cloud Storage for media; Cloud Functions/Queues for async jobs; OpenTelemetry for tracing.
**Integrations:** Apple HealthKit, Google Fit (v1.1), Strava (optional v1.2).

---

## 6) Scoring Model (Deterministic & Anti‑Cheat Friendly)

### 6.1 Strength Session → Points

For each set i of an exercise mapped to a primary muscle group g:

```
volume_i = reps_i × weight_i  (kg)
intensity_factor = 1 + min( (weight_i / body_weight) × 0.15, 0.30 )  // caps gaming
set_points_i = volume_i × intensity_factor
```

Session points for group g:

```
session_points_g = Σ set_points_i × exercise_bias_g
```

Where `exercise_bias_g` in \[0.7, 1.0] accounts for isolation vs compound to prevent overclaim. Example: bench → chest 1.0, triceps 0.2 overflow (see 6.3).

### 6.2 Cardio Session → Points

```
base = duration_minutes × MET × 10
hr_factor = clamp( avg_HR / HRR_target , 0.8 , 1.2 )
cardio_points = base × hr_factor
```

`MET` from user‑selected modality; default 8 for running, 10 for rowing; validated by wearable when available.

### 6.3 Overflow Mapping for Compounds (Optional v1.1)

Compound lifts distribute fractions to secondary groups to improve fairness:

* Squat: legs 1.0, core 0.25, back 0.15
* Deadlift: back 1.0, legs 0.35, grip/arms 0.15, core 0.25
* Bench: chest 1.0, shoulders 0.25, arms 0.2
  Overflow caps per session to reduce inflation: secondary sum ≤ 0.6 × primary.

### 6.4 Normalization & Decay

Weekly leaderboards use raw points. Personal 30d displays exponential decay for recency visualization:

```
P_decay(t days old) = P_raw × e^(−t / τ)  with τ = 15 days
```

### 6.5 Streak Boost

If user logs valid activity on ≥ 3 consecutive days, apply a multiplicative 1.05 boost to that day’s points, cap 1.15 at ≥ 10 days. Boost is visible and logged separate to prevent retro edits.

### 6.6 Anti‑Cheat Heuristics

* Per‑session caps by bodyweight and exercise class (e.g., bench single‑set cap 2.5 × BW × 10 reps).
* Z‑score anomaly detection per user percentile over last 8 weeks.
* Edit window 2 hours; after that, edits create a new revision and require mod/admin review if >20% change.
* Wearable‑verified sessions flagged “verified,” weighted +3% for clan totals to incentivize honest data.

---

## 7) Data Model (Relational Core)

### 7.1 Entities

**users**(id, handle, email, auth\_provider, body\_weight, height, created\_at, privacy\_flags)

**clans**(id, name, slug, emblem\_url, description, visibility, created\_at)

**clan\_members**(clan\_id, user\_id, role\[member|officer|leader], joined\_at, status)

**exercises**(id, name, muscle\_primary, muscle\_secondary JSON, met\_default, type\[strength|cardio])

**workouts**(id, user\_id, started\_at, ended\_at, source\[manual|healthkit|googlefit|strava], verified\_bool)

**sets**(id, workout\_id, exercise\_id, reps, weight\_kg, rpe, points\_primary, points\_secondary JSON)

**cardio\_sessions**(id, workout\_id, exercise\_id, duration\_min, distance\_km, avg\_hr, met, points)

**totems\_weekly**(id, clan\_id, week\_start\_date, muscle\_group, points\_total, verified\_points\_total)

**portfolios\_daily**(id, user\_id, date, muscle\_group, points\_total, verified\_points\_total, streak\_count)

**leaderboards** materialized views backed by Redis sorted sets.

**awards**(id, user\_id|clan\_id, season\_id, type, metadata JSON)

**seasons**(id, starts\_at, ends\_at, ruleset\_version)

**audit\_logs**(id, actor\_id, action, entity, before JSON, after JSON, created\_at)

Indexes: composite on (clan\_id, week\_start\_date, muscle\_group), (user\_id, date, muscle\_group); GIN on JSON fields.

---

## 8) API Design (REST, JSON)

Auth via Firebase JWT in `Authorization: Bearer`.

### 8.1 Auth & Profile

POST /v1/auth/exchange  → {token}
GET  /v1/me              → {user, portfolio\_summary}
PATCH /v1/me             → update profile/body\_weight/privacy

### 8.2 Clans

POST   /v1/clans                 → create
GET    /v1/clans?query=…\&page=…  → search/list
GET    /v1/clans/{id}            → details + totems + roster
POST   /v1/clans/{id}/join       → request join
POST   /v1/clans/{id}/members/{uid}/role  → set role (leader/officer only)
PATCH  /v1/clans/{id}            → update settings

### 8.3 Workouts

POST /v1/workouts                 → create session {started\_at, source}
POST /v1/workouts/{wid}/sets      → add set {exercise\_id, reps, weight\_kg, rpe}
POST /v1/workouts/{wid}/cardio    → add cardio {exercise\_id, duration\_min, distance\_km, avg\_hr}
POST /v1/workouts/{wid}/finalize  → compute & lock points
GET  /v1/workouts?user=me\&range=7d → list
DELETE /v1/workouts/{wid} within edit window

### 8.4 Portfolios & Totems

GET /v1/portfolio?range=7d|30d|lifetime → vector by muscle
GET /v1/clans/{id}/totems?week=YYYY‑WW → points per muscle
GET /v1/leaderboards/personal?range=7d → rank in‑clan, city, global
GET /v1/leaderboards/clans?week=YYYY‑WW → clan ranks

### 8.5 Seasons & Awards

GET /v1/seasons/current
GET /v1/awards?user=me|clan={id}

### 8.6 Admin/Anti‑Cheat

GET  /v1/admin/anomalies?week=…
POST /v1/admin/verify/{workout\_id}

**Example Response — Portfolio**

```json
{
  "range": "7d",
  "user_id": "u_123",
  "vector": {
    "chest": 18230,
    "back": 22110,
    "shoulders": 11200,
    "arms": 7400,
    "legs": 30550,
    "core": 6200,
    "cardio": 9800
  },
  "streak": 6,
  "verified_share": 0.72
}
```

---

## 9) Client UX Flows

**Onboarding:** sign in → choose/join clan → set bodyweight → optional connect HealthKit/Google Fit → first log.
**Log Strength:** pick exercise → enter sets quickly with numeric keypad → auto compute points → save.
**Log Cardio:** pick modality → start timer or import from wearable → end → compute points.
**View:** Home shows weekly personal rank in clan, clan’s global rank, and contribution delta vs yesterday. Portfolio screen shows 7‑axis chart. Clan screen shows Totems levels.
**Share:** Generate weekly summary image (server renders on demand) with personal contribution, clan rank, and top muscle.

---

## 10) Wearable Integrations (v1.1)

**Apple HealthKit:** read workouts (HKWorkoutType), active energy, heart rate samples. Map to modality; mark verified.
**Google Fit:** Sessions + DataSources for HR, calories, distance. Debounce duplicates via sourceId hash.
**Strava (optional):** webhook events for activities; only cardio modalities count.

---

## 11) Leaderboard Engine

Redis ZSET per scope and metric:

* `lb:user:clan:{clanId}:week:{isoWeek}` score = Σ week points (all muscles or per muscle key)
* `lb:clan:global:week:{isoWeek}` score = Σ clan Totems
  Write on finalize; read with pagination. Nightly reconciliation job replays Postgres deltas to Redis to ensure consistency.

Ties broken by earlier achievement time (lower `first_achieved_at`).

---

## 12) Jobs & Schedulers

* **FinalizeWorkoutJob** computes points, persists to portfolios\_daily and totems\_weekly.
* **SeasonRolloverJob** snapshots leaderboards, issues awards, resets week keys.
* **AnomalyScanJob** flags suspicious workouts.
* **SummaryRenderJob** composes share images (server‑side canvas) and caches.

---

## 13) Security & Privacy

* Firebase Auth + rules; server also verifies JWT and enforces RBAC on clan endpoints.
* PII minimization: email hashed for ranking scopes; opt‑in public profiles.
* Tamper resistance: points computed server‑side only; client sends raw logs.
* Rate limiting on write endpoints; HMAC on webhook sources.

---

## 14) Analytics (Event Schema)

`app_open`, `workout_start`, `set_add`, `workout_finalize`, `connect_health`, `streak_inc`, `share_export`, `clan_join`, `leaderboard_view`, `sub_trial_start`, `sub_convert`.

North‑star: Weekly Active Loggers (WAL). Secondary: clan retention, verified% of workouts, median streak length, share rate, conversion to paid.

---

## 15) Monetization

* **PLUS subscription:** advanced analytics, export, longer history, verified badge emphasis, custom portfolio skins, priority name.
* **Clan Customization Packs:** emblem/banners, totem skins.
* **One‑off:** season highlight PDF.

Free tier preserves core loop: logging + rankings.

---

## 16) Growth Loops

* Shareable weekly summary images.
* Clan invites with deep links; join via code.
* Referral boosts (both referrer and referee get +3% verified weighting for 7 days).

---

## 17) Edge Cases & Rules

* Editing after finalize: within 2 hours; else create a revision; leaderboards recomputed via delta apply.
* Leaving a clan mid‑week: user’s contributions remain with clan for that week; new clan starts next week.
* Private users still contribute anonymized points to clan but are hidden on personal leaderboards.
* Multiple devices/timezones: server uses UTC for seasons; client displays local.

---

## 18) Example SQL (Postgres)

```sql
CREATE TABLE users (
  id uuid PRIMARY KEY,
  handle text UNIQUE NOT NULL,
  email text UNIQUE NOT NULL,
  body_weight numeric(5,2),
  height numeric(5,2),
  created_at timestamptz DEFAULT now()
);

CREATE TABLE clans (
  id uuid PRIMARY KEY,
  name text NOT NULL,
  slug text UNIQUE NOT NULL,
  emblem_url text,
  description text,
  visibility text DEFAULT 'public',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE clan_members (
  clan_id uuid REFERENCES clans(id) ON DELETE CASCADE,
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  role text DEFAULT 'member',
  status text DEFAULT 'active',
  joined_at timestamptz DEFAULT now(),
  PRIMARY KEY (clan_id, user_id)
);

CREATE TABLE workouts (
  id uuid PRIMARY KEY,
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  started_at timestamptz,
  ended_at timestamptz,
  source text,
  verified_bool boolean DEFAULT false
);

CREATE TABLE sets (
  id uuid PRIMARY KEY,
  workout_id uuid REFERENCES workouts(id) ON DELETE CASCADE,
  exercise_id uuid,
  reps int,
  weight_kg numeric(6,2),
  rpe numeric(3,1),
  points_primary numeric(12,2),
  points_secondary jsonb
);

CREATE TABLE portfolios_daily (
  id uuid PRIMARY KEY,
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  date date,
  muscle_group text,
  points_total numeric(12,2),
  verified_points_total numeric(12,2),
  streak_count int,
  UNIQUE (user_id, date, muscle_group)
);

CREATE TABLE totems_weekly (
  id uuid PRIMARY KEY,
  clan_id uuid REFERENCES clans(id) ON DELETE CASCADE,
  week_start_date date,
  muscle_group text,
  points_total numeric(14,2),
  verified_points_total numeric(14,2),
  UNIQUE (clan_id, week_start_date, muscle_group)
);
```

---

## 19) Server Pseudocode — Finalize Workout

```ts
async function finalizeWorkout(workoutId) {
  const w = await db.workouts.find(workoutId);
  assert(w.user_id);
  const sets = await db.sets.where({workout_id: workoutId});
  const cardio = await db.cardio_sessions.where({workout_id: workoutId});

  const byMuscle = new Map<string, number>();

  for (const s of sets) {
    const ex = await cache.exercise(s.exercise_id);
    const vol = s.reps * s.weight_kg;
    const intensity = 1 + Math.min((s.weight_kg / user.body_weight) * 0.15, 0.30);
    const base = vol * intensity;
    add(byMuscle, ex.muscle_primary, base * 1.0);
    for (const [mg, frac] of Object.entries(ex.muscle_secondary || {})) {
      add(byMuscle, mg, base * Math.min(frac, 0.6));
    }
  }

  for (const c of cardio) {
    const base = c.duration_min * c.met * 10;
    const hrFactor = clamp(c.avg_hr / c.hrr_target, 0.8, 1.2);
    add(byMuscle, 'cardio', base * hrFactor);
  }

  const streak = await computeStreak(w.user_id);
  const boost = streak >= 10 ? 1.15 : streak >= 3 ? 1.05 : 1.0;

  const weekStart = isoWeekStart(w.ended_at);
  const date = toDate(w.ended_at);

  for (const [mg, pts] of byMuscle) {
    const boosted = pts * boost;
    await db.portfolios_daily.upsert({user_id: w.user_id, date, muscle_group: mg}, {
      $inc: {points_total: boosted, verified_points_total: w.verified_bool ? boosted : 0},
      $set: {streak_count: streak}
    });

    const clanIds = await clansOfUser(w.user_id);
    for (const cid of clanIds) {
      await db.totems_weekly.upsert({clan_id: cid, week_start_date: weekStart, muscle_group: mg}, {
        $inc: {points_total: boosted, verified_points_total: w.verified_bool ? boosted : 0}
      });
      await redis.zincrby(`lb:clan:global:week:${weekKey(weekStart)}`, boosted, cid);
      await redis.zincrby(`lb:user:clan:${cid}:week:${weekKey(weekStart)}`, boosted, w.user_id);
    }
  }

  await flagAnomalies(workoutId);
}
```

---

## 20) Mobile UI Skeleton (RN/Flutter)

**Tabs:** Home, Log, Portfolio, Clan, Leaderboards, Profile.
**Home:** this‑week personal rank in clan, delta vs yesterday, quick actions (Log Strength, Log Cardio).
**Log:** numeric keypad optimized; barcode‑like quick repeat for sets; timer for cardio.
**Portfolio:** 7‑axis chart, toggle 7d/30d/lifetime, streak indicator.
**Clan:** Totems with levels, weekly totals per muscle, roster with member contributions.
**Leaderboards:** my clan, city, global; per‑muscle filters; pagination.

---

## 21) QA & Testing

* Unit tests on scoring model with golden datasets.
* Property tests on anti‑cheat caps.
* Integration tests for finalize→leaderboard propagation.
* Snapshot tests for share images.
* Beta via TestFlight/Play Internal; track crash‑free sessions.

---

## 22) Roadmap

**v1.0 (8–10 weeks):** Auth, logging, portfolios, clans, weekly Totems, leaderboards, shares, PLUS basic.
**v1.1:** HealthKit/Google Fit ingest, overflow mapping, clan chat, anomaly console.
**v1.2:** Strava ingest, city/geo leaderboards, team events, seasonal highlights PDF export.

---

## 23) Build Checklist (MVP Exit Criteria)

* P0 crash‑free > 99%.
* WAL ≥ 30% of WAU.
* Verified workouts ≥ 40% of total.
* Median streak ≥ 4 days by week 3.
* Share rate ≥ 12% of weekly active.

---

## 24) Branding Notes

Name: **TOTEM**. Tone: clean, meritocratic, numbers‑first. Visuals: minimal geometric totems per muscle. No cartoon mascots. Emphasis on clarity and legitimacy.

---

## 25) Handoff Summary for AI Engineers

* Implement §6 scoring server‑side only.
* Ship endpoints in §8 with auth and rate limits.
* Use schemas in §7/§18; Redis ZSETs for leaderboards.
* Integrate streak boosts and season rollover jobs in §12.
* Ship five core screens in §20 with fast logging UX.

This document is the canonical reference for the MVP. Deviations require updating ruleset\_version in `seasons`.
