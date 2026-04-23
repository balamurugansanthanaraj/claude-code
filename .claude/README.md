# Pod Triage — Incident Investigation Agent

Autonomous Kubernetes pod troubleshooting agent for on-premise clusters
using OpenCode + Dynatrace.

---

## File Structure

```
pod-triage/
├── .opencode/
│   ├── agents/
│   │   └── pod-triage.md          # Agent — goal + tools + constraints
│   └── skills/
│       └── pod-triage-skill.md    # Skill — on-premise K8s expertise
├── .claude/
│   └── commands/
│       └── pod-triage.md          # Claude Code slash command
├── outputs/
│   └── rca-template.md            # RCA output format reference
├── pod-triage.sh                  # Shell script trigger
└── README.md
```

---

## How To Use

### Option 1 — Shell Script (Recommended)

```bash
# Set Dynatrace credentials
export DYNATRACE_BASE_URL=https://your-dynatrace-host/api
export DYNATRACE_TOKEN=your-api-token

# Run triage
./pod-triage.sh <cluster-context> <deployment-or-pod> "<issue>"

# Examples
./pod-triage.sh prod-onprem-01 payment-service "pods restarting frequently"
./pod-triage.sh staging-onprem-02 auth-deployment "ImagePullBackOff on all replicas"
./pod-triage.sh prod-onprem-01 order-service "pod stuck in Pending state"
```

### Option 2 — Claude Code Slash Command

```bash
/pod-triage prod-onprem-01 payment-service "pods restarting frequently"
```

### Option 3 — Direct OpenCode CLI

```bash
opencode -p "
  Use agent : .opencode/agents/pod-triage.md
  Use skill : .opencode/skills/pod-triage-skill.md

  Cluster/Context    : prod-onprem-01
  Deployment/Pod     : payment-service
  Issue Description  : pods restarting frequently since 10AM IST
  Reported At        : 2026-04-22 10:00 IST
"
```

---

## Design Principles

| Layer   | File                      | Responsibility                              |
|---------|---------------------------|---------------------------------------------|
| Agent   | pod-triage.md             | Goal, tools, constraints — no steps         |
| Skill   | pod-triage-skill.md       | On-premise K8s expertise + Dynatrace usage  |
| Command | .claude/commands/         | One-liner trigger for Claude Code users     |
| Script  | pod-triage.sh             | CLI trigger with input validation           |
| Output  | outputs/rca-*.md          | Structured RCA per incident                 |

---

## Environment Variables

| Variable            | Description                    | Required |
|---------------------|--------------------------------|----------|
| DYNATRACE_BASE_URL  | Dynatrace API base URL         | Yes      |
| DYNATRACE_TOKEN     | Dynatrace API token (read-only)| Yes      |

Never hardcode credentials. Always export via env vars or secrets manager.

---

## What The Agent Does NOT Do

- ❌ Restart pods
- ❌ Rollback deployments
- ❌ Delete resources
- ❌ Access nodes without human approval
- ❌ Assume root cause without investigation

---

## RCA Output Location

```
outputs/rca-<deployment>-<timestamp>.md
```

Example:
```
outputs/rca-payment-service-20260422-103045.md
```
