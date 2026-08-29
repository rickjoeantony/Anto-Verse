# Flutter Mobile Client — Middle-Man-3 Backend Connection

**Status:** Canonical Implementation Complete  
**Verification Date:** 2026-08-29  
**Target:** `leukquant app` <-> `middle-man-3` REST & WebSocket APIs

---

## 1. Executive Summary

The LeukQuant Flutter Mobile Client is integrated with the `middle-man-3` threat intelligence backend according to the API contract and security requirements. All backend URLs are dynamically injected at compile-time via `--dart-define` flags, ensuring zero hardcoded endpoints and strict environment isolation (Local / Staging / Production).

---

## 2. Architecture & Communication Constraints

```
┌─────────────────────────────────────────────────────────────┐
│                 LeukQuant Flutter Mobile Client             │
│  - In-Memory JWT Storage Only (Never in SharedPreferences)  │
│  - In-Memory CookieJar (Never Persisted to Disk)            │
│  - Redacted Logging (Tokens, Auth Headers, Passwords)        │
└──────────────┬───────────────────────────────▲──────────────┘
               │                               │
               │ HTTPS REST Requests           │ WSS Live Events Stream
               │ (Bearer JWT / In-Memory Jar)  │ (/api/ws?token=<jwt>)
               ▼                               │
┌──────────────────────────────────────────────┴──────────────┐
│                    middle-man-3 Backend                     │
│  - /api/auth/login, /api/auth/refresh, /api/auth/logout     │
│  - /api/dashboard/stats, /api/dashboard/events, /api/reports │
│  - /api/health, /api/config, /api/ip/:ip/sessions           │
└─────────────────────────────────────────────────────────────┘
```

### Safety & Isolation Rules Enforced:
1. **Zero Backend Modifications**: Connected strictly to existing `middle-man-3` endpoints without alterations to Java backend code.
2. **Direct DB & Ingestion Isolation**: The mobile client has no direct access to PostgreSQL or `middle-man-1`.
3. **No Admin API Exposure**: Admin dashboard functions remain restricted to platform operations.
4. **Token Security**:
   - In-memory JWT only. No disk persistence (`SharedPreferences` or local database storage).
   - In-memory `CookieJar` with `dio_cookie_manager` for `httpOnly` refresh tokens.
5. **Credential Masking**: All captured credentials rendered as `username ••••••••`. Raw passwords are never exposed in UI or error reports.
6. **Safe Payloads**: Payloads are displayed as read-only text, truncated to safe preview length, with control characters stripped. Never executed.
7. **Redacted WebSocket Logs**: WebSocket connection strings redact tokens (`/api/ws?token=[REDACTED]`). Events deduplicated by ID.

---

## 3. Endpoints & Screen Mappings

| Screen | Backend Endpoint | Function & Behavior |
| :--- | :--- | :--- |
| **Login** | `POST /api/auth/login` | Authenticates user; handles 401 (invalid credentials), 429 (rate limit lock), and connectivity failures. Renders environment badge (`LOCAL`, `STAGING`, `PRODUCTION`). |
| **Overview** | `GET /api/dashboard/stats` | Renders total attacks, active threats, blocked IPs, distinct honeypots, hourly trends, threat distribution, and top vectors. Displays *"Awaiting backend data"* when unpopulated. |
| **Events Feed** | `GET /api/dashboard/events?limit=50` | Displays threat severity, attack type, source IP, country, sanitized payload preview, and masked credentials. |
| **Event Details** | `GET /api/events/:id` | Full forensic view with threat level, abuse score, reviewed state, safe payload, and masked credentials. |
| **Incidents** | Derived from `events` | Derives high-risk items (threatLevel $\ge$ 4) labeled *"Derived from verified events"*. No fake incident endpoints. |
| **Reports** | `GET /api/reports` | Fetches verified compliance and incident reports; renders empty state if none exist. |
| **Deployments** | Placeholder View | Displays *"Deployment status awaiting backend service"*. |
| **Diagnostics** | `GET /api/health`, `GET /api/config` | Shows API host, WebSocket connection state, session state, and sanitized telemetry export. |

---

## 4. Test Verification Matrix

All unit and widget test suites pass:
- [x] Login success stores JWT in memory only
- [x] Login 401 returns invalid credentials message without refresh attempts
- [x] Protected endpoint 401 triggers single refresh attempt and retries original request
- [x] Refresh 401 clears in-memory session and routes to Login
- [x] 429 status code disables sign-in button temporarily
- [x] Captured attacker credentials always masked in UI (`root ••••••••`)
- [x] Payload preview truncated and never executed
- [x] WebSocket URL tokens redacted in logs
- [x] WebSocket deduplicates incoming events by ID in ring buffer
- [x] Refresh cookies stored exclusively in in-memory `CookieJar`
- [x] Zero JWT leakage into `SharedPreferences`
- [x] Dashboard stats and event views parse real backend JSON without crashing
- [x] Safe null handling for legacy/missing telemetry fields
- [x] Offline and connection error fallback states

---

## 5. Final Status

Flutter connected to middle-man-3 contract.  
Real staging device validation pending.
