#!/usr/bin/env bash
set -euxo pipefail
cd "$(dirname "$0")"
CHART=mini-project/notes-chart
NS=helm-lab
TEMP_CHART=$(mktemp -d)/practice
helm create "$TEMP_CHART"
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo bitnami/nginx --versions | head -12 || true
helm lint "$CHART"
helm template notes "$CHART"
helm install notes "$CHART" -n "$NS" --create-namespace --wait --timeout 180s
helm list -n "$NS"
helm status notes -n "$NS"
helm get values notes -n "$NS"
helm get manifest notes -n "$NS"
helm upgrade notes "$CHART" -n "$NS" -f "$CHART/values-prod.yaml" --wait --timeout 180s
kubectl get pods -n "$NS"
kubectl exec -n "$NS" deploy/notes-deploy -- printenv ENVIRONMENT
helm upgrade notes "$CHART" -n "$NS" -f "$CHART/values-prod.yaml" --set replicaCount=2 --set app.environment=staging --wait --timeout 180s
kubectl get pods -n "$NS"
helm history notes -n "$NS"
helm rollback notes 1 -n "$NS" --wait --timeout 180s
helm history notes -n "$NS"
kubectl get pods -n "$NS"
kubectl exec -n "$NS" deploy/notes-deploy -- printenv ENVIRONMENT
helm uninstall notes -n "$NS" --wait
helm list -n "$NS"
