#!/bin/bash
# ================================================================
# Rollback — Revert to the previous deployment version
# Usage: ./rollback.sh <deployment-name> <namespace>
# Example: ./rollback.sh frontend app
# ================================================================

DEPLOYMENT=${1:-"frontend"}
NAMESPACE=${2:-"app"}

echo "⏪ Rolling back deployment: $DEPLOYMENT in namespace: $NAMESPACE"

kubectl rollout undo deployment/$DEPLOYMENT -n $NAMESPACE

echo "⏳ Waiting for rollback to complete..."
kubectl rollout status deployment/$DEPLOYMENT -n $NAMESPACE --timeout=120s

echo ""
echo "✅ Rollback complete!"
kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT
