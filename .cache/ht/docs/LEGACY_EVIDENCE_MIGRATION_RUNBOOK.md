# Production Legacy Forensic Evidence Migration Runbook
======================================================
**Document Version:** 1.0.0  
**Target Environment:** LeukQuant Production PostgreSQL Cluster  
**Security Classification:** RESTRICTED / COMPLIANCE OPERATIONAL

---

## 1. Context & Security Notice

Legacy evidence records ingested prior to Phase 6B utilized simple Base64 encoding. Under the LeukQuant Security Standard:
- **Base64 is not encryption.**
- All legacy records lacking `ciphertext` and `nonce` columns must be treated as **plaintext forensic records**.
- Flyway migration `V4__aes_gcm_evidence_encryption.sql` is strictly **non-destructive** and preserves all legacy rows with `encrypted_credentials` without dropping or deleting data.

---

## 2. Pre-Migration Prerequisites & Compliance Checklist

Before executing any production migration, the following sign-offs are mandatory:

- [ ] **Data Retention Compliance Sign-off**: Legal & CISO authorization to process historical forensic evidence records.
- [ ] **Encrypted Snapshot Backup**:
  ```bash
  pg_dump -h prod-db.internal -U postgres -d leukquant \
    --table=restricted_event_evidence \
    --table=honeydata \
    | gpg --symmetric --cipher-algo AES256 -o leukquant_evidence_backup_$(date +%Y%m%d).sql.gpg
  ```
- [ ] **Active Key Ring Provisioning**: Ensure `LEUKQUANT_EVIDENCE_KEY_ID` and `LEUKQUANT_EVIDENCE_ENCRYPTION_KEY` (Base64 random 32-byte key) are configured in Coolify production secret storage.
- [ ] **Verified Rollback Plan**: Ability to restore encrypted backup table if migration script encounters unexpected data anomalies.

---

## 3. Migration Execution Options

### Option A: Offline Cryptographic Re-Encryption Batch (Recommended)

An offline worker script connects using dedicated `forensic_evidence_reader` and `mm1_honeydata_writer` credentials:

1. Queries unmigrated records:
   ```sql
   SELECT e.id, e.honeydata_event_id, e.external_event_id, e.encrypted_credentials,
          h.tenant_id, h.deployment_id
   FROM "restricted_event_evidence" e
   JOIN "honeydata" h ON e.honeydata_event_id = h.event_id
   WHERE e.ciphertext IS NULL AND e.encrypted_credentials IS NOT NULL;
   ```
2. For each row:
   - Decodes legacy Base64 string into raw credentials.
   - Computes AAD context: `computeAad(tenant_id, deployment_id, external_event_id)`.
   - Encrypts via `AES/GCM/NoPadding` with unique 12-byte `SecureRandom` nonce and 128-bit authentication tag.
   - Updates target record:
     ```sql
     UPDATE "restricted_event_evidence"
     SET "ciphertext" = :ciphertextBase64,
         "nonce" = :nonceBase64,
         "algorithm" = 'AES/GCM/NoPadding',
         "encryption_key_id" = :activeKeyId,
         "encrypted_credentials" = NULL
     WHERE "id" = :id;
     ```

### Option B: Controlled Compliance Purge of Expired Evidence

If legacy records exceed the compliance retention boundary ($\ge 90$ days):
```sql
DELETE FROM "restricted_event_evidence"
WHERE "ciphertext" IS NULL AND "captured_at" < (CURRENT_TIMESTAMP - INTERVAL '90' DAY);
```

---

## 4. Post-Migration Verification

Verify all active forensic evidence records are protected under AES-256-GCM:

```sql
-- Assert 0 unencrypted legacy rows remain
SELECT COUNT(*) AS unencrypted_legacy_rows
FROM "restricted_event_evidence"
WHERE "ciphertext" IS NULL;

-- Assert all encrypted rows have valid nonces and algorithm tags
SELECT COUNT(*) AS valid_aes_gcm_records
FROM "restricted_event_evidence"
WHERE "ciphertext" IS NOT NULL 
  AND "nonce" IS NOT NULL 
  AND "algorithm" = 'AES/GCM/NoPadding'
  AND "encryption_key_id" IS NOT NULL;
```
