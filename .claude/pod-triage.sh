#!/bin/bash
# pod-triage.sh
# Trigger the pod triage agent from CLI
#
# Usage:
#   ./pod-triage.sh <cluster-context> <deployment-or-pod> "<issue description>"
#
# Examples:
#   ./pod-triage.sh prod-onprem-01 payment-service "pods restarting frequently"
#   ./pod-triage.sh staging-onprem-02 auth-deployment "ImagePullBackOff on all replicas"

set -e

# ── Input validation ────────────────────────────────────────────────────────
if [ "$#" -lt 3 ]; then
  echo ""
  echo "  Usage: ./pod-triage.sh <cluster-context> <deployment-or-pod> \"<issue>\""
  echo ""
  echo "  Example:"
  echo "    ./pod-triage.sh prod-onprem-01 payment-service \"pods restarting frequently\""
  echo ""
  exit 1
fi

CLUSTER_CONTEXT=$1
DEPLOYMENT_OR_POD=$2
ISSUE_DESCRIPTION=$3
REPORTED_AT=$(date '+%Y-%m-%d %H:%M %Z')
TIMESTAMP=$(date '+%Y%m%d-%H%M%S')

# ── Dynatrace config (set via env vars, never hardcode) ─────────────────────
DYNATRACE_BASE_URL=${DYNATRACE_BASE_URL:-""}
DYNATRACE_TOKEN=${DYNATRACE_TOKEN:-""}

if [ -z "$DYNATRACE_BASE_URL" ] || [ -z "$DYNATRACE_TOKEN" ]; then
  echo ""
  echo "  ⚠️  Warning: DYNATRACE_BASE_URL or DYNATRACE_TOKEN not set."
  echo "  Export them before running:"
  echo "    export DYNATRACE_BASE_URL=https://your-dynatrace-host/api"
  echo "    export DYNATRACE_TOKEN=your-api-token"
  echo ""
fi

# ── Output directory ────────────────────────────────────────────────────────
mkdir -p outputs

# ── Run agent ───────────────────────────────────────────────────────────────
echo ""
echo "  🔍 Starting Pod Triage"
echo "  ─────────────────────────────────────────"
echo "  Cluster     : $CLUSTER_CONTEXT"
echo "  Target      : $DEPLOYMENT_OR_POD"
echo "  Issue       : $ISSUE_DESCRIPTION"
echo "  Reported At : $REPORTED_AT"
echo "  ─────────────────────────────────────────"
echo ""

opencode -p "
  Use agent : .opencode/agents/pod-triage.md
  Use skill : .opencode/skills/pod-triage-skill.md

  Cluster/Context    : $CLUSTER_CONTEXT
  Deployment/Pod     : $DEPLOYMENT_OR_POD
  Issue Description  : $ISSUE_DESCRIPTION
  Reported At        : $REPORTED_AT

  Dynatrace Base URL : $DYNATRACE_BASE_URL
  Dynatrace Token    : $DYNATRACE_TOKEN

  Output RCA to      : outputs/rca-${DEPLOYMENT_OR_POD}-${TIMESTAMP}.md
"

echo ""
echo "  ✅ Triage complete."
echo "  📄 RCA saved to: outputs/rca-${DEPLOYMENT_OR_POD}-${TIMESTAMP}.md"
echo ""
