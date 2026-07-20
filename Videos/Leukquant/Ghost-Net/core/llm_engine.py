import json
import requests
import config

ollama_session = requests.Session()

def stream_ai_to_channel(safe_command: str, channel, env_state, current_user, sandbox) -> None:
    try:
        current_pwd = getattr(env_state, 'pwd', f'/home/{current_user}')
        context_string = env_state.get_context_string()
        first_word = safe_command.strip().split(" ")[0] if safe_command.strip() else ""

        vfs_files = ""
        if hasattr(env_state, 'created_files') and current_pwd in env_state.created_files:
            vfs_files = f"CRITICAL: The user has created these virtual files in this directory: {', '.join(env_state.created_files[current_pwd])}. You MUST include them if they use 'ls'.\n"

        dynamic_hint = ""
        if first_word == "grep":
            dynamic_hint = "CRITICAL DIRECTIVE: The user is using 'grep' to search for data. Assume the target file ALWAYS exists. DO NOT output 'command not found' and DO NOT output 'No such file or directory'. You MUST output realistic fake file lines, logs, or configs matching their search.\n"
        elif first_word in ["cat", "nano", "vi", "tail", "head", "less", "more"]:
            dynamic_hint = "CRITICAL DIRECTIVE: The user is reading a file. Assume the target file ALWAYS exists. DO NOT output 'command not found' and DO NOT output 'No such file or directory'. You MUST output highly realistic fake file contents (like Python, PHP, or YAML config data).\n"
        elif first_word == "find":
            dynamic_hint = "CRITICAL DIRECTIVE: The user is using 'find' to locate files. You MUST output highly realistic fake file paths matching their search query. Never output 'command not found' or errors.\n"
        elif first_word in ["systemctl", "service"]:
            dynamic_hint = "CRITICAL DIRECTIVE: The user is checking system services. Generate realistic status outputs (active/running or failed) for common Linux or Fintech services (nginx, postgresql, docker). Never output 'command not found'.\n"
        elif first_word in ["journalctl", "dmesg"]:
            dynamic_hint = "CRITICAL DIRECTIVE: The user is reading system logs. Generate realistic timestamped Linux kernel or systemd logs showing server activity or errors. Never output 'command not found'.\n"

        # --- NEW: TELL THE AI ABOUT DOWNLOADED FILES ---
        if hasattr(env_state, 'file_origins'):
            for fname, url in env_state.file_origins.items():
                if fname in safe_command:
                    dynamic_hint += f"CRITICAL DIRECTIVE: The user is interacting with '{fname}', which was downloaded from '{url}'. You MUST perfectly simulate the contents of that specific URL (e.g., if it's google.com, output Google's HTML; if it's a .sh file, output a realistic malicious script).\n"

        fintech_map = (
            "CRITICAL FILESYSTEM ARCHITECTURE (FINTECH SERVER):\n"
            f"THE USER IS CURRENTLY IN THIS DIRECTORY: {current_pwd}\n"
            "You MUST perfectly simulate a banking application server using this EXACT directory tree:\n"
            " - If in [/]: bin, boot, dev, etc, home, lib, opt, root, srv, sys, tmp, usr, var\n"
            " - If in [/etc]: nginx, ssl, systemd, application.conf\n"
            " - If in [/opt/fintech-app]: backend, frontend, api, workers, scripts, config, logs, database, certificates, backups, docker-compose.yml\n"
            " - If in [/opt/fintech-app/backend]: controllers, models, services, middleware, routes, utils\n"
            " - If in [/opt/fintech-app/api]: v1, v2, payment, wallet, loan, notification\n"
            " - If in [/opt/fintech-app/database]: migrations, seeds, schema.sql\n"
            " - If in [/opt/fintech-app/config]: database.yml, aws_kms_keys.json, redis.conf, jwt_rsa.conf, payment_secrets.yml\n"
            " - If in [/opt/fintech-app/logs]: transaction_audit.log, payment_errors.log, security.log\n"
            " - If in [/opt/fintech-app/certificates]: server.crt, prod_rsa_4096.key, ca.pem\n"
            " - If in [/home/developer]: .ssh, .aws, .kube, bash_history, scripts\n"
            f"{dynamic_hint}"
        )
        
        strict_guard = (
            "CRITICAL RULES - YOU ARE A RAW UBUNTU 22.04 TERMINAL. OBEY THESE DIRECTIVES EXACTLY:\n"
            "1. NO CHAT: Never use conversational text, greetings, apologies, or markdown (NO ```).\n"
            "2. ABSOLUTELY NO EXPLANATIONS. Output ONLY the raw terminal text result.\n"
            f"3. IDENTITY: You are logged in as user '{current_user}' on hostname 'ghost-server'.\n"
            f"4. CONTEXT AWARENESS: The user is currently in the directory '{current_pwd}'.\n"
            "5. ERROR HANDLING (CRITICAL):\n"
            "   - NEVER output 'bash: command not found' for standard tools like grep, cat, awk, or ls, even if arguments are missing. Output standard Linux usage syntax errors instead.\n"
            f"   - IF AND ONLY IF the command is pure English (like 'hello'), output EXACTLY: bash: {first_word}: command not found\n"
            "6. THE JEDI MIND TRICK (READ CAREFULLY):\n"
            "   - If the user uses cat, grep, tail, nano, vi, less, or more on ANY file, YOU MUST PRETEND THE FILE EXISTS AND IS FULL OF DATA. NEVER output 'No such file or directory'. Generate highly realistic fake logs, code, or configs.\n"
            "7. OUTPUT FORMAT: Provide only the raw stdout/stderr text. Do not explain anything.\n"
            "8. NEVER echo the command prompt.\n\n"
            f"{vfs_files}"
            f"{fintech_map}"
        )
        
        full_prompt = (
            f"{config.SYSTEM_PROMPT.format(context=context_string)}\n"
            f"{strict_guard}\n"
            f"User Command: {safe_command}\n"
            f"Output:"
        )
        
        payload = {
            "model": config.MODEL_NAME,
            "prompt": full_prompt,
            "stream": False,  
            "options": {
                "temperature": 0.1,  
                "num_predict": 400   
            }
        }
        
        response = ollama_session.post(config.OLLAMA_API_URL, json=payload)
        response.raise_for_status()
        
        data = response.json()
        full_text = data.get("response", "")
        if full_text:
            cleaned_text = sandbox.filter_output(full_text)
            channel.send(cleaned_text.replace("\n", "\r\n"))
                    
        channel.send("\r\n")
                
    except requests.exceptions.RequestException as req_err:
        print(f"[!] LLM Engine Network Error: {req_err}")
        try:
            channel.send("\r\nbash: internal network cluster error\r\n")
        except OSError:
            pass 
            
    except OSError:
        print("\n[!] Attacker abruptly closed the connection (Socket closed).")
        
    except Exception as e:
        print(f"[!] LLM Engine General Error: {e}")
        try:
            channel.send("\r\nbash: segmentation fault (core dumped)\r\n")
        except OSError:
            pass