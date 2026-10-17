#!/bin/bash
# ================================================================
# Health Check — Verify all services are running
# Usage: ./health-check.sh
# ================================================================

echo "=========================================="
echo "  Health Check — All Services"
echo "=========================================="

echo ""
echo "── Kubernetes Nodes ──"
kubectl get nodes

echo ""
echo "── App Pods ──"
kubectl get pods -n app -o wide

echo ""
echo "── App Services ──"
kubectl get svc -n app

echo ""
echo "── Monitoring Pods ──"
kubectl get pods -n monitoring

echo ""
echo "── Monitoring Services ──"
kubectl get svc -n monitoring

echo ""
echo "── Resource Usage ──"
kubectl top pods -n app 2>/dev/null || echo "(metrics-server may need a moment to start)"

echo ""
echo "── API Health Check ──"
FRONTEND_URL=$(minikube service frontend-service -n app --url 2>/dev/null)
if [ -n "$FRONTEND_URL" ]; then
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $FRONTEND_URL)
    echo "Frontend ($FRONTEND_URL): HTTP $HTTP_CODE"
else
    echo "Frontend: Unable to get URL"
fi

echo ""
echo "=========================================="
echo "  Health check complete!"
echo "=========================================="
