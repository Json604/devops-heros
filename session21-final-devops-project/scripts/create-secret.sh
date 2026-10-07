#!/usr/bin/env bash
set -euo pipefail
NS=${1:-helpdesk}
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -
if kubectl get secret helpdesk-database -n "$NS" >/dev/null 2>&1; then
  echo 'Database Secret already exists; keeping the current password.'
  exit 0
fi
SECRET_FILE=$(mktemp)
trap 'rm -f "$SECRET_FILE"' EXIT
chmod 600 "$SECRET_FILE"
openssl rand -hex 24 | tr -d '\n' > "$SECRET_FILE"
kubectl create secret generic helpdesk-database -n "$NS" --from-file=password="$SECRET_FILE"
