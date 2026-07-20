import multiprocessing
import threading
import socket
import time
from utils.logger import log_event
from core.server import start_server as start_ssh_server
import config

def graceful_teardown(client):
    """A script-safe teardown that prevents Nmap LUA_YIELD crashes."""
    try:
        # 1. Gracefully close the sending half of the connection (Sends a polite FIN packet)
        # This tells Nmap "We are done talking", but keeps the line open for Nmap's scripts.
        client.shutdown(socket.SHUT_WR)
        
        # 2. Wait up to 2 seconds for Nmap's Lua scripts to finish processing and close their end
        client.settimeout(2.0)
        while True:
            data = client.recv(1024)
            if not data:
                break # Nmap has politely hung up!
    except Exception:
        pass
    finally:
        try:
            client.close()
        except Exception:
            pass

def handle_ftp(client, addr):
    try:
        client.send(b"220 (vsFTPd 3.0.3)\r\n")
        user_data = client.recv(1024).decode(errors='ignore').strip()
        if user_data.startswith("USER"):
            client.send(b"331 Please specify the password.\r\n")
            pass_data = client.recv(1024).decode(errors='ignore').strip()
            
            log_event(addr[0], "FTP_AUTH_ATTEMPT", username=user_data, password=pass_data)
            print(f"[FTP] Credential attempt from {addr[0]} | {user_data} : {pass_data}")
            
            client.send(b"530 Login incorrect.\r\n")
    except:
        pass
    finally:
        graceful_teardown(client)

def handle_smtp(client, addr):
    try:
        client.send(b"220 mail.ghost-server ESMTP Postfix (Ubuntu)\r\n")
        data = client.recv(1024).decode(errors='ignore').strip()
        if data:
            log_event(addr[0], "SMTP_PROBE", payload=data)
            print(f"[SMTP] Spam bot probe from {addr[0]}: {data}")
        client.send(b"250 mail.ghost-server\r\n")
    except:
        pass
    finally:
        graceful_teardown(client)

def handle_http(client, addr):
    try:
        req = client.recv(2048).decode(errors='ignore')
        if req:
            first_line = req.split('\n')[0].strip()
            log_event(addr[0], "HTTP_PROBE", request=first_line)
            print(f"[HTTP] Web request from {addr[0]}: {first_line}")
            
        resp = (
            "HTTP/1.1 200 OK\r\n"
            "Server: nginx/1.18.0 (Ubuntu)\r\n"
            "Connection: close\r\n"
            "Content-Type: text/html\r\n\r\n"
            "<html><head><title>Welcome to nginx!</title></head>\n"
            "<body><h1>Welcome to nginx!</h1><p>If you see this page, the nginx web server is successfully installed and working.</p></body></html>\n"
        )
        client.send(resp.encode())
    except:
        pass
    finally:
        graceful_teardown(client)

def handle_mysql(client, addr):
    try:
        mysql_handshake = b"\x4a\x00\x00\x00\x0a5.5.5-10.4.24-MariaDB\x00\x11\x00\x00\x00~~!K%?7r\x00\xff\xfe\x08\x02\x00\xff\x81\x15\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00>v(o&5W6t,D)\x00mysql_native_password\x00"
        client.send(mysql_handshake)
        data = client.recv(1024)
        log_event(addr[0], "MYSQL_DB_PROBE", payload=str(data))
        print(f"[MySQL] Database scan detected from {addr[0]}")
    except:
        pass
    finally:
        graceful_teardown(client)

def handle_silent_protocol(client, addr, protocol_name):
    try:
        data = client.recv(2048)
        if data:
            log_event(addr[0], f"{protocol_name}_PROBE", payload=str(data))
            print(f"[{protocol_name}] Probe detected from {addr[0]}")
    except:
        pass
    finally:
        graceful_teardown(client)

def service_worker(protocol_name, port, handler_func):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    try:
        sock.bind((config.HONEYPOT_HOST, port))
        sock.listen(100)
        print(f"[*] {protocol_name} Listener Active on Port {port} (PID: {multiprocessing.current_process().pid})")
    except PermissionError:
        print(f"[!] FAILED: Cannot bind {protocol_name} to Port {port}. Please run your terminal as Administrator!")
        return
    except OSError as e:
        print(f"[!] FAILED: Port {port} is already in use by another program! ({e})")
        return
    except Exception as e:
        print(f"[!] FAILED: {protocol_name} Port {port} error - {e}")
        return

    while True:
        try:
            client, addr = sock.accept()
            if protocol_name in ["POSTGRES", "RDP"]:
                threading.Thread(target=handler_func, args=(client, addr, protocol_name), daemon=True).start()
            else:
                threading.Thread(target=handler_func, args=(client, addr), daemon=True).start()
        except KeyboardInterrupt:
            break
        except Exception:
            pass

def launch_orchestrator():
    print("""
    =============================================
         GHOST-NET ENTERPRISE ORCHESTRATOR
    =============================================
    Starting Isolated Protocol Environments...
    """)
    
    protocols = [
        ("FTP", 21, handle_ftp),
        ("SMTP", 25, handle_smtp),
        ("HTTP", 80, handle_http),
        ("MYSQL", 3306, handle_mysql),
        ("RDP", 3389, handle_silent_protocol),
        ("POSTGRES", 5432, handle_silent_protocol)
    ]
    
    processes = []
    
    ssh_proc = multiprocessing.Process(target=start_ssh_server)
    ssh_proc.start()
    processes.append(ssh_proc)
    time.sleep(0.2)
    
    for name, port, handler in protocols:
        p = multiprocessing.Process(target=service_worker, args=(name, port, handler))
        p.start()
        processes.append(p)
        time.sleep(0.1) 
        
    print("\n[*] All environments isolated and active. Awaiting targets...\n")
    
    try:
        for p in processes:
            p.join()
    except KeyboardInterrupt:
        print("\n[*] Shutting down all protocol environments...")
        for p in processes:
            p.terminate()

if __name__ == "__main__":
    launch_orchestrator()