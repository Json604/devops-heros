#!/usr/bin/env sh
set -eu
base=$(dirname "$0")
kubectl delete -f "$base/ingress.yaml" --ignore-not-found
kubectl delete -f "$base/frontend.yaml" --ignore-not-found
kubectl delete -f "$base/backend.yaml" --ignore-not-found
kubectl delete -f "$base/secret.yaml" --ignore-not-found
kubectl delete -f "$base/configmap.yaml" --ignore-not-found
