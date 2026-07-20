# Ghost-Net/main.py

import os
import sys

# CRITICAL FIX: We now import the Master Orchestrator instead of just the SSH server
from core.orchestrator import launch_orchestrator

if __name__ == "__main__":
    
    launch_orchestrator()

