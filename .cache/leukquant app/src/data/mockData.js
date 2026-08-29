// src/data/mockData.js
// Authentic enterprise telemetry and security domain data for Leukquant

export const MOCK_ANALYST = {
  name: "Dr. Rick J. Antony",
  role: "Lead Threat Analyst & SOC Lead",
  clearance: "Tier 3 (Enterprise Master)",
  email: "rick.antony@leukquant.internal",
  avatarUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80",
  clusterId: "EU-CENTRAL-CLUST-09",
  lastSync: "Just now"
};

export const MOCK_SECURITY_METRICS = {
  clusterPosture: "Shielded",
  uptime: "99.99%",
  activeSensors: 48,
  criticalIncidentsCount: 3,
  highRiskEventsCount: 14,
  ingressRate: "1.4k ev/s",
  lastEventTime: "12s ago",
  decoyNodesOnline: 12,
  totalDecoys: 12,
  honeypotInteractions24h: 382,
  containmentEfficiency: "98.4%"
};

export const MOCK_24H_CHART_DATA = [
  { time: "00:00", events: 12, critical: 0, high: 2 },
  { time: "02:00", events: 8, critical: 0, high: 1 },
  { time: "04:00", events: 15, critical: 1, high: 3 },
  { time: "06:00", events: 28, critical: 0, high: 4 },
  { time: "08:00", events: 64, critical: 2, high: 12 },
  { time: "10:00", events: 98, critical: 3, high: 19 },
  { time: "12:00", events: 142, critical: 5, high: 28 },
  { time: "14:00", events: 110, critical: 2, high: 22 },
  { time: "16:00", events: 165, critical: 4, high: 34 },
  { time: "18:00", events: 130, critical: 1, high: 20 },
  { time: "20:00", events: 88, critical: 0, high: 14 },
  { time: "22:00", events: 45, critical: 1, high: 8 }
];

export const MOCK_THREAT_DISTRIBUTION = [
  { name: "Canary Trigger", count: 184, percent: 48, color: "#007AFF" },
  { name: "Credential Attack", count: 96, percent: 25, color: "#FF9500" },
  { name: "Port Recon", count: 65, percent: 17, color: "#AF52DE" },
  { name: "Critical Breach Attempt", count: 37, percent: 10, color: "#FF3B30" }
];

export const MOCK_PROTOCOL_BREAKDOWN = [
  { protocol: "SSH (22)", events: 420, percent: 42, color: "#007AFF" },
  { protocol: "HTTPS (443)", events: 290, percent: 29, color: "#34C759" },
  { protocol: "PostgreSQL (5432)", events: 145, percent: 14, color: "#FF9500" },
  { protocol: "DNS (53)", events: 95, percent: 9, color: "#AF52DE" },
  { protocol: "MySQL (3306)", events: 50, percent: 6, color: "#5856D6" }
];

export const MOCK_SECURITY_EVENTS = [
  {
    id: "EVT-8941-XJ",
    classification: "Honeytoken Secret Access",
    classificationReasons: [
      "Simulated AWS STS assume-role token queried from unknown ASN 14061",
      "Decoy DynamoDB canary table interaction confirmed",
      "Signature matches known cloud infrastructure scanner"
    ],
    severity: "critical", // critical, high, warning, info
    protocol: "HTTPS",
    destinationPort: "443",
    sourceIp: "185.220.101.44",
    country: "Germany (DE)",
    countryCode: "🇩🇪",
    canaryReference: "canary-aws-prod-decoy-04",
    recommendedAction: "Quarantine source subnet and rotate ephemeral decoy STS credentials immediately.",
    maskedCredentials: "admin_cloud_iam / **********",
    timestamp: "Just now",
    rawPayload: {
      action: "sts:AssumeRole",
      role_arn: "arn:aws:iam::883921094812:role/CanaryAuditAdmin",
      user_agent: "aws-sdk-go/v1.44.200 (go1.20; linux; amd64)",
      client_asn: 14061,
      tls_cipher: "TLS_AES_128_GCM_SHA256"
    }
  },
  {
    id: "EVT-8940-QL",
    classification: "SSH Password Spraying",
    classificationReasons: [
      "High frequency brute-force against decoy bastion host",
      "Exceeded rate limit: 45 authentication attempts in 6 seconds",
      "Dictionary wordlist matching observed"
    ],
    severity: "high",
    protocol: "SSH",
    destinationPort: "22",
    sourceIp: "91.240.118.172",
    country: "Netherlands (NL)",
    countryCode: "🇳🇱",
    canaryReference: "ghost-bastion-edge-01",
    recommendedAction: "Maintain perimeter drop rule on ingress firewall. Null-route inbound IP.",
    maskedCredentials: "root / **********",
    timestamp: "2m ago",
    rawPayload: {
      service: "OpenSSH_8.9p1",
      auth_method: "password",
      attempt_count: 45,
      targeted_users: ["root", "ubuntu", "admin", "devops", "deploy"]
    }
  },
  {
    id: "EVT-8939-MK",
    classification: "PostgreSQL Decoy Probe",
    classificationReasons: [
      "Direct connection to decoy database endpoint",
      "Enumeration of `pg_shadow` and `information_schema` tables"
    ],
    severity: "high",
    protocol: "POSTGRES",
    destinationPort: "5432",
    sourceIp: "45.154.255.89",
    country: "Switzerland (CH)",
    countryCode: "🇨🇭",
    canaryReference: "db-canary-financial-replica",
    recommendedAction: "Log connection metadata and correlate with ingress gateway logs.",
    maskedCredentials: "postgres / **********",
    timestamp: "5m ago",
    rawPayload: {
      db_name: "prod_customers_shadow",
      query_fingerprint: "SELECT * FROM information_schema.tables WHERE table_schema='public'",
      client_encoding: "UTF8"
    }
  },
  {
    id: "EVT-8938-AA",
    classification: "Suspicious API Port Scan",
    classificationReasons: [
      "SYN packet burst across TCP ports 8080, 8443, 9000, 9200",
      "Originating from unverified VPN exit gateway"
    ],
    severity: "warning",
    protocol: "TCP",
    destinationPort: "8443",
    sourceIp: "193.32.162.201",
    country: "Romania (RO)",
    countryCode: "🇷🇴",
    canaryReference: "perimeter-sensor-dmz-02",
    recommendedAction: "Observe decoy interaction timeline. No credential leak detected.",
    maskedCredentials: "anonymous / **********",
    timestamp: "11m ago",
    rawPayload: {
      ports_scanned: [80, 443, 8080, 8443, 9000, 9092, 9200],
      tcp_flags: "SYN",
      duration_ms: 340
    }
  },
  {
    id: "EVT-8937-ZX",
    classification: "Decoy Health Heartbeat",
    classificationReasons: [
      "Scheduled node telemetry health ping",
      "Decoy sensor latency verified at 4ms"
    ],
    severity: "info",
    protocol: "HTTPS",
    destinationPort: "443",
    sourceIp: "10.0.4.18",
    country: "Internal Mesh",
    countryCode: "🛡️",
    canaryReference: "canary-mesh-controller",
    recommendedAction: "No action needed. Ingress nodes fully synchronised.",
    maskedCredentials: "system / **********",
    timestamp: "18m ago",
    rawPayload: {
      status: "HEALTHY",
      active_decoys: 12,
      latency_ms: 4.2
    }
  },
  {
    id: "EVT-8936-BB",
    classification: "SQL Injection Probe on Decoy Web App",
    classificationReasons: [
      "Pattern matching `' OR 1=1 --` on mock login endpoint",
      "Fuzzing user parameter payloads"
    ],
    severity: "high",
    protocol: "HTTPS",
    destinationPort: "443",
    sourceIp: "103.145.12.8",
    country: "Singapore (SG)",
    countryCode: "🇸🇬",
    canaryReference: "web-canary-portal-login",
    recommendedAction: "Isolate session token and fingerprint browser canvas hash.",
    maskedCredentials: "sqli_payload / **********",
    timestamp: "24m ago",
    rawPayload: {
      uri: "/api/v1/auth/login",
      method: "POST",
      body_sample: "username=admin' UNION SELECT null, password_hash FROM users--",
      user_agent: "sqlmap/1.7.2#stable"
    }
  }
];

export const MOCK_INCIDENTS = [
  {
    id: "INC-2026-0042",
    title: "AWS Production Honeytoken Leak in External Repo",
    description: "Decoy IAM access key canary triggered from foreign ASN. Suspected exposure in open git commit.",
    severity: "critical",
    status: "Investigating", // Investigating, Contained, Mitigated, Resolved
    assignee: "Dr. Rick J. Antony",
    scope: "Cloud Infrastructure / AWS Decoy",
    recommendedAction: "Audit recent git commit histories, null-route attacker IP range, and issue canary key revocation.",
    createdAt: "28m ago",
    timeline: [
      {
        stage: "Detection",
        description: "Automated Ghost-Net sensor flagged STS AssumeRole invocation on canary key `AKIA...7XQ`.",
        timestamp: "08:14:02 AM",
        isCompleted: true
      },
      {
        stage: "Correlation",
        description: "IP 185.220.101.44 correlated with 3 prior port reconnaissance events from ASN 14061.",
        timestamp: "08:16:45 AM",
        isCompleted: true
      },
      {
        stage: "Triage & Containment",
        description: "Perimeter firewall rule active. Ephemeral honeytoken invalidated to halt further reconnaissance.",
        timestamp: "08:21:10 AM",
        isCompleted: true
      },
      {
        stage: "Resolution",
        description: "Final post-incident audit and perimeter rule verification pending analyst sign-off.",
        timestamp: "In Progress",
        isCompleted: false
      }
    ]
  },
  {
    id: "INC-2026-0041",
    title: "Distributed SSH Brute-Force Wave on Bastion Decoy",
    description: "Synchronized credential dictionary stuffing against edge canary honeypot from 4 ASN sources.",
    severity: "high",
    status: "Contained",
    assignee: "SOC Automated Tier 1",
    scope: "DMZ Edge Cluster",
    recommendedAction: "Dynamic fail2ban jail applied across all edge gateway ingress controllers.",
    createdAt: "2h ago",
    timeline: [
      {
        stage: "Detection",
        description: "Threshold exceeded: >120 failed SSH logins/min on honeypot port 22.",
        timestamp: "06:30:00 AM",
        isCompleted: true
      },
      {
        stage: "Correlation",
        description: "Matched attack signatures with botnet cluster C2 node in Netherlands.",
        timestamp: "06:32:12 AM",
        isCompleted: true
      },
      {
        stage: "Triage & Containment",
        description: "Dynamic rate-limit drop and decoy response tarpit enabled.",
        timestamp: "06:35:40 AM",
        isCompleted: true
      },
      {
        stage: "Resolution",
        description: "Traffic subsided. All decoy sensors reporting nominal baseline.",
        timestamp: "07:10:00 AM",
        isCompleted: true
      }
    ]
  },
  {
    id: "INC-2026-0040",
    title: "Decoy PostgreSQL Port Scan & Enum",
    description: "Database credential brute force on port 5432 targeting synthetic customer data shards.",
    severity: "high",
    status: "Contained",
    assignee: "Security Operations Tier 2",
    scope: "Synthetic DB Shard 3",
    recommendedAction: "Maintain blackhole routing on source ASN and review query hashes.",
    createdAt: "5h ago",
    timeline: [
      {
        stage: "Detection",
        description: "Canary database connection received from unregistered IP address.",
        timestamp: "03:15:19 AM",
        isCompleted: true
      },
      {
        stage: "Correlation",
        description: "Identified attempt to read decoy financial tables.",
        timestamp: "03:18:22 AM",
        isCompleted: true
      },
      {
        stage: "Triage & Containment",
        description: "Synthetic response delayed with deception tarpit.",
        timestamp: "03:22:00 AM",
        isCompleted: true
      },
      {
        stage: "Resolution",
        description: "No real production systems were accessible or impacted.",
        timestamp: "04:00:00 AM",
        isCompleted: true
      }
    ]
  },
  {
    id: "INC-2026-0039",
    title: "Synthetic Kubernetes Service Account Probe",
    description: "Attempted query to `/api/v1/namespaces/default/secrets` using decoy service token.",
    severity: "warning",
    status: "Resolved",
    assignee: "Dr. Rick J. Antony",
    scope: "K8s Cluster Decoy Mesh",
    recommendedAction: "Incident closed. Decoy token automatically rotated.",
    createdAt: "Yesterday",
    timeline: [
      {
        stage: "Detection",
        description: "Decoy API endpoint logged token introspection query.",
        timestamp: "Yesterday, 16:40",
        isCompleted: true
      },
      {
        stage: "Correlation",
        description: "Origin traced to external security research crawler.",
        timestamp: "Yesterday, 16:45",
        isCompleted: true
      },
      {
        stage: "Triage & Containment",
        description: "Automated honeypot token discarded and reseeded.",
        timestamp: "Yesterday, 16:50",
        isCompleted: true
      },
      {
        stage: "Resolution",
        description: "Incident resolved with zero impact to tenant infrastructure.",
        timestamp: "Yesterday, 17:15",
        isCompleted: true
      }
    ]
  }
];

export const MOCK_REPORTS = [
  {
    id: "REP-2026-W34",
    title: "7-Day Executive Security Brief",
    periodicity: "Weekly Brief",
    description: "Holistic overview of all perimeter honeypot interactions, threat distribution, and decoy containment effectiveness.",
    coveragePeriod: "Aug 18 – Aug 25, 2026",
    format: "PDF",
    fileSize: "2.4 MB",
    isReady: true,
    highlights: {
      totalEvents: "3,842 verified signals",
      incidentsContained: "100%",
      avgContainmentTime: "4.2 minutes",
      topTargetedDecoy: "AWS Honeytoken Cluster"
    }
  },
  {
    id: "REP-2026-AUD",
    title: "Incident Audit & Compliance Log",
    periodicity: "Audit Trail",
    description: "Detailed chronological record of SOC responses, containment timestamps, and threat actor IP correlations for compliance.",
    coveragePeriod: "Last 30 Days",
    format: "PDF",
    fileSize: "4.1 MB",
    isReady: true,
    highlights: {
      totalEvents: "14,920 telemetry points",
      soc2Compliance: "100% Compliant",
      iso27001Posture: "Audited & Verified",
      signatureValidation: "SHA-256 Valid"
    }
  },
  {
    id: "REP-2026-M08",
    title: "Monthly Threat Intelligence Digest",
    periodicity: "Monthly",
    description: "In-depth intelligence analysis regarding emerging credential stuffing patterns and automated scanner ASN trends.",
    coveragePeriod: "August 2026",
    format: "PDF",
    fileSize: "5.8 MB",
    isReady: true,
    highlights: {
      totalEvents: "48,200 probes",
      blockedSubnets: "124 CIDR blocks",
      zeroDayProbes: "3 signature anomalies",
      readinessScore: "99.4/100"
    }
  }
];

export const MOCK_DECOY_SENSORS = [
  { id: "SENS-AWS-01", name: "AWS STS Honeytoken Guard", status: "Active", latency: "2ms", type: "Cloud IAM" },
  { id: "SENS-SSH-04", name: "Bastion SSH Decoy Node", status: "Active", latency: "4ms", type: "Compute" },
  { id: "SENS-DB-02", name: "PostgreSQL Replica Canary", status: "Active", latency: "3ms", type: "Database" },
  { id: "SENS-K8S-09", name: "K8s ServiceAccount Tarpit", status: "Active", latency: "5ms", type: "Mesh" },
  { id: "SENS-WEB-03", name: "Decoy Login Portal Trapper", status: "Active", latency: "6ms", type: "Web" }
];
