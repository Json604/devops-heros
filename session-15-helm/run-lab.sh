#!/usr/bin/env bash
set -euxo pipefail
cd "$(dirname "$0")"
HELM_BIN=${HELM_BIN:-helm}
CHART=mini-project/notes-chart
NS=helm-lab
TEMP_CHART=$(mktemp -d)/practice
"$HELM_BIN" create "$TEMP_CHART"
"$HELM_BIN" repo add bitnami https://charts.bitnami.com/bitnami
"$HELM_BIN" repo update
"$HELM_BIN" search repo bitnami/nginx --versions | head -12 || true
"$HELM_BIN" lint "$CHART"
"$HELM_BIN" template notes "$CHART"
"$HELM_BIN" install notes "$CHART" -n "$NS" --create-namespace --wait --timeout 180s
"$HELM_BIN" list -n "$NS"
"$HELM_BIN" status notes -n "$NS"
"$HELM_BIN" get values notes -n "$NS"
"$HELM_BIN" get manifest notes -n "$NS"
"$HELM_BIN" upgrade notes "$CHART" -n "$NS" -f "$CHART/values-prod.yaml" --wait --timeout 180s
kubectl get pods -n "$NS"
kubectl exec -n "$NS" deploy/notes-deploy -- printenv ENVIRONMENT
# Intentionally omit --wait: inspect the failed rollout, then recover it.
"$HELM_BIN" upgrade notes "$CHART" -n "$NS" -f "$CHART/values-prod.yaml" --set image.tag=broken-tag-does-not-exist
failure_seen=false
for attempt in {1..30}; do
  kubectl get pods -n "$NS"
  reasons=$(kubectl get pods -n "$NS" -o jsonpath='{.items[*].status.containerStatuses[*].state.waiting.reason}')
  if [[ "$reasons" == *ImagePullBackOff* ]]; then failure_seen=true; break; fi
  sleep 5
done
kubectl describe pods -n "$NS"
kubectl get events -n "$NS" --sort-by=.lastTimestamp
test "$failure_seen" = true
kubectl get pods -n "$NS"
"$HELM_BIN" history notes -n "$NS"
"$HELM_BIN" rollback notes 2 -n "$NS" --wait --timeout 180s
"$HELM_BIN" history notes -n "$NS"
kubectl get pods -n "$NS"
kubectl exec -n "$NS" deploy/notes-deploy -- printenv ENVIRONMENT
"$HELM_BIN" uninstall notes -n "$NS" --wait
"$HELM_BIN" list -n "$NS"
