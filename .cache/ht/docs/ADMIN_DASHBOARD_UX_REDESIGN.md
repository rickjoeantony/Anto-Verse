# LeukQuant Admin Dashboard UI/UX Redesign Specification
==========================================================
**Document Version:** 1.0.0-PRO  
**Date:** 2026-08-15  
**Target:** Multi-Tenant Operations & Admin SaaS Platform (`ADMIN-DASHBOARD`)

---

## 1. Design Vision & Operational Role

The Admin Dashboard provides LeukQuant platform administrators and internal security engineers with operational oversight of multi-tenant infrastructure, tenant licensing, honeypot deployments, agent health, and forensic audit records.

### Separation of Concerns:
- **Customer Tenant Data**: Isolated by `tenant_id` / account boundary.
- **Deployment & Agent Health**: Ingestion nodes, token lifecycle, and connectivity telemetry.
- **Internal Operations & Retention**: Automated cleanup schedules, database maintenance, and quarantine inspection.
- **Restricted Forensic Evidence**: Vault containing encrypted credentials with explicit role-gating and access audit tracking.

---

## 2. Admin Information Architecture & Navigation

```
Admin Operations Platform
├── 1. Operations Overview (/operations or /)
│   ├── Active Tenants Metric
│   ├── Healthy Deployments Metric
│   ├── Degraded / Offline Agents Metric
│   ├── Total Events (24h) & Critical Threat Volume
│   ├── Ingestion Quarantine Count & Failed Deliveries
│   └── 24h Attack Hourly Velocity Chart
│
├── 2. Tenants (/tenants or /accounts)
│   ├── Tenant Account Directory & Plan Tier (Starter, Growth, Enterprise)
│   ├── Tenant Status (Active, Suspended, Auto-Paused)
│   ├── Provision New Tenant Form
│   └── Manage Subscriptions & Suspend Actions
│
├── 3. Deployments (/deployments)
│   ├── Global Deployment Inventory
│   └── Node Architecture & Heartbeat Status
│
├── 4. Agents (/agents)
│   ├── Registered Agent Registry
│   ├── Token Creation & Expiry Timestamps
│   └── Token Rotation Guide & Status
│
├── 5. Events & Incidents (/events)
│   ├── Cross-Tenant Security Event Feed (Masked Data)
│   └── Restricted Forensic Evidence Access Guard (Role Gated)
│
├── 6. Alert Policies (/alerts)
│   ├── Global Notification Routing Policies
│   └── Dispatch Channels (Email, Slack, Webhook)
│
├── 7. Reports & Retention (/reports)
│   ├── Ingestion Retention Policy (14-day Quarantine, 90-day Evidence)
│   └── Cross-Tenant Analytics Summary
│
├── 8. Audit Logs (/audit-logs)
│   ├── Automated Retention Purge Execution Logs (`cleanup_audit_log`)
│   └── Operator Action History
│
└── 9. System Health (/system-health or /database)
    ├── PostgreSQL Connection Pool Telemetry
    ├── Schema Version & Migration Status
    └── Maintenance & Database Diagnostics
```

---

## 3. Restricted Forensic Evidence Vault Policy

To satisfy privacy regulations and security audit standards:
1. **Never Displayed in Normal Event Tables**: The main admin event table displays only `credentials_masked` (`admin:***`).
2. **Role-Gated Access Modal**: Clicking "Inspect Evidence" opens a dedicated modal with:
   - A prominent warning banner: `RESTRICTED FORENSIC EVIDENCE — AUTHORIZED SECURITY AUDIT ONLY`.
   - Explicit declaration that access is logged in the immutable audit trail.
   - Requirement for the operator to hold the `forensic_evidence_reader` role.
3. **No Insecure Client Decryption**: The frontend does not store or process master decryption keys.
