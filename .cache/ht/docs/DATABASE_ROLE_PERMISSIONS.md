# LeukQuant Database Role Permissions & Least Privilege Matrix
==============================================================
**Document Version:** 2.1.0-PRO  
**Status:** Canonical Security Specification  
**Environment:** Staging / Production PostgreSQL Tier

---

## 1. Overview & Principle of Least Privilege

The LeukQuant database security model enforces strict **separation of duties** and **least privilege access control**. Database roles are segregated by operational function:

- **Ingestion Writers** (`mm1_honeydata_writer`): May only insert telemetry and vault evidence. They cannot mutate existing telemetry or access administrative configurations.
- **Dashboard & API Readers** (`mm3_dashboard_reader`): May only read masked analytical projections via the `"user data"` view. They are explicitly denied access to raw captured credential material and forensic vaults.
- **Forensic Evidence Investigators** (`forensic_evidence_reader`): Dedicated audited role with restricted read-only access to `restricted_event_evidence`. Forensic evidence at rest is encrypted with **AES-256-GCM**; accessing the ciphertext requires database role authorization and the active key ring from secret storage with deterministic AAD context.
- **Migration & DDL Admin** (`migration_admin`): Dedicated deployment role for applying schema migrations.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                               DATABASE ROLE BOUNDARIES                                 │
├──────────────────────────┬─────────────────────────────┬───────────────────────────────┤
│ Ingestion Role           │ Analytics / Dashboard Role  │ Forensic Evidence Role        │
│ (mm1_honeydata_writer)   │ (mm3_dashboard_reader)      │ (forensic_evidence_reader)    │
├──────────────────────────┼─────────────────────────────┼───────────────────────────────┤
│ • INSERT on honeydata    │ • SELECT on "user data" VIEW│ • Audited SELECT on           │
│ • INSERT on quarantine   │ • SELECT on accounts        │   restricted_event_evidence   │
│ • INSERT on evidence     │ • CRUD on sessions          │ • Audited SELECT on           │
│ • SELECT on agents       │ • CRUD on push_subscriptions│   honeydata base table        │
│ ❌ NO access to accounts │ ❌ DENIED raw credentials   │ ❌ NO access to sessions or   │
│ ❌ NO UPDATE/DELETE on HD│ ❌ DENIED evidence vault    │    push subscriptions         │
└──────────────────────────┴─────────────────────────────┴───────────────────────────────┘
```

---

## 2. Role Permissions Matrix

| Database Object | Object Type | `migration_admin` | `mm1_honeydata_writer` | `mm3_dashboard_reader` | `forensic_evidence_reader` |
| :--- | :--- | :---: | :---: | :---: | :---: |
| **`honeydata`** | Base Table | ALL (DDL/DML) | `INSERT`, `SELECT` | ❌ **DENIED** | `SELECT` |
| **`restricted_event_evidence`** | Base Table (AES-GCM Vault) | ALL (DDL/DML) | `INSERT`, `SELECT`, `DELETE` (TTL) | ❌ **DENIED** | `SELECT` |
| **`ingestion_quarantine`** | Base Table | ALL (DDL/DML) | `INSERT`, `SELECT`, `DELETE` (TTL) | ❌ **DENIED** | ❌ **DENIED** |
| **`cleanup_audit_log`** | Base Table | ALL (DDL/DML) | `INSERT`, `SELECT` | `SELECT` | `SELECT` |
| **`forensic_access_audit`** | Base Table | ALL (DDL/DML) | `INSERT`, `SELECT` | ❌ **DENIED** | `SELECT` |
| **`agents`** | Base Table | ALL (DDL/DML) | `SELECT` | `SELECT` | ❌ **DENIED** |
| **`accounts`** | Base Table | ALL (DDL/DML) | ❌ **DENIED** | `SELECT` | ❌ **DENIED** |
| **`profiles`** | Base Table | ALL (DDL/DML) | ❌ **DENIED** | `SELECT`, `INSERT`, `UPDATE` | ❌ **DENIED** |
| **`sessions`** | Base Table | ALL (DDL/DML) | ❌ **DENIED** | `SELECT`, `INSERT`, `UPDATE`, `DELETE` | ❌ **DENIED** |
| **`push_subscriptions`** | Base Table | ALL (DDL/DML) | ❌ **DENIED** | `SELECT`, `INSERT`, `UPDATE`, `DELETE` | ❌ **DENIED** |
| **`"user data"`** | View | ALL | ❌ **DENIED** | `SELECT` | `SELECT` |
| **Sequences (`*_seq`)** | Sequences | USAGE | `USAGE` | `USAGE` (sessions/push) | ❌ **DENIED** |

---

## 3. PostgreSQL Role Setup & Grant Scripts

```sql
-- ============================================================================
-- LEUKQUANT POSTGRESQL LEAST PRIVILEGE CONFIGURATION
-- ============================================================================

-- 1. Create Application Roles (Without superuser privileges)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mm1_honeydata_writer') THEN
        CREATE ROLE mm1_honeydata_writer WITH LOGIN PASSWORD 'change-me-writer-pwd';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mm3_dashboard_reader') THEN
        CREATE ROLE mm3_dashboard_reader WITH LOGIN PASSWORD 'change-me-reader-pwd';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'forensic_evidence_reader') THEN
        CREATE ROLE forensic_evidence_reader WITH LOGIN PASSWORD 'change-me-forensic-pwd';
    END IF;
END $$;

-- 2. Revoke Public Default Privileges
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO mm1_honeydata_writer, mm3_dashboard_reader, forensic_evidence_reader;

-- 3. Configure mm1_honeydata_writer Permissions
GRANT INSERT, SELECT ON TABLE "honeydata" TO mm1_honeydata_writer;
GRANT INSERT, SELECT, DELETE ON TABLE "ingestion_quarantine" TO mm1_honeydata_writer;
GRANT INSERT, SELECT, DELETE ON TABLE "restricted_event_evidence" TO mm1_honeydata_writer;
GRANT INSERT, SELECT ON TABLE "cleanup_audit_log" TO mm1_honeydata_writer;
GRANT SELECT ON TABLE "agents" TO mm1_honeydata_writer;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO mm1_honeydata_writer;

-- Strictly revoke UPDATE/DELETE on honeydata for writer
REVOKE UPDATE, DELETE ON TABLE "honeydata" FROM mm1_honeydata_writer;

-- 4. Configure mm3_dashboard_reader Permissions (Dashboard & Threat Intelligence)
GRANT SELECT ON TABLE "user data" TO mm3_dashboard_reader;
GRANT SELECT ON TABLE "accounts" TO mm3_dashboard_reader;
GRANT SELECT, INSERT, UPDATE ON TABLE "profiles" TO mm3_dashboard_reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE "sessions" TO mm3_dashboard_reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE "push_subscriptions" TO mm3_dashboard_reader;
GRANT SELECT ON TABLE "cleanup_audit_log" TO mm3_dashboard_reader;
GRANT USAGE, SELECT ON SEQUENCE "sessions_id_seq", "push_subscriptions_id_seq" TO mm3_dashboard_reader;

-- Explicitly revoke access to raw tables for reader
REVOKE ALL ON TABLE "honeydata" FROM mm3_dashboard_reader;
REVOKE ALL ON TABLE "restricted_event_evidence" FROM mm3_dashboard_reader;
REVOKE ALL ON TABLE "ingestion_quarantine" FROM mm3_dashboard_reader;

-- 5. Configure forensic_evidence_reader Permissions
GRANT SELECT ON TABLE "restricted_event_evidence" TO forensic_evidence_reader;
GRANT SELECT ON TABLE "honeydata" TO forensic_evidence_reader;
GRANT SELECT ON TABLE "cleanup_audit_log" TO forensic_evidence_reader;
GRANT SELECT, INSERT ON TABLE "forensic_access_audit" TO forensic_evidence_reader;

REVOKE ALL ON TABLE "sessions" FROM forensic_evidence_reader;
REVOKE ALL ON TABLE "push_subscriptions" FROM forensic_evidence_reader;
REVOKE ALL ON TABLE "accounts" FROM forensic_evidence_reader;
```

---

## 4. Staging Permission Validation Checks

To verify role enforcement on staging before go-live, execute the following permission validation suite:

```sql
-- Test 1: mm3_dashboard_reader CAN read "user data" view
SET ROLE mm3_dashboard_reader;
SELECT event_id, attacker_ip, credentials_masked FROM "user data" LIMIT 1;

-- Test 2: mm3_dashboard_reader CANNOT read honeydata base table (MUST FAIL with 42501)
-- Expected error: permission denied for table honeydata
SELECT * FROM "honeydata" LIMIT 1;

-- Test 3: mm3_dashboard_reader CANNOT read restricted_event_evidence (MUST FAIL with 42501)
-- Expected error: permission denied for table restricted_event_evidence
SELECT * FROM "restricted_event_evidence" LIMIT 1;

-- Test 4: mm1_honeydata_writer CANNOT update honeydata (MUST FAIL with 42501)
SET ROLE mm1_honeydata_writer;
UPDATE "honeydata" SET "notes" = 'tampered' WHERE "event_id" = 1;

-- Reset role
RESET ROLE;
```
