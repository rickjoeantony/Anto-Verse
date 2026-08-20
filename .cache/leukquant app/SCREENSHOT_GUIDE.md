# LeukQuant Mobile - Visual Design & Screen Guide

This guide details each modernized screen, layout hierarchy, and verification checkpoints for the **LeukQuant Mobile** UI.

---

## 1. Onboarding Screen (`/onboarding`)

### Page 1: Observe
```
+----------------------------------------+
| (Shield) LeukQuant               Skip  |
|                                        |
| +------------------------------------+ |
| |              OBSERVE               | |
| |                                    | |
| |       [Radar & Decoy Nodes]        | |
| |                                    | |
| |    See suspicious activity early   | |
| |                                    | |
| | Ghost-Net observes interaction with| |
| | controlled decoy services before   | |
| | attackers reach real systems.      | |
| +------------------------------------+ |
|                                        |
| [Back]        [== . . ]         [Next] |
+----------------------------------------+
```

### Page 2: Understand
```
+----------------------------------------+
| (Shield) LeukQuant               Skip  |
|                                        |
| +------------------------------------+ |
| |            UNDERSTAND              | |
| |                                    | |
| |     [Timeline & Signals Stack]     | |
| |                                    | |
| |  Understand every security event   | |
| |                                    | |
| | Turn complex security signals into | |
| | clear timelines, severity, and     | |
| | recommended actions.               | |
| +------------------------------------+ |
|                                        |
| [Back]        [ . == . ]        [Next] |
+----------------------------------------+
```

### Page 3: Act
```
+----------------------------------------+
| (Shield) LeukQuant               Skip  |
|                                        |
| +------------------------------------+ |
| |               ACT                  | |
| |                                    | |
| |    [Verified Shield & Broadcast]   | |
| |                                    | |
| |        Act with confidence         | |
| |                                    | |
| | Receive verified incident updates  | |
| | and keep your organisation         | |
| | informed.                          | |
| +------------------------------------+ |
|                                        |
| [Back]        [ . . == ] [Get Started] |
+----------------------------------------+
```

---

## 2. Overview & Analytics Screen (`/overview`)

```
+----------------------------------------+
| Security Overview          [Demo] [Theme] [🔔]|
| Awaiting organisation data             |
|----------------------------------------|
| +------------------------------------+ |
| | Deployment Health        [STANDBY] | |
| | (•) Awaiting backend data          | |
| | Sensor telemetry stream is pending | |
| +------------------------------------+ |
|                                        |
| +----------------+ +-----------------+ |
| | [!] Critical   | | [▲] High-Risk   | |
| |   Incidents    | |     Events      | |
| |       —        | |       —         | |
| +----------------+ +-----------------+ |
|                                        |
| +------------------------------------+ |
| | [🕒] Last Event Received            | |
| |       —                            | |
| +------------------------------------+ |
|                                        |
| +------------------------------------+ |
| | Security Activity             [24H]| |
| | Verified events over time          | |
| | [~~~~~ Activity Trend Line ~~~~~]  | |
| +------------------------------------+ |
|                                        |
| +------------------------------------+ |
| | Threat Distribution                | |
| | Telemetry categorisation           | |
| | [ (O) Donut ]  Reconnaissance 42%  | |
| |                Credential Atk 28%  | |
| +------------------------------------+ |
|                                        |
| +------------------------------------+ |
| | Protocol Activity                  | |
| | Interaction by decoy service       | |
| | [||| Bar Chart: SSH, HTTP, DB...]  | |
| +------------------------------------+ |
|                                        |
| +------------------------------------+ |
| | [💡] Recommended Action             | |
| | Awaiting backend security policies | |
| +------------------------------------+ |
|                                        |
| Recent Activity                        |
| +------------------------------------+ |
| | [Inbox] Awaiting backend data      | |
| +------------------------------------+ |
+----------------------------------------+
| [Overview] [Events] [Inc] [Rep] [Set]  |
+----------------------------------------+
```

---

## 3. Events Screen (`/events`) & Details Bottom Sheet

```
+----------------------------------------+
| Security Events  Canary Telemetry      |
|----------------------------------------|
| [ Search events by ID, IP, proto... ]  |
| Severity: [All] [Critical] [High] ...  |
| Protocol: [All] [SSH] [HTTPS] [DB] ... |
|----------------------------------------|
| (•) Displaying 4 of 4 events           |
|                                        |
| +------------------------------------+ |
| | [CRITICAL] EVT-2026-8941  14 min   | |
| | Automated SSH Credential Spray     | |
| | [SSH] [198.51.100.44:2222] [DE]    | |
| +------------------------------------+ |
+----------------------------------------+
```

### Event Details Bottom Sheet Modal
- Top rounded 28px corners
- Recommended Action banner
- Classification reasons
- Parameters: Protocol, Port, Source IP, Country, Canary Reference
- **Masked Credentials**: `admin / **********`

---

## 4. Settings Screen (`/settings`)

```
+----------------------------------------+
| Settings       Workspace Preferences   |
|----------------------------------------|
| +------------------------------------+ |
| | [👤] Awaiting profile data         | |
| |      Sign in with corporate ID     | |
| |      Pending Profile Sync          | |
| +------------------------------------+ |
|                                        |
| +------------------------------------+ |
| | Theme Mode                         | |
| | [ System ]  [ Light ]  [ Dark ]    | |
| +------------------------------------+ |
|                                        |
| +------------------------------------+ |
| | Notifications & Alerts             | |
| | In-App Security Alerts         [X] | |
| | Push Notifications   [PENDING]     | |
| +------------------------------------+ |
|                                        |
| [           [Logout] Sign Out        ] |
+----------------------------------------+
| [Overview] [Events] [Inc] [Rep] [Set]  |
+----------------------------------------+
```
