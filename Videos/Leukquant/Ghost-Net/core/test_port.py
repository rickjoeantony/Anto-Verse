import socket

def test_port(port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        sock.bind(('0.0.0.0', port))
        sock.listen(1)
        print(f"[+] SUCCESS: Port {port} is open and available!")
    except Exception as e:
        print(f"[-] FAILED: Cannot open port {port}. Error: {e}")
    finally:
        sock.close()

if __name__ == "__main__":
    test_port(2222)