# LeukQuant Frontend UI Component & Architecture Map
======================================================
**Document Version:** 1.0.0-PRO  
**Date:** 2026-08-15  
**Scope:** `DASHBOARD` and `ADMIN-DASHBOARD` Components

---

## 1. Client Dashboard (`DASHBOARD`) Component Map

| Component / Page | File Path | Previous Cyber Style | Redesigned Enterprise SaaS Style |
| :--- | :--- | :--- | :--- |
| **Design System & Global CSS** | `src/index.css` | Neon cyan glow, dark space background, matrix effects, pulsating dots. | Crisp slate design tokens (`#F8FAFC`, `#FFFFFF`, `#E2E8F0`), accessible contrast, clean typography. |
| **Main Application Layout** | `src/components/Layout.tsx` | Particle background canvas, high-glow header. | Calm white/slate app shell, semantic navigation landmarks, breadcrumbs. |
| **Sidebar Navigation** | `src/components/Sidebar.tsx` | Dark terminal icons with glowing borders. | Modern enterprise sidebar with collapsible items, badge counters, and active indicators. |
| **Overview Page** | `src/pages/Dashboard.tsx` | Raw terminal attack stream, neon graphs. | Operational command center answering health, 24h incidents, and recommended next actions. |
| **Events Page & Table** | `src/pages/Events.tsx`, `src/components/EventsTable.tsx` | Monospace log dump with glowing severity badges. | Filterable enterprise table (Time, Classification, Severity, Protocol, Source IP, Country, Action Taken, Status) + slide-out Event Detail Drawer. |
| **Incidents Page** | `src/pages/Incidents.tsx` (or `Alerts.tsx`) | Cyber alert stream with blinking warnings. | Structured incident cards with observation summaries, timelines, and evidence download actions. |
| **Threat Map** | `src/pages/Map.tsx`, `src/components/AttackMap.tsx` | Glowing neon continent overlays and laser beams. | Clean geographic distribution map with accurate clusters and calm markers. |
| **Reports Page** | `src/pages/Reports.tsx` | Raw JSON and chart dumps. | Executive summaries, vector breakdowns, and export utilities. |
| **Settings Page** | `src/pages/Settings.tsx` | Dark form with mock Web Push toggles. | Professional notification channel manager with clear backend service status badges. |
| **Attack Alert Banner** | `src/components/AttackAlertBanner.tsx` | Loud full-screen flashing alerts with audio. | Restrained, non-blinking toast and banner system deduplicated by `event_id`. |
| **Matrix Rain & Particles** | `src/components/MatrixRain.tsx`, `BackgroundParticles.tsx` | Legacy hacker animations. | **Cleanly Removed / Deactivated**. |

---

## 2. Admin Dashboard (`ADMIN-DASHBOARD`) Component Map

| Component / Page | File Path | Previous Cyber Style | Redesigned Enterprise SaaS Style |
| :--- | :--- | :--- | :--- |
| **Admin Design System** | `src/index.css`, `tailwind.config.js` | Dark hacker theme with heavy shadows and glowing buttons. | Aligned with shared enterprise design tokens (`#F8FAFC`, `#FFFFFF`, `#E2E8F0`, `#0F172A`). |
| **Admin Shell Layout** | `src/components/layout/AppShell.tsx` | Terminal shell with dark header. | Modern multi-tenant management shell with operator profile and quick status. |
| **Admin Sidebar** | `src/components/layout/Sidebar.tsx` | Monospace navigation. | 9-item operational navigation hierarchy with live counts and active indicators. |
| **Operations Overview** | `src/pages/OperationsPage.tsx` | Basic account count and plan cards. | 8 operational cards (Tenants, Deployments, Degraded Agents, 24h Events, Critical Threats, Quarantine, Failed Telemetry, Pending Agents). |
| **Tenants Page** | `src/pages/AccountsPage.tsx` | Plain account table. | Enterprise tenant management with plan tiers, auto-pause controls, and suspension actions. |
| **Deployments & Agents** | `src/pages/DeploymentsPage.tsx`, `src/pages/AgentsPage.tsx` | Merged in database views. | Dedicated deployment node tracking and agent token lifecycle monitors. |
| **Global Events & Incidents** | `src/pages/AdminEventsPage.tsx` | Basic database query view. | Cross-tenant security event stream with role-gated forensic evidence vault modal. |
| **System Health & Database** | `src/pages/DatabasePage.tsx` | Raw schema dumps. | Database connection pool diagnostics, Flyway migration version, and clone tools. |
| **Alert Policies** | `src/pages/AlertsPage.tsx` | Basic text inputs. | Structured global notification routing policies. |
