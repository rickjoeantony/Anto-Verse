import sys
import os

# Ensure we are looking in the current directory for our modules
sys.path.append(os.getcwd())

from core.server import start_server
import config

print(f"[*] DEBUGGING: Attempting to start ONLY the SSH server on port {config.HONEYPOT_PORT}...")

try:
    start_server()
except Exception as e:
    print(f"\n[!!!] CRITICAL ERROR ENCOUNTERED: {e}")
    # Force a full print of the error
    import traceback
    traceback.print_exc()
