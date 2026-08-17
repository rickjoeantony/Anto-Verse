# LeukQuant Multi-Bug Test Matrix
==================================
**Document Version:** 2.2.0-PRO  
**Date:** 2026-08-17  
**Scope:** Multi-Layer Runtime Verification (Layers 1-11) Across All Repositories  
**Status:** ALL 11 TEST LAYERS VALIDATED & PASSING

---

## 1. Multi-Layer Test Matrix Summary

| Layer # | Test Layer Domain | Target Subsystems | Critical Invariant Tested | Execution Result |
| :--- | :--- | :--- | :--- | :---: |
| **Layer 1** | Login & Session Lifecycle | `middle-man-3`, `DASHBOARD` | BCrypt verify, JWT refresh rotation, state transitions, logout cookie clear | **PASSED** |
| **Layer 2** | Client Dashboard Routes & Runtime | `DASHBOARD` | 10 client routes, ErrorBoundary wrap, offline fallback, diagnostics drill | **PASSED** |
| **Layer 3** | Credential Object/String/Null/Array UI | `DASHBOARD` (`masking.ts`) | Polymorphic type safety for string, object, array, and null credentials | **PASSED** |
| **Layer 4** | Reports & PDF Safety | `DASHBOARD` (`Reports.tsx`) | Zero hardcoded sensors, zero fake ports, dynamic GeoIP derivation, SHA-256 digest | **PASSED** |
| **Layer 5** | Ghost-Net SEC Telemetry Ingestion | `Honey-tech`, `middle-man-1` | ISO-8601 UTC Instant, header-only SEC, masked DB sink, HTTP 200/201 response | **PASSED** |
| **Layer 6** | Flyway & Database Migration | `middle-man-1`, `PostgreSQL` | Flyway V1-V4 repeatable migrations, partitioned `honeydata` table | **PASSED** |
| **Layer 7** | AES-256-GCM Evidence Vault | `middle-man-1` (`EvidenceService`) | 256-bit AES-GCM encryption, 12-byte random nonce, deterministic AAD binding | **PASSED** |
| **Layer 8** | Tenant Isolation & Cross-Tenant Rejection | `middle-man-1`, `PostgreSQL` | Alpha/Beta test tenant isolation, cross-tenant API denial, cross-SEC rejection | **PASSED** |
| **Layer 9** | Admin Dashboard Operations | `ADMIN-DASHBOARD` | Zero mock datasets, single-view raw SEC modal, role-gated forensic vault | **PASSED** |
| **Layer 10**| WebSocket Ticket Subprotocol Auth | `middle-man-3`, `DASHBOARD` | Subprotocol ticket & header auth (ZERO JWTs in URL query strings) | **PASSED** |
| **Layer 11**| Coolify Staging Deployment | `Docker`, `Coolify` | Production build verification, environment secret integrity, zero plain secrets | **PASSED** |

---

## 2. Detailed Layer Invariant Verification

### Layer 1: Login & Session Lifecycle
- **Password Hashing**: Verified BCrypt hashing with work factor 12.
- **Session Tokens**: Short-lived access JWT (15 min) + `HttpOnly`, `Secure`, `SameSite=Lax` refresh token cookie (7 days).
- **Session Termination**: Calling `/api/auth/logout` clears refresh cookie and revokes session server-side.

### Layer 2: Client Dashboard Routes & Runtime
- **Routing Invariants**: Audited `/login`, `/dashboard`, `/events`, `/incidents`, `/alerts`, `/reports`, `/deployments`, `/map`, `/live`, `/settings`.
- **Fault Tolerance**: Top-level `ErrorBoundary` prevents React fatal unmounting on rendering anomalies.

### Layer 3: Credential UI Polymorphic Safety
- **Polymorphism**: `formatCredentialsDisplay` normalizes `"root:pass"`, `{ username: "admin", password: "123" }`, `[{username: "u1"}, {username: "u2"}]`, and `null`.
- **Masking Guarantee**: Plaintext passwords converted to masked asterisks (e.g. `root:***`).

### Layer 4: Reports & PDF Safety
- **Dynamic Derivation**: Sensors and ports derived directly from active telemetry events.
- **Geospatial Precision**: Labeled as "Derived Regional Attack Distribution (GeoIP Reference)".
- **Audit Verification**: SHA-256 digest embedded in document footer.

### Layer 5: Ghost-Net SEC Telemetry Ingestion
- **Transport Security**: Header-only authentication (`Authorization: Bearer <SEC>`, `X-Honeypot-Id`).
- **Timestamp Standardization**: UTC ISO-8601 with Zulu indicator (`Z`) parsed into Java `Instant`.

### Layer 6: Flyway Database Migrations
- **Schema Separation**: Segregated schemas for `honeydata`, `userdata`, `accounts`, and `sessions`.
- **Integrity**: Clean V1-V4 migration script repeatability on disposable database.

### Layer 7: AES-256-GCM Evidence Vault
- **Cryptographic Cipher**: `AES/GCM/NoPadding` with 128-bit authentication tag.
- **Nonce & AAD**: 12-byte cryptographically secure random nonce with Additional Authenticated Data (`tenant_id`, `deployment_id`, `external_event_id`).

### Layer 8: Tenant Isolation
- **Tenant Segregation**: `Tenant-Alpha` and `Tenant-Beta` test accounts strictly isolated.
- **Cross-Honeypot Rejection**: Rejects SEC of Honeypot A when presented with ID of Honeypot B.

### Layer 9: Admin Dashboard Operations
- **Live Endpoints Only**: Zero hardcoded mock arrays in runtime tables.
- **Single-View SEC Warning**: Raw SEC secret shown once upon creation and never returned in cleartext.

### Layer 10: WebSocket Ticket Subprotocol Auth
- **No JWT in URL Query String**: Handshake interceptor accepts authentication via `Sec-WebSocket-Protocol: leukquant-ticket, <ticket>`, `Authorization: Bearer <token>`, and secure cookies.

### Layer 11: Coolify Staging Deployment
- **Container Build Checks**: TypeScript builds compile with 0 errors across `DASHBOARD` and `ADMIN-DASHBOARD`.
- **Java Build Checks**: Maven builds succeed cleanly across `middle-man-1` and `middle-man-3`.
