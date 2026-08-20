# LeukQuant Mobile Phase 2: Real Staging API Integration

> **Status:** Flutter Phase 2 API integration is prepared for staging implementation. Authentication refresh support and WebSocket ticket support depend on confirmed middle-man-3 staging endpoints.

---

## 1. Environment & API Configuration
Base URLs are injected at compile-time via `--dart-define` and default to empty strings to prevent accidental staging or production connections in local development builds:

```bash
flutter run \
  --dart-define=API_BASE_URL=https://api-staging.leukquant.com \
  --dart-define=WS_BASE_URL=wss://api-staging.leukquant.com \
  --dart-define=APP_ENV=staging
```

If `API_BASE_URL` is empty, the application cleanly displays:
```text
Backend connection not configured.
```

---

## 2. Authentication & Token Lifecycle Strategy

### 2.1 Option A — Memory-Only JWT (Implemented)
- **Access JWT Storage**: Kept strictly in memory (`inMemoryTokenProvider`).
- **Storage Rules**: `SharedPreferences` and persistent storage are **never** used for tokens.
- **Session Expiry**: When the JWT expires (HTTP 401), in-memory tokens are immediately flushed and the UI presents:
  > *"Your session has expired. Please sign in again."*
- **Sign Out**: `POST /api/auth/logout` invalidates the server session, followed by in-memory state disposal.

### 2.2 Future Refresh Token Flow (Option B)
`flutter_secure_storage` is intentionally withheld until the middle-man-3 staging server deploys a dedicated mobile refresh token endpoint.

---

## 3. Real-Time Telemetry via WebSocket Subprotocol Authentication

To avoid exposing one-time tickets in proxy logs, server access logs, or monitoring traces, WebSocket authentication uses the **Sec-WebSocket-Protocol** subprotocol header:

```text
Flutter Client Logs In
        ↓
Access JWT Stored in Memory
        ↓
POST /api/auth/ws-ticket
        ↓
Receive Single-Use, Short-Lived Ticket
        ↓
WSS /api/ws (No Query Parameters)
Sec-WebSocket-Protocol: leukquant-ticket, <ticket>
        ↓
middle-man-3 Validates & Consumes Ticket
        ↓
Tenant-Safe Live Event Stream
```

### Flutter Subprotocol Connection:
```dart
WebSocketChannel.connect(
  Uri.parse('${AppConfig.wsBaseUrl}/api/ws'),
  protocols: ['leukquant-ticket', ticket],
);
```

---

## 4. Connectivity vs. Backend Health Separation

Physical network availability (`connectivity_plus`) is decoupled from staging backend reachability:

| State | Physical Network | API Status | WebSocket | Top Bar Badge |
| :--- | :--- | :--- | :--- | :--- |
| **No Internet** | Offline | — | Disconnected | `No Network` (Red) |
| **Server Down** | Online | 5xx / Connection Error | Disconnected | `Backend Unavailable` (Amber) |
| **Unconfigured** | Online | Unconfigured | Disconnected | `Unconfigured` (Grey) |
| **Connecting** | Online | 200 OK | Connecting / Ticket Exchange | `Syncing` (Blue) |
| **Healthy Stream** | Online | 200 OK | Connected (Subprotocol verified) | `Live` (Green) |

---

## 5. Security & Isolation Matrix

- **Credentials**: Decoy and honeytoken credentials are fully sanitized before rendering (`admin / **********`).
- **Targeted Ports**: Port charts strictly evaluate `target_port`, `honeypot_port`, and `decoy_port`. Source ports are excluded.
- **Client-Safe Scopes**: Mobile client only accesses Client Dashboard-safe middle-man-3 endpoints. Admin endpoints, database ports, SEC tokens, and agent provisioning APIs remain strictly isolated.
