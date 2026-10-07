# Sessions 13–21: submission record

**Name:** Kartikey

**Roll number:** 24bcs10121

Repository: [Json604/devops-heros, submission branch](https://github.com/Json604/devops-heros/tree/submission/kartikey-10121)

Recorded on 7 October 2026. The [root index](README.md) links every assignment and the [final project](session21-final-devops-project/README.md).

## Completed and verified

| Session | Implementation and observed result |
|---|---|
| 13 | Volume documentation; PVC retained student data across Pod deletion; CPU HPA scaled 1 → 5 → 1; load generator and probe-equipped mini-project. |
| 14 | Broken/fixed manifests and investigations for crashes, pull errors, scheduling, mounts, configuration, DNS, selectors and ports; before/after output. |
| 15 | Notes Helm chart; create/repo/search/install/list/status/get; two upgrades; rollback to revision 1; verification; uninstall. |
| 16 | Calculator app and 7 tests; build artifact; Docker image; GHCR push; two-replica Kubernetes deployment and HTTP check in GitHub Actions. |
| 17 | 17 API tests, frontend build, SAST, SCA, secret scanning, both container scans, security gates, SHA-tagged GHCR publication and Kubernetes deployment. |
| 18 | S3 Terraform implementation; AWS service research; provider initialization, validation and mocked-provider tests. Live AWS work remains pending below. |
| 19 | VPC, two subnets, routes, Security Group, EC2 and S3 code; architecture and commands; validation and mocked-provider tests. Live AWS work remains pending below. |
| 20 | Prometheus application/cAdvisor targets UP; Grafana live metrics; application-down alert reached Firing and service recovered; Argo repaired replica drift. |
| 21 | Campus Helpdesk UI/API/PostgreSQL/migrations; non-root images; ConfigMap/Secret/Ingress/HPA/probes/PVC; Helm; EKS Terraform; monitoring; GitOps; failure recovery. |

[Consolidated local verification](evidence/verification.txt) passed: 7 calculator tests, 17 API tests, frontend production build, both Helm charts, and all three Terraform projects. Terraform tests mock AWS; they are not live cloud operations.

## Successful hosted pipelines

- [Session 16: CI and CD passed](https://github.com/Json604/devops-heros/actions/runs/37625465561)
- [Sessions 17/21: tests, security, GHCR and Kubernetes passed](https://github.com/Json604/devops-heros/actions/runs/37625465559)

Both helpdesk images were published with tag `af5deab26c61c57d991fc5816c6abcc350977e7a`:

```text
ghcr.io/json604/campus-helpdesk-backend:af5deab26c61c57d991fc5816c6abcc350977e7a
ghcr.io/json604/campus-helpdesk-frontend:af5deab26c61c57d991fc5816c6abcc350977e7a
```

The [hosted scan summary](session21-final-devops-project/evidence/ci-security-summary.txt) records zero HIGH/CRITICAL findings for both. The earlier failed gate is retained as evidence of an actual blocked release, followed by remediation. The registry push is verified in Actions logs; the GHCR account-management screenshot was not captured because the local token has no `read:packages` scope. No token permissions were expanded.

## Screenshot index

- [Storage and HPA](session-13-storage-hpa-probes/screenshots/session13.jpg)
- [Troubleshooting](session-14-kubernetes-troubleshooting/screenshots/session14.jpg)
- [Helm lifecycle](session-15-helm/screenshots/session15.jpg)
- [Calculator GitHub pipeline](session-16-github-actions/screenshots/github-actions.jpg)
- [Terraform S3 checks](session18-terraform-iac/screenshots/session18.jpg)
- [Terraform cloud checks](session19-cloud-terraform/screenshots/session19.jpg)
- [GitOps self-heal](session20-monitoring-observability-gitops/screenshots/gitops.jpg)
- [Helpdesk application](session21-final-devops-project/screenshots/helpdesk-compose.jpg)
- [Kubernetes application](session21-final-devops-project/screenshots/helpdesk-kubernetes.jpg)
- [API tests](session21-final-devops-project/screenshots/api-tests.jpg)
- [Kubernetes resources](session21-final-devops-project/screenshots/kubernetes.jpg)
- [DevSecOps pipeline](session21-final-devops-project/screenshots/github-actions.jpg)
- [Security results](session21-final-devops-project/screenshots/security.jpg)
- [Prometheus targets](session21-final-devops-project/screenshots/prometheus-targets.jpg)
- [Grafana dashboard](session21-final-devops-project/screenshots/grafana.jpg)
- [Alert firing output](session21-final-devops-project/screenshots/alerts.jpg)
- [Final troubleshooting](session21-final-devops-project/screenshots/final-troubleshooting.jpg)

Command-output screenshots are browser captures of the recorded transcripts, labeled as such. Application, monitoring and GitHub screenshots capture their live pages. Full text evidence accompanies the screenshots.

## Outstanding external requirements

1. Real AWS S3, EC2/VPC and EKS provisioning, live plans, `apply`, `show`, `output`, Console screenshots and `destroy`. No AWS profile or spending authorization was provided; no paid resources were created. The complete code and commands are ready. [EKS pricing](https://aws.amazon.com/eks/pricing/) includes cluster charges as well as the underlying resources.
2. The instructor's live/recorded presentation and submission-form delivery. These have not been represented as completed.
3. A signed-in GHCR package-page screenshot if required by the grading rubric; successful publication and SHA tags are already documented in hosted logs.

## Running locally

The Compose demonstration runs at [localhost:3100](http://localhost:3100). Kubernetes is in the dedicated `kartikey-devops` Minikube profile. Port-forwards, while active, expose the Kubernetes frontend at 3101, Grafana at 3102, Prometheus at 9090 and Ingress at 8180 (Host header `helpdesk.local`).

To reproduce checks, install Python requirements in a virtual environment and use:

```bash
PYTHON_BIN=/path/to/venv/bin/python HELM_BIN=/path/to/helm bash scripts/verify-coursework.sh
```

Secrets and Terraform state are excluded from Git. The application database is a local demonstration database. Stop Compose with `docker compose -f session21-final-devops-project/docker-compose.yml down`. Delete the disposable cluster with `minikube delete -p kartikey-devops` after saving any additional evidence.
