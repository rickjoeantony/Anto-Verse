# Strix AI Staging Test — Honeypot-Only Scope Specification
===========================================================
**Document Version:** 1.0.0-PRO  
**Target Environment:** Ghost-Net Staging Honeypot VPS  
**Test Category:** Isolated Honeypot Security & Regression Verification  
**Author:** Antigravity AI SecOps Engineering  
**Last Updated:** 2026-08-19  

---

## 1. Executive Summary & Authorization Boundary

This document defines the strict, non-negotiable boundaries and test plan for the authorized **Strix AI Staging Evaluation** of the **Ghost-Net Decoy Honeypot Sensor**.

> [!IMPORTANT]
> **Strict Operational Ground Rules**:
> 1. **Do NOT run Strix AI automatically** against unapproved targets or outside of authorized manual staging operator invocations.
> 2. **Target ONLY** the Ghost-Net Staging Honeypot VPS on **SSH port 2222** (and the optional HTTP decoy listener if and only if explicitly enabled by the operator).
> 3. **Zero Destructive Flood Tests**: Do not perform volumetric DoS or destructive resource exhaustion attacks.
> 4. **Zero Customer Data**: Use synthetic `Honey-tech` artifacts only. Real customer tokens, credentials, or production databases must never be introduced.
> 5. **Do NOT mark Honeypot "undetectable"**: Acknowledge emulation boundaries, synthetic fingerprint characteristics, and protocol nuance.
> 6. **Do NOT mark product "production ready"**: The honeypot is evaluated under controlled staging conditions.

---

## 2. Explicit Scope Exclusions (Strictly Forbidden Targets)

The following components and infrastructure subsystems are **STRICTLY EXCLUDED** from Strix AI scanning, penetration testing, and probing:

| Excluded Subsystem | Description & Architecture Boundary | Exclusion Rationale |
| :--- | :--- | :--- |
| **`middle-man-1`** | Core Telemetry Ingestion Gateway (Spring Boot / Java) | Central ingestion pipeline; external scanning prohibited. |
| **`middle-man-3`** | WebSocket Live Incident Broadcast Hub | Real-time push multiplexer; excluded from payload fuzzing. |
| **`PostgreSQL`** | Primary relational database & partitioned tables | Stored telemetry and user records; direct access forbidden. |
| **`Client Dashboard`** | React / Vite Frontend customer user interface | Web application UI; excluded from automated attacker agents. |
| **`Admin Dashboard`** | React / Vite Superadmin control portal | Administrative orchestration UI; strictly out of scope. |
| **`Coolify`** | Staging server orchestrator & deployment daemon | Infrastructure orchestrator; host security boundary must not be touched. |
| **`Cloudflare`** | Edge CDN, DNS, WAF, and Reverse Proxy | Upstream edge network; flood or scan bypass tests forbidden. |
| **`SEC / Auth APIs`** | Agent token validation and authentication endpoints | Authentication model verification is handled via unit tests only. |
| **`Forensic Vault`** | Encrypted payload archive and tamper-evident storage | Evidence storage tier; out of honeypot sensor test scope. |
| **`Web Push / FCM`** | Push notification delivery microservice | End-user notification channel; live dispatch suppressed. |
| **`KRP / Customer Systems`** | Knowledge Base, customer VPCs, and client networks | Client network boundary; absolute isolation required. |
| **`Production Systems`** | All live production tenants, domains, and clusters | Staging isolation invariant. |

---

## 3. Authorized In-Scope Target Matrix

| Target Asset | Network Address / Interface | Port | Transport Protocol | Permitted Testing Activity |
| :--- | :--- | :---: | :---: | :--- |
| **Ghost-Net Staging Honeypot** | Dedicated Staging VPS Interface | `2222` | `SSH 2.0 (TCP)` | Banner inspection, key exchange negotiation, synthetic authentication, virtual shell interaction, canary trip evaluation, per-IP rate limit evaluation. |
| **HTTP Decoy (Optional)** | Dedicated Staging VPS Interface | `8080` / `80` | `HTTP/1.1 (TCP)` | Web decoy probe & login form interaction *(Only if explicitly enabled by staging operator)*. |

---

## 4. 18-Point Honeypot Scope Verification Matrix

All test activities, local regression suites, and automated evaluation metrics must adhere to the 18 specific test dimensions below:

```
+-------------------------------------------------------------------------------+
|                       GHOST-NET HONEYPOT TEST SCOPE MATRIX                    |
+----+----------------------------------------------------+---------------------+
| ID | Requirement / Scope Dimension                      | Target Subsystem    |
+----+----------------------------------------------------+---------------------+
| 01 | SSH banner stability                               | Stealth SSH Core    |
| 02 | SSH transport compatibility                        | RFC 4253 KEX / Wire |
| 03 | Synthetic authentication consistency               | Virtual Creds Store |
| 04 | Virtual shell command handling                     | Virtual Shell Engine|
| 05 | Virtual shell semicolon command handling           | Pipeline Parser     |
| 06 | Virtual filesystem behavior                        | In-Memory POSIX FS  |
| 07 | Fake user/home directory consistency               | Persona Manager     |
| 08 | Fake /etc/passwd behavior                          | Virtual System Files|
| 09 | Fake config/canary file behavior                   | Canary Subsystem    |
| 10 | Fake credential reuse detection if enabled         | Cross-Protocol Trap |
| 11 | Host filesystem leakage prevention                 | Sandbox Containment |
| 12 | Host environment-variable leakage prevention       | Env Isolation       |
| 13 | Hostname/process/network leakage prevention        | Runtime Identity    |
| 14 | No real command execution                          | Execution Barrier   |
| 15 | Unknown command behavior                           | Shell Error Realism |
| 16 | Listener stability after disconnect                | Socket Transport    |
| 17 | Controlled per-IP rate limit behavior              | Adaptive Limiter    |
| 18 | No global lockout of unrelated source IP           | IP Partitioning     |
+----+----------------------------------------------------+---------------------+
```

### Detailed Dimension Specifications

1. **SSH Banner Stability**: The honeypot must present a consistent, unmutated RFC 4253 banner across sequential connections. Per-connection randomized banner flipping is forbidden to ensure persona integrity.
2. **SSH Transport Compatibility**: Full RFC 4253 packet framing, binary serialization (`mpint`, `string`, `namelist`), Key Exchange (`curve25519-sha256`, `diffie-hellman-group14-sha256`, `diffie-hellman-group16-sha512`), RSA host keys (`rsa-sha2-512`, `rsa-sha2-256`, `ssh-rsa`), symmetric encryption (`aes128-ctr`, `aes256-ctr`), and HMAC integrity (`hmac-sha2-256`, `hmac-sha2-512`).
3. **Synthetic Authentication Consistency**: Configured synthetic decoy credentials (`deploy:deploy2024!`, `ubuntu:ubuntu`, `sysadmin:sysadmin2024`, `root:toor`, `admin:admin123`) must be deterministically accepted; unconfigured or invalid credentials must be deterministically rejected with audit telemetry.
4. **Virtual Shell Command Handling**: Emulation of core POSIX builtins and system utilities (`pwd`, `cd`, `ls`, `cat`, `whoami`, `id`, `uname`, `env`, `printenv`, `echo`, `which`, `type`, `history`) returning realistic outputs with standard exit codes.
5. **Virtual Shell Semicolon Command Handling**: Support for sequential semicolon pipelines (`cmd1; cmd2; cmd3`), respecting single/double quotes and maintaining working directory / environment state across statements.
6. **Virtual Filesystem Behavior**: A complete, in-memory POSIX filesystem structure (`/bin`, `/etc`, `/home`, `/var/log`, `/opt`, `/tmp`) with realistic file sizes, permissions, directory hierarchies, and in-memory globbing.
7. **Fake User/Home Directory Consistency**: Dynamic alignment between logged-in fake user (`ubuntu`, `deploy`, `root`), `$HOME`, `$USER`, working directory, and terminal prompt (`user@ghost-server:~#` vs `user@ghost-server:~$`).
8. **Fake `/etc/passwd` Behavior**: The virtual `/etc/passwd` file must contain standard Linux system accounts (`root`, `daemon`, `bin`, `sys`, `sync`) alongside persona-specific decoy accounts, formatted with exactly 7 standard colon-delimited fields.
9. **Fake Config/Canary File Behavior**: Decoy configuration and credential files (`wp-config.php`, `.aws/credentials`, `backup_script.sh`, `database.yml`) containing convincing canary values that trip audit alerts upon access.
10. **Fake Credential Reuse Detection**: Cross-protocol tracking of attacker-harvested credentials to detect when synthetic credentials captured on SSH are replayed against other decoys or admin forms.
11. **Host Filesystem Leakage Prevention**: Absolute containment within the in-memory virtual filesystem. Directory traversal (`../../../../`) and attempts to access real host files (`C:\Windows`, `/etc/shadow` on host) must be trapped and blocked.
12. **Host Environment-Variable Leakage Prevention**: Commands like `env`, `printenv`, and `export` must return synthetic environment variables only. Zero real host process environment variables (e.g. `USERPROFILE`, `APPDATA`, API keys) may appear.
13. **Hostname/Process/Network Leakage Prevention**: `hostname`, `uname -a`, `ip a`, `ifconfig`, and `ps` must report synthetic persona information only, preventing disclosure of the underlying host's actual hardware, hostname, or IP.
14. **No Real Command Execution**: Invariant forbidding any call to `subprocess`, `os.system`, `os.popen`, `pty`, or host binaries. All command execution must be completely emulated in software.
15. **Unknown Command Behavior**: Unrecognized or unsupported commands must return standard bash error responses (`bash: <cmd>: command not found` with exit code 127) rather than Python exceptions or server disconnects.
16. **Listener Stability After Disconnect**: Socket server must remain robust and accept new incoming connections even when prior clients abruptly terminate with RST/FIN, send malformed binary frames, or disconnect mid-handshake.
17. **Controlled Per-IP Rate Limit Behavior**: The honeypot must implement bounded tarpit delays on burst traffic from aggressive scanners without crashing or dropping low-frequency benign interactions.
18. **No Global Lockout of Unrelated Source IP**: Rate-limiting and blocking rules must be strictly partitioned by source IP; throttling or blocking attacker IP A must never degrade or lock out independent source IP B.

---

## 5. Staging Test Execution Rules

1. **Pre-Test Local Verification**: All 18 dimensions must pass 100% in local regression test execution (`pytest tests/security/test_strix_honeypot_regression.py`) before initiating Strix AI staging sessions.
2. **Operator Authorization**: Automated staging scanning may only proceed when a certified human operator explicitly approves the specific IP, port, and test window.
3. **Observability**: Live telemetry output, audit logs (`logs/ghost-net.log`), and honeypot events must be monitored for real-time validation.
