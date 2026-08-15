# LeukQuant Agent Token Contract Specification
===============================================

## 1. Overview
This contract defines the unified agent token generation, hashing, verification, and lifecycle specification shared across **Node.js** (`ADMIN-DASHBOARD` provisioning) and **Java** (`middle-man-1` / `middle-man-3` ingestion & validation).

---

## 2. Shared Environment Secret

| Variable Name | Java Spring Property | Required Length | Purpose |
| :--- | :--- | :--- | :--- |
| `LEUKQUANT_AGENT_TOKEN_PEPPER` | `leukquant.agent-token.pepper` | Minimum 32 characters (256-bit entropy recommended) | Cryptographic secret key used as HMAC key for token hashing |

> [!CAUTION]
> In production and staging, `LEUKQUANT_AGENT_TOKEN_PEPPER` must be identical across all microservices (Node.js admin backend and Spring Boot services). Startup will abort if this secret is missing or under 32 characters in production mode.
> Legacy `LEUKQUANT_AUTH_PEPPER` is deprecated and will not satisfy production startup requirements.

---

## 3. Token Format & Generation

1. **Entropy Source**: Cryptographically secure pseudo-random number generator (`crypto.randomBytes(32)` in Node.js / `SecureRandom` in Java).
2. **Raw Token Prefix**: `lka_` (LeukQuant Agent)
3. **Raw Token Structure**:
   ```
   lka_<64-character-lowercase-hexadecimal>
   ```
   **Total Length**: 68 characters.
   **Example**: `lka_d49f05a6391d4e41b2c405a7698a9668d2b27a3f019058b871c8b7468165b4c9`

---

## 4. Hashing & Verification Algorithm

1. **Algorithm**: `HMAC-SHA256`
2. **Key**: UTF-8 bytes of `LEUKQUANT_AGENT_TOKEN_PEPPER`
3. **Payload**: UTF-8 bytes of the full `raw_token` string (including `lka_` prefix)
4. **Output Format**: Lowercase hexadecimal string (64 characters)
5. **Database Storage**: Stored in `agents.agent_token_hash`

### Mathematical Definition:
$$\text{agent\_token\_hash} = \text{hex}(\text{HMAC-SHA256}(\text{key} = \text{LEUKQUANT\_AGENT\_TOKEN\_PEPPER}, \text{data} = \text{raw\_token}))$$

### Implementation Examples

#### Node.js (Provisioning & Rotation)
```javascript
const crypto = require('crypto');

function generateAgentToken(pepper) {
  const randomHex = crypto.randomBytes(32).toString('hex');
  const rawToken = `lka_${randomHex}`;
  const tokenHash = crypto.createHmac('sha256', pepper).update(rawToken, 'utf8').digest('hex');
  return { rawToken, tokenHash };
}
```

#### Java / Spring Boot (Ingestion Verification)
```java
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.HexFormat;

public class AgentTokenValidator {
    public static String hashToken(String rawToken, String pepper) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        SecretKeySpec secretKey = new SecretKeySpec(pepper.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
        mac.init(secretKey);
        byte[] rawHmac = mac.doFinal(rawToken.getBytes(StandardCharsets.UTF_8));
        return HexFormat.of().formatHex(rawHmac);
    }

    public static boolean constantTimeEquals(String hashA, String hashB) {
        if (hashA == null || hashB == null) return false;
        return MessageDigest.isEqual(
            hashA.getBytes(StandardCharsets.UTF_8),
            hashB.getBytes(StandardCharsets.UTF_8)
        );
    }
}
```

---

## 5. Token Lifecycle & Single-View Policy

1. **Single-View Display**:
   - The plaintext `raw_token` is returned **only once** in the `POST /api/admin/agents/provision` or `POST /api/admin/agents/:id/rotate-token` HTTP response.
   - The database **never** stores the plaintext token.
   - The database `agent_token_hash` is **never** returned in any `GET` API response.
2. **Ingestion Verification Rules**:
   An agent request is authorized if and only if:
   - Header contains `Authorization: Bearer <raw_token>`.
   - The computed hash matches an entry in `agents` table where:
     - `is_active = TRUE`
     - `token_revoked_at IS NULL`
     - `token_expires_at > CURRENT_TIMESTAMP`
     - `tenant_id` and `deployment_id` match the payload boundaries.
3. **Revocation**:
   - `POST /api/admin/agents/:id/revoke` immediately sets `is_active = FALSE` and `token_revoked_at = CURRENT_TIMESTAMP`.
4. **Audit Trail**:
   - Every provision, rotation, and revocation action writes an immutable record to the audit logs.
