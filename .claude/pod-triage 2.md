# Pod Triage Command

Troubleshoot a Kubernetes pod issue using the pod triage agent and skill.

## Usage
/pod-triage <cluster-context> <deployment-or-pod> "<issue description>"

## Examples
/pod-triage prod-onprem-01 payment-service "pods restarting frequently since 10AM IST"
/pod-triage staging-onprem-02 auth-deployment "ImagePullBackOff on all replicas"
/pod-triage prod-onprem-01 order-service "pod stuck in Pending state"

## What This Does
Invokes the pod triage agent with the provided inputs.
Agent will autonomously investigate and produce an RCA to /outputs/.

---

Use agent : .opencode/agents/pod-triage.md
Use skill : .opencode/skills/pod-triage-skill.md

Cluster/Context    : $1
Deployment/Pod     : $2
Issue Description  : $3
Reported At        : $(date '+%Y-%m-%d %H:%M %Z')
