# Ghost-Net/utils/logger.py

import json
import os
from datetime import datetime

LOG_FILE = "logs/threat_data.json"

# Exhaustive list covering every single file and folder in the Fintech Architecture
HIGH_VALUE_TARGETS = [
    # Root & System Configs
    "/opt/fintech-app", "/etc/nginx", "/etc/ssl", "/etc/systemd", "application.conf",
    # App Core Directories
    "backend", "frontend", "api", "workers", "scripts", "config", "logs", "database", "certificates", "backups",
    # Backend & API Routes
    "controllers", "models", "services", "middleware", "routes", "utils",
    "v1", "v2", "payment", "wallet", "loan", "notification",
    # Database & Configurations
    "migrations", "seeds", "schema.sql",
    "database.yml", "application.yml", "redis.conf", "jwt.conf", "payment.conf",
    # Logs
    "application.log", "error.log", "payment.log", "audit.log", "security.log",
    # Certificates & Backups
    "server.crt", "server.key", "ca.pem",
    "daily", "weekly", "monthly",
    # Automation Scripts
    "deploy.sh", "backup.sh", "restart.sh", "healthcheck.sh",
    # Additional Infrastructure
    "/var/log/nginx", "/var/log/app", "/var/log/audit",
    "/srv/uploads", "/home/developer",
    "vault", "kms", "iam", "firewall", "monitoring"
]

def log_event(ip_address, event_type, **kwargs):
    """
    Records attacker activity into a JSON-formatted log file.
    Uses JSON Lines format (append mode) to prevent data corruption during crashes.
    """
    timestamp = datetime.utcnow().isoformat() + "Z"
    
    severity = "LOW"
    alert_tag = "GENERAL_ACTIVITY"
    
    command_text = kwargs.get("command", "").lower()
    
    # --- NEW: ADVANCED PATTERN ANALYSIS ENGINE ---
    threat_category = "Reconnaissance"
    mitre_tactic = "TA0007 (Discovery)"
    conclusion = "Attacker is exploring the file system or executing basic commands."
    
    if "wget" in command_text and "chmod" in command_text:
        threat_category = "Malware Dropper"
        mitre_tactic = "TA0002 (Execution)"
        conclusion = "CRITICAL: Attacker is attempting to download and execute a remote payload (likely Mirai or Gafgyt)."
        severity = "CRITICAL"
    elif "nc -e" in command_text or "/dev/tcp" in command_text or "bash -i" in command_text:
        threat_category = "Reverse Shell"
        mitre_tactic = "TA0011 (Command and Control)"
        conclusion = "CRITICAL: Attacker is attempting to open a reverse connection to control the server remotely."
        severity = "CRITICAL"
    elif "xmrig" in command_text or "stratum" in command_text or "minerd" in command_text:
        threat_category = "Cryptojacking"
        mitre_tactic = "TA0040 (Impact)"
        conclusion = "HIGH: Attacker is trying to deploy a CPU/GPU cryptocurrency miner."
        severity = "HIGH"
    elif "shadow" in command_text or "passwd" in command_text:
        threat_category = "Credential Theft"
        mitre_tactic = "TA0006 (Credential Access)"
        conclusion = "HIGH: Attacker is attempting to steal system password hashes for offline cracking."
        severity = "HIGH"
    
    # Check if the attacker is snooping in our juicy fintech folders
    for target in HIGH_VALUE_TARGETS:
        if target in command_text:
            severity = "CRITICAL"
            alert_tag = f"FINTECH_TARGET_ACCESSED: {target}"
            conclusion = f"CRITICAL: Attacker is actively targeting sensitive financial data or configurations ({target})."
            threat_category = "Data Exfiltration Target"
            break
            
    # Elevate severity if they try to use sudo/su passwords
    if event_type == "SECONDARY_AUTH":
        severity = "HIGH"
        alert_tag = "CREDENTIAL_THEFT_ATTEMPT"
        conclusion = "Attacker attempted to elevate privileges using stolen credentials."
        threat_category = "Privilege Escalation"
        mitre_tactic = "TA0004 (Privilege Escalation)"
    
    log_entry = {
        "timestamp": timestamp,
        "attacker_ip": ip_address,
        "event_type": event_type,
        "severity": severity,
        "alert_tag": alert_tag,
        "threat_intelligence": {
            "category": threat_category,
            "mitre_attck_tactic": mitre_tactic,
            "behavioral_conclusion": conclusion
        },
        "details": kwargs
    }
    
    try:
        # --- NEW: AUTO-CREATE DIRECTORY IF IT DOESN'T EXIST ---
        log_dir = os.path.dirname(LOG_FILE)
        if log_dir: # Only try to make a directory if a folder path is specified
            os.makedirs(log_dir, exist_ok=True)
            
        with open(LOG_FILE, "a", encoding="utf-8") as f:
            f.write(json.dumps(log_entry) + "\n")
            
    except PermissionError:
        print(f"[!] LOGGING ERROR: {LOG_FILE} is locked. Close it if you have it open!")
    except Exception as e:
        print(f"[!] LOGGING ERROR: Could not write to JSON file: {e}")