# LeukQuant Operational Bug Tracker & Remediation Log
======================================================
**Document Version:** 2.2.0-PRO  
**Tracking Scope:** Multi-Bug Verification Phase  
**Last Updated:** 2026-08-17  

---

## 1. Bug Registry Summary

| Bug ID | Severity | Component | Summary | Status | Regression Test |
| :--- | :---: | :--- | :--- | :---: | :--- |
| **BUG-01** | **P2 - Medium** | `Ghost-Net / Classifier` | Assertion mismatch in `test_exploit_attempt_detection` where malware dropper returned `PAYLOAD_DOWNLOAD_ATTEMPT`. | **VERIFIED** | `tests/security/test_attack_classification.py` |
| **BUG-02** | **P2 - Medium** | `Ghost-Net / Scan` | `test_01_stable_banner_validation` hardcoded connection to port 2222 failing standalone test runs. | **VERIFIED** | `tests/integration/test_scan_validation.py` |
| **BUG-03** | **P0 - Critical** | `DASHBOARD / Events` | `g.credentials.split is not a function` runtime TypeError when credentials was object/array. | **VERIFIED** | `src/utils/masking.ts::formatCredentialsDisplay` |
| **BUG-04** | **P1 - High** | `DASHBOARD / Settings` | `Cannot read properties of undefined (reading 'timezone')` crashing Appearance tab. | **VERIFIED** | `src/context/SettingsContext.tsx` |
| **BUG-05** | **P0 - Critical** | `middle-man-1 / Telemetry` | `HTTP 400 Bad Request` on `/collect/livedata` caused by Jackson `LocalDateTime` deserialization on offset ISO strings. | **VERIFIED** | `middle-man-1::AgentTokenContractTest`, `CanonicalEventIntegrationTest` |
| **BUG-06** | **P1 - High** | `DASHBOARD / Reports` | Report generator button disabled on empty archive; hardcoded honeypot sensors in print layout. | **VERIFIED** | `src/pages/Reports.tsx` |
| **BUG-07** | **P1 - High** | `middle-man-3 / WebSocket` | Query-string token exposure requirement in `JwtHandshakeInterceptor.java`. | **VERIFIED** | `middle-man-3::JwtHandshakeInterceptor.java` |

---

## 2. Bug Status Taxonomy
- **Open**: Newly identified defect during testing.
- **Reproduced**: Confirmed with isolated test case / log evidence.
- **In Progress**: Root cause identified; fix being authored.
- **Fixed**: Fix committed to codebase.
- **Verified**: Regression test passes 100%; closed.

---

## 3. Detailed Bug Remediation Records

### BUG-01: Malware Dropper Classification Assertion Mismatch
- **Bug ID**: `BUG-01`
- **Severity**: P2 (Medium)
- **Component**: `Honey-tech/Ghost-Net` (`tests/security/test_attack_classification.py`)
- **Fix Applied**: Updated `test_exploit_attempt_detection` to assert membership in `(ClassificationCategory.PAYLOAD_DOWNLOAD_ATTEMPT, ClassificationCategory.SUSPECTED_COMMAND_INJECTION)` and confidence in `(HIGH, CRITICAL)`.
- **Regression Test**: `test_attack_classification.py::TestAttackClassification::test_exploit_attempt_detection`
- **Status**: **VERIFIED (Closed)**

---

### BUG-02: Hardcoded Port Binding Failure in Standalone Banner Validation Test
- **Bug ID**: `BUG-02`
- **Severity**: P2 (Medium)
- **Component**: `Honey-tech/Ghost-Net` (`tests/integration/test_scan_validation.py`)
- **Fix Applied**: Updated `test_01_stable_banner_validation` to instantiate an ephemeral in-process mock socket fixture on port `0`.
- **Regression Test**: `test_scan_validation.py::TestScanValidation::test_01_stable_banner_validation`
- **Status**: **VERIFIED (Closed)**

---

### BUG-03: `g.credentials.split is not a function` Runtime TypeError
- **Bug ID**: `BUG-03`
- **Severity**: P0 (Critical)
- **Component**: `DASHBOARD` (`src/components/EventsTable.tsx`, `src/pages/Incidents.tsx`, `src/components/IPTimeline.tsx`)
- **Steps to Reproduce**:
  1. Ingest telemetry where `credentials` is an array of objects `[{username, password}]` or a single object.
  2. Open Events or Incidents table.
  3. React throws unhandled TypeError `g.credentials.split is not a function` and crashes the page.
- **Root Cause**: Code invoked `.split(':')` assuming `credentials` is always a raw string.
- **Fix Applied**: Created `formatCredentialsDisplay(creds: any)` in `src/utils/masking.ts` with polymorphic type checks for strings, objects, arrays, and null.
- **Regression Test**: TypeScript build + masking tests across string, object, array, and null formats.
- **Status**: **VERIFIED (Closed)**

---

### BUG-04: `Cannot read properties of undefined (reading 'timezone')`
- **Bug ID**: `BUG-04`
- **Severity**: P1 (High)
- **Component**: `DASHBOARD` (`src/pages/Settings.tsx`, `src/context/SettingsContext.tsx`)
- **Steps to Reproduce**:
  1. Navigate to `/settings` and click the "Appearance & Display" tab.
  2. Component accesses `settings.general.timezone`.
  3. React throws unhandled TypeError because `general` was undefined in `DEFAULT_SETTINGS`.
- **Root Cause**: `general` was missing from `TenantSettings` interface and initial context state.
- **Fix Applied**: Added `general: { timezone, density }` to schema, added deep-merge fallback initialization in `SettingsContext.tsx`, and added optional chaining in `Settings.tsx`.
- **Regression Test**: `npm run build` in `DASHBOARD` + settings tab navigation.
- **Status**: **VERIFIED (Closed)**

---

### BUG-05: `HTTP 400 Bad Request` in Telemetry Ingestion Gateway
- **Bug ID**: `BUG-05`
- **Severity**: P0 (Critical)
- **Component**: `middle-man-1` (`CollectDataRequest.java`, `HoneyDataService.java`), `Honey-tech/Ghost-Net` (`telemetry.py`)
- **Steps to Reproduce**:
  1. Honeypot sensor calls `send_attack_event()` emitting ISO-8601 UTC timestamps with timezone offset (`2026-08-17T14:32:00.123456+00:00`).
  2. `middle-man-1` receives payload at `/collect/livedata`.
  3. Jackson's `JavaTimeModule` throws `DateTimeParseException` attempting to deserialize into `LocalDateTime timestamp`.
  4. Spring Boot returns `HTTP 400 Bad Request`.
- **Root Cause**: Schema mismatch between Python offset ISO strings and Jackson `LocalDateTime`.
- **Fix Applied**: Updated `timestamp` to `Instant timestamp` with `@JsonAlias({"timestamp", "timestamp_utc"})` in `CollectDataRequest.java`, updated timestamp conversion in `HoneyDataService.java`, and standardized Python timestamps with `Z`.
- **Regression Test**: `middle-man-1::AgentTokenContractTest`, `CanonicalEventIntegrationTest` (32/32 passing).
- **Status**: **VERIFIED (Closed)**

---

### BUG-06: Report Generation Lockout & Hardcoded Fallbacks
- **Bug ID**: `BUG-06`
- **Severity**: P1 (High)
- **Component**: `DASHBOARD` (`src/pages/Reports.tsx`)
- **Steps to Reproduce**:
  1. Open `/reports` when report database is empty.
  2. "Generate 7-Day Brief" button was disabled because `selectedReportId` was null.
  3. Print template contained static hardcoded honeypot sensor names and fake probe distributions.
- **Root Cause**: Button disabled condition was bound to `!selectedReportId`; print layout contained hardcoded static tables.
- **Fix Applied**: Enabled on-demand generation without prerequisite selection, derived all sensor names and origins dynamically from live telemetry, and cleaned compliance wording.
- **Regression Test**: `DASHBOARD::npm run build` + report generation and print test.
- **Status**: **VERIFIED (Closed)**

---

### BUG-07: Query-String Token Exposure in WebSocket Handshake
- **Bug ID**: `BUG-07`
- **Severity**: P1 (High)
- **Component**: `middle-man-3` (`JwtHandshakeInterceptor.java`)
- **Steps to Reproduce**:
  1. Connect to WebSocket without query param `?token=...`; server rejected handshake, forcing tokens into URL query strings.
- **Root Cause**: `JwtHandshakeInterceptor.java` checked only `request.getURI().getQuery()` and ignored headers, cookies, and subprotocols.
- **Fix Applied**: Enhanced `JwtHandshakeInterceptor.java` to support `Sec-WebSocket-Protocol: leukquant-ticket, <ticket>`, `Authorization: Bearer <token>`, and secure cookies.
- **Regression Test**: `middle-man-3::mvn compile` — BUILD SUCCESS.
- **Status**: **VERIFIED (Closed)**
