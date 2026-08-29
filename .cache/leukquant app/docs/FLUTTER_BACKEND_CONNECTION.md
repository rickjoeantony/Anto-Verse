# LeukQuant Mobile - Backend Connection & Multi-Environment Guide

## Overview

The LeukQuant Flutter Mobile app connects to the `middle-man-3` backend service via confirmed REST endpoints and real-time WebSocket telemetry (`/api/ws`).

To adhere to enterprise security standards and prevent accidental data leakage or hardcoded secrets, backend URLs are **injected strictly at compile-time via `--dart-define`**.

---

## 1. Compile-Time Environment Flags

| Flag | Description | Supported Values | Default |
|---|---|---|---|
| `API_BASE_URL` | Base URL for REST API endpoints | `http://...` / `https://...` | `""` (Empty string) |
| `WS_BASE_URL` | Base URL for WebSocket telemetry stream | `ws://...` / `wss://...` | `""` (Empty string) |
| `APP_ENV` | Explicit target execution environment | `local`, `staging`, `production` | `""` (Evaluated via `effectiveEnv`) |

### Environment Evaluation Logic (`AppConfig.effectiveEnv`):
- **Explicit `APP_ENV` flag always wins** if provided.
- If `APP_ENV` is omitted:
  - In **Release mode** (`kReleaseMode == true`): Defaults to `production`.
  - In **Debug/Profile mode**: Defaults to `local`.

---

## 2. Environment Security Constraints

### A. Local (`APP_ENV=local`)
- Intended for development against local emulators, simulators, or LAN endpoints.
- Cleartext HTTP and `ws://` schemes are permitted.
- Displays a visible `DEV/LOCAL BACKEND` indicator in the UI.
- Android cleartext traffic is isolated to the debug source set (`android/app/src/debug/AndroidManifest.xml`) for `10.0.2.2` and `localhost`.

### B. Staging (`APP_ENV=staging`)
- Requires secure `https://` for `API_BASE_URL` and `wss://` for `WS_BASE_URL`.
- Displays a subtle `STAGING` badge.
- Internal/VPN hosts are permitted during controlled testing, but must use `https://` / `wss://`.
- Rejects unencrypted `http://` or `ws://` with a configuration error.

### C. Production (`APP_ENV=production`)
- Requires strict `https://` and `wss://` protocols.
- **Strictly forbids** all private, loopback, link-local, and mDNS hostnames:
  - `127.0.0.1`, `localhost`, `0.0.0.0`, `::1`
  - `10.0.0.0/8` (`10.*`)
  - `192.168.0.0/16` (`192.168.*`)
  - `172.16.0.0/12` (`172.16.*` to `172.31.*`)
  - `169.254.0.0/16` (Link-local IPv4)
  - `*.local` / `local` (mDNS)
  - `10.0.2.2` (Android emulator bridge)
- If production URLs are missing or insecure, the app locks network activity and displays `"Backend connection not configured."`
- **Zero environment badges** appear in production mode.

---

## 3. Run & Build Commands

### A. Android Emulator (Local)
The Android emulator routes `10.0.2.2` to the host machine's `localhost`:
```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:8080 \
  --dart-define=WS_BASE_URL=ws://10.0.2.2:8080 \
  --dart-define=APP_ENV=local
```

### B. Physical Device (Local Wi-Fi / LAN)
Replace `<LAPTOP_LAN_IP>` with your computer's local Wi-Fi IP address (e.g. `192.168.1.50`):
```bash
flutter run \
  --dart-define=API_BASE_URL=http://<LAPTOP_LAN_IP>:8080 \
  --dart-define=WS_BASE_URL=ws://<LAPTOP_LAN_IP>:8080 \
  --dart-define=APP_ENV=local
```

### C. Staging Build
```bash
flutter build apk --debug \
  --dart-define=API_BASE_URL=https://api-staging.leukquant.com \
  --dart-define=WS_BASE_URL=wss://api-staging.leukquant.com \
  --dart-define=APP_ENV=staging
```

### D. Production Release Build
```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.leukquant.com \
  --dart-define=WS_BASE_URL=wss://api.leukquant.com \
  --dart-define=APP_ENV=production
```

---

## 4. Confirmed Middle-Man-3 Endpoints

The mobile client interacts exclusively with the following endpoints:

| Method | Path | Description | Authentication |
|---|---|---|---|
| `GET` | `/api/health` | Health and liveness probe | Public |
| `GET` | `/api/config` | Public server configuration | Public |
| `POST` | `/api/auth/login` | Email/password sign-in | Public (Sets httpOnly cookie) |
| `POST` | `/api/auth/refresh` | Rotates access JWT | httpOnly Cookie |
| `POST` | `/api/auth/logout` | Revokes server session | Protected |
| `GET` | `/api/user/profile` | Analyst profile & permissions | Bearer JWT |
| `PATCH` | `/api/user/profile` | Updates user settings | Bearer JWT |
| `GET` | `/api/dashboard/stats` | Honeypot & threat metrics | Bearer JWT |
| `GET` | `/api/dashboard/events?limit=50` | Recent telemetry events | Bearer JWT |
| `GET` | `/api/reports` | Security briefs and audit logs | Bearer JWT |
| `WSS` | `/api/ws?token=<jwt>` | Inbound live event stream | Query JWT Token |

---

## 5. Safe Latency Diagnostics Buckets

The Connection Diagnostics screen (`/more/diagnostics`) reports latency in five complete brackets:

| Latency Bucket | Status Description |
|---|---|
| `< 50ms` | Optimal |
| `50–150ms` | Normal |
| `150–300ms` | Moderate |
| `> 300ms` | High Latency |
| `Timeout` | Request exceeded 5s threshold |

---

## 6. Physical Device Acceptance & Staging Validation Checklist

To complete final acceptance on physical staging hardware, execute and record the following steps:

```bash
# 1. Build staging APK with correct dart-defines
flutter build apk --debug \
  --dart-define=API_BASE_URL=https://api-staging.leukquant.com \
  --dart-define=WS_BASE_URL=wss://api-staging.leukquant.com \
  --dart-define=APP_ENV=staging

# 2. Install on connected physical device
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

### Verification Matrix:

| Step | Acceptance Criteria | Result (PASS / FAIL) | Evidence / Notes |
|---|---|---|---|
| **1. APK Build** | Build succeeds with staging `--dart-define` parameters | `PASS` | Compiled cleanly (`build/app/outputs/flutter-apk/app-debug.apk`) |
| **2. Device Install** | Installs onto physical device without certificate/security errors | `PASS` | Successfully pushed and launched on `Samsung Galaxy SM_A366E` (`RZGYB2CFTZF`) |
| **3. Real Login** | `POST /api/auth/login` succeeds with valid test credentials | `PENDING CREDENTIAL TEST` | JWT stored in-memory only |
| **4. Real Stats JSON** | `GET /api/dashboard/stats` returns live telemetry JSON | `PENDING CREDENTIAL TEST` | Cards populate without crash |
| **5. WebSocket Stream** | Connects to `wss://api-staging.leukquant.com/api/ws` | `PENDING CREDENTIAL TEST` | Badge transitions to `LIVE` |
| **6. Live Ingress Event** | Inbound telemetry appears dynamically on Events feed | `PENDING CREDENTIAL TEST` | Deduped by Event ID |
| **7. Diagnostics Screen** | `/more/diagnostics` shows API Reachable & latency bucket | `PENDING CREDENTIAL TEST` | Zero token leakage |

**Sign-off Record**:
- **Date Tested**: `____________________`
- **Device Model / OS**: `____________________`
- **Tester Signature**: `____________________`
- **Final Result**: `[ ] PASS   [ ] FAIL`
