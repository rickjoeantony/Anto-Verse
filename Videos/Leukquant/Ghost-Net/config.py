HONEYPOT_HOST = "0.0.0.0"
HONEYPOT_PORT = 2222
HOST_KEY_FILE = "server.key"
MODEL_NAME = "qwen2.5:0.5b"
OLLAMA_API_URL = "http://localhost:11434/api/generate"
SYSTEM_PROMPT = "You are a Linux server. {context}."

# ADD THIS LIST:
SSH_BANNERS = [
    "SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.4",
    "SSH-2.0-OpenSSH_7.6p1 Ubuntu-4ubuntu0.3",
    "SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.3",
    "SSH-2.0-OpenSSH_9.0p1 Ubuntu-1ubuntu1",
    "SSH-2.0-Dropbear_2020.81",
    "SSH-2.0-OpenSSH_7.2p2 Ubuntu-4ubuntu2.8",
    "SSH-2.0-OpenSSH_8.4p1 Debian-5+deb11u1"
]