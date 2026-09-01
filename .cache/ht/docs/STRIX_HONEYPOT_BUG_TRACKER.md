# Ghost-Net Honeypot — Strix AI Staging Bug Tracker & Remediation Log
=====================================================================
**Document Version:** 1.0.0-PRO  
**Tracking Scope:** Ghost-Net Staging Preparation & Regression Verification  
**Author:** Antigravity AI SecOps Engineering  
**Last Updated:** 2026-08-19  

---

## 1. Bug Registry Summary

| Bug ID | Severity | Component | Summary | Status | Regression Test |
| :--- | :---: | :--- | :--- | :---: | :--- |
| **BUG-STRIX-01** | **P0 - Critical** | `Ghost-Net / Telemetry` | `sec` token inadvertently included in outgoing telemetry JSON payload body instead of header-only. | **VERIFIED** | `tests/integration/test_canonical_telemetry_contract.py` |
| **BUG-STRIX-02** | **P1 - High** | `Ghost-Net / Config` | `ConfigDecryptionError` raised during test execution due to missing test mode environment flag. | **VERIFIED** | `tests/conftest.py`, `tests/__init__.py` |
| **BUG-STRIX-03** | **P2 - Medium** | `Ghost-Net / Tests` | `ModuleNotFoundError: No module named 'paramiko'` crashing standalone test runner in minimal Python environments. | **VERIFIED** | `tests/integration/test_stealth_ssh.py` |
| **BUG-STRIX-04** | **P2 - Medium** | `Ghost-Net / Classifier` | Return type mismatch in `check_credential_reuse` where test expected a tuple rather than a dictionary result. | **VERIFIED** | `tests/security/test_strix_honeypot_regression.py` |
| **BUG-STRIX-05** | **P3 - Low** | `Ghost-Net / Tests` | Static code substring search failing on docstring references in `test_14_no_real_command_execution`. | **VERIFIED** | `tests/security/test_strix_honeypot_regression.py` |
| **BUG-STRIX-06** | **P1 - High** | `Ghost-Net / Telemetry` | `send_telemetry_health_check` assigning `health_payload["sec"] = sec` in healthcheck body. | **VERIFIED** | `tests/integration/test_operational_fixes.py` |

---

## 2. Bug Status Taxonomy
- **Open**: Newly identified defect during staging testing.
- **Reproduced**: Confirmed with isolated test case / log trace.
- **In Progress**: Root cause identified; fix being authored.
- **Fixed**: Fix committed to codebase.
- **Verified**: Regression test passes 100%; closed.

---

## 3. Detailed Bug Remediation Records

### BUG-STRIX-01: SEC Token Leakage in JSON Telemetry Payload Body
- **Bug ID**: `BUG-STRIX-01`
- **Severity**: P0 (Critical)
- **Component**: `Honey-tech/Ghost-Net` (`utils/telemetry.py`)
- **Steps to Reproduce**:
  1. Call `send_attack_event()` with a configured `SEC` token.
  2. Inspect the generated `payload` dictionary passed to `_async_send`.
  3. `payload["sec"]` contains the raw 64-character hex SEC token.
- **Root Cause**:
  Legacy compatibility code in `utils/telemetry.py` line 277 executed `payload["sec"] = sec`, violating the header-only authentication contract defined in `docs/SEC_AUTHENTICATION_MODEL.md`.
- **Fix Applied**:
  Removed `payload["sec"] = sec` from `utils/telemetry.py`. SEC is strictly assigned to `headers["Authorization"] = f"Bearer {sec}"`.
- **Evidence**:
  ```python
  # Before:
  if sec:
      headers["Authorization"] = f"Bearer {sec}"
      payload["sec"] = sec

  # After:
  if sec:
      headers["Authorization"] = f"Bearer {sec}"
  ```
- **Regression Test**: `tests/integration/test_canonical_telemetry_contract.py::TestCanonicalTelemetryContract::test_canonical_sensor_proposals_and_sec_only_header_auth`
- **Status**: **VERIFIED (Closed)**

---

### BUG-STRIX-02: Hardware-Bound Config Decryption Failure During Test Execution
- **Bug ID**: `BUG-STRIX-02`
- **Severity**: P1 (High)
- **Component**: `Honey-tech/Ghost-Net` (`config_store.py`, `tests/conftest.py`)
- **Steps to Reproduce**:
  1. Run `pytest` or `unittest` on a machine whose hardware ID does not match the encrypted `config/ghost-net.enc` store.
  2. `config_store.load_config()` throws `ConfigDecryptionError` and aborts test execution.
- **Root Cause**:
  `config_store.py` checks `os.environ.get("GHOSTNET_TEST_MODE") == "1"` to bypass hardware decryption during automated testing, but test runners did not initialize this environment variable prior to module import.
- **Fix Applied**:
  1. Created `tests/conftest.py` setting `os.environ["GHOSTNET_TEST_MODE"] = "1"` for pytest.
  2. Updated `tests/__init__.py` to set `GHOSTNET_TEST_MODE = "1"` for `unittest` discovery.
- **Regression Test**: `pytest` across all 258 test cases.
- **Status**: **VERIFIED (Closed)**

---

### BUG-STRIX-03: Missing Paramiko Dependency Crashing Test Runner
- **Bug ID**: `BUG-STRIX-03`
- **Severity**: P2 (Medium)
- **Component**: `Honey-tech/Ghost-Net` (`tests/integration/test_stealth_ssh.py`)
- **Steps to Reproduce**:
  1. Execute `test_stealth_ssh.py` on a lightweight Python environment without `paramiko` installed.
  2. `test_synthetic_and_invalid_credential_flow` attempts `import paramiko` without exception handling.
  3. Runner terminates with unhandled `ModuleNotFoundError`.
- **Root Cause**:
  Hard dependency on optional third-party library in integration test fixture.
- **Fix Applied**:
  Wrapped `import paramiko` with `try ... except ImportError: self.skipTest("paramiko not installed in current environment")`.
- **Regression Test**: `tests/integration/test_stealth_ssh.py::TestStealthSSHEngine::test_synthetic_and_invalid_credential_flow`
- **Status**: **VERIFIED (Closed)**

---

### BUG-STRIX-04: Return Contract Mismatch in Credential Reuse Tracker
- **Bug ID**: `BUG-STRIX-04`
- **Severity**: P2 (Medium)
- **Component**: `Honey-tech/Ghost-Net` (`ghostnet/classifier.py`, `tests/security/test_strix_honeypot_regression.py`)
- **Steps to Reproduce**:
  1. Call `cross_protocol_tracker.check_credential_reuse(...)`.
  2. Method returns a dictionary `{'type': 'cross_protocol_credential_reuse', ...}` or `None`.
  3. Calling code unpacking `is_reused, details = ...` throws `ValueError: too many values to unpack`.
- **Root Cause**:
  Method signature in `ghostnet/classifier.py` returns `Optional[Dict[str, Any]]`, whereas caller attempted tuple unpacking.
- **Fix Applied**:
  Updated caller assertion to evaluate `reuse_result is not None` and access dictionary fields directly (`reuse_result["source_protocol"]`).
- **Regression Test**: `tests/security/test_strix_honeypot_regression.py::TestStrixHoneypotRegression::test_10_fake_credential_reuse_detection`
- **Status**: **VERIFIED (Closed)**

---

### BUG-STRIX-05: Docstring False-Positive in Zero Host Execution AST Audit
- **Bug ID**: `BUG-STRIX-05`
- **Severity**: P3 (Low)
- **Component**: `Honey-tech/Ghost-Net` (`tests/security/test_strix_honeypot_regression.py`)
- **Steps to Reproduce**:
  1. Run `test_14_no_real_command_execution` with naive source string search `self.assertNotIn("subprocess.run", source)`.
  2. `ghostnet/virtual_shell.py` header docstring contains `- Zero subprocess.run(), os.system(), pty...`.
  3. Assertion fails due to the docstring text rather than executable code.
- **Root Cause**:
  Raw string search inspected comments and docstrings in addition to executable AST nodes.
- **Fix Applied**:
  Replaced substring search with Python `ast` syntax tree inspection, asserting no `ast.Import` or `ast.ImportFrom` for `subprocess` or `pty`, and no `ast.Call` for `os.system` / `os.popen`.
- **Regression Test**: `tests/security/test_strix_honeypot_regression.py::TestStrixHoneypotRegression::test_14_no_real_command_execution`
- **Status**: **VERIFIED (Closed)**

---

### BUG-STRIX-06: SEC Token in Telemetry Health-Check Payload
- **Bug ID**: `BUG-STRIX-06`
- **Severity**: P1 (High)
- **Component**: `Honey-tech/Ghost-Net` (`utils/telemetry.py`)
- **Steps to Reproduce**:
  1. Call `send_telemetry_health_check()`.
  2. Code assigns `health_payload["sec"] = sec` in line 340.
  3. Healthcheck body exposes raw SEC token.
- **Root Cause**:
  Residual assignment in `send_telemetry_health_check()` mirroring legacy `send_attack_event()` behavior.
- **Fix Applied**:
  Removed `health_payload["sec"] = sec`; SEC token is now transmitted strictly in `headers["Authorization"] = f"Bearer {sec}"`.
- **Regression Test**: `tests/integration/test_operational_fixes.py::TestOperationalFixes::test_send_telemetry_health_check_with_mock_response`
- **Status**: **VERIFIED (Closed)**
