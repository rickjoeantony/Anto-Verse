import re
import queue
import threading
import json
from datetime import datetime

# Our ultra-fast memory queue. By setting maxsize=10000, we prevent memory exhaustion 
# during a massive DDoS or botnet swarm attack.
payload_queue = queue.Queue(maxsize=10000)

class PayloadDetector:
    def __init__(self):
        print("[*] Payload Detector Initializing: Compiling 40+ Regex Signatures...")
        
        # We pre-compile all regexes with re.IGNORECASE for sub-millisecond execution speeds.
        raw_signatures = {
            # === BOTNETS & DROPPERS (Mirai, Gafgyt, Tsunami) ===
            "Mirai_BusyBox_Invoke": r"busybox\s+[a-z]+",
            "Mirai_Binary_Execution": r"/bin/busybox",
            "Wget_Dropper_Script": r"wget\s+(?:http|ftp).*?\.sh",
            "Curl_Pipe_Execution": r"curl\s+(?:-O|-o|.*http).*?\.sh\s*\|",
            "Tftp_Download": r"tftp\s+-g",
            "Malware_Chmod_Execution": r"chmod\s+(?:\+x|777)",
            "Botnet_Cleanup_Routine": r"rm\s+-rf\s+(?:/var/run|/tmp)",
            "Hex_Encoded_Dropper": r"echo\s+-e\s+[\"']\\x[0-9a-fA-F]",
            
            # === REVERSE SHELLS ===
            "Bash_Reverse_Shell": r"bash\s+-i\s*>\&",
            "Dev_TCP_Socket": r"/dev/tcp/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}",
            "Netcat_Execute_Shell": r"nc\s+-e\s+/bin/(?:ba)?sh",
            "Netcat_OpenBSD_Shell": r"nc\s+-c\s+/bin/(?:ba)?sh",
            "Python_PTY_Spawn": r"python\s+-c\s+['\"]import pty",
            "Python_Socket_Shell": r"python\s+-c\s+['\"]import socket",
            "Perl_Socket_Shell": r"perl\s+-e\s+['\"]use Socket",
            "PHP_Reverse_Shell": r"php\s+-r\s+['\"]\$sock",
            "Ruby_Socket_Shell": r"ruby\s+-rsocket",
            "Lua_Socket_Shell": r"lua\s+-e\s+['\"]require\('socket'\)",
            "Socat_Exec_Shell": r"socat\s+exec:.*pty",
            "Zsh_Modload_Shell": r"zsh\s+-c\s+['\"]zmodload",
            "Awk_Inet_Socket": r"awk\s+'BEGIN\s*\{\s*s\s*=\s*\"/inet/tcp/",
            
            # === CRYPTO MINERS ===
            "Miner_XMRig": r"xmrig",
            "Miner_Minerd": r"minerd",
            "Miner_XMR_Stak": r"xmr-stak",
            "Stratum_Mining_Protocol": r"stratum\+tcp",
            "Known_Miner_Pool_Monero": r"pool\.supportxmr\.com|mine\.moneropool\.com",
            "Known_Miner_Pool_Generic": r"c3pool|nanopool",
            
            # === PERSISTENCE MECHANISMS ===
            "SSH_Authorized_Keys_Tamper": r"echo\s+.*?>>\s*(?:~|\$HOME|\/root)\/.ssh\/authorized_keys",
            "Crontab_Tamper": r"echo\s+.*?>>\s*/etc/crontab",
            "Crontab_List_Recon": r"crontab\s+-l",
            "Systemd_Service_Enable": r"systemctl\s+(?:enable|start)",
            "InitD_Service_Tamper": r"update-rc\.d|chkconfig\s+--add",
            "Bashrc_Profile_Tamper": r"(?:~|\$HOME)/\.bashrc|/etc/profile",
            "Background_Nohup_Task": r"nohup\s+.*?\s+&",
            
            # === RECON & EXFILTRATION ===
            "Shadow_File_Theft": r"cat\s+/etc/shadow",
            "Passwd_File_Recon": r"cat\s+/etc/passwd",
            "System_Arch_Recon": r"uname\s+-a",
            "CPU_Hardware_Recon": r"lscpu", # Frequently used by miners to check cores
            "Memory_Recon": r"free\s+-m",
            "Process_List_Recon": r"ps\s+(?:aux|-ef)",
            "Network_Route_Recon": r"netstat\s+(?:-an|-nlp)|ifconfig|ip\s+(?:a|route|link)|arp\s+-a",
            "Nmap_Port_Scan": r"nmap\s+",
            "Ping_Sweep": r"ping\s+-c",
            "Find_SUID_Binaries": r"find\s+/\s+-perm\s+-4000",
            
            # === KNOWN EXPLOIT STRINGS ===
            "Log4j_JNDI_Exploit": r"\$\{jndi:(?:ldap|rmi)",
            "Shellshock_Exploit": r"\(\)\s*\{\s*:\;\s*\}\;",
            "Base64_Obfuscated_Payload": r"base64\s+-d",
            "Anti_Forensics_History_Wipe": r"history\s+-c"
        }
        
        # Compile them all!
        self.signatures = {name: re.compile(regex, re.IGNORECASE) for name, regex in raw_signatures.items()}

    def scan(self, ip, command):
        """Scans a command against all signatures and logs matches instantly."""
        for threat_name, compiled_regex in self.signatures.items():
            if compiled_regex.search(command):
                # We have a match! 
                print(f"\n[🚨 CRITICAL PAYLOAD DETECTED] IP: {ip} | Threat: {threat_name}")
                self.log_alert(ip, threat_name, command)
                # Don't break, keep scanning in case the payload contains multiple threat vectors

    def log_alert(self, ip, threat_name, command):
        timestamp = datetime.utcnow().isoformat() + "Z"
        alert_data = {
            "timestamp": timestamp,
            "ip": ip,
            "threat_signature": threat_name,
            "raw_payload": command
        }
        try:
            with open("payload_alerts.json", "a", encoding="utf-8") as f:
                f.write(json.dumps(alert_data) + "\n")
        except Exception as e:
            print(f"[!] Alert logging failed: {e}")

def worker_loop():
    """Runs continuously in a background thread, pulling events from the queue."""
    detector = PayloadDetector()
    while True:
        try:
            # Block until an event is available in the queue
            event = payload_queue.get()
            detector.scan(event['ip'], event['command'])
            payload_queue.task_done()
        except Exception as e:
            print(f"[!] Queue Worker Error: {e}")

def start_payload_scanner():
    """Spawns the background daemon thread for payload analysis."""
    t = threading.Thread(target=worker_loop, daemon=True)
    t.start()
    print("[*] High-Speed Payload Scanner Queue activated in background.")