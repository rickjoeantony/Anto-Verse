# Ghost-Net/read.py
import paramiko
import time
import sys

def auto_attack():
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    server_address = '127.0.0.1'
    port = 2222
    
    print(f"[*] Launching automated strike against {server_address}:{port}...")
    
    try:
        # Any credentials work on our honeypot!
        client.connect(hostname=server_address, port=port, username='ubuntu', password='hacked123')
        print("[+] Authentication successful. We are in.\n")
        
        shell = client.invoke_shell()
        time.sleep(1) # Wait for banner
        
        # Print initial banner
        if shell.recv_ready():
                print(shell.recv(4096).decode('utf-8', errors='ignore'), end="")
        
        while True:
            command = input("")
            if command.lower() in ['exit', 'quit']:
                break
                
            shell.send(command + "\n")
            
            burst_buffer = ""
            
            while True:
                # --- ANTI-FREEZE PROTECTION ---
                if shell.closed:
                    print("\n[!] The Honeypot server forcibly closed the connection!")
                    return
                    
                # Read output as it arrives
                if shell.recv_ready():
                    chunk = shell.recv(4096).decode('utf-8', errors='ignore')
                    burst_buffer += chunk 
                    
                    # Break loop if standard prompt OR a password prompt appears
                    if "ubuntu@ghost-server:~$" in chunk or "password for ubuntu:" in chunk.lower() or "Password:" in chunk:
                        
                        # --- ECHO CANCELLATION ---
                        # Remove the command the server echoes back so it doesn't print twice
                        echo_str = command + "\r\n"
                        if burst_buffer.startswith(echo_str):
                            burst_buffer = burst_buffer[len(echo_str):]
                        elif echo_str in burst_buffer:
                            burst_buffer = burst_buffer.replace(echo_str, "", 1)
                            
                        # --- PROMPT FORMATTING FIX ---
                        # Force the prompt to a new line in case the AI missed a trailing newline
                        burst_buffer = burst_buffer.replace("ubuntu@ghost-server:~$", "\r\nubuntu@ghost-server:~$")
                        # Deduplicate if it already had a newline so we don't get huge gaps
                        burst_buffer = burst_buffer.replace("\r\n\r\nubuntu@ghost-server:~$", "\r\nubuntu@ghost-server:~$")
                        burst_buffer = burst_buffer.replace("\n\r\nubuntu@ghost-server:~$", "\nubuntu@ghost-server:~$")
                        # Clean up if it was at the very start of the output
                        if burst_buffer.startswith("\r\nubuntu@ghost-server:~$"):
                            burst_buffer = burst_buffer[2:]
                            
                        # Blast the cleaned text block to the screen instantly!
                        sys.stdout.write(burst_buffer)
                        sys.stdout.flush()
                        break
                else:
                    # ONLY sleep if the buffer is empty. This drastically speeds up the streaming text!
                    time.sleep(0.01)
                
    except paramiko.AuthenticationException:
        print("[-] Authentication failed.")
    except Exception as e:
        print(f"[-] Network error: {e}")
    finally:
        client.close()
        print("\n[*] Connection terminated.")

if __name__ == "__main__":
    auto_attack()
