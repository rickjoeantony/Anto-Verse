# LeukQuant Client Dashboard UI/UX Redesign Specification
===========================================================
**Document Version:** 1.0.0-PRO  
**Date:** 2026-08-15  
**Target:** Client Security SaaS Dashboard (`DASHBOARD`)

---

## 1. Design Vision & Guiding Philosophy

The LeukQuant Client Dashboard provides security teams, CTOs, and devops engineers with an immediate, calm, and actionable view of their threat landscape. It replaces dark neon hacker aesthetics with a clean, trustworthy, enterprise-grade interface.

### Principles:
1. **Calm by Default**: Avoid high-frequency visual alarms for low-risk events. Matrix rain, glowing cyan borders, CRT scanlines, and spinning indicators are eliminated.
2. **Operational Answers First**: When an operator logs in, the screen immediately answers:
   - *Is my deployment healthy?*
   - *Did anything important happen?*
   - *What should I do next?*
3. **Restrained Severity Semantics**:
   - Red (`#DC2626`) is reserved strictly for critical incidents and degraded services requiring immediate intervention.
   - Orange (`#EA580C`) / Amber (`#D97706`) for high/medium suspicious activity.
   - Slate (`#64748B`) for informational/low-severity events and unknown input.
   - Green (`#15803D`) for healthy services, nominal operations, and resolved items.

---

## 2. Design Tokens & Visual Hierarchy

```css
:root {
  /* Surface & Base */
  --bg-app: #F8FAFC;
  --surface: #FFFFFF;
  --surface-muted: #F1F5F9;
  --surface-elevated: #FFFFFF;
  --border: #E2E8F0;
  --border-subtle: #F1F5F9;

  /* Typography & Text */
  --text-primary: #0F172A;
  --text-secondary: #64748B;
  --text-muted: #94A3B8;

  /* Brand Accents */
  --brand-primary: #1D4ED8;
  --brand-primary-hover: #1E40AF;
  --brand-secondary: #0F766E;

  /* Severity Spectrum */
  --severity-low: #64748B;
  --severity-low-bg: #F1F5F9;
  --severity-medium: #D97706;
  --severity-medium-bg: #FEF3C7;
  --severity-high: #EA580C;
  --severity-high-bg: #FFEDD5;
  --severity-critical: #DC2626;
  --severity-critical-bg: #FEE2E2;

  /* Status Colors */
  --status-success: #15803D;
  --status-success-bg: #DCFCE7;
  --status-neutral: #64748B;
  --status-neutral-bg: #F1F5F9;
}
```

---

## 3. Information Architecture & Navigation

```
Client Dashboard
├── 1. Overview (/dashboard)
│   ├── Deployment Health Summary
│   ├── Critical Incidents & High-Risk Activity Metrics
│   ├── Last Event Received & Last Alert Delivered
│   ├── Current Recommended Action Card
│   └── 24h Attack Volume & Vector Breakdown
│
├── 2. Events (/events)
│   ├── Canonical Security Event Table (Time, Classification, Severity, Protocol, Source IP, Country, Action Taken, Status)
│   └── Event Detail Drawer (Slide-out: Timeline, Reasons, Network Flags, Masked Credentials)
│
├── 3. Incidents (/incidents or /alerts)
│   ├── Human-Readable Incident Cards
│   ├── Observation Detail & Timeline
│   ├── Recommended Response Actions
│   └── Export Evidence Report
│
├── 4. Reports (/reports)
│   ├── Executive Threat Summary
│   ├── Top Attack Vectors & Source Geographies
│   └── PDF / CSV Report Generation
│
├── 5. Deployments (/deployments)
│   ├── Active Sensor Nodes & Honeypot Status
│   └── Node Heartbeat & Ingestion Connectivity
│
└── 6. Settings (/settings)
    ├── Notification Channels (Email, Slack, Webhook)
    ├── Web Push Configuration (Status banner declared)
    ├── Notification Severity Filtering
    └── Profile & Password Management
```

---

## 4. Event Detail Drawer & Privacy Model

When an operator clicks any row in the Events Table, a slide-out drawer opens displaying:
1. **Header**: Event ID, timestamp (UTC ISO format), classification badge, and review action button.
2. **Classification Reasons**: Extracted from `sensor_reasons` / `classification_reasons` (e.g. *"Known credential stuffing spray"*, *"SSH rapid failure burst"*).
3. **Network Enrichment**: Independent flags for `is_tor` (🧅 Tor Exit Node), `is_vpn` (🛡️ VPN), and `is_proxy` (🌐 Proxy).
4. **Credential Privacy**: Attacker username with masked password (`admin:***`). Raw credentials are never transmitted to or displayed in the client UI.
5. **Canary Token Match**: Canary ID highlighted if present.
6. **Recommended Action**: Clear tactical recommendation (e.g. *"Block IP 198.51.100.22 on edge firewall"* or *"Continue standard observation"*).

---

## 5. Alert UX & Notification Design

1. **Unknown Input & Reconnaissance**: Logged silently to event history without triggering toast popups or audio alerts.
2. **High Severity Activity**: Renders a compact toast notification that automatically dismisses after 6 seconds.
3. **Critical Severity Incidents**: Renders a calm, non-blinking top banner requiring explicit operator acknowledgment.
4. **Controlled Test Alerts**: Clearly labeled with a distinct blue badge: `Controlled Test Alert`.
5. **No Replay on Refresh**: Alert context deduplicates incoming events by `event_id` and does not replay historical events upon page reload.
