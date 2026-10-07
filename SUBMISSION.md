# Sessions 13–21: submission record

**Name:** Kartikey

**Roll number:** 24bcs10121

Repository: [Json604/devops-heros, submission branch](https://github.com/Json604/devops-heros/tree/submission/kartikey-10121)

Recorded on 7 October 2026. The [root index](README.md) links every assignment and the [final project](session21-final-devops-project/README.md).

## Completed and verified

| Session | Implementation and observed result |
|---|---|
| 13 | Volume documentation; PVC retained student data across Pod deletion; CPU HPA scaled 1 → 5 → 1; load generator and probe-equipped mini-project, separately scaled 2 → 5 → 2 under HTTP load. |
| 14 | Broken/fixed manifests and investigations for crashes, pull errors, scheduling, mounts, configuration, DNS, selectors and ports; before/after output. |
| 15 | Notes Helm chart; create/repo/search/install/list/status/get; production upgrade; deliberately broken image upgrade; rollback to working revision 2; three healthy production replicas; uninstall. |
| 16 | Calculator app and 7 tests; build artifact; Docker image; GHCR push; two-replica Kubernetes deployment and HTTP check in GitHub Actions. |
| 17 | 17 API tests, frontend build, SAST, SCA, secret scanning, both container scans, security gates, SHA-tagged GHCR publication and Kubernetes deployment. |
| 18 | S3 Terraform implementation and AWS research; real AWS plan/apply/show/output completed; 5 resources created and destroyed; Console screenshots and cleanup verification saved. |
| 19 | VPC, two subnets, routes, Security Group, EC2 and S3 provisioned on AWS; browser/HTTP verification passed; all 14 resources destroyed; screenshots and cleanup verification saved. |
| 20 | Prometheus application/cAdvisor targets UP; Grafana live metrics; application-down alert reached Firing and service recovered; Argo repaired replica drift. |
| 21 | Campus Helpdesk UI/API/PostgreSQL/migrations; non-root images; ConfigMap/Secret/Ingress/HPA/probes/PVC; Helm; EKS Terraform; monitoring; GitOps; failure recovery. |

[Consolidated local verification](evidence/verification.txt) passed: 7 calculator tests, 17 API tests, frontend production build, both Helm charts, and all three Terraform projects. Terraform tests mock AWS; they are not live cloud operations.

## Successful hosted pipelines

- [Session 16: CI and CD passed](https://github.com/Json604/devops-heros/actions/runs/37628858550)
- [Sessions 17/21: tests, security, GHCR and Kubernetes passed](https://github.com/Json604/devops-heros/actions/runs/37628858501)

Both helpdesk images were published with tag `6c333d1aa10b8d5ebc9961ff04d0707bae371e84`:

```text
ghcr.io/json604/campus-helpdesk-backend:6c333d1aa10b8d5ebc9961ff04d0707bae371e84
ghcr.io/json604/campus-helpdesk-frontend:6c333d1aa10b8d5ebc9961ff04d0707bae371e84
```

The [hosted scan summary](session21-final-devops-project/evidence/ci-security-summary.txt) records zero HIGH/CRITICAL findings for both. The earlier failed gate is retained as evidence of an actual blocked release, followed by remediation. The registry push is verified in Actions logs and the public [GHCR package listing](https://github.com/Json604?tab=packages). A [package-page screenshot](session21-final-devops-project/screenshots/ghcr-packages.jpg) is included.

## Screenshot index

- [Storage and HPA](session-13-storage-hpa-probes/screenshots/session13.jpg)
- [Troubleshooting](session-14-kubernetes-troubleshooting/screenshots/session14.jpg)
- [Helm lifecycle](session-15-helm/screenshots/session15.jpg)
- [Calculator GitHub pipeline](session-16-github-actions/screenshots/github-actions.jpg)
- [Terraform S3 checks](session18-terraform-iac/screenshots/session18.jpg)
- [Live S3 creation and cleanup](session18-terraform-iac/screenshots/aws-lifecycle.jpg)
- [Live EC2/VPC/S3 creation and cleanup](session19-cloud-terraform/screenshots/aws-lifecycle.jpg)
- [Terraform cloud checks](session19-cloud-terraform/screenshots/session19.jpg)
- [GitOps self-heal](session20-monitoring-observability-gitops/screenshots/gitops.jpg)
- [Helpdesk application](session21-final-devops-project/screenshots/helpdesk-compose.jpg)
- [Kubernetes application](session21-final-devops-project/screenshots/helpdesk-kubernetes.jpg)
- [API tests](session21-final-devops-project/screenshots/api-tests.jpg)
- [Kubernetes resources](session21-final-devops-project/screenshots/kubernetes.jpg)
- [DevSecOps pipeline](session21-final-devops-project/screenshots/github-actions.jpg)
- [Published GHCR packages](session21-final-devops-project/screenshots/ghcr-packages.jpg)
- [Security results](session21-final-devops-project/screenshots/security.jpg)
- [Prometheus targets](session21-final-devops-project/screenshots/prometheus-targets.jpg)
- [Grafana dashboard](session21-final-devops-project/screenshots/grafana.jpg)
- [Alert firing output](session21-final-devops-project/screenshots/alerts.jpg)
- [Final troubleshooting](session21-final-devops-project/screenshots/final-troubleshooting.jpg)

Command-output screenshots are browser captures of the recorded transcripts, labeled as such. Application, monitoring and GitHub screenshots capture their live pages. Full text evidence accompanies the screenshots.

## Outstanding external requirements

1. Session 21 remains separate: EKS provisioning and its plan/Console/destroy evidence have not been completed. Sessions 18 and 19 live AWS requirements are complete and their resources were removed. The Session 21 review also identified production ServiceMonitor prerequisites, specific screenshots, and the persistent release demonstration still to address.
2. The instructor's live/recorded presentation and submission-form delivery. These have not been represented as completed.

## Running locally

The Compose demonstration runs at [localhost:3100](http://localhost:3100). Kubernetes is in the dedicated `kartikey-devops` Minikube profile. Port-forwards, while active, expose the Kubernetes frontend at 3101, Grafana at 3102, Prometheus at 9090 and Ingress at 8180 (Host header `helpdesk.local`).

To reproduce checks, install Python requirements in a virtual environment and use:

```bash
PYTHON_BIN=/path/to/venv/bin/python HELM_BIN=/path/to/helm bash scripts/verify-coursework.sh
```

Secrets and Terraform state are excluded from Git. The application database is a local demonstration database. Stop Compose with `docker compose -f session21-final-devops-project/docker-compose.yml down`. Delete the disposable cluster with `minikube delete -p kartikey-devops` after saving any additional evidence.
