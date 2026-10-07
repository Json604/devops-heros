#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
PYTHON_BIN=${PYTHON_BIN:-python3}
HELM_BIN=${HELM_BIN:-helm}
"$PYTHON_BIN" -m pytest -q session-16-github-actions/10-final-cicd-pipeline/tests
"$PYTHON_BIN" -m pytest -q session21-final-devops-project/application/backend/tests
(cd session21-final-devops-project/application/frontend && npm ci && npm run build)
"$HELM_BIN" lint session-15-helm/mini-project/notes-chart
"$HELM_BIN" lint session21-final-devops-project/helm/helpdesk
for project in session18-terraform-iac/terraform-s3-demo session19-cloud-terraform session21-final-devops-project/terraform; do
  terraform -chdir="$project" fmt -check
  terraform -chdir="$project" init -backend=false
  terraform -chdir="$project" validate
  terraform -chdir="$project" test
 done
