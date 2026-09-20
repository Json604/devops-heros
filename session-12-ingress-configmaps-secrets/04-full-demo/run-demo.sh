#!/usr/bin/env sh
set -eu
kubectl apply -f "$(dirname "$0")/configmap.yaml"
kubectl apply -f "$(dirname "$0")/secret.yaml"
kubectl apply -f "$(dirname "$0")/backend.yaml"
kubectl apply -f "$(dirname "$0")/frontend.yaml"
kubectl apply -f "$(dirname "$0")/ingress.yaml"
kubectl rollout status deployment/yatri-backend --timeout=180s
kubectl rollout status deployment/yatri-frontend --timeout=180s
kubectl get configmap,secret,ingress,deploy,svc,pods -l app=yatri-app
