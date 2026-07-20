import threading
import paramiko
import socket
import time
import logging
import multiprocessing
import random
from core.bash import execute_bash_command
from core.sandbox import SandboxGuard
from utils.logger import log_event
import config

# Mute Paramiko's internal error logging
logging.getLogger("paramiko").setLevel(logging.CRITICAL)

class DummyShell:
    """Mock shell class to keep Paramiko happy."""
    def __init__(self, transport):
        self.transport = transport
    def send(self, data):
        pass
    def recv(self, nbytes):
        return b""
    def recv_ready(self):
        return True

def handle_client(client, addr):
    client_ip = addr[0]
    transport = None
    try:
        transport = paramiko.Transport(client)
        # --- DYNAMIC BANNER ROTATION ---
        transport.local_version = random.choice(config.SSH_BANNERS)
        
        transport.add_server_key(paramiko.RSAKey(filename=config.HOST_KEY_FILE))
        
        server = HoneypotServer(client_ip)
        transport.start_server(server=server)
        
        channel = transport.accept(20)
        if channel:
            channel.send("Welcome to Ubuntu 22.04 LTS\r\n\r\n")
            while True:
                command = channel.recv(1024).decode('utf-8', errors='ignore').strip()
                if not command:
                    break
                execute_bash_command(command, channel, server.env_state, "ubuntu")
    except Exception as e:
        pass
    finally:
        if transport:
            transport.close()

class HoneypotServer(paramiko.ServerInterface):
    def __init__(self, client_ip):
        self.client_ip = client_ip
        # Initialize basic environment state
        class EnvState:
            def __init__(self):
                self.pwd = "/home/ubuntu"
                self.current_user = "ubuntu"
                self.login_password = "hacked123"
            def get_context_string(self):
                return f"User: {self.current_user}, PWD: {self.pwd}"
        self.env_state = EnvState()

    def check_auth_password(self, username, password):
        log_event(self.client_ip, "SSH_AUTH", username=username, password=password)
        print(f"[SSH] Alert: Login attempt from {self.client_ip} | User: {username} | Pass: {password}")
        return paramiko.AUTH_SUCCESSFUL

    def check_channel_request(self, kind, chanid):
        if kind == 'session':
            return paramiko.OPEN_SUCCEEDED
        return paramiko.OPEN_FAILED_ADMINISTRATIVELY_PROHIBITED

    def check_channel_shell_request(self, channel):
        return True

    def check_channel_pty_request(self, channel, term, width, height, pixelwidth, pixelheight, modes):
        return True

def start_server():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind((config.HONEYPOT_HOST, config.HONEYPOT_PORT))
    sock.listen(100)
    print(f"[*] SSH Listener Active on Port {config.HONEYPOT_PORT} (PID: {multiprocessing.current_process().pid})")
    
    while True:
        client, addr = sock.accept()
        threading.Thread(target=handle_client, args=(client, addr), daemon=True).start()
class DummyShell:
    
    """A wrapper to adapt paramiko's channel into our custom interface."""
    def __init__(self, chan):
        self.chan = chan

    def send(self, data):
        self.chan.send(data)

    def recv(self, size):
        return self.chan.recv(size)
        
    def recv_ready(self):
        return self.chan.recv_ready()

class SessionState:
    """Holds environment state for a single attacker's connection."""
    def __init__(self):
        self.pwd = "/home/ubuntu"
        self.current_user = "ubuntu"
        self.bash_vars = {
            "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            "USER": "ubuntu",
            "HOME": "/home/ubuntu",
            "SHELL": "/bin/bash"
        }
        self.created_files = {}
        self.file_origins = {}
        self.login_password = ""

    def get_context_string(self):
        return f"USER={self.current_user} PWD={self.pwd}"

class HoneypotServer(paramiko.ServerInterface):
    def __init__(self, client_ip):
        self.event = threading.Event()
        self.client_ip = client_ip
        self.captured_password = ""

    def check_channel_request(self, kind, chanid):
        if kind == 'session':
            return paramiko.OPEN_SUCCEEDED
        return paramiko.OPEN_FAILED_ADMINISTRATIVELY_PROHIBITED

    def check_auth_password(self, username, password):
        log_event(self.client_ip, "SSH_AUTH_ATTEMPT", username=username, password=password)
        print(f"[SSH] Alert: Login attempt from {self.client_ip} | User: {username} | Pass: {password}")
        self.captured_password = password
        return paramiko.AUTH_SUCCESSFUL

    def get_allowed_auths(self, username):
        return 'password'

    def check_channel_shell_request(self, channel):
        self.event.set()
        return True

    def check_channel_pty_request(self, channel, term, width, height, pixelwidth, pixelheight, modes):
        return True

def handle_client(client, addr):
    client_ip = addr[0]
    transport = None
    try:
        transport = paramiko.Transport(client)
        transport.local_version = random.choice(config.SSH_BANNERS)
        transport.add_server_key(paramiko.RSAKey(filename=config.HOST_KEY_FILE))
        
        server = HoneypotServer(client_ip)
        try:
            transport.start_server(server=server)
        except paramiko.SSHException:
            return
            
        channel = transport.accept(20)
        if channel is None:
            return

        server.event.wait(10)
        if not server.event.is_set():
            return
            
        log_event(client_ip, "SSH_SESSION_STARTED")
        
        channel.send("Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.15.0-89-generic x86_64)\r\n\r\n")
        channel.send(" * Documentation:  https://help.ubuntu.com\r\n")
        channel.send(" * Management:     https://landscape.canonical.com\r\n")
        channel.send(" * Support:        https://ubuntu.com/advantage\r\n\r\n")
        channel.send("Last login: Mon Oct 30 14:32:01 2023 from 192.168.1.100\r\n")

        env_state = SessionState()
        env_state.login_password = server.captured_password
        
        dummy_shell = DummyShell(channel)

        while True:
            current_user = getattr(env_state, 'current_user', 'ubuntu')
            prompt_symbol = "#" if current_user == "root" else "$"
            
            display_pwd = env_state.pwd
            if current_user == "root" and display_pwd == "/root":
                display_pwd = "~"
            elif current_user != "root" and display_pwd == f"/home/{current_user}":
                display_pwd = "~"
                
            channel.send(f"{current_user}@ghost-server:{display_pwd}{prompt_symbol} ")
            
            command = ""
            while True:
                char = channel.recv(1).decode('utf-8', errors='ignore')
                if char == '\r':
                    break
                elif char in ['\x08', '\x7f']:
                    if len(command) > 0:
                        command = command[:-1]
                        channel.send('\x08 \x08')
                else:
                    command += char
                    channel.send(char)

            if not command.strip():
                channel.send("\r\n")
                continue
                
            log_event(client_ip, "COMMAND_EXECUTED", command=command)
            
            if command.lower() in ['exit', 'quit']:
                channel.send("\r\nlogout\r\n")
                break
                
            channel.send("\r\n")
            execute_bash_command(command, dummy_shell, env_state, current_user)
            
    except Exception:
        pass
    finally:
        if transport:
            try:
                # Graceful TCP Teardown for Nmap
                time.sleep(0.2)
                client.shutdown(socket.SHUT_RDWR)
            except Exception:
                pass
            transport.close()
        try:
            client.close()
        except Exception:
            pass

def start_server():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    try:
        sock.bind((config.HONEYPOT_HOST, config.HONEYPOT_PORT))
        sock.listen(100)
        # Now this will work because we imported multiprocessing!
        print(f"[*] SSH Listener Active on Port {config.HONEYPOT_PORT} (PID: {multiprocessing.current_process().pid})")
    except Exception as e:
        print(f"[-] Bind failed: {e}")
        return

    while True:
        try:
            client, addr = sock.accept()
            threading.Thread(target=handle_client, args=(client, addr), daemon=True).start()
        except KeyboardInterrupt:
            break
        except Exception:
            pass

# ... existing code ...
def handle_client(client, addr):
    client_ip = addr[0]
    transport = None

class DummyShell:
    """A wrapper to adapt paramiko's channel into our custom interface."""
    def __init__(self, chan):
        self.chan = chan

    def send(self, data):
        self.chan.send(data)

    def recv(self, size):
        return self.chan.recv(size)
        
    def recv_ready(self):
        return self.chan.recv_ready()

class SessionState:
    """Holds environment state for a single attacker's connection."""
    def __init__(self):
        self.pwd = "/home/ubuntu"
        self.current_user = "ubuntu"
        self.bash_vars = {
            "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            "USER": "ubuntu",
            "HOME": "/home/ubuntu",
            "SHELL": "/bin/bash"
        }
        self.created_files = {}
        self.file_origins = {}
        self.login_password = ""

    def get_context_string(self):
        return f"USER={self.current_user} PWD={self.pwd}"

class HoneypotServer(paramiko.ServerInterface):
    def __init__(self, client_ip):
        self.event = threading.Event()
        self.client_ip = client_ip
        self.captured_password = ""

    def check_channel_request(self, kind, chanid):
        if kind == 'session':
            return paramiko.OPEN_SUCCEEDED
        return paramiko.OPEN_FAILED_ADMINISTRATIVELY_PROHIBITED

    def check_auth_password(self, username, password):
        log_event(self.client_ip, "SSH_AUTH_ATTEMPT", username=username, password=password)
        print(f"[SSH] Alert: Login attempt from {self.client_ip} | User: {username} | Pass: {password}")
        self.captured_password = password
        return paramiko.AUTH_SUCCESSFUL

    def get_allowed_auths(self, username):
        return 'password'

    def check_channel_shell_request(self, channel):
        self.event.set()
        return True

    def check_channel_pty_request(self, channel, term, width, height, pixelwidth, pixelheight, modes):
        return True

def handle_client(client, addr):
    client_ip = addr[0]
    transport = None
    try:
        transport = paramiko.Transport(client)
        transport.local_version = random.choice(config.SSH_BANNERS)
        transport.add_server_key(paramiko.RSAKey(filename=config.HOST_KEY_FILE))
        
        server = HoneypotServer(client_ip)
        try:
            transport.start_server(server=server)
        except paramiko.SSHException:
            return
            
        channel = transport.accept(20)
        if channel is None:
            return

        server.event.wait(10)
        if not server.event.is_set():
            return
            
        log_event(client_ip, "SSH_SESSION_STARTED")
        
        channel.send("Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.15.0-89-generic x86_64)\r\n\r\n")
        channel.send(" * Documentation:  https://help.ubuntu.com\r\n")
        channel.send(" * Management:     https://landscape.canonical.com\r\n")
        channel.send(" * Support:        https://ubuntu.com/advantage\r\n\r\n")
        channel.send("Last login: Mon Oct 30 14:32:01 2023 from 192.168.1.100\r\n")

        env_state = SessionState()
        env_state.login_password = server.captured_password
        
        dummy_shell = DummyShell(channel)

        while True:
            current_user = getattr(env_state, 'current_user', 'ubuntu')
            prompt_symbol = "#" if current_user == "root" else "$"
            
            display_pwd = env_state.pwd
            if current_user == "root" and display_pwd == "/root":
                display_pwd = "~"
            elif current_user != "root" and display_pwd == f"/home/{current_user}":
                display_pwd = "~"
                
            channel.send(f"{current_user}@ghost-server:{display_pwd}{prompt_symbol} ")
            
            command = ""
            while True:
                char = channel.recv(1).decode('utf-8', errors='ignore')
                if char == '\r':
                    break
                elif char in ['\x08', '\x7f']:
                    if len(command) > 0:
                        command = command[:-1]
                        channel.send('\x08 \x08')
                else:
                    command += char
                    channel.send(char)

            if not command.strip():
                channel.send("\r\n")
                continue
                
            log_event(client_ip, "COMMAND_EXECUTED", command=command)
            
            if command.lower() in ['exit', 'quit']:
                channel.send("\r\nlogout\r\n")
                break
                
            channel.send("\r\n")
            execute_bash_command(command, dummy_shell, env_state, current_user)
            
    except Exception:
        pass
    finally:
        if transport:
            try:
                # Graceful TCP Teardown for Nmap
                time.sleep(0.2)
                client.shutdown(socket.SHUT_RDWR)
            except Exception:
                pass
            transport.close()
        try:
            client.close()
        except Exception:
            pass

def start_server():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    try:
        sock.bind((config.HONEYPOT_HOST, config.HONEYPOT_PORT))
        sock.listen(100)
        # Now this will work because we imported multiprocessing!
        print(f"[*] SSH Listener Active on Port {config.HONEYPOT_PORT} (PID: {multiprocessing.current_process().pid})")
    except Exception as e:
        print(f"[-] Bind failed: {e}")
        return

    while True:
        try:
            client, addr = sock.accept()
            threading.Thread(target=handle_client, args=(client, addr), daemon=True).start()
        except KeyboardInterrupt:
            break
        except Exception:
            pass