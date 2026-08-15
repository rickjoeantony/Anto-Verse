# LeukQuant Staging Acceptance & Gatekeeping Checklist
======================================================
**Document Version:** 3.0.0-PRO  
**Target Milestone:** Coolify Staging Deployment & KRP Enterprise Pilot  
**Canonical Directory:** `C:\Users\rickj\.cache\ht\docs\`  
**Date:** 2026-08-15  
**Current Phase Status:** `Locally Tested & Validated / Awaiting Coolify Staging Deployment Logs`  

---

## 1. Quality Gates Assessment Matrix

| Quality Gate | Description | Local Verification | Coolify Staging Verification | Overall Gate Status |
| :--- | :--- | :---: | :---: | :---: |
| **Gate 1: Zero P0/P1 Bugs** | No open Critical or High severity defects in tracker. | ✅ `PASSED` (0 open) | ⏳ `Awaiting Staging` | `Locally Validated` |
| **Gate 2: Static Secrets & Config** | Zero hardcoded credentials, single canonical pepper. | ✅ `PASSED` (0 leaks) | ⏳ `Awaiting Staging` | `Locally Validated` |
| **Gate 3: Honeypot Containment** | Virtual shell containment verified, zero host leakage. | ✅ `PASSED` (257 tests) | ⏳ `Awaiting Staging` | `Locally Validated` |
| **Gate 4: SSH Protocol Interop** | SSH crypto invariants, packet parsing, and ciphers. | ✅ `PASSED` (100% OK) | ⏳ `Awaiting Staging` | `Locally Validated` |
| **Gate 5: Flyway & DB RBAC** | Migrations V1-V4 verified; least-privilege roles enforced. | ✅ `PASSED` (31 tests) | ⏳ `Awaiting Staging` | `Locally Validated` |
| **Gate 6: API Security & CSRF** | Auth tokens, CSRF, Origin headers, and rate limits verified. | ✅ `PASSED` (11 tests) | ⏳ `Awaiting Staging` | `Locally Validated` |
| **Gate 7: Client Dashboard UI** | All 9 routes responsive, accessible, masked creds only. | ✅ `PASSED` (0 errors) | ⏳ `Awaiting Staging` | `Locally Validated` |
| **Gate 8: Admin Dashboard UI** | Single-view agent token policy, role-gated forensic vault. | ✅ `PASSED` (0 errors) | ⏳ `Awaiting Staging` | `Locally Validated` |
| **Gate 9: End-to-End Telemetry** | Controlled event flows from sensor to dashboards. | ✅ `PASSED` (Contract OK)| ⏳ `Awaiting Staging` | `Locally Validated` |
| **Gate 10: Staging Infrastructure** | Coolify staging variables, non-public DB, health checks. | ✅ `Prepared` | ⏳ `Awaiting Staging` | `Prepared` |

---

## 2. Gatekeeping Decisions & Promotion Status

```text
======================================================
  STAGING & PILOT PROMOTION DECISION
======================================================
  1. Local Code & Test Quality:    PASSED (299/299 tests, 0 build errors)
  2. Staging Deployment Status:    Awaiting Coolify Staging Deployment Logs
  3. Staging Promotion Decision:   APPROVED TO DEPLOY TO COOLIFY STAGING
  4. KRP Enterprise Pilot Status:  BLOCKED (Pending Coolify Staging Proof)
======================================================
```

---

## 3. Mandatory Sign-off Criteria for KRP Pilot Promotion

Promotion from Coolify Staging to the KRP Enterprise Pilot requires the following evidence to be pasted into `docs/COOLIFY_STAGING_EXECUTION_LOG.md`:
- [ ] Real Coolify container logs showing Flyway migrations `V1`, `V2`, `V3`, `V4` successfully applied.
- [ ] Output of `SELECT * FROM flyway_schema_history ORDER BY installed_rank;` from Coolify PostgreSQL.
- [ ] Real agent token provisioned via Coolify Admin UI and single-view token display verified.
- [ ] Synthetic event sent from Ghost-Net staging sensor, successfully stored with AES-256-GCM encrypted evidence in `restricted_event_evidence`, and visible masked in `"user data"`.
- [ ] Client & Admin Dashboards successfully connected to staging `middle-man-3` WebSocket feed.
