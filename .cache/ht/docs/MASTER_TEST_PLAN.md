# LeukQuant Master Test Plan & Operational QA Specification
============================================================
**Document Version:** 1.0.0-PRO  
**Status:** Canonical Operational QA Specification  
**Environment Scope:** Local Development, Disposable Databases, Coolify Staging, Staging VPS

---

## 1. Objective & Scope

The objective of this Master Test Plan is to **systematically identify, prioritise, reproduce, and remediate known defects and high-risk failure conditions across the LeukQuant staging scope** prior to Coolify staging and the KRP enterprise pilot.

### Target Systems Under Test (SUT):
- **Telemetry Honeypot Engine**: `Honey-tech/Ghost-Net` (Python 3.10+)
- **Telemetry Ingestion Engine**: `middle-man-1` (Java 21, Spring Boot 3.4, Flyway)
- **Real-Time Analytics Engine**: `middle-man-3` (Java 21, Spring Boot, WebSocket)
- **Client Security Dashboard**: `DASHBOARD` (React, TypeScript, Vite, TailwindCSS)
- **Platform Operations Admin Dashboard**: `ADMIN-DASHBOARD` (React, Vite, Node Express Backend)
- **Edge Analytics & Workers**: `LEUKQUANT` (TypeScript, Cloudflare Workers / Node)

---

## 2. Testing Safety & Operational Rules

1. **No feature additions**: Maintain existing architectural boundaries.
2. **Local & Staging restriction**: All testing is restricted to `localhost`, disposable databases, Coolify staging, and staging VPS.
3. **No destructive floods or production migrations**: No high-volume connection floods, destructive cleanups, or public third-party scanning.
4. **Zero credential leakage**: Never use real customer data. Never log raw passwords, encryption keys, token hashes, or database secrets.

---

## 3. Bug Classification & Severity Criteria

| Severity Level | Definition | Mandatory Resolution SLA |
| :--- | :--- | :--- |
| **P0 - Critical** | Severe security flaw, data exposure, credential leak, or complete system compromise. | Immediate fix & mandatory regression test before any further testing. |
| **P1 - High** | Primary functional workflow broken (e.g. sensor cannot dispatch, dashboard cannot render live data). | Required fix & regression test before staging promotion. |
| **P2 - Medium** | Non-critical feature failure, edge-case UI error, or partial degradation. | Addressed during QA remediation cycle. |
| **P3 - Low** | Minor visual defect, spacing anomaly, or documentation typo. | Tracked and addressed without blocking deployment. |

---

## 4. Test Layers Matrix

### Layer 1: Static Code, Secret & Configuration Audit
- `TC-L1-01`: Scan for committed secrets, credentials, or default passwords (`password=`, `change-me`).
- `TC-L1-02`: Verify absence of Base64 pseudo-encryption in evidence vaults.
- `TC-L1-03`: Verify canonical `LEUKQUANT_AGENT_TOKEN_PEPPER` without legacy `LEUKQUANT_AUTH_PEPPER` fallbacks.
- `TC-L1-04`: Audit frontends for raw database credentials or unmasked tokens.
- `TC-L1-05`: Audit UI builds for mock/nominal data suppression in production mode.

### Layer 2: Dependency & Container Security Audit
- `TC-L2-01`: Node package security audits (`npm audit`) on `DASHBOARD` and `ADMIN-DASHBOARD`.
- `TC-L2-02`: Python dependency scanning (`pip list` / known CVEs) in `Ghost-Net`.
- `TC-L2-03`: Java Maven dependency tree & vulnerability checks in `middle-man-1`.
- `TC-L2-04`: Dockerfile configuration and least-privilege user checks.

### Layer 3: Ghost-Net Honeypot Unit, Canary & Shell Containment
- `TC-L3-01`: Unit and operational test suite execution (`run_tests.py`, unittest).
- `TC-L3-02`: Virtual shell command containment (`whoami`, `pwd`, `hostname`, `uname -a`, `env`, `history`, `ls -la`, `cat /etc/passwd`).
- `TC-L3-03`: Synthetic login rejection and canary alert generation.
- `TC-L3-04`: Connection rate limiting and lockout isolation.

### Layer 4: SSH & Protocol Interoperability
- `TC-L4-01`: OpenSSH client protocol handshake (`KEXINIT`, key exchange, `NEWKEYS`).
- `TC-L4-02`: Paramiko library interop and synthetic channel negotiation.
- `TC-L4-03`: Banner stability and error-free connection termination.

### Layer 5: Java Backend, Flyway Lifecycle & Crypto
- `TC-L5-01`: Java Maven clean compile and test execution (`31/31 passed`).
- `TC-L5-02`: Flyway lifecycle verification on PostgreSQL (fresh DB vs already-migrated DB).
- `TC-L5-03`: Production security startup validator enforcement.
- `TC-L5-04`: AES-256-GCM authenticated encryption, AAD context binding, and key ring rotation.

### Layer 6: PostgreSQL RBAC & Database Permissions
- `TC-L6-01`: `mm1_honeydata_writer` INSERT permissions on telemetry/quarantine/evidence; UPDATE/DELETE denied on `honeydata`.
- `TC-L6-02`: `mm3_dashboard_reader` SELECT permissions on `"user data"` view; DENIED base `honeydata` and `restricted_event_evidence`.
- `TC-L6-03`: `forensic_evidence_reader` audited read access to `restricted_event_evidence`.

### Layer 7: API Authorization & Edge Cases
- `TC-L7-01`: 401 Unauthorized on missing, malformed, or expired agent tokens.
- `TC-L7-02`: 403 Forbidden on 4-way agent binding mismatch (tenant/deployment/agent).
- `TC-L7-03`: 409 Conflict on cross-agent event ID collisions.
- `TC-L7-04`: 200 OK idempotent response on duplicate events from same agent.
- `TC-L7-05`: Admin CSRF tokens, strict Origin header verification, and cookie flags.

### Layer 8: Client Dashboard Real Browser & Accessibility
- `TC-L8-01`: Route navigation across all 9 dashboard pages.
- `TC-L8-02`: Responsive layouts (Desktop, Tablet, Mobile) without horizontal overflow.
- `TC-L8-03`: axe-core accessibility compliance and keyboard focus rings.
- `TC-L8-04`: Empty, loading, and backend error state rendering.
- `TC-L8-05`: Credential masking verification (`username:***`).

### Layer 9: Admin Dashboard Real Browser & Operations
- `TC-L9-01`: Route navigation across all 9 admin pages.
- `TC-L9-02`: Single-view raw agent token display upon provisioning.
- `TC-L9-03`: Agent token rotation and instant revocation.
- `TC-L9-04`: Role-gated forensic evidence modal and audit log insertion.
- `TC-L9-05`: Deployment health status fallback (`awaiting_heartbeat`).

### Layer 10: End-to-End Controlled Telemetry Pipeline
- `TC-L10-01`: Controlled event dispatch from Ghost-Net $\rightarrow$ `middle-man-1` $\rightarrow$ DB $\rightarrow$ `middle-man-3` $\rightarrow$ Dashboards.
- `TC-L10-02`: Verification of masked credentials across all viewing surfaces.

### Layer 11: Staging Acceptance, Bug Remediation & Readiness Scorecard
- `TC-L11-01`: Full triage and remediation of all discovered P0–P3 bugs in `docs/BUG_TRACKER.md`.
- `TC-L11-02`: Execution of regression tests for all resolved issues.
- `TC-L11-03`: Compilation of `docs/TEST_EVIDENCE_LOG.md` and `docs/STAGING_ACCEPTANCE_CHECKLIST.md`.

---

## 5. Exit Criteria & Staging Acceptance Gates

The QA phase is officially complete when:
- [x] Zero open P0 or P1 bugs.
- [x] All mandatory local and staging test layers executed.
- [x] All skipped tests explicitly tracked with documented rationale.
- [x] Flyway migrations verified on PostgreSQL.
- [x] Real browser tests passed across Client and Admin dashboards.
- [x] Zero raw credentials or secret exposures.
