class VirtualEnvironment:
    def __init__(self):
        self.pwd = "/root"
        
        self.system_files = [
            "/root/.bash_history",
            "/var/www/html/wp-config.php",
            "/var/www/html/index.php",
            "/home/ubuntu/.aws/credentials",
            "/etc/passwd",
            "/etc/shadow"
        ]
        
        
        self.custom_files = []

    def update_state(self, command):
        parts = command.strip().split()
        if not parts:
            return

        cmd = parts[0]

        # Track Directory Changes (cd)
        if cmd == "cd" and len(parts) > 1:
            target = parts[1]
            if target == "..":
                if self.pwd != "/":
                    self.pwd = "/".join(self.pwd.split("/")[:-1]) or "/"
            elif target.startswith("/"):
                self.pwd = target # Absolute path
            else:
                self.pwd = f"{self.pwd}/{target}".replace("//", "/") # Relative path

        # Track File/Folder Creation (mkdir, touch)
        elif cmd in ["mkdir", "touch"] and len(parts) > 1:
            for item in parts[1:]:
                if item.startswith("-"): continue # Ignore flags like -p
                
                path = item if item.startswith("/") else f"{self.pwd}/{item}".replace("//", "/")
                if path not in self.custom_files and path not in self.system_files:
                    self.custom_files.append(path)
        
        # Track File Deletion (rm) to maintain the illusion of control
        elif cmd == "rm" and len(parts) > 1:
            for item in parts[1:]:
                if item.startswith("-"): continue
                
                path = item if item.startswith("/") else f"{self.pwd}/{item}".replace("//", "/")
                if path in self.custom_files:
                    self.custom_files.remove(path)
                elif path in self.system_files:
                    self.system_files.remove(path)
                
                elif "ai" in cmd:
                    pass

    def get_context_string(self):
        """Generates the exact prompt injection string for the local AI engine."""
        all_files = self.system_files + self.custom_files
        return (
            f"Current Working Directory: {self.pwd}\n"
            f"Existing Files/Folders on System (MUST be included in ls/find outputs if in current directory): {', '.join(all_files)}\n"
        )

# --- STANDALONE TESTER ---
# This block only runs if you execute memory.py directly. 
# It won't interfere when we import this into the main server later.
if __name__ == "__main__":
    print("[*] Booting Virtual Environment Memory Test...")
    env = VirtualEnvironment()
    
    print(f"Start PWD: {env.pwd}")
    
    env.update_state("cd /var/www/html")
    print(f"After 'cd /var/www/html' -> PWD: {env.pwd}")
    
    env.update_state("touch malicious_payload.php")
    print(f"After 'touch malicious_payload.php' -> Custom Files: {env.custom_files}")
    
    print("\n[--- What the AI Brain Will See ---]")
    print(env.get_context_string())


    