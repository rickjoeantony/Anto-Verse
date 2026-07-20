import paramiko
import time
import sys

def run_automated_test():
    host = '127.0.0.1'
    port = 2223
    user = 'ubuntu'
    password = 'hacked123'
    
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"[*] Initializing Automated Honeypot Testing Bot against {host}:{port}...")
    
    try:
        client.connect(hostname=host, port=port, username=user, password=password)
        print("[+] Connection established! Bot is infiltrating the honeypot...\n")
    except Exception as e:
        print(f"[-] Failed to connect. Is Ghost-Net running? Error: {e}")
        return

    shell = client.invoke_shell()
    time.sleep(1)
    
    # Read and print the initial Ubuntu welcome banner
    if shell.recv_ready():
        banner = shell.recv(4096).decode('utf-8', errors='ignore')
        print(banner, end="")

    def execute_command(cmd, wait_for_prompt=True):
        """Sends a command and dynamically waits for the prompt to return."""
        print(f"\n[BOT] Executing: {cmd}")
        shell.send(cmd + "\n")
        
        output = ""
        timeout = 15 # Wait up to 15 seconds for the AI to generate a response
        start_time = time.time()
        
        while True:
            if shell.recv_ready():
                chunk = shell.recv(4096).decode('utf-8', errors='ignore')
                output += chunk
                
                # Write the output to our screen just like a real terminal
                sys.stdout.write(chunk)
                sys.stdout.flush()
                
                # If we see the prompt again, we know the honeypot finished responding
                if wait_for_prompt and "ghost-server:" in chunk and ("$" in chunk or "#" in chunk):
                    break
                    
            if time.time() - start_time > timeout:
                print("\n[!] Command timed out waiting for AI response.")
                break
                
            time.sleep(0.05)
            
        return output

    try:
        # Test 1: Basic Identity & Static Interceptors
        execute_command("whoami")
        execute_command("pwd")
        
        # Test 2: The Fintech Directory Trap
        execute_command("cd /opt/fintech-app/config")
        execute_command("ls")
        
        # Test 3: Trigger the AI Hallucination Engine (Fake DB config)
        print("\n[*] BOT: Testing AI generation for sensitive files...")
        execute_command("cat database.yml")
        
        # Test 4: Root Escalation Trap
        print("\n[*] BOT: Testing privilege escalation...")
        shell.send("sudo su\n")
        time.sleep(0.5)
        if shell.recv_ready():
            sys.stdout.write(shell.recv(1024).decode('utf-8'))
            
        # Send fake root password
        shell.send("root123\n")
        time.sleep(1)
        if shell.recv_ready():
            sys.stdout.write(shell.recv(1024).decode('utf-8'))
            
        # Verify the prompt changed to root (#)
        execute_command("whoami")
        execute_command("cd /root")
        
        # Test 5: Session Termination
        print("\n[*] BOT: Testing session termination...")
        execute_command("exit", wait_for_prompt=False)
        
    except KeyboardInterrupt:
        print("\n[*] Test aborted by user.")
    finally:
        client.close()
        print("\n\n[*] Bot testing sequence complete. Connection closed.")

if __name__ == "__main__":
    run_automated_test()
