#!/usr/bin/env python3
"""
LeukQuant Safe Staging Service Health Check Tool
=================================================
STAGING/VALIDATION ONLY — READ-ONLY SAFE GET HEALTH CHECKER

Verifies the HTTP/HTTPS health and availability of deployed LeukQuant staging services.

Strict Safety Guarantees:
- Uses ONLY safe GET requests to public health endpoints.
- Accepts explicit CLI arguments; NEVER uses production URLs by default.
- Never reads or exposes passwords, secrets, tokens, or encryption keys.
- Never calls mutating (POST/PUT/PATCH/DELETE) endpoints.
- Never connects directly to databases or creates test accounts.
- Records HTTP status, latency, TLS/HTTPS status, redirect behavior, and timestamp.
"""

import sys
import json
import time
import argparse
import urllib.request
import urllib.error
import urllib.parse
import ssl
from datetime import datetime, timezone
from typing import Dict, Any, Optional, List, Tuple


def check_endpoint(
    name: str,
    base_url: str,
    endpoint_paths: List[str],
    timeout: float = 10.0,
    headers: Optional[Dict[str, str]] = None
) -> Dict[str, Any]:
    """
    Checks one or more health endpoint paths on a target base URL using safe GET.
    Returns structured audit record with HTTP status, latency, TLS status, and response snippet.
    """
    cleaned_base = base_url.rstrip("/")
    if not (cleaned_base.startswith("http://") or cleaned_base.startswith("https://")):
        return {
            "service": name,
            "configured_url": base_url,
            "status": "CONFIG_ERROR",
            "error": "URL must explicitly include protocol scheme (http:// or https://)",
            "timestamp": datetime.now(timezone.utc).isoformat()
        }

    attempted_records = []
    success_record = None

    for path in endpoint_paths:
        target_url = f"{cleaned_base}{path}" if path.startswith("/") else f"{cleaned_base}/{path}"
        req_headers = {
            "User-Agent": "LeukQuant-Staging-HealthChecker/1.0",
            "Accept": "application/json, text/html, */*"
        }
        if headers:
            req_headers.update(headers)

        start_time = time.perf_counter()
        req = urllib.request.Request(target_url, headers=req_headers, method="GET")

        # Create standard SSL context (strict TLS validation)
        ctx = ssl.create_default_context()
        is_https = target_url.startswith("https://")

        try:
            with urllib.request.urlopen(req, timeout=timeout, context=ctx) as response:
                latency_ms = round((time.perf_counter() - start_time) * 1000, 2)
                status_code = response.getcode()
                final_url = response.geturl()
                redirected = final_url != target_url
                content_type = response.headers.get("Content-Type", "")
                raw_body = response.read(2048)  # Read at most 2KB for safety

                # Safe parsing of response body without exposing secrets
                body_summary = "Non-empty response"
                parsed_json_status = None
                try:
                    text_content = raw_body.decode("utf-8", errors="replace").strip()
                    if "json" in content_type or text_content.startswith("{"):
                        data = json.loads(text_content)
                        if isinstance(data, dict):
                            # Extract safe status fields
                            parsed_json_status = data.get("status") or data.get("success") or data.get("time")
                            body_summary = f"JSON status: {data.get('status', 'received')}"
                    elif "html" in content_type or "<html" in text_content.lower():
                        body_summary = "HTML Document"
                    else:
                        body_summary = text_content[:120] if text_content else "Empty body"
                except Exception:
                    body_summary = "Binary / unparsed content"

                record = {
                    "service": name,
                    "target_url": target_url,
                    "final_url": final_url,
                    "http_status": status_code,
                    "latency_ms": latency_ms,
                    "tls_enabled": is_https,
                    "tls_valid": is_https,
                    "redirected": redirected,
                    "content_type": content_type,
                    "safe_response_status": parsed_json_status if parsed_json_status is not None else body_summary,
                    "body_summary": body_summary,
                    "endpoint_verified": True,
                    "error": None,
                    "timestamp": datetime.now(timezone.utc).isoformat()
                }
                attempted_records.append(record)
                if status_code in (200, 204, 301, 302, 307, 308):
                    success_record = record
                    break

        except urllib.error.HTTPError as e:
            latency_ms = round((time.perf_counter() - start_time) * 1000, 2)
            record = {
                "service": name,
                "target_url": target_url,
                "http_status": e.code,
                "latency_ms": latency_ms,
                "tls_enabled": is_https,
                "tls_valid": is_https,
                "redirected": False,
                "endpoint_verified": False,
                "safe_response_status": f"HTTP {e.code} ({e.reason})",
                "error": f"HTTP {e.code}: {e.reason}",
                "timestamp": datetime.now(timezone.utc).isoformat()
            }
            attempted_records.append(record)

        except urllib.error.URLError as e:
            latency_ms = round((time.perf_counter() - start_time) * 1000, 2)
            reason_str = str(e.reason)
            record = {
                "service": name,
                "target_url": target_url,
                "http_status": None,
                "latency_ms": latency_ms,
                "tls_enabled": is_https,
                "tls_valid": False if "certificate" in reason_str.lower() or "ssl" in reason_str.lower() else is_https,
                "redirected": False,
                "endpoint_verified": False,
                "safe_response_status": "Connection Failed",
                "error": f"Connection Error: {reason_str}",
                "timestamp": datetime.now(timezone.utc).isoformat()
            }
            attempted_records.append(record)

        except Exception as e:
            latency_ms = round((time.perf_counter() - start_time) * 1000, 2)
            record = {
                "service": name,
                "target_url": target_url,
                "http_status": None,
                "latency_ms": latency_ms,
                "tls_enabled": is_https,
                "tls_valid": False,
                "redirected": False,
                "endpoint_verified": False,
                "safe_response_status": "Execution Error",
                "error": f"{type(e).__name__}: {str(e)}",
                "timestamp": datetime.now(timezone.utc).isoformat()
            }
            attempted_records.append(record)

    if success_record:
        return success_record

    # If all attempted paths failed
    primary = attempted_records[0] if attempted_records else {}
    return {
        "service": name,
        "configured_url": base_url,
        "primary_target": primary.get("target_url"),
        "http_status": primary.get("http_status"),
        "latency_ms": primary.get("latency_ms"),
        "tls_enabled": primary.get("tls_enabled"),
        "tls_valid": primary.get("tls_valid"),
        "endpoint_verified": False,
        "safe_response_status": "Health endpoint not implemented — deployment cannot be verified automatically.",
        "error": primary.get("error") or "All candidate health endpoints returned non-200 status",
        "attempted_endpoints": [r.get("target_url") for r in attempted_records],
        "timestamp": datetime.now(timezone.utc).isoformat()
    }


def main():
    parser = argparse.ArgumentParser(
        description="LeukQuant Safe Staging Service Health Check Tool. Verifies non-secret GET endpoints."
    )
    parser.add_argument("--mm1-url", type=str, help="middle-man-1 ingestion service base URL (e.g. http://127.0.0.1:8081)")
    parser.add_argument("--mm3-url", type=str, help="middle-man-3 analytics service base URL (e.g. http://127.0.0.1:8080)")
    parser.add_argument("--admin-api-url", type=str, help="Admin backend API base URL (e.g. http://127.0.0.1:8088)")
    parser.add_argument("--dashboard-url", type=str, help="Client Dashboard SPA base URL (e.g. http://127.0.0.1:80)")
    parser.add_argument("--admin-dashboard-url", type=str, help="Admin Dashboard SPA base URL (e.g. http://127.0.0.1:8088)")
    parser.add_argument("--website-url", type=str, help="Cloudflare public website base URL (e.g. https://leukquant.me)")
    parser.add_argument("--timeout", type=float, default=10.0, help="HTTP request timeout in seconds (default: 10.0)")
    parser.add_argument("--json", action="store_true", help="Output results formatted as JSON")

    args = parser.parse_args()

    targets: List[Tuple[str, Optional[str], List[str]]] = [
        ("middle-man-1", args.mm1_url, ["/collect/health", "/actuator/health", "/"]),
        ("middle-man-3", args.mm3_url, ["/api/health", "/actuator/health", "/"]),
        ("Admin Backend", args.admin_api_url, ["/api/health", "/api/admin/health", "/api/admin/session"]),
        ("Client Dashboard", args.dashboard_url, ["/"]),
        ("Admin Dashboard", args.admin_dashboard_url, ["/api/health", "/"]),
        ("LEUKQUANT Website", args.website_url, ["/api/health", "/"])
    ]

    configured_targets = [(name, url, paths) for name, url, paths in targets if url]

    if not configured_targets:
        print("=" * 78)
        print("  LEUKQUANT STAGING HEALTH CHECK TOOL")
        print("=" * 78)
        print("No target URLs provided.")
        print("\nPlease provide at least one service URL using command-line arguments:")
        print("  --mm1-url <URL>              (Candidate endpoints: /collect/health, /actuator/health)")
        print("  --mm3-url <URL>              (Candidate endpoints: /api/health, /actuator/health)")
        print("  --admin-api-url <URL>        (Candidate endpoints: /api/health)")
        print("  --dashboard-url <URL>        (Candidate endpoints: /)")
        print("  --admin-dashboard-url <URL>  (Candidate endpoints: /api/health, /)")
        print("  --website-url <URL>          (Candidate endpoints: /api/health, /)")
        print("\nExample:")
        print("  python scripts/check_staging_services.py \\")
        print("    --mm1-url http://localhost:8081 \\")
        print("    --mm3-url http://localhost:8080 \\")
        print("    --admin-api-url http://localhost:8088 \\")
        print("    --dashboard-url http://localhost:3000 \\")
        print("    --admin-dashboard-url http://localhost:8088 \\")
        print("    --website-url https://leukquant.me")
        print("=" * 78)
        sys.exit(0)

    results = []
    print("=" * 78)
    print("  LEUKQUANT STAGING HEALTH AUDIT REPORT")
    print(f"  Execution Time: {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')}")
    print("=" * 78)

    for name, url, paths in configured_targets:
        res = check_endpoint(name, url, paths, timeout=args.timeout)
        results.append(res)

        # Pretty print result (Pure ASCII for Windows cp1252 console safety)
        status_symbol = "[PASS] [HEALTHY]" if res.get("endpoint_verified") else "[FAIL] [UNREACHABLE / UNVERIFIED]"
        print(f"\n{status_symbol} {name}")
        print(f"  Target URL:     {res.get('target_url') or res.get('configured_url')}")
        print(f"  HTTP Status:    {res.get('http_status') or 'N/A'}")
        print(f"  Latency:        {res.get('latency_ms', 'N/A')} ms")
        print(f"  TLS Active:     {res.get('tls_enabled')} (Valid: {res.get('tls_valid')})")
        print(f"  Status Summary: {res.get('safe_response_status')}")
        if res.get("error"):
            print(f"  Diagnostic:     {res.get('error')}")

    print("\n" + "=" * 78)
    summary_passed = sum(1 for r in results if r.get("endpoint_verified"))
    print(f"Summary: {summary_passed}/{len(results)} configured services verified online.")
    print("=" * 78)

    if args.json:
        print("\n--- JSON OUTPUT ---")
        print(json.dumps(results, indent=2))


if __name__ == "__main__":
    main()
