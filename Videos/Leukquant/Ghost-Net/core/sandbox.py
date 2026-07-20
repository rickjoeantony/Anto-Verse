# Ghost-Net/core/sandbox.py

import requests
import config
import re

class SandboxGuard:
    def __init__(self, env_state=None):
        print("[*] Bash Sandbox Active: Emulating environment variables and filtering.")
        self.env_state = env_state
        
        # Initialize bash variable memory if it doesn't exist yet
        if self.env_state and not hasattr(self.env_state, 'bash_vars'):
            self.env_state.bash_vars = {
                "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "USER": "ubuntu",
                "HOME": "/home/ubuntu",
                "SHELL": "/bin/bash"
            }

        # A list of keywords attackers use to try and break out of the AI's persona
        self.forbidden_phrases = [
            "ignore previous",
            "forget everything",
            "system prompt",
            "instructions",
            "tell me a joke",
            "jailbreak",
            "ignore all",
            "bypass"
        ]

    def filter_input(self, user_command):
        """Scans the command for prompt injection and resolves Bash variables dynamically."""
        cmd_lower = user_command.lower()
        
        for phrase in self.forbidden_phrases:
            if phrase in cmd_lower:
                print(f"[🛡️ BASH SANDBOX] Blocked Prompt Injection Attempt: '{user_command}'")
                # Return a safe command so the AI throws a realistic bash error
                return "echo 'bash: syntax error near unexpected token'"
                
        # --- BASH ENVIRONMENT SIMULATOR ---
        if self.env_state:
            # 1. Expand variables (e.g., echo $USER -> echo ubuntu)
            for var, val in self.env_state.bash_vars.items():
                user_command = user_command.replace(f"${var}", val)
                user_command = user_command.replace(f"${{{var}}}", val)
                
            # 2. Variable Assignment (e.g., export FOO=bar)
            # This regex captures both 'FOO=bar' and 'export FOO=bar'
            assign_match = re.match(r'^(?:export\s+)?([a-zA-Z_][a-zA-Z0-9_]*)=(.*)$', user_command.strip())
            if assign_match:
                var_name = assign_match.group(1)
                var_value = assign_match.group(2).strip("\"'")
                self.env_state.bash_vars[var_name] = var_value
                print(f"[🛠️ BASH] Stored Variable: {var_name} = {var_value}")
                # Return a flag so we don't trigger the AI for silent variable assignments
                return "BASH_INTERNAL_HANDLED"
                
        return user_command

    def filter_output(self, token):
        """Strips markdown formatting and backticks from the AI's output stream."""
        if not token:
            return ""
            
        # Remove all backticks so the terminal doesn't render ``` 
        cleaned = token.replace("`", "")
        
        # Scrub common markdown language tags that get left behind
        tags_to_remove = ["bash\n", "sh\n", "plaintext\n", "shell\n", "html\n"]
        for tag in tags_to_remove:
            cleaned = cleaned.replace(tag, "")
        
        return cleaned

    def execute_in_sandbox(self, payload):
        """Proxies the request to Ollama. We can add rate limiting or logging here later."""
        # Fire the payload at Ollama and return the streaming response
        response = requests.post(config.OLLAMA_API_URL, json=payload, stream=True)
        response.raise_for_status()
        return response