# LeukQuant Staging Rollback Plan & Disaster Recovery Runbook
============================================================
**Document Version:** 1.0.0-PRO  
**Target Environment:** Coolify Staging Tier  
**Scope:** Automated Database Rollback, Container Rollback & Incident Containment  
**Last Updated:** 2026-08-15  

---

## 1. Rollback Trigger Criteria

A rollback on the Coolify staging environment is mandatory if any of the following failure modes occur:
1. **Flyway Migration Failure**: Any schema migration fails to apply or corrupts the schema table (`flyway_schema_history`).
2. **Critical Security Vulnerability (P0)**: Discovery of unencrypted plaintext credential storage, secret exposure in logs, or unauthorized cross-tenant data leakage.
3. **Continuous CrashLoopBackOff**: Backend services fail startup assertions (e.g. invalid secret entropy, DB connection refusal) and cannot recover within 3 restarts.
4. **Data Corruption or Inconsistent State**: Inability to reconstruct AES-256-GCM authenticated context (AAD mismatch) or database integrity constraints broken.

---

## 2. Emergency Rollback Procedures

### Scenario A: Database Schema Rollback & Backup Restoration
If a Flyway migration or schema update causes failure:

```bash
# 1. Stop all ingestion and backend containers to prevent partial writes
docker stop middle-man-1-staging middle-man-3-staging admin-backend-staging

# 2. Terminate active database connections
psql -h localhost -U postgres -d leukquant_staging -c "
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'leukquant_staging'
  AND pid <> pg_backend_pid();"

# 3. Drop corrupted staging database and recreate from pre-migration snapshot
dropdb -h localhost -U postgres leukquant_staging
createdb -h localhost -U postgres leukquant_staging

# 4. Restore baseline backup
psql -h localhost -U postgres -d leukquant_staging < backup_baseline_<timestamp>.sql

# 5. Verify database integrity
psql -h localhost -U postgres -d leukquant_staging -c "
SELECT version, description, success FROM flyway_schema_history ORDER BY installed_rank;"
```

---

### Scenario B: Container & Service Version Rollback
If a container deployment introduces a regression:

```bash
# 1. In Coolify Dashboard -> Service Settings -> Deployments
# Select the previous stable commit SHA or tag (e.g. v2.0.0-stable)

# 2. Trigger instant redeploy with previous environment configurations
# Coolify command via CLI or UI:
coolify deploy --service <service-id> --commit <previous-stable-sha>

# 3. Verify health status
curl -f http://localhost:8081/actuator/health || echo "Health check failed!"
```

---

### Scenario C: Compromised Staging Key / Pepper Rotation
If a staging secret (e.g. `LEUKQUANT_AGENT_TOKEN_PEPPER` or `ADMIN_KEY`) is accidentally exposed:

1. **Immediate Revocation**:
   - Generate new random 256-bit secret via PowerShell:
     ```powershell
     $bytes = New-Object byte[] 32
     [System.Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
     [Convert]::ToBase64String($bytes)
     ```
2. **Coolify Secrets Update**:
   - Update secret in Coolify environment variables without saving to Git.
3. **Agent Token Re-provisioning**:
   - Issue batch rotation for staging sensor agents via `POST /api/admin/agents/:id/rotate-token`.
4. **Audit Log Verification**:
   - Inspect `cleanup_audit_log` and `forensic_access_audit` for anomalous access.

---

## 3. Post-Rollback Validation Checklist

- [ ] All containers report status `Healthy` (`UP`).
- [ ] Database restored to verified clean snapshot.
- [ ] Flyway schema history in valid, consistent state.
- [ ] Zero unencrypted evidence records present.
- [ ] Smoke test passes for sensor ingest and dashboard WebSocket feed.
