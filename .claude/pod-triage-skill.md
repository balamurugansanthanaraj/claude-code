# Pod Triage Skill

## Pod State Interpretation

### OOMKilled
- Check memory trend in Dynatrace — trend over time, not just current snapshot
- Gradual memory growth = memory leak (likely code issue)
- Sudden spike = burst load or external trigger
- Compare actual usage vs configured limits
- On-premise: check node memory too, not just pod limits

### CrashLoopBackOff
- Always check last 3 restarts, not just the current one
- Correlate restart timestamps with Dynatrace anomaly feed
- Check if all replicas are affected or just one (node-specific issue?)
- Check application logs for stack traces before kubectl events

### Pending
- First suspect : node selector + taint/toleration mismatch
- Second suspect: insufficient CPU or memory on available nodes
- On-premise: no auto-scaling — resource contention is real and common
- Check node conditions: kubectl get nodes -o wide

### Evicted
- First suspect: node disk pressure
- Check /var/log and /var/lib/containerd on affected node
- On-premise: NFS mounts fill up silently — verify mount points

### ImagePullBackOff
- Check local registry health first — not Docker Hub
- Verify registry pod is running in registry namespace
- Check imagePullSecrets on the pod spec

### Terminating (stuck)
- Check finalizers on the pod
- Check if the underlying node is reachable
- Check if the namespace itself is terminating

---

## Dynatrace Usage

### What To Check
- Service health anomalies around the reported incident time
- Pod CPU and memory metrics vs configured limits
- Failed transaction count correlated with pod restarts
- Infrastructure health of the underlying node
- Any auto-raised Dynatrace problem tickets for the service

### Correlation Window
- Always pull metrics from 30 mins before the reported issue time
- Compare with baseline from the same time window the previous week
- Look for anomaly detection alerts that fired before the human noticed

---

## On-Premise K8s Quirks

- CoreDNS failures are common — if symptoms are intermittent, suspect DNS
- NFS mount failures are silent — always verify mount points on affected node
- Certificates expire without auto-renewal — check cert age if TLS errors appear
- No HPA by default — resource contention hits harder than in cloud clusters
- Local registry downtime causes ImagePullBackOff cluster-wide
- kubelet on node can become unhealthy without pod-level symptoms — check journalctl

---

## Deployment Correlation

- Flag any Helm release within 30 mins of the reported issue time
- Run: helm history <release-name> -n <namespace>
- Our deployments are Helm only — no raw kubectl apply
- Maintenance window: Sunday 2AM–4AM IST (deprioritize alerts in this window)

---

## RCA Writing Standard

- Root cause      : 1 clear non-technical sentence
- Timeline        : Chronological, include timestamps
- Blast radius    : What was affected, how many users/services impacted
- Investigation   : What you checked and why (your reasoning, not raw commands)
- Remediation     : Immediate fix + long-term prevention
- Recurrence risk : Low / Medium / High with reason
- Avoid raw kubectl/helm commands in the final RCA body
- Audience        : Non-technical stakeholders — keep it plain English
- Always end with a "Prevention" section
- Flag explicitly if this issue has occurred before
