import posixpath
from core.sandbox import SandboxGuard
from core.llm_engine import stream_ai_to_channel

def execute_bash_command(user_command: str, channel, env_state, current_user="ubuntu") -> None:
    # 1. Connect to the Sandbox Engine First
    sandbox = SandboxGuard(env_state)
    safe_command = sandbox.filter_input(user_command)
    
    # --- SILENT BASH ASSIGNMENTS ---
    if safe_command == "BASH_INTERNAL_HANDLED":
        return
        
    # CRITICAL: Save the old path in case we need to revert a bad 'cd'
    old_pwd = getattr(env_state, 'pwd', f'/home/{current_user}')
    
    cmd_lower = safe_command.strip().lower()
    first_cmd_word = cmd_lower.split()[0] if cmd_lower.strip() else ""
        # --- HARDENED SYSTEM COMMANDS ---
    if first_cmd_word == "whoami":
        channel.send(f"{current_user}\r\n")
        return
    
    if first_cmd_word == "id":
        if current_user == "root":
            channel.send("uid=0(root) gid=0(root) groups=0(root)\r\n")
        else:
            channel.send("uid=1000(ubuntu) gid=1000(ubuntu) groups=1000(ubuntu),4(adm),27(sudo)\r\n")
        return

    if first_cmd_word == "uname":
        channel.send("Linux ghost-server 5.15.0-89-generic #99-Ubuntu SMP Mon Oct 30 20:42:41 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux\r\n")
        return

    if first_cmd_word in ["ps", "top", "htop"]:
        channel.send(
            "USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND\r\n"
            "root           1  0.0  0.1 167008 11392 ?        Ss   Oct10   0:05 /sbin/init\r\n"
            "root         350  0.0  0.0  12400  4200 ?        Ss   Oct10   0:01 /lib/systemd/systemd-journald\r\n"
            "root         543  0.0  0.0  12344  4000 ?        Ss   Oct10   0:00 sshd: /usr/sbin/sshd -D\r\n"
            "www-data    2048  1.5  2.2 602300 92320 ?        Sl   Oct10   1:12 nginx: worker process\r\n"
            "ubuntu      3050  0.0  0.1   8340  3400 pts/0    Ss   14:20   0:00 -bash\r\n"
            "ubuntu      3051  0.0  0.0   8900  3200 pts/0    R+   14:21   0:00 ps aux\r\n"
        )
        return

    if first_cmd_word == "ls":
        # ... keep your existing ls logic, but ensure it returns clean formatting ...
        pass
# ... existing code ...

        # --- NEW: GOLD STANDARD DECEPTION LIBRARY ---
        DECEPTION_TEMPLATES = {
            "/etc/passwd": "root:x:0:0:root:/root:/bin/bash\ndaemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin\nubuntu:x:1000:1000:Ubuntu:/home/ubuntu:/bin/bash\npostgres:x:101:104::/var/lib/postgresql:/usr/sbin/nologin",
            "/etc/shadow": "root:$6$aU9/x...$7qP1...:19500:0:99999:7:::\nubuntu:$6$vB2$qwe...$8aN2...:19500:0:99999:7:::",
            ".aws/credentials": "[default]\naws_access_key_id = AKIAIOSFODNN7EXAMPLE\naws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
            "wp-config.php": "define( 'DB_NAME', 'wp_production' );\ndefine( 'DB_USER', 'db_admin' );\ndefine( 'DB_PASSWORD', 'SuperSecurePass123!' );\ndefine( 'DB_HOST', 'localhost' );",
            ".bash_history": "ls -la\ncd /opt/fintech-app\ncat config/database.yml\ndocker-compose up -d\nhistory"
        }

        # Inject this into the system prompt logic
        template_text = "\n".join([f"Template for {k}: {v}" for k, v in DECEPTION_TEMPLATES.items()])
        
        strict_guard = (
            f"CRITICAL RULES: ... (your existing rules)\n"
            f"USE THESE EXACT FILE TEMPLATES IF THE USER READS THESE FILES:\n{template_text}\n"
        )
    
    # --- PYTHON LEVEL STATIC INTERCEPTS ---
    if first_cmd_word == "whoami":
        channel.send(f"{current_user}\r\n")
        return
    if first_cmd_word == "id":
        if current_user == "root":
            channel.send("uid=0(root) gid=0(root) groups=0(root)\r\n")
        else:
            channel.send("uid=1000(ubuntu) gid=1000(ubuntu) groups=1000(ubuntu),4(adm),27(sudo)\r\n")
        return
    if first_cmd_word == "hostname":
        channel.send("ghost-server\r\n")
        return
    if first_cmd_word == "pwd":
        current_pwd = getattr(env_state, 'pwd', f'/home/{current_user}')
        channel.send(f"{current_pwd}\r\n")
        return
    if first_cmd_word == "clear":
        channel.send("\033[2J\033[H")
        return

    # --- ADVANCED SYSTEM & RECON INTERCEPTORS ---
    if first_cmd_word == "uname":
        channel.send("Linux ghost-server 5.15.0-89-generic #99-Ubuntu SMP Mon Oct 30 20:42:41 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux\r\n")
        return
    if first_cmd_word == "free":
        channel.send("               total        used        free      shared  buff/cache   available\r\nMem:           8192        2048        1024         128        5120        5800\r\nSwap:          2048           0        2048\r\n")
        return
    if first_cmd_word == "df":
        channel.send("Filesystem      Size  Used Avail Use% Mounted on\r\ntmpfs           796M  1.2M  795M   1% /run\r\n/dev/sda1        50G   22G   26G  46% /\r\ntmpfs           3.9G     0  3.9G   0% /dev/shm\r\n")
        return
    if first_cmd_word in ["ps", "top", "htop"]:
        channel.send("USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND\r\nroot           1  0.0  0.1 167008 11392 ?        Ss   Oct10   0:05 /sbin/init\r\nroot         543  0.0  0.0  12344  4000 ?        Ss   Oct10   0:00 sshd: /usr/sbin/sshd -D\r\nubuntu      1024  0.0  0.0   8340  3400 pts/0    Ss   10:00   0:00 -bash\r\nroot        2048  5.0  2.0 543200 84320 ?        Sl   10:05   0:12 /opt/fintech-app/backend/node server.js\r\nubuntu      2049  0.0  0.0   8900  3200 pts/0    R+   10:06   0:00 ps aux\r\n")
        return
        
    if first_cmd_word in ["netstat", "ss"]:
        channel.send("Active Internet connections (servers and established)\r\nProto Recv-Q Send-Q Local Address           Foreign Address         State      \r\ntcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN     \r\ntcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN     \r\ntcp        0      0 0.0.0.0:443             0.0.0.0:*               LISTEN     \r\ntcp        0      0 127.0.0.1:5432          0.0.0.0:*               LISTEN     \r\ntcp        0      0 192.168.1.5:22          192.168.1.100:54321     ESTABLISHED\r\n")
        return
    if first_cmd_word == "history":
        channel.send("    1  ls -la\r\n    2  cd /opt/fintech-app\r\n    3  cat config/database.yml\r\n    4  nano .env\r\n    5  docker-compose up -d\r\n    6  history\r\n")
        return
    if cmd_lower in ["ip route", "route"]:
        channel.send("default via 192.168.1.1 dev eth0 proto dhcp src 192.168.1.5 metric 100 \r\n192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.5 \r\n")
        return
    if cmd_lower in ["ifconfig", "ip a", "ipconfig"]:
        ifconfig_mock = (
            "eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500\r\n"
            "        inet 192.168.1.105  netmask 255.255.255.0  broadcast 192.168.1.255\r\n"
            "        inet6 fe80::a00:27ff:fe8f:1a2b  prefixlen 64  scopeid 0x20<link>\r\n"
            "        ether 08:00:27:8f:1a:2b  txqueuelen 1000  (Ethernet)\r\n"
            "        RX packets 13423  bytes 1234567 (1.2 MB)\r\n"
            "        RX errors 0  dropped 0  overruns 0  frame 0\r\n"
            "        TX packets 11234  bytes 987654 (987.6 KB)\r\n"
            "        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0\r\n"
        )
        channel.send(ifconfig_mock)
        return

    # --- NETWORK DOWNLOAD SIMULATORS (CURL / WGET) ---
    if first_cmd_word == "curl":
        channel.send("<!DOCTYPE html>\r\n<html>\r\n<head>\r\n<title>Welcome to nginx!</title>\r\n</head>\r\n<body>\r\n<h1>Welcome to nginx!</h1>\r\n<p>If you see this page, the nginx web server is successfully installed and working.</p>\r\n</body>\r\n</html>\r\n")
        return
        
    if first_cmd_word == "wget":
        parts = safe_command.split()
        target_url = parts[-1] if len(parts) > 1 and not parts[-1].startswith("-") else "http://malicious-ip.com/payload.sh"
        filename = target_url.split("/")[-1] if "/" in target_url else "index.html"
        if not filename or "?" in filename:
            filename = "downloaded_payload.sh"
            
        # Fake wget progress output
        wget_output = (
            f"--2023-10-27 14:22:34--  {target_url}\r\n"
            f"Resolving host... 104.18.2.11\r\n"
            f"Connecting to 104.18.2.11:80... connected.\r\n"
            f"HTTP request sent, awaiting response... 200 OK\r\n"
            f"Length: 612 [text/x-sh]\r\n"
            f"Saving to: '{filename}'\r\n\r\n"
            f"     0K                                                        100% 2.34M=0s\r\n\r\n"
            f"2023-10-27 14:22:34 (2.34 MB/s) - '{filename}' saved [612/612]\r\n"
        )
        channel.send(wget_output)
        
        # Magically add the downloaded file to the Virtual File System!
        current_pwd = getattr(env_state, 'pwd', f'/home/{current_user}')
        if not hasattr(env_state, 'created_files'):
            env_state.created_files = {}
        if current_pwd not in env_state.created_files:
            env_state.created_files[current_pwd] = []
        if filename not in env_state.created_files[current_pwd]:
            env_state.created_files[current_pwd].append(filename)
            
        # --- NEW: TRACK WHERE THE FILE CAME FROM FOR THE AI ---
        if not hasattr(env_state, 'file_origins'):
            env_state.file_origins = {}
        env_state.file_origins[filename] = target_url
        
        return

    # --- SUDO / ROOT ESCALATION TRAP ---
    if first_cmd_word in ["sudo", "su"]:
        if getattr(env_state, 'current_user', 'ubuntu') == "root":
            return # Already root
            
        channel.send(f"[sudo] password for {current_user}: ")
        password_buffer = ""
        
        while True:
            char = channel.recv(1).decode('utf-8', errors='ignore')
            if char == '\r':
                channel.send('\r\n')
                break
            elif char in ['\x08', '\x7f']: # Backspace
                if len(password_buffer) > 0:
                    password_buffer = password_buffer[:-1]
            elif char == '\x03': # Ctrl+C
                channel.send('^C\r\n')
                return
            else:
                password_buffer += char

        # Check if they guessed the original login password
        expected_password = getattr(env_state, 'login_password', 'ubuntu')
        
        if password_buffer == expected_password or password_buffer == "root":
            env_state.current_user = "root"
            env_state.pwd = "/root"
        else:
            channel.send("su: Authentication failure\r\n")
        return

    # --- CD INTERCEPTOR ---
    if first_cmd_word == "cd":
        # Ensure we know the correct home directory based on the user privilege
        home_dir = "/root" if current_user == "root" else f"/home/{current_user}"
        parts = safe_command.split(maxsplit=1)
        
        if len(parts) > 1:
            target = parts[1].strip()
            
            if target == "..." or target.startswith("...."):
                channel.send(f"bash: cd: {target}: No such file or directory\r\n")
                env_state.pwd = old_pwd # Revert bad memory state
                return
                
            # Expand tilde (~) to the user's correct home directory
            if target.startswith("~"):
                target = target.replace("~", home_dir, 1)
                
            # Handle absolute vs relative paths properly
            if target.startswith("/"):
                env_state.pwd = posixpath.normpath(target)
            else:
                env_state.pwd = posixpath.normpath(posixpath.join(old_pwd, target))
        else:
            # Typing just 'cd' should go home
            env_state.pwd = home_dir
        return

    # --- TOUCH INTERCEPTOR ---
    if first_cmd_word == "touch":
        parts = safe_command.split(maxsplit=1)
        if len(parts) > 1:
            filename = parts[1].strip()
            current_pwd = getattr(env_state, 'pwd', f'/home/{current_user}')
            if not hasattr(env_state, 'created_files'):
                env_state.created_files = {}
            if current_pwd not in env_state.created_files:
                env_state.created_files[current_pwd] = []
            if filename not in env_state.created_files[current_pwd]:
                env_state.created_files[current_pwd].append(filename)
        return

    # --- VIM / NANO INTERACTIVE TRAP ---
    if first_cmd_word in ["vi", "vim", "nano"]:
        filename = safe_command.split(maxsplit=1)[1] if len(safe_command.split()) > 1 else "New File"
        channel.send(f"\033[2J\033[H\r\n~ \r\n~ \r\n~ \r\n~ \r\n\"{filename}\" [New File]\r\n")
        
        editor_buffer = ""
        while True:
            char = channel.recv(1).decode('utf-8', errors='ignore')
            if char == '\x1b': 
                # CRITICAL FIX: Swallow the next 2 bytes if they pressed an Arrow Key (^[A, ^[B, ^[C, ^[D)
                if channel.recv_ready():
                    channel.recv(2)
                continue 
            elif char == '\r':
                channel.send('\r\n')
                editor_buffer += '\n'
                if ":wq" in editor_buffer:
                    channel.send("\033[2J\033[H")
                    current_pwd = getattr(env_state, 'pwd', f'/home/{current_user}')
                    if not hasattr(env_state, 'created_files'):
                        env_state.created_files = {}
                    if current_pwd not in env_state.created_files:
                        env_state.created_files[current_pwd] = []
                    if filename not in env_state.created_files[current_pwd]:
                        env_state.created_files[current_pwd].append(filename)
                    break
            elif char == '\x08' or char == '\x7f':
                # CRITICAL FIX: Only backspace if there is text to delete, preventing UI corruption
                if len(editor_buffer) > 0:
                    editor_buffer = editor_buffer[:-1]
                    channel.send('\x08 \x08')
            else:
                editor_buffer += char
                channel.send(char)
        return

    # --- GREP HIGH-SPEED INTERCEPTOR ---
    if first_cmd_word == "grep":
        if "error" in cmd_lower or "fail" in cmd_lower:
            channel.send("May 10 08:14:02 ghost-server kernel: [ 12.345] EXT4-fs (sda1): error count since last fsck: 2\r\n")
            channel.send("May 10 09:22:15 ghost-server sshd[10243]: error: PAM: Authentication failure for root from 192.168.1.5\r\n")
            return
        elif "root" in cmd_lower:
            channel.send("root:x:0:0:root:/root:/bin/bash\r\n")
            return
        # If they search for something juicy, it falls through to the AI engine at the bottom of the file!

    # --- GLOBAL PYTHON LEVEL LS INTERCEPTOR ---
    if first_cmd_word in ["ls", "ll", "dir"]:
        home_dir = "/root" if current_user == "root" else f"/home/{current_user}"
        current_pwd = getattr(env_state, 'pwd', f'/home/{current_user}')
        parts = safe_command.split()
        target_dir = current_pwd
        
        # Check if they passed an argument (like 'ls documents' or 'ls /etc')
        if len(parts) > 1 and not parts[1].startswith("-"):
            arg = parts[1]
            
            # Apply Tilde Expansion to 'ls' commands as well
            if arg.startswith("~"):
                arg = arg.replace("~", home_dir, 1)
                
            if arg.startswith("/"):
                target_dir = arg
            else:
                target_dir = posixpath.normpath(posixpath.join(current_pwd, arg))
                
        dynamic_files = ""
        if hasattr(env_state, 'created_files') and target_dir in env_state.created_files:
            dynamic_files = "  " + "  ".join(env_state.created_files[target_dir])
            
        target_lower = target_dir.lower()
        if target_dir == "/":
            channel.send(f"bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var{dynamic_files}\r\n")
        elif target_dir == "/opt/fintech-app":
            channel.send(f"api  backend  backups  certificates  config  database  docker-compose.yml  Dockerfile  frontend  logs  README.md  scripts  workers{dynamic_files}\r\n")
        elif target_dir == "/opt/fintech-app/config":
            channel.send(f"application.yml  aws_kms_keys.json  database.yml  jwt_rsa.conf  payment_secrets.yml  redis.conf{dynamic_files}\r\n")
        elif target_dir == "/opt/fintech-app/api":
            channel.send(f"loan_processor.js  payment_gateway.js  stripe_webhooks.js  v1  v2{dynamic_files}\r\n")
        elif target_dir == "/etc":
            channel.send(f"application.conf  nginx  ssl  systemd{dynamic_files}\r\n")
        elif target_lower in [f"/home/{current_user}", "/root", "~", "/root/"]:
            channel.send(f"Desktop  Documents  Downloads  Music  Pictures  Videos  snap{dynamic_files}\r\n")
        elif target_lower in [f"/home/{current_user}/documents", "/root/documents"]:
            channel.send(f"financial_report.pdf  passwords.txt  Q3_architecture_ideas.docx{dynamic_files}\r\n")
        elif target_lower in [f"/home/{current_user}/downloads", "/root/downloads"]:
            channel.send(f"wp-config-backup.zip  install.sh  .bash_history{dynamic_files}\r\n")
        else:
            output = dynamic_files.strip()
            if output:
                channel.send(f"{output}\r\n")
            else:
                channel.send(f"ls: cannot access '{parts[1] if len(parts) > 1 else ''}': No such file or directory\r\n")
        return

    # 2. Connect the Sandbox directly to the LLM Engine for generation
    stream_ai_to_channel(safe_command, channel, env_state, current_user, sandbox)