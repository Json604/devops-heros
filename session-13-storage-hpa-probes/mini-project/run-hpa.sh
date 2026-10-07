#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../../.."
NS=production-webapp
cleanup() { kubectl delete deployment web-load-generator -n "$NS" --ignore-not-found; }
trap cleanup EXIT
set -x
kubectl get hpa,pods -n "$NS"
kubectl exec -n "$NS" deployment/web-app -- curl -fsS http://web-service
kubectl apply -f session-13-storage-hpa-probes/mini-project/load-generator.yaml
kubectl rollout status deployment/web-load-generator -n "$NS" --timeout=180s
scaled=false
for i in {1..48}; do
 kubectl get hpa,pods -n "$NS"
 kubectl top pods -n "$NS" -l app=web-app
 replicas=$(kubectl get deployment web-app -n "$NS" -o jsonpath='{.status.readyReplicas}')
 if [[ "${replicas:-0}" -gt 2 ]]; then scaled=true; break; fi
 sleep 10
done
kubectl describe hpa web-app-hpa -n "$NS"
test "$scaled" = true
cleanup
for i in {1..54}; do
 kubectl get hpa -n "$NS"
 replicas=$(kubectl get deployment web-app -n "$NS" -o jsonpath='{.status.replicas}')
 if [[ "${replicas:-0}" = 2 ]]; then
  kubectl rollout status deployment/web-app -n "$NS" --timeout=120s
  kubectl get pods -n "$NS"
  kubectl describe hpa web-app-hpa -n "$NS"
  trap - EXIT
  exit 0
 fi
 sleep 10
done
exit 1
