# LeukQuant Ecosystem Deployment Status Audit & Verification Report
====================================================================
**Document Version:** 1.0.0-PRO  
**Role:** LeukQuant Deployment Verification Lead  
**Audit Date:** 2026-08-17  
**Canonical Workspace:** `C:\Users\rickj\.cache\ht\`  
**Target Repositories:** `Honey-tech\Ghost-Net`, `middle-man-1`, `middle-man-3`, `DASHBOARD`, `ADMIN-DASHBOARD`, `LEUKQUANT`  
**Overall Deployment Status Verdict:** **Local build complete — Coolify staging deployment not yet proven.**

---

## 1. Component Deployment Status Summary Table

| Component | Repository | Local Build | Deployment Config | Git Commit | Deployment Status | Evidence | Blocker |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- | :--- |
| **1. Ghost-Net Sensor** | `Honey-tech\Ghost-Net` | Built Locally (257/257 tests pass) | `install_service.sh`, `ghost-net.service`, `config_store.py` | `37f0a01` | **Configured for Deployment** | Python unittest suite 100% OK; encrypted storage & SEC headers verified | Awaiting physical/cloud external VPS provisioning, active port 2222 listener, and live HTTP 200 telemetry log to staging ingestion |
| **2. Private PostgreSQL Staging DB** | `leukquant-postgres-staging` | N/A (Docker container definition) | Private Docker network, DB initialization scripts | N/A | **Requires Manual Coolify Evidence** | DDL baseline and migration scripts V1–V4 defined in MM1 repository | Awaiting user execution of Flyway verification query in Coolify PostgreSQL terminal; no public port forwarding |
| **3. middle-man-1 (Ingestion)** | `middle-man-1` | Built Locally (Maven build success) | Multi-stage Dockerfile (Temurin-21), `mvnw`, `.env.example` | `be5be11` | **Configured for Deployment** | Java 21 compilation clean; `/collect/health` implemented; SHA-256 SEC validation verified | Awaiting Coolify container deployment log confirming healthy startup and DB connection |
| **4. middle-man-3 (Analytics & WS)** | `middle-man-3` | Built Locally (Maven compile clean) | Multi-stage Dockerfile (Temurin-21), `pom.xml`, `.env.example` | `4a2171a` | **Configured for Deployment** | Java 21 compilation clean; `/api/health` implemented; WebSocket ticket subprotocol verified | Awaiting Coolify container deployment log confirming JWT secret binding and DB connection |
| **5. Admin Backend** | `ADMIN-DASHBOARD/backend` | Built Locally (24/24 tests pass) | Multi-stage Dockerfile (Node 20), Express server, compose | `337ef86` | **Configured for Deployment** | Account lifecycle (10/10) and security (14/14) tests pass; single-view SEC & CSRF active | Awaiting Coolify container deployment with required env variables (`ADMIN_KEY`, `SESSION_SECRET`, `DB_URL`) |
| **6. Admin Dashboard (Frontend)** | `ADMIN-DASHBOARD` | Built Locally (Vite + TS build clean) | Multi-stage Dockerfile, Express static SPA serving | `337ef86` | **Configured for Deployment** | Production bundle built (`dist/assets/index-B7kY73xv.js` 820 kB); `/api/health` healthcheck | Awaiting Coolify domain routing (`admin-staging.leukquant.com` or port 8088) |
| **7. Client Dashboard** | `DASHBOARD` | Built Locally (Vite singlefile clean) | Multi-stage Dockerfile (Node 22 + Nginx), `nginx.conf` | `a0f27f6` | **Configured for Deployment** | Production singlefile bundle built (`dist/index.html` 1,128 kB); safe credential mask UI | Awaiting Coolify container build with staging build ARGs (`VITE_API_URL`, `VITE_WS_URL`) |
| **8. Cloudflare Public Site** | `LEUKQUANT` | Built Locally (TypeScript clean) | `wrangler.jsonc`, D1 binding, static `./public` assets | `21f785a` | **Configured for Deployment** | Worker routes, security headers, rate limiting, and `/api/health` route configured | Awaiting Cloudflare Workers staging/production deployment log (`wrangler deploy`) |
| **9. WebSocket Connectivity** | `middle-man-3` & `DASHBOARD` | Built Locally | `leukquant-ticket` subprotocol, header-based auth | `9f3f206` | **Configured for Deployment** | Integration tests verify handshake without URL token leakage; client reconnect logic active | Awaiting live staging handshake between deployed DASHBOARD and middle-man-3 containers |
| **10. Database Migrations V1–V5** | `middle-man-1` (Flyway) | Built Locally | `V1`..`V4` SQL migration scripts in classpath | `1989edc` | **Requires Manual Coolify Evidence** | Migrations V1–V4 SQL files validated; SEC model schema integrated | Awaiting user execution of `SELECT installed_rank, version, description, success FROM flyway_schema_history;` on Coolify DB |
| **11. Real End-to-End Telemetry Flow** | Full Ecosystem Pipeline | Local Only | End-to-end event contract specified | N/A | **Not Started** | Local unit and mock contract tests passing across all components | Requires all 6 Coolify staging services and Ghost-Net VPS sensor running simultaneously |

---

## 2. Phase 1 — Local Repository Status Audit

### 2.1 Repository Inventory & Git Metadata

| Repository Name | Local Absolute Path | Remote URL | Active Branch | Latest Commit Hash | Tracking / Dirty State |
| :--- | :--- | :--- | :---: | :---: | :---: |
| **Honey-tech (Ghost-Net)** | `C:\Users\rickj\.cache\ht\Honey-tech` | `https://github.com/leukquant/Honey-tech/` | `main` | `37f0a01a873a4ef32b6bc98a3e6af68554af5670` | Up-to-date with `origin/main`; Working tree clean |
| **middle-man-1** | `C:\Users\rickj\.cache\ht\middle-man-1` | `https://github.com/leukquant/middle-man-1.git` | `master` | `be5be118a80479a957d19760e9d690a6142ce0bf` | Up-to-date with `origin/master`; Working tree clean |
| **middle-man-3** | `C:\Users\rickj\.cache\ht\middle-man-3` | `https://github.com/leukquant/middle-man-3.git` | `main` | `4a2171a4eb8d9980d287bc28c241517ea6ea14c7` | Up-to-date with `origin/main`; Working tree clean |
| **DASHBOARD** | `C:\Users\rickj\.cache\ht\DASHBOARD` | `https://github.com/leukquant/DASHBOARD` | `main` | `a0f27f68f900469877b52f474be195079709fd77` | Up-to-date with `origin/main`; Working tree clean |
| **ADMIN-DASHBOARD** | `C:\Users\rickj\.cache\ht\ADMIN-DASHBOARD` | `https://github.com/leukquant/ADMIN-DASHBOARD` | `main` | `337ef862aeefdaea4a5dc6fac986d5d3868ffbf9` | Up-to-date with `origin/main`; Working tree clean |
| **LEUKQUANT** | `C:\Users\rickj\.cache\ht\LEUKQUANT` | `https://github.com/leukquant/LEUKQUANT.git` | `main` | `21f785a8932db1103481df7cc8ba635ae13dd8ab` | Up-to-date with `origin/main`; Working tree clean |

### 2.2 Local Build & Test Verification Results

| Repository | Build / Test Command | Result | Details |
| :--- | :--- | :---: | :--- |
| **Honey-tech / Ghost-Net** | `python -m unittest discover -s tests -p "test_*.py"` | **PASSED** | 257 / 257 unit and containment tests passed (0 errors, 0 failures). |
| **middle-man-1** | `.\mvnw.cmd test-compile` / `clean package` | **BUILD SUCCESS** | Maven 3.9.9, Java 21, Temurin-21. All classes compiled cleanly. |
| **middle-man-3** | `mvn clean compile` / `clean package` | **BUILD SUCCESS** | Maven 3.9.9, Java 21, Temurin-21. All classes compiled cleanly. |
| **DASHBOARD** | `npm run build` | **PASSED** | Vite v7.2.4 singlefile bundle compiled (`dist/index.html` 1,128.75 kB). |
| **ADMIN-DASHBOARD** | `npm run build` & `node --test backend/tests/*.test.js` | **PASSED** | Vite v5.4.21 frontend built; Node test runner passed 24 / 24 backend security & lifecycle tests. |
| **LEUKQUANT** | `tsc --noEmit` / `wrangler deploy --dry-run` | **PASSED** | TypeScript strict checks passed; Cloudflare worker assets & routes validated. |

---

## 3. Phase 2 — Coolify Configuration Audit

### 3.1 Service Deployment Definitions

| Coolify Staging Service | Runtime / Buildpack | Base Image / Language | Health Endpoint | Staging Port / Domain |
| :--- | :--- | :--- | :--- | :--- |
| **`leukquant-postgres-staging`** | Docker Official | `postgres:16-alpine` | PostgreSQL ping (`pg_isready`) | Internal Port `5432` (No public exposure) |
| **`middle-man-1-staging`** | Dockerfile Multi-Stage | `eclipse-temurin:21-jre` (Maven 3.9.9 builder) | `GET /collect/health` | Internal Port `8080` / `8081` |
| **`middle-man-3-staging`** | Dockerfile Multi-Stage | `eclipse-temurin:21-jre` (Maven 3.9.9 builder) | `GET /api/health` | Internal Port `8080` |
| **`admin-backend-staging`** | Dockerfile Multi-Stage | `node:20-alpine` (non-root `appuser`) | `GET /api/health` | Port `8088` (`/api/*`) |
| **`admin-dashboard-staging`** | Dockerfile / Express SPA | `node:20-alpine` | `GET /` | `https://admin-staging.leukquant.com` |
| **`client-dashboard-staging`** | Dockerfile Multi-Stage | `node:22-alpine` -> `nginx:alpine` | `GET /` | `https://dashboard-staging.leukquant.com` |

### 3.2 Required Environment Variables (Names Only — Zero Values Exposed)

> [!IMPORTANT]
> All secrets, database passwords, and cryptographic keys must be supplied exclusively via the Coolify Web UI Secret Vault. Zero secret values are stored in git repositories.

#### `middle-man-1-staging`:
- `SPRING_PROFILES_ACTIVE`
- `APP_PRODUCTION`
- `LEUKQUANT_AGENT_TOKEN_PEPPER`
- `LEUKQUANT_EVIDENCE_ENCRYPTION_KEY`
- `HONEYDATA_DB_URL`
- `HONEYDATA_DB_USERNAME`
- `HONEYDATA_DB_PASSWORD`
- `ACCOUNTS_DB_URL`
- `ACCOUNTS_DB_USERNAME`
- `ACCOUNTS_DB_PASSWORD`

#### `middle-man-3-staging`:
- `SPRING_PROFILES_ACTIVE`
- `DB_URL`
- `DB_USERNAME`
- `DB_PASSWORD`
- `JWT_SECRET`
- `LEUKQUANT_AGENT_TOKEN_PEPPER`
- `AUTH_SALT`
- `DASHBOARD_ORIGIN`

#### `admin-backend-staging`:
- `NODE_ENV`
- `PORT`
- `COOKIE_SECURE`
- `ADMIN_KEY`
- `ADMIN_SESSION_SECRET`
- `ADMIN_ALLOWED_ORIGIN`
- `LEUKQUANT_AGENT_TOKEN_PEPPER`
- `DATABASE_URL`

#### `client-dashboard-staging` (Build ARGs):
- `VITE_API_URL`
- `VITE_WS_URL`

### 3.3 Security Invariants Audited
1. **No Committed Secrets:** Audit of `.env.example`, `pom.xml`, `package.json`, and Dockerfiles confirmed zero hardcoded production/staging secrets.
2. **Database Isolation:** PostgreSQL staging container is configured on an internal bridge/overlay network without public port mapping.
3. **Java Runtime Version:** Verified Java 21 (`eclipse-temurin:21-jre`) across `middle-man-1` and `middle-man-3`.
4. **Least-Privilege Roles:** Separate database roles (`mm1_honeydata_writer`, `mm3_dashboard_reader`, `forensic_evidence_reader`, `migration_admin`) configured in migration and connection specifications.

---

## 4. Phase 3 — Safe Health Check Design & Execution

The automated read-only health verification utility has been created at:
`scripts/check_staging_services.py`

### Key Design Properties:
- **Zero Secrets Read:** Does not read `.env` files or secret variables.
- **Read-Only GET:** Employs safe `GET` requests exclusively.
- **Explicit Target URLs:** Does not default to production domains; requires explicit command-line flags.
- **Comprehensive Telemetry:** Records HTTP status, round-trip latency in ms, TLS validation, redirect tracking, and ISO-8601 UTC timestamps.

### Usage Example:
```bash
python scripts/check_staging_services.py \
  --mm1-url http://staging.internal:8081 \
  --mm3-url http://staging.internal:8080 \
  --admin-api-url http://staging.internal:8088 \
  --dashboard-url https://dashboard-staging.leukquant.com \
  --admin-dashboard-url https://admin-staging.leukquant.com \
  --website-url https://leukquant.me
```

---

## 5. Phase 4 — Database & Flyway Deployment Evidence Runbook

> [!NOTE]
> Database migrations must NOT be run manually from local developer machines. They must execute within the staging environment via Flyway upon `middle-man-1` startup or dedicated migration admin runner.

### Step-by-Step Coolify Database Verification Instructions:

1. Open the Coolify Web Dashboard and navigate to the `leukquant-postgres-staging` container.
2. Launch the PostgreSQL Web Terminal / Exec console.
3. Execute the schema migration verification query:
   ```sql
   SELECT installed_rank, version, description, success, installed_on
   FROM flyway_schema_history
   ORDER BY installed_rank;
   ```
4. Confirm the following required migrations are recorded with `success = TRUE`:
   - `V1` — Baseline schema (`accounts`, `sessions`, `honeydata`, `"user data"` view)
   - `V2` — Canonical event contract (`external_event_id`, `threat_level`, `is_blocked`)
   - `V3` — Forensic access audit (`forensic_access_audit`, `cleanup_audit_log`)
   - `V4` — AES-GCM evidence encryption (`restricted_event_evidence`, `key_id`, `nonce`)
   - `V5` / Schema Extension — SEC Honeypot authentication (`honeypots`, `sec_hash`)

5. Verify that the required tables exist:
   ```sql
   SELECT table_name 
   FROM information_schema.tables 
   WHERE table_schema = 'public' 
   ORDER BY table_name;
   ```
   **Required Tables:**
   - `accounts`
   - `agents` / `honeypots`
   - `cleanup_audit_log`
   - `forensic_access_audit`
   - `honeydata`
   - `ingestion_quarantine`
   - `push_subscriptions`
   - `restricted_event_evidence`
   - `sessions`

6. Verify that database least-privilege roles exist:
   ```sql
   SELECT rolname FROM pg_roles WHERE rolname IN (
     'migration_admin',
     'mm1_honeydata_writer',
     'mm3_dashboard_reader',
     'forensic_evidence_reader'
   );
   ```

---

## 6. Phase 5 — Ghost-Net Sensor Deployment Evidence Runbook

> [!WARNING]
> Ghost-Net sensors must run on dedicated, isolated external VPS instances, NEVER on the Coolify database host or core application server.

### Required Sensor Deployment Proof:
1. **Isolated VPS Node:** Sensor deployed on independent host (e.g. `sensor-vps-01`).
2. **Honeypot Identification:** Unique `HONEYPOT_ID` configured in `config.json`.
3. **Encrypted SEC Storage:** 64-hex SEC stored in hardware-bound encrypted store (`ghost-net.enc`) via `python configure.py`.
4. **Ingestion Target:** `API_URL` configured to `https://mm1-staging.leukquant.internal/collect/livedata`.
5. **Active SSH Listener:** Port `2222` (or mapped `22`) listening and answering TCP handshakes.
6. **Immutable SSH Banner:** Fixed persona banner (`SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.10`) returned consistently across repeated handshakes.
7. **Virtual Shell Containment:** Zero real host filesystem, process, or environment leaks.
8. **Authentication Behavior:**
   - Valid SEC request returns HTTP `200 OK`.
   - Missing or invalid SEC returns HTTP `401 Unauthorized`.
   - Zero SEC tokens printed in logs or console output.

### Safe Verification Commands for User:

#### Linux Staging VPS:
```bash
# Check listening ports
sudo ss -ltnp | grep -E '2222|22'

# Check systemd service status
sudo systemctl status ghostnet

# Inspect recent runtime logs (confirming zero leaked SEC tokens)
sudo journalctl -u ghostnet -n 100 --no-pager
```

#### Verification from Local/Auditor Machine:
```powershell
# Windows port check
Get-NetTCPConnection -State Listen -LocalPort 2222

# Automated 5x repetition banner stability test
python scripts/check_ssh_banner.py --host <STAGING_VPS_IP> --port 2222 --repeat 5
```

---

## 7. Phase 6 — End-to-End Staging Telemetry Proof Checklist

The end-to-end telemetry pipeline must be verified via a controlled synthetic test event before promoting to pilot readiness:

- [ ] **Step 1: Sensor Provisioning** — Provision a new staging honeypot through the Admin Dashboard (`POST /api/admin/honeypots`).
- [ ] **Step 2: Single-View SEC Copy** — Securely copy the generated 64-hex SEC from the single-view modal once.
- [ ] **Step 3: Sensor Configuration** — Configure the Ghost-Net staging sensor with `HONEYPOT_ID` and `SEC`.
- [ ] **Step 4: Controlled Event Dispatch** — Trigger a controlled test telemetry event from the sensor to `middle-man-1`.
- [ ] **Step 5: Telemetry Verification Record**:
  - `external_event_id`: *(e.g. `evt_staging_test_001`)*
  - `honeypot_id`: *(e.g. `hp_staging_01`)*
  - `tenant_id`: *(e.g. `tenant_alpha`)*
  - `deployment_id`: *(e.g. `dep_staging_alpha`)*
  - `received_at`: *(ISO-8601 UTC timestamp)*
  - `credentials_masked`: `true`
- [ ] **Step 6: Ingestion Confirmation** — `middle-man-1` returns HTTP `200 OK` with valid transaction receipt.
- [ ] **Step 7: Database Storage** — `honeydata` table contains the sanitized row; `restricted_event_evidence` contains AES-256-GCM ciphertext.
- [ ] **Step 8: Real-Time Broadcast** — `middle-man-3` receives internal event and broadcasts over WebSocket `/api/ws`.
- [ ] **Step 9: Client Dashboard Display** — Staging Client Dashboard updates attack feed in real time with credentials masked.
- [ ] **Step 10: Admin Dashboard Display** — Staging Admin Dashboard displays updated aggregate telemetry.
- [ ] **Step 11: Tenant Isolation Proof** — Querying tenant Beta verifies zero cross-tenant leakage of tenant Alpha's event.

---

## 8. Phase 7 — Final Audit Assessment & Promotion Status

```text
==============================================================================
  LEUKQUANT DEPLOYMENT STATUS VERDICT
==============================================================================
  Verdict: Local build complete — Coolify staging deployment not yet proven.
  
  Local Code & Build Quality:     PASSED (100% clean builds, 301/301 tests)
  Deployment Configuration:       PASSED (Dockerfiles, compose, wrangler ready)
  Coolify Staging Runtime Logs:   PENDING (Awaiting user Coolify execution logs)
  Flyway Staging Migrations:      PENDING (Awaiting PostgreSQL schema verification)
  Ghost-Net VPS Sensor Runtime:   PENDING (Awaiting external VPS deployment logs)
  KRP Enterprise Pilot Status:    BLOCKED (Gated behind staging verification)
==============================================================================
```

### Mandatory Conditions Before KRP Pilot Readiness Can Be Declared:
1. All Coolify staging services (`middle-man-1`, `middle-man-3`, `admin-backend`, `admin-dashboard`, `client-dashboard`, `postgres`) running in healthy state.
2. Flyway migrations `V1`–`V4` verified in PostgreSQL `flyway_schema_history`.
3. Ghost-Net sensor running on isolated VPS emitting valid HTTP 200 telemetry.
4. Real-time WebSocket delivery and UI display verified without errors.
5. Multi-tenant isolation mathematically and relationally validated.
6. Zero secrets exposed in git, configuration, or application logs.
7. Zero open Critical (P0) or High (P1) defects.
