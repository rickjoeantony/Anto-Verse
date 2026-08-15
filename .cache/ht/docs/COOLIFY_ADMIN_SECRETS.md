# Coolify Staging & Production Deployment Secrets
===================================================

This document outlines the mandatory environment variables required for deploying LeukQuant services (**Admin Dashboard**, **Client Dashboard**, and **Middle-Man Backend Engines**) to Coolify.

---

## 1. Secret Generation Guidelines

> [!CAUTION]
> **Strict Secret Security Requirements**:
> - **Never commit secret material to Git.**
> - **Never paste production or staging secrets into documentation, chats, or commit logs.**
> - Use cryptographically secure pseudo-random generators to generate secrets locally and privately.
> - Store exclusively in Coolify's environment variable vault.

### Local Secret Generation Commands

#### Option A: Windows PowerShell (No OpenSSL required)
```powershell
# 1. Generate Base64-encoded random 32-byte (256-bit) AES Key for LEUKQUANT_EVIDENCE_ENCRYPTION_KEY
$bytes = New-Object byte[] 32
[System.Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
[Convert]::ToBase64String($bytes)

# 2. Generate Base64-encoded random 32-byte secret for LEUKQUANT_AGENT_TOKEN_PEPPER
$bytes = New-Object byte[] 32
[System.Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
[Convert]::ToBase64String($bytes)

# 3. Generate 64-char Hex secret for ADMIN_KEY, ADMIN_SESSION_SECRET, or JWT_SECRET
$bytes = New-Object byte[] 32
[System.Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
[System.BitConverter]::ToString($bytes).Replace("-", "").ToLower()
```

#### Option B: Linux / macOS / Bash OpenSSL
```bash
# 1. Generate Base64 32-byte AES key
openssl rand -base64 32

# 2. Generate Base64 32-byte Agent Token Pepper
openssl rand -base64 32

# 3. Generate Hex 32-byte Master Secrets (ADMIN_KEY, JWT_SECRET)
openssl rand -hex 32
```

---

## 2. Admin Dashboard Environment Variables (`ADMIN-DASHBOARD`)

| Variable Name | Required? | Example Format | Description |
| :--- | :---: | :--- | :--- |
| `ADMIN_KEY` | **YES** | Hex/Base64 ($\ge 32$ chars) | Master bootstrap secret for platform operator authentication. Must be high entropy. |
| `ADMIN_SESSION_SECRET` | **YES** | Hex/Base64 ($\ge 32$ chars) | Express session encryption cookie secret. |
| `LEUKQUANT_AGENT_TOKEN_PEPPER` | **YES** | Hex/Base64 ($\ge 32$ chars) | Canonical shared cryptographic HMAC secret used to hash agent tokens. |
| `AUTH_SALT` | **YES** | Random String | Salt used for legacy account credential verification and bcrypt migration. |
| `DATABASE_URL` | **YES** | Connection URI | PostgreSQL database connection string (`postgresql://user:pass@host:5432/db`). |
| `COOKIE_SECURE` | **YES** | `true` (Staging/Prod) / `false` (Local dev) | Set to `true` when running over HTTPS in Coolify. |
| `ADMIN_ALLOWED_ORIGIN` | **YES** | `https://admin.leukquant.com` | Allowed origin for strict CORS and CSRF Origin header validation. |
| `PORT` | Optional | `8082` | Port for Express Admin Backend API server. |
| `NODE_ENV` | **YES** | `staging` / `production` | Enables strict startup validation and disables debug helpers. |

---

## 3. Spring Boot Middle-Man Services (`middle-man-1` / `middle-man-3`)

### `middle-man-1` (Telemetry Ingestion Engine)
| Variable Name | Required? | Example Format | Description |
| :--- | :---: | :--- | :--- |
| `SPRING_PROFILES_ACTIVE` | **YES** | `staging` / `prod` | Activates target Spring configuration profile. |
| `APP_PRODUCTION` | **YES** | `false` (Staging) / `true` (Prod) | Controls strict production startup validator enforcement. |
| `LEUKQUANT_AGENT_TOKEN_PEPPER` | **YES** | Base64/Hex ($\ge 32$ chars) | Canonical shared pepper for HMAC-SHA256 agent token verification. Must match `ADMIN-DASHBOARD` identically. |
| `LEUKQUANT_EVIDENCE_ENCRYPTION_KEY` | **YES** | `BASE64_32_BYTE_KEY` | Base64-encoded random 32-byte (256-bit) AES key. Used for AES-256-GCM forensic evidence vault encryption. |
| `LEUKQUANT_EVIDENCE_KEY_ID` | Optional | `aes-256-gcm-v1` | Identifier of active encryption key attached to new evidence records (default `aes-256-gcm-v1`). |
| `LEUKQUANT_EVIDENCE_PREVIOUS_KEYS` | Optional | `{"aes-256-gcm-v0": "BASE64_KEY"}` | JSON map of retired encryption keys used to decrypt historical evidence records until TTL expiration. |
| `HONEYDATA_DB_URL` | **YES** | JDBC URI | PostgreSQL connection URL (`jdbc:postgresql://host:5432/db`). |
| `HONEYDATA_DB_USERNAME` | **YES** | `mm1_honeydata_writer` | PostgreSQL least-privilege writer role. |
| `HONEYDATA_DB_PASSWORD` | **YES** | Complex DB Password | PostgreSQL password for `mm1_honeydata_writer` role. |
| `ACCOUNTS_DB_URL` | **YES** | JDBC URI | PostgreSQL accounts DB URL. |
| `ACCOUNTS_DB_USERNAME` | **YES** | `accounts_user` | PostgreSQL accounts DB user. |
| `ACCOUNTS_DB_PASSWORD` | **YES** | Complex DB Password | PostgreSQL accounts DB password. |

### `middle-man-3` (Analytics & WebSocket Engine)
| Variable Name | Required? | Example Format | Description |
| :--- | :---: | :--- | :--- |
| `SPRING_PROFILES_ACTIVE` | **YES** | `staging` / `prod` | Target configuration profile. |
| `DB_URL` | **YES** | JDBC URI | PostgreSQL connection URL. |
| `DB_USERNAME` | **YES** | `mm3_dashboard_reader` | PostgreSQL least-privilege reader role. |
| `DB_PASSWORD` | **YES** | Complex DB Password | PostgreSQL password for reader role. |
| `JWT_SECRET` | **YES** | High entropy secret ($\ge 256$ bits) | JWT signature verification secret. |
| `LEUKQUANT_AGENT_TOKEN_PEPPER` | **YES** | Base64/Hex ($\ge 32$ chars) | Canonical shared token pepper. |
| `AUTH_SALT` | **YES** | Random String | Salt for account verification. |
| `DASHBOARD_ORIGIN` | **YES** | `https://dashboard-staging.leukquant.com` | Allowed dashboard origin for WebSocket and CORS. |

---

## 4. Startup Failure Policy

In `production` or `staging` mode, both Spring Boot and Node.js backend perform strict startup validation:

1. **Missing or Insecure Admin Key**: Process exits with code `1` if `ADMIN_KEY` $< 32$ chars or contains default placeholders.
2. **Missing or Low-Entropy Agent Token Pepper**: Startup is aborted if `LEUKQUANT_AGENT_TOKEN_PEPPER` is missing, $< 32$ chars, or has low-entropy repeating characters. Prohibits silent fallback to legacy `LEUKQUANT_AUTH_PEPPER`.
3. **Missing or Invalid Evidence Encryption Key**: Spring Boot aborts startup immediately if `LEUKQUANT_EVIDENCE_ENCRYPTION_KEY` is missing, default, invalid Base64, or decodes to anything other than **exactly 32 bytes** (256 bits).
4. **Default Database Credentials**: Startup is aborted if `HONEYDATA_DB_PASSWORD` or `ACCOUNTS_DB_PASSWORD` is set to default `'postgres'`.
