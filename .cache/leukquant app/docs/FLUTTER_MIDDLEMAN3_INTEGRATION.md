# LeukQuant Mobile Flutter Client ↔ Middle-Man-3 API Integration

## Overview
This document specifies the architecture, contract compliance, security controls, and endpoint mapping connecting the **LeukQuant Flutter Mobile Client App** to the **middle-man-3 Spring Boot 3.4.1 (Java 21, PostgreSQL, WebSocket)** backend.

---

## 1. Environment & Base URL Configuration

The application uses compile-time environment flags via `--dart-define` to prevent accidental connections to staging or production backends during local development.

```dart
// lib/core/config/app_config.dart
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: '',
);

static const String wsBaseUrl = String.fromEnvironment(
  'WS_BASE_URL',
  defaultValue: '',
);
```

### Staging Build Invocation
```powershell
flutter build apk --debug \
  --dart-define=API_BASE_URL=https://api-staging.leukquant.com \
  --dart-define=WS_BASE_URL=wss://api-staging.leukquant.com \
  --dart-define=APP_ENV=staging
```

If `API_BASE_URL` is empty, the app renders:
> *"Backend connection not configured."*

---

## 2. Confirmed Middle-Man-3 API Endpoints

The mobile client strictly communicates only with the following confirmed REST and WebSocket endpoints:

### Public Endpoints
| Method | Endpoint | Description | Return Data |
|---|---|---|---|
| `GET` | `/api/health` | Backend service health check | `{ status, uptime }` |
| `GET` | `/api/config` | Client configuration properties | Feature flags and configs |
| `POST` | `/api/auth/login` | User authentication | `{ jwt, user }` + `httpOnly` refresh cookie |
| `POST` | `/api/auth/refresh` | Rotate refresh token | `{ jwt }` (rotates cookie) |
| `POST` | `/api/auth/logout` | Revoke session & cookie | Empty 200 OK |

### Authenticated Endpoints (`Authorization: Bearer <jwt>`)
| Method | Endpoint | Description | Return Data |
|---|---|---|---|
| `GET` | `/api/user/profile` | Authenticated user profile | `{ id, email, name, avatar, role/plan }` |
| `PATCH` | `/api/user/profile` | Update profile settings | Updated profile object |
| `GET` | `/api/dashboard/stats` | Aggregate dashboard statistics | Total attacks, origins, hourly, vectors |
| `GET` | `/api/dashboard/events?limit=50` | Telemetry events list | Sanitized security events (limit: 50) |
| `GET` | `/api/dashboard/attacks?limit=50` | Attack telemetry feed | Ingress attack volume |
| `GET` | `/api/events/:id` | Single event details | Detailed event record |
| `PATCH` | `/api/events/:id` | Review/triage event | `{ reviewed: true }` |
| `GET` | `/api/reports` | Generated compliance briefs | List of report metadata |
| `POST` | `/api/reports/:id/regenerate` | Re-trigger report compilation | Status response |
| `GET` | `/api/ip/:ip/sessions` | Attacker IP session history | Sessions with masked credentials |
| `WSS` | `/api/ws?token=<jwt>` | Live WebSocket telemetry feed | Streaming `SecurityEvent` JSON frames |

*Note: The mobile client does not connect directly to PostgreSQL and does not call internal Admin Dashboard APIs.*

---

## 3. Mobile Security Rules & Data Sanitization

### A. Credential Masking
- The backend may return captured decoy credentials in `SecurityEvent` or `IpSessionsData`:
  ```json
  "credentials": [{"username": "root", "password": "plainTextPassword123"}]
  ```
- **Mobile Enforcement**: The client discards the raw password during deserialization and replaces it immediately with bullet masking (`••••••••`):
  ```text
  root ••••••••
  ```
- Raw password values are **never logged**, **never included in crash reports**, and **never displayed on screen**.

### B. Payload Sanitization
- `SecurityEvent.payload` may contain raw attacker payloads (e.g. `rm -rf /`, binary exploit shellcodes, or injection commands).
- **Mobile Enforcement**:
  - Truncates to a maximum length of 80–120 characters safe preview.
  - Strips non-printable ASCII control characters (`\x00-\x1F\x7F`).
  - Rendered exclusively inside read-only `SelectableText`.
  - Never executed or parsed as active scripts or clickable hyperlinks.

### C. In-Memory CookieJar for Refresh Tokens
- The backend manages refresh tokens via `httpOnly` cookies.
- Flutter mobile has no browser engine.
- **Mobile Enforcement**: The client uses `dio_cookie_manager` with a volatile in-memory `CookieJar()`:
  ```dart
  _cookieJar = CookieJar(); // RAM only
  _dio.interceptors.add(CookieManager(_cookieJar));
  ```
- Refresh cookies and JWTs reside exclusively in RAM. No tokens or cookies ever touch `SharedPreferences` or disk. App restart requires user re-authentication.

### D. Protected 401 Refresh vs. Login 401
- **Login 401**: Wrong credentials → Shows *"Invalid email or password"*. Does **NOT** attempt token refresh.
- **Protected API 401**: Expired access token → Calls `POST /api/auth/refresh` once:
  - If refresh succeeds with new JWT → Retries original request once.
  - If refresh fails (401) → Clears session in memory, triggers `sessionExpired`, and navigates to Login.

### E. Rate Limiting (HTTP 429)
- Login: 5/minute; Refresh: 10/minute.
- On HTTP 429, the app displays: *"Too many attempts. Please wait a moment and try again."*
- Disables the Sign In button for a 30-second cooldown timer. Does not retry in a loop.

### F. WebSocket URL Token Protection
- Current connection: `wss://api-staging.leukquant.com/api/ws?token=<jwt>`
- The full URL with token query parameter is **strictly redacted in all debug prints and loggers**:
  ```text
  [WebSocket] -> Connecting to wss://api-staging.leukquant.com/api/ws?token=[REDACTED]
  ```
- **Phase 3 Roadmap**: A ticket/subprotocol authentication upgrade (`Sec-WebSocket-Protocol: leukquant-ticket, <ticket>`) is planned for backend Phase 3 to avoid query-parameter token transmission.

---

## 4. Domain Model Mappings

### `SecurityEvent`
```dart
class SecurityEvent {
  final String id;
  final DateTime timestamp;
  final String sourceIp;
  final String country;
  final String countryCode;
  final double? lat;
  final double? lng;
  final String type;
  final int threatLevel; // 1 to 5
  final String honeypot;
  final String payload; // Sanitized safe preview
  final double abuseScore;
  final bool reviewed;
  final List<CredentialItem> credentials; // Password always masked as ••••••••
  final String protocol;
  final String destinationPort;
  final String canaryReference;
  final String recommendedAction;
  final List<String> classificationReasons;
}
```

### `DashboardStats`
```dart
class DashboardStats {
  final int totalAttacks;
  final int activeThreats;
  final int blockedIPs;
  final int honeypots;
  final int attacksToday;
  final int criticalAlerts;
  final List<OriginGeo> origins;
  final List<HourlyDataPoint> hourlyData;
  final List<ThreatDistributionItem> threatDistribution;
  final List<TopThreatVector> topThreatVectors;
  final String systemUptime;
}
```

### `UserProfile`
```dart
class UserProfile {
  final String id;
  final String name;
  final String? email;
  final String? avatar;
  final String plan; // 'starter' | 'growth' | 'enterprise' | 'admin'
  final String? organisation;
  final String? workspaceId;
}
```
*Note: The backend `role` field represents the customer subscription PLAN and is labeled "Plan" in the UI.*

---

## 5. Screen Connection Matrix

1. **Login Screen**:
   - `POST /api/auth/login` → Success stores JWT in RAM → calls `GET /api/user/profile` → navigates to Overview.
   - 401 → *"Invalid email or password"*.
   - 429 → *"Too many attempts. Please wait a moment and try again."* (disables button with cooldown).
   - Timeout / Offline → *"Backend unavailable. Please check your connection and retry."*
2. **Overview (Home)**:
   - `GET /api/dashboard/stats` → Renders Critical Alerts, Attacks Today, Active Threats, Blocked IPs, Hourly trend chart, Threat distribution, Top vectors.
   - Offline / Error → Displays *"Awaiting backend data"* without displaying fake values.
3. **Events**:
   - `GET /api/dashboard/events?limit=50` (uses `/events`, not `/attacks`).
   - Detail view: Sanitized payload, masked credentials (`root ••••••••`), threat level (1-5), abuse score, reviewed status toggle (`PATCH /api/events/:id`), and IP Sessions button.
4. **Incidents**:
   - Derived honestly ONLY from real verified events with `threatLevel >= 4`, labeled: *"Derived from verified events"*.
   - If empty: *"Incident service awaiting backend endpoint."*
5. **Reports**:
   - `GET /api/reports` and `POST /api/reports/:id/regenerate`.
   - If empty: *"No reports have been generated yet."*
6. **Deployments**:
   - Displays honest status: *"Deployment status awaiting backend service."*
7. **IP Sessions**:
   - `GET /api/ip/:ip/sessions`
   - Strict credential masking (`••••••••`), read-only command list, and security banner: *"Sensitive activity data. Authorised review only."*

---

## 6. Verification & Test Suite

All 12 required test suites pass cleanly via `flutter test`:
- `test/unit/middleman3_api_test.dart`
- `test/unit/api_client_test.dart`
- `test/unit/incidents_provider_test.dart`
- `test/unit/severity_level_test.dart`
- `test/unit/onboarding_test.dart`
- `test/unit/theme_controller_test.dart`
- `test/widget/login_screen_test.dart`
- `test/widget/splash_screen_test.dart`
- `test/widget/empty_state_view_test.dart`
- `test/widget/liquid_glass_test.dart`
- `test/widget/responsive_screens_test.dart`
- `test/widget/severity_badge_test.dart`
- `test/widget/status_card_test.dart`

---

## 7. Status

> **Flutter client API integration implemented against middle-man-3 contract. Real staging device validation pending.**
