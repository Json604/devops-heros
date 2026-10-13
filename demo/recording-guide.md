# Presentation and live recording guide

This is a preparation guide, not a submitted video. Record your explanation with the visible application, terminal and browser. Avoid recording credentials, `.env`, kubeconfigs, AWS login prompts or Terraform state.

## Slides first (about 4 minutes)

Open [slides.pdf](slides.pdf) full screen. Explain the campus IT support problem, then the stack and request path. Explain how isolated API tests stop bad releases, why both runtime images use non-root users, and how the HIGH/CRITICAL Trivy gate precedes publication. Describe Terraform's VPC/EKS resources, Helm's workloads and probes, Argo's release reconciliation, and the Prometheus/Grafana metrics. Finish with recovery, cleanup and production limitations.

Use your own explanations. The historical screenshots demonstrate the recorded 7 October execution. They are not a replacement for the required live walkthrough.

## Preparation

1. Start recording before the push. Open the codebase, GitHub Actions, AWS VPC/EKS Console, Argo CD, the application, Prometheus Targets and Grafana in advance.
2. Start Compose from `session21-final-devops-project` using `docker compose up -d --build`. Open `http://localhost:3100` for the existing local configuration (default on a clean setup is 3000). Create and resolve a request.
3. Reauthenticate the existing `coursework` profile if needed: `aws login --profile coursework --region ap-south-1`.
4. Follow [Terraform setup](../session21-final-devops-project/terraform/README.md) to review a new plan and deploy. Update the administrator CIDR locally. Follow the Kubernetes, monitoring and GitOps instructions in the [project README](../session21-final-devops-project/README.md). Verify everything before starting the presentation.
5. Keep the cluster available until the live recording ends, then follow the documented cleanup procedure and capture its completion.

## Live walkthrough (after the slides)

### 1. Codebase

Show `application/backend/app/main.py`, `schemas.py`, `tests/test_api.py`, the Alembic migration, frontend source, Dockerfiles, workflow, chart and Terraform. Explain why SQLite unit tests are isolated and how the Compose/PostgreSQL smoke test verifies the actual database path.

### 2. CI/CD push and full run

Make a small meaningful documentation or UI change, commit and push to the repository's `main` branch. Show the push and the resulting Actions run. Explain the test/security job, both image builds, both Trivy reports, GHCR SHA tags and Kind deployment smoke test. Wait for the run to finish successfully and include that result in the recording. A failed gate must be fixed before claiming success.

```bash
gh run list --repo Json604/devops-heros --workflow helpdesk.yml --branch main --limit 3
gh run watch RUN_ID --repo Json604/devops-heros --exit-status
```

`RUN_ID` means the actual run triggered by your recorded push. Show its URL in the browser.

### 3. Terraform and AWS Console

Show a non-empty reviewed plan **before** apply, then the real apply result. Open the Console in `ap-south-1` and show the VPC, both subnets, active EKS cluster and managed node group. An already-applied plan may have no changes; explain that rather than passing it off as the creation plan.

### 4. Argo CD and GitOps

Promote the successful run's image SHA in `helm/helpdesk/values-release.yaml`, commit and push. Show the actual Argo Application progressing to Synced/Healthy and the Deployments running those tags. The EKS Application tracks `main`. Explain pruning, self-healing and rollback by Git revert.

### 5. Kubernetes and Ingress

```bash
kubectl config current-context
kubectl get nodes
kubectl get pods,deploy,svc,ingress,hpa,pvc -n helpdesk
helm list -n helpdesk
kubectl get application -n argocd
```

Show two ready frontend replicas and at least two ready backend replicas, healthy PostgreSQL, the completed migration job, ClusterIP Services and Ingress routes. A completed one-shot migration Job is expected to show Completed, not Running. Open the application through the Ingress controller port-forward/hostname and create a ticket.

### 6. Prometheus and Grafana

```bash
kubectl port-forward -n helpdesk svc/backend 8001:8000
# In another terminal:
curl -fsS http://localhost:8001/metrics
```

Show both app targets as UP in Prometheus. Refresh application requests and show populated live Grafana panels. Explain the request counter, request rate, and the difference between Prometheus and HPA Metrics Server. Use [the monitoring guide](../session21-final-devops-project/monitoring/README.md) for the EKS-specific port-forwards and dashboard.

### 7. Cleanup and upload

Capture the reviewed destroy plan and its completion. Delete application PVCs while the CSI driver still runs, following the existing cleanup guide. Verify project resources are gone. Export an MP4 with readable text and audible narration, review it start to finish, and commit it under `demo/` if below GitHub's single-file limit or attach it to a GitHub release. Add a working repository-accessible link in `demo/README.md` and the audit.

## Final form check

Use the earlier deadline supplied in the form: **16 October 2026, 11:59 PM**. The reference repository lists a later conflicting date; do not rely on it.

- Email and Scaler email: `kartikey.24bcs10121@sst.scaler.com`
- Full name: use your official full name (the repository currently says Kartikey).
- Group: choose your actual Group A/B; do not infer it from old assignment form links.
- Numeric roll number: `10121`.
- GitHub URL: `https://github.com/Json604/devops-heros` after all final artifacts are on `main` and publicly accessible.

Only one form submission is allowed. The form has not been submitted by this audit.
