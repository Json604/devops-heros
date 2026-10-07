#!/usr/bin/env bash
set -euo pipefail
NS=helpdesk
DEPLOY=helpdesk-backend
ORIGINAL_IMAGE=$(kubectl get deployment "$DEPLOY" -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].image}')
restore() {
  kubectl set image -n "$NS" deployment/"$DEPLOY" "backend=$ORIGINAL_IMAGE"
  kubectl patch service/backend -n "$NS" -p '{"spec":{"selector":{"app":"helpdesk-backend"}}}'
  kubectl patch deployment/"$DEPLOY" -n "$NS" --type=json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/ready"}]'
}
trap restore EXIT
set -x
kubectl set image -n "$NS" deployment/"$DEPLOY" backend=python:missing-24bcs10121
sleep 25
kubectl get pods -n "$NS"
kubectl describe pods -n "$NS" -l app=helpdesk-backend
kubectl get events -n "$NS" --sort-by=.lastTimestamp
kubectl set image -n "$NS" deployment/"$DEPLOY" "backend=$ORIGINAL_IMAGE"
kubectl rollout status -n "$NS" deployment/"$DEPLOY" --timeout=180s
kubectl patch service/backend -n "$NS" -p '{"spec":{"selector":{"app":"wrong-app"}}}'
sleep 5
kubectl describe service/backend -n "$NS"
kubectl get endpointslices -n "$NS" -l kubernetes.io/service-name=backend
kubectl get pods -n "$NS" --show-labels
kubectl patch service/backend -n "$NS" -p '{"spec":{"selector":{"app":"helpdesk-backend"}}}'
sleep 5
kubectl get endpointslices -n "$NS" -l kubernetes.io/service-name=backend
kubectl patch deployment/"$DEPLOY" -n "$NS" --type=json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/missing"}]'
sleep 20
kubectl get pods -n "$NS"
kubectl describe pods -n "$NS" -l app=helpdesk-backend
kubectl logs -n "$NS" -l app=helpdesk-backend --tail=12
restore
kubectl rollout status -n "$NS" deployment/"$DEPLOY" --timeout=180s
kubectl exec -n "$NS" deployment/"$DEPLOY" -- python -c 'import urllib.request; print(urllib.request.urlopen("http://backend:8000/ready").read().decode())'
kubectl get pods,svc -n "$NS"
trap - EXIT
