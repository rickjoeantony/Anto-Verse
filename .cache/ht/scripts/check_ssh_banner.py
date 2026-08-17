#!/usr/bin/env python3
"""
Ghost-Net Raw SSH Banner Validation Tool
========================================
STAGING/VALIDATION ONLY — RAW SOCKET BANNER TESTER

Validates that an SSH server listener returns a compliant, stable SSH banner:
- Starts with SSH-2.0-
- Ends with CRLF (\\r\\n)
- Non-empty
- Byte-for-byte identical across repeated sequential connections

Strict Safety Guarantees:
- Uses ONLY standard library socket module (no Paramiko, no port scanning, no flooding).
- Sequential connections (one at a time).
- Never prints credentials or secrets.
"""

import sys
import argparse
import socket
from typing import List, Tuple, Dict, Any

EXPECTED_PERSONA_BANNER = "SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.10"


def get_raw_ssh_banner(host: str, port: int, timeout: float) -> Tuple[bool, bytes, str]:
    """
    Connects to target host:port via plain TCP socket, receives up to 256 bytes,
    and returns (success, raw_bytes, error_message).
    """
    try:
        with socket.create_connection((host, port), timeout=timeout) as s:
            s.settimeout(timeout)
            # Receive raw banner bytes (up to 256 bytes)
            data = s.recv(256)
            return True, data, ""
    except socket.timeout:
        return False, b"", f"Connection timed out after {timeout}s"
    except ConnectionRefusedError:
        return False, b"", f"Connection refused on {host}:{port}"
    except Exception as e:
        return False, b"", f"Socket error: {type(e).__name__}: {e}"


def sanitize_banner_display(raw: bytes) -> str:
    """Converts raw bytes to printable ASCII string, replacing control characters."""
    decoded = raw.decode("ascii", errors="replace")
    display = decoded.replace("\r", "\\r").replace("\n", "\\n")
    return display


def validate_banner_bytes(raw: bytes) -> Tuple[bool, List[str]]:
    """
    Validates banner format:
    1. Starts with SSH-2.0-
    2. Ends with \\r\\n
    3. Non-empty
    """
    issues = []
    if not raw:
        issues.append("Banner is EMPTY (0 bytes received)")
        return False, issues

    if not raw.startswith(b"SSH-2.0-"):
        issues.append(f"Banner does not start with 'SSH-2.0-' (received: {sanitize_banner_display(raw)})")

    if not raw.endswith(b"\r\n"):
        issues.append(f"Banner does not terminate with CRLF (\\r\\n)")

    return (len(issues) == 0), issues


def run_banner_check(host: str, port: int, repeat: int, timeout: float) -> Tuple[str, List[str], Dict[str, Any]]:
    """
    Performs 'repeat' sequential connections to host:port and checks banner stability.
    Returns (status, warnings/errors, report_details).
    """
    attempts: List[Dict[str, Any]] = []
    successful_banners: List[bytes] = []
    issues: List[str] = []

    print(f"[*] Starting SSH Banner Check on {host}:{port} ({repeat} sequential repetitions)...")

    for i in range(1, repeat + 1):
        success, raw, err = get_raw_ssh_banner(host, port, timeout)
        disp = sanitize_banner_display(raw) if success else "-"

        valid_fmt, fmt_issues = validate_banner_bytes(raw) if success else (False, [err])

        attempt_info = {
            "index": i,
            "success": success,
            "raw_bytes": raw,
            "display": disp,
            "valid_format": valid_fmt,
            "error": err if not success else None,
            "format_issues": fmt_issues,
        }
        attempts.append(attempt_info)

        if success:
            successful_banners.append(raw)
            print(f"    Attempt {i}/{repeat}: [{disp}] -> {'VALID' if valid_fmt else 'INVALID FORMAT'}")
        else:
            print(f"    Attempt {i}/{repeat}: FAILED ({err})")
            issues.append(f"Attempt {i} failed: {err}")

    # Evaluate results
    report_details: Dict[str, Any] = {
        "host": host,
        "port": port,
        "repeat": repeat,
        "attempts": attempts,
        "successful_count": len(successful_banners),
        "is_stable": False,
        "banner_display": None,
        "banner_str": None,
    }

    if len(successful_banners) == 0:
        overall_status = "FAIL"
        issues.append("No banner could be retrieved from target host.")
        return overall_status, issues, report_details

    # Check stability across repetitions
    unique_banners = list(set(successful_banners))
    is_stable = (len(unique_banners) == 1)

    first_banner = successful_banners[0]
    first_banner_str = first_banner.decode("ascii", errors="replace").strip()

    valid_format, format_issues = validate_banner_bytes(first_banner)

    if not is_stable:
        overall_status = "FAIL"
        issues.append(f"UNSTABLE BANNER: Banner changed across repeated connections ({len(unique_banners)} distinct variations returned).")
    elif not valid_format:
        overall_status = "FAIL"
        issues.extend(format_issues)
    elif len(successful_banners) < repeat:
        overall_status = "WARNING"
        issues.append(f"Banner is valid and stable, but {repeat - len(successful_banners)} connection(s) failed.")
    else:
        # Check if banner matches expected production persona banner
        expected_bytes = EXPECTED_PERSONA_BANNER.encode("ascii") + b"\r\n"
        if first_banner == expected_bytes:
            overall_status = "PASS"
        else:
            overall_status = "PASS"  # Still PASS as per instructions if configuration intentionally uses another approved banner
            issues.append(f"Note: Persona banner returned '{first_banner_str}' (expected baseline persona: '{EXPECTED_PERSONA_BANNER}').")

    report_details = {
        "host": host,
        "port": port,
        "repeat": repeat,
        "attempts": attempts,
        "successful_count": len(successful_banners),
        "is_stable": is_stable,
        "banner_display": sanitize_banner_display(first_banner),
        "banner_str": first_banner_str,
    }

    return overall_status, issues, report_details


def print_banner_report(overall_status: str, issues: List[str], report: Dict[str, Any]):
    """Prints formatted ASCII report."""
    print("=" * 80)
    print(" [STAGING/VALIDATION ONLY] GHOST-NET RAW SSH BANNER DIAGNOSTIC")
    print("=" * 80)
    print(f" Target Host      : {report.get('host')}")
    print(f" Target Port      : {report.get('port')}")
    print(f" Repetitions      : {report.get('repeat')}")
    print("-" * 80)

    if report.get("banner_str"):
        print(f" Received Banner  : \"{report.get('banner_str')}\"")
        print(f" Raw Escaped      : \"{report.get('banner_display')}\"")
        print(f" Banner Stability : {'STABLE (100% identical across attempts)' if report.get('is_stable') else 'UNSTABLE / ROTATING'}")
    else:
        print(" Received Banner  : NONE (Connection Failed)")

    print("-" * 80)
    if issues:
        print(" [DIAGNOSTIC NOTES / WARNINGS]")
        for issue in issues:
            print(f"   [!] {issue}")
        print("-" * 80)

    print(f" VALIDATION STATUS: {overall_status}")
    print("=" * 80)


def main():
    parser = argparse.ArgumentParser(description="Ghost-Net Raw SSH Banner Test Tool")
    parser.add_argument("--host", type=str, default="127.0.0.1", help="Target VPS IP or hostname")
    parser.add_argument("--port", type=int, default=2222, help="Target SSH port (default: 2222)")
    parser.add_argument("--repeat", type=int, default=5, help="Number of repeated connections (default: 5)")
    parser.add_argument("--timeout", type=float, default=5.0, help="Socket connection timeout in seconds (default: 5.0)")

    args = parser.parse_args()

    status, issues, report = run_banner_check(args.host, args.port, args.repeat, args.timeout)
    print_banner_report(status, issues, report)

    if status == "FAIL":
        sys.exit(1)
    else:
        sys.exit(0)


if __name__ == "__main__":
    main()
