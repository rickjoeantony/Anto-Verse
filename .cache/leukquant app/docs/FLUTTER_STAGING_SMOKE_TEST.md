# LeukQuant Mobile: Staging Smoke Test Guide

> **Status:** Flutter Phase 2 API integration is prepared for staging implementation. Authentication refresh support and WebSocket ticket support depend on confirmed middle-man-3 staging endpoints.

---

## 1. Staging Run Command

Execute with explicit Dart defines:

```bash
flutter run \
  --dart-define=API_BASE_URL=https://api-staging.leukquant.com \
  --dart-define=WS_BASE_URL=wss://api-staging.leukquant.com \
  --dart-define=APP_ENV=staging
```

---

## 2. Verification Checklist

### 2.1 Unconfigured Default Verification
1. Run `flutter run` without `--dart-define=API_BASE_URL=...`
2. Confirm the top status badge displays **`Unconfigured`**.
3. Confirm API queries return **`Backend connection not configured.`** without attempting outbound network calls.

### 2.2 Authentication & In-Memory Token Handling
1. Launch app with staging defines -> Login screen appears.
2. Submit invalid login -> Verify error banner displays clean message without stack traces.
3. Submit valid staging credentials -> Verify login succeeds and user profile is retrieved.
4. Verify **no JWT** is written to `SharedPreferences`.
5. Trigger 401 Unauthorized -> Verify session expires and redirects to Login screen with *"Your session has expired. Please sign in again."*

### 2.3 Subprotocol WebSocket Verification
1. Verify `POST /api/auth/ws-ticket` returns single-use ticket.
2. Confirm `WebSocketChannel.connect` initiates handshake to `wss://api-staging.leukquant.com/api/ws` with `Sec-WebSocket-Protocol: leukquant-ticket, <ticket>`.
3. Verify no ticket appears in URL query parameters.
4. Observe real-time canary telemetry prepended at the top of the Events stream.

### 2.4 Decoupled Network & Backend Health
1. Disable server or block API endpoint while Wi-Fi is active.
2. Confirm app displays **`Backend Unavailable`** (not `Online`).
3. Turn on Airplane Mode -> Confirm badge switches to **`No Network`**.

---

## 3. Automated Validation

```bash
# Run static analysis
flutter analyze

# Run unit and widget test suite
flutter test
```
