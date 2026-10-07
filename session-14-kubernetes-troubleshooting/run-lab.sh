#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
NS=troubleshooting-lab
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -
for problem in crashloop imagepull pending containercreating configuration dns; do
  echo "=== $problem: broken ==="
  kubectl apply -n "$NS" -f "cases/$problem-broken.yaml"
  sleep 20
  kubectl get pod -n "$NS" "$problem" -o wide
  kubectl describe pod -n "$NS" "$problem"
  kubectl logs -n "$NS" "$problem" --tail=15 || true
  kubectl events -n "$NS" --for "pod/$problem" || true
  echo "=== $problem: fixed ==="
  kubectl delete pod -n "$NS" "$problem" --wait=true
  kubectl apply -n "$NS" -f "cases/$problem-fixed.yaml"
  kubectl wait -n "$NS" --for=condition=Ready "pod/$problem" --timeout=180s
  kubectl get pod -n "$NS" "$problem"
  kubectl logs -n "$NS" "$problem" --tail=10
 done
kubectl apply -n "$NS" -f mini-project/deployment.yaml -f mini-project/service.yaml
kubectl rollout status -n "$NS" deployment/troubleshooting-app --timeout=180s
kubectl patch service -n "$NS" troubleshooting-service -p '{"spec":{"selector":{"app":"wrong-app"}}}'
kubectl get pods -n "$NS" --show-labels
kubectl describe service -n "$NS" troubleshooting-service
kubectl get endpointslices -n "$NS" -l kubernetes.io/service-name=troubleshooting-service
kubectl apply -n "$NS" -f mini-project/service.yaml
kubectl get endpointslices -n "$NS" -l kubernetes.io/service-name=troubleshooting-service
kubectl exec -n "$NS" crashloop -- wget -T 5 -qO- http://troubleshooting-service
kubectl patch service -n "$NS" troubleshooting-service -p '{"spec":{"ports":[{"port":80,"targetPort":81}]}}'
sleep 5
if kubectl exec -n "$NS" crashloop -- wget -T 5 -qO- http://troubleshooting-service; then
  echo 'Expected the incorrect port to fail'; exit 1
fi
kubectl get service -n "$NS" troubleshooting-service -o yaml
kubectl exec -n "$NS" deployment/troubleshooting-app -- curl -fsS localhost:80
kubectl apply -n "$NS" -f mini-project/service.yaml
kubectl exec -n "$NS" crashloop -- wget -T 5 -qO- http://troubleshooting-service
kubectl explain pod.spec.containers.readinessProbe
kubectl top pods -n "$NS"
kubectl get pods -n "$NS" -o wide
