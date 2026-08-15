-- ============================================================================
-- LEUKQUANT MANUAL STAGING / TEST DATA SANITIZATION SCRIPT
-- PURPOSE: Purge legacy Base64 unencrypted evidence records on staging/test databases.
-- CAUTION: Do NOT execute on production without compliance sign-off & verified backup.
-- ============================================================================

BEGIN;

-- 1. Identify legacy Base64 unencrypted rows (where ciphertext IS NULL and encrypted_credentials IS NOT NULL)
SELECT COUNT(*) AS legacy_unencrypted_count 
FROM "restricted_event_evidence" 
WHERE "ciphertext" IS NULL AND "encrypted_credentials" IS NOT NULL;

-- 2. Purge unencrypted legacy evidence records from staging/test environment
DELETE FROM "restricted_event_evidence"
WHERE "ciphertext" IS NULL;

-- 3. Verify clean state
SELECT COUNT(*) AS remaining_evidence_records 
FROM "restricted_event_evidence";

COMMIT;
