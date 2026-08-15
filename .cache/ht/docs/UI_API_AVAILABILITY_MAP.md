# LeukQuant UI / API Availability & Integration Map
=====================================================
**Document Version:** 1.0.0-PRO  
**Date:** 2026-08-15  
**Scope:** Client Dashboard (`DASHBOARD`) & Admin Dashboard (`ADMIN-DASHBOARD`)

---

## 1. Overview & Operational Principles

To guarantee enterprise trustworthiness and prevent misleading operators:
1. **Zero Mock Production Data**: No fabricated tenant, agent, event, health, alert policy, forensic evidence, push, or report data will ever be displayed in the UI.
2. **Graceful Degradation & Unavailable States**: If a backend API is not yet provisioned or in-progress, the UI component will render a clean, professional **"Awaiting Backend Service / In Progress"** or **"Service Unavailable"** state rather than crashing or showing fake mock counters.
3. **Strict Null/Undefined Safety**: All canonical event contract fields (e.g. `sensor_classification`, `credentials_masked`, `occurred_at`, `received_at`) are treated as optional with safe fallbacks to prevent crashes on legacy payloads.
4. **Role Gating for Forensic Evidence**: Raw evidence from `restricted_event_evidence` will never appear in standard tables and will remain role-gated with explicit warning dialogs.
5. **No False Push Guarantees**: Web Push notification controls will explicitly declare backend push status and will not claim closed-browser delivery until Phase 6B VAPID backend services are active.

---

## 2. Client Dashboard API Availability Matrix (`DASHBOARD`)

| Page / Widget | Required Endpoint / Protocol | Real Data Source | Availability Status | Fallback State when Unavailable | UI Display Behavior |
| :--- | :--- | :--- | :---: | :--- | :--- |
| **Overview: Deployment Health Card** | `GET /api/dashboard/stats`, `GET /api/health` | `middle-man-3` DashboardService | **LIVE** | Displays "Health status unavailable" | `SHOWN_ACTIVE` |
| **Overview: Critical Incidents Card** | `GET /api/dashboard/stats` | `middle-man-3` (`criticalAlerts`) | **LIVE** | Displays 0 / "No incidents" | `SHOWN_ACTIVE` |
| **Overview: High-Risk Activity Card** | `GET /api/dashboard/stats` | `middle-man-3` (`activeThreats`, `threatLevel`) | **LIVE** | Displays "Calculating risk..." | `SHOWN_ACTIVE` |
| **Overview: Last Event Received** | `GET /api/dashboard/events?limit=1` | `middle-man-3` EventService | **LIVE** | Displays "No events recorded" | `SHOWN_ACTIVE` |
| **Overview: Last Alert Delivered** | `GET /api/dashboard/attacks?limit=1` | `middle-man-3` DashboardService | **LIVE** | Displays "No recent alerts" | `SHOWN_ACTIVE` |
| **Overview: Recommended Next Action** | Derived from highest-severity active event/stat | Frontend policy derived from live stats | **LIVE** | Displays "System operating nominally — continue standard monitoring" | `SHOWN_ACTIVE` |
| **Events: Canonical Table** | `GET /api/dashboard/events` | `middle-man-3` `/api/dashboard/events` (reads `"user data"` view) | **LIVE** | Empty state: "No security events found" | `SHOWN_ACTIVE` |
| **Events: Event Detail Drawer** | `GET /api/events/{id}` or selected row state | `middle-man-3` EventController | **LIVE** | Safe empty fields: `None`, `observe`, `***` | `SHOWN_ACTIVE` |
| **Events: Mark Event Reviewed** | `PATCH /api/events/{id}` | `middle-man-3` EventController | **LIVE** | Toast error: "Failed to update review status" | `SHOWN_ACTIVE` |
| **Incidents: Active Incidents List** | `GET /api/dashboard/attacks` | `middle-man-3` `/api/dashboard/attacks` | **LIVE** | Empty state: "No active security incidents" | `SHOWN_ACTIVE` |
| **Incidents: Download Evidence Report** | `GET /api/reports/pdf` / `GET /api/reports/generate` | `middle-man-3` ReportController | **LIVE** | Button disabled with toast: "Report generation pending" | `SHOWN_ACTIVE` |
| **Reports: Summary & Executive View** | `GET /api/reports/summary`, `GET /api/reports/generate` | `middle-man-3` ReportController | **LIVE** | Empty report card: "Insufficient telemetry for period" | `SHOWN_ACTIVE` |
| **Deployments: Active Sensor Nodes** | `GET /api/dashboard/stats`, `GET /api/auth/profile` | `middle-man-3` User profile & deployment metadata | **IN_PROGRESS** (Transitional string hierarchy) | Shows active profile deployment binding | `SHOWN_ACTIVE` |
| **Settings: Alert Email / Webhooks** | `GET /api/auth/profile`, `PUT /api/auth/profile` | `middle-man-3` UserController | **LIVE** | Displays current profile email and notification thresholds | `SHOWN_ACTIVE` |
| **Settings: Web Push Notification Toggle** | `POST /api/notifications/subscribe` (VAPID backend) | `middle-man-3` Notification Engine (Phase 6B) | **PENDING_PHASE_6B** | Status banner: *"Backend push gateway pending deployment (Phase 6B). In-app browser alerts active."* | `SHOWN_UNAVAILABLE_PENDING` (Toggle disabled / labeled pending) |
| **Live Attack Feed** | `WebSocket /api/ws` | `middle-man-3` LiveAttackWebSocketHandler | **LIVE** | Disconnect indicator: "Live feed reconnecting..." | `SHOWN_ACTIVE` |
| **Global Threat Map** | `GET /api/geo/map` | `middle-man-3` GeoController | **LIVE** | Displays clean map container without points | `SHOWN_ACTIVE` |

---

## 3. Admin Dashboard API Availability Matrix (`ADMIN-DASHBOARD`)

| Page / Widget | Required Endpoint / Protocol | Real Data Source | Availability Status | Fallback State when Unavailable | UI Display Behavior |
| :--- | :--- | :--- | :---: | :--- | :--- |
| **Operations: Active Tenants Card** | `GET /api/admin/analytics` (`totals.total_accounts`) | Express Backend `server.js` | **LIVE** | Displays `--` with retry button | `SHOWN_ACTIVE` |
| **Operations: Total Events in 24h** | `GET /api/admin/analytics` (`totals.total_events`, `hourly`) | Express Backend `server.js` | **LIVE** | Displays 0 / "No 24h activity" | `SHOWN_ACTIVE` |
| **Operations: Critical Threats Metric** | `GET /api/admin/analytics` (`totals.critical`) | Express Backend `server.js` | **LIVE** | Displays 0 | `SHOWN_ACTIVE` |
| **Operations: Blocked Attacks Metric** | `GET /api/admin/analytics` (`totals.blocked`) | Express Backend `server.js` | **LIVE** | Displays 0 | `SHOWN_ACTIVE` |
| **Operations: Failed Telemetry & Quarantine Card** | `GET /api/admin/quarantine/count` | `middle-man-1` / DB `ingestion_quarantine` | **IN_PROGRESS** (Table created in Phase 6A) | Status badge: *"Quarantine retention engine active (14-day TTL)"* | `SHOWN_ACTIVE` |
| **Operations: Pending Agent Registrations** | `GET /api/admin/agents/pending` | `middle-man-1` / DB `agents` | **IN_PROGRESS** (Table created in Phase 6A) | Displays current active agent count from database | `SHOWN_ACTIVE` |
| **Tenants: Customer Accounts Table** | `GET /api/admin/accounts` | Express Backend `server.js` (`accounts` & `profiles`) | **LIVE** | Empty table: "No customer accounts found" | `SHOWN_ACTIVE` |
| **Tenants: Create / Suspend / Auto-Pause Account** | `POST /api/admin/accounts`, `PATCH /api/admin/accounts/:user` | Express Backend `server.js` | **LIVE** | Error toast on failure | `SHOWN_ACTIVE` |
| **Deployments: Global Deployment Inventory** | `GET /api/admin/deployments` | Express Backend `server.js` | **LIVE** (Derived from honeypot IDs and accounts) | Lists detected deployment nodes | `SHOWN_ACTIVE` |
| **Agents: Token Lifecycle & Health** | `GET /api/admin/agents` | `middle-man-1` DB `agents` table | **IN_PROGRESS** | Displays agent schema bounds and token rotation guide | `SHOWN_ACTIVE` |
| **Events & Incidents: Global Feed** | `GET /api/admin/events` | Express Backend `server.js` (reads `"user data"` view) | **LIVE** | Empty state: "No events recorded" | `SHOWN_ACTIVE` |
| **Events: Restricted Forensic Evidence Vault** | `GET /api/admin/evidence/{id}` | `middle-man-1` `restricted_event_evidence` (Phase 6B/RBAC) | **PENDING_RBAC_PHASE_6B** | Access-gated dialog: *"Forensic evidence is encrypted at rest. Requires forensic_evidence_reader database credentials and explicit audit log authorization."* | `ROLE_GATED_LOCKED` (Role-gated modal, raw credentials never displayed without key) |
| **Alert Policies: Routing Configuration** | `GET /api/admin/alerts`, `POST /api/admin/alerts` | Express Backend `server.js` | **LIVE** | Displays active routing policies | `SHOWN_ACTIVE` |
| **Audit Logs: Retention Purge History** | `GET /api/admin/audit/cleanup` | `middle-man-1` DB `cleanup_audit_log` | **IN_PROGRESS** (Table created in Phase 6A) | Displays: *"Retention purge scheduled nightly at 02:00 UTC"* | `SHOWN_ACTIVE` |
| **System Health: Database Diagnostics & Cloning** | `GET /api/admin/database/overview`, `POST /api/admin/database/clone` | Express Backend `server.js` | **LIVE** | Displays PostgreSQL connection pool status and schema version | `SHOWN_ACTIVE` |

---

## 4. Route Preservation & Backward Compatibility Matrix

### Client Dashboard Routes (`DASHBOARD`)
- `/dashboard` $\rightarrow$ **Overview** (Preserved)
- `/events` $\rightarrow$ **Events** (Preserved)
- `/map` $\rightarrow$ **Threat Map** (Preserved)
- `/live` $\rightarrow$ **Live Event Feed** (Preserved)
- `/alerts` $\rightarrow$ **Incidents & Alerts** (Preserved)
- `/reports` $\rightarrow$ **Reports** (Preserved)
- `/settings` $\rightarrow$ **Settings** (Preserved)
- `/incidents` $\rightarrow$ **Incidents** (New direct route, `/alerts` also points here or aliases)
- `/deployments` $\rightarrow$ **Deployments** (New direct route)

### Admin Dashboard Routes (`ADMIN-DASHBOARD`)
- `/operations` $\rightarrow$ **Operations Overview** (New primary route, `/` redirects here)
- `/accounts` or `/tenants` $\rightarrow$ **Tenants & Accounts** (Preserved with alias)
- `/deployments` $\rightarrow$ **Deployments** (New dedicated route)
- `/agents` $\rightarrow$ **Agents & Tokens** (New dedicated route)
- `/events` $\rightarrow$ **Global Events** (New dedicated route)
- `/alerts` $\rightarrow$ **Alert Policies** (Preserved)
- `/reports` $\rightarrow$ **Reports & Retention** (New dedicated route)
- `/audit-logs` $\rightarrow$ **Audit Logs** (New dedicated route)
- `/database` or `/system-health` $\rightarrow$ **System Health** (Preserved with alias)

---

## 5. Security & Data Integrity Invariants

1. **No Client Database Direct Access**: No frontend JavaScript or React component interacts directly with PostgreSQL. All data queries flow through authenticated API endpoints (`middle-man-3` or `ADMIN-DASHBOARD/backend`).
2. **Credential Sanitization in UI**: Frontend components only receive and display `credentials_masked` (e.g. `admin:***`). Raw plaintext passwords are never queried, cached, or logged in frontend state.
3. **Tenant Scoping Enforcement**: All client requests carry Bearer JWT tokens containing `tenantId` / `detectedBy`. `middle-man-3` restricts queries to the caller's tenant boundary.
