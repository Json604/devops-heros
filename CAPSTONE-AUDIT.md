# Final capstone submission audit

**Reviewed 13 October 2026 · Kartikey · 24bcs10121**

**Status: repository deliverables complete.** All ten modules have implementation and verification evidence, including the 12-slide PDF and edited narrated walkthrough MP4. Fresh EKS deployment, GitOps promotion, live application/monitoring capture and complete AWS cleanup were performed on 13 October. The video discloses synthesized narration and editing. No form submission has been made.

## Authoritative requirements

- [Project brief](https://github.com/Nency-Ravaliya/devsecops-python/blob/main/README.md)
- [Ten-module rubric](https://github.com/Nency-Ravaliya/devsecops-python/blob/main/GRADING.md)
- [Submission guidelines](https://github.com/Nency-Ravaliya/devsecops-python/blob/main/SUBMISSION.md)

The referenced repository has `README.md`, `GRADING.md` and `SUBMISSION.md`; its inspected tree has no `student-guide.md`. The two submission documents explicitly require a video and at least eight slides. The earlier statement in our coursework record that presentation was waived has been corrected.

**Deadline:** the supplied Google Form says **16 October 2026, 11:59 PM**, while the repository lists 19 October. Work to the earlier form deadline; confirm any extension directly with the instructor.

## Rubric and evidence mapping

Paths below are relative to `session21-final-devops-project/` unless linked otherwise. Historical evidence describes actual saved results from 7 October, not a currently running cloud cluster. Points are rubric weights, not a promised grade.

| Module | Points | Implementation and evidence | Assessment |
|---|---:|---|---|
| M1 Application | 10 | [FastAPI routes](session21-final-devops-project/application/backend/app/main.py) include GET/POST/PUT/DELETE and health. [Alembic migration](session21-final-devops-project/application/backend/alembic/versions/0001_create_tickets.py) creates tickets. [React source](session21-final-devops-project/application/frontend/src/main.jsx), responsive styles and [fresh browser screenshot](session21-final-devops-project/screenshots/compose-recheck-2026-10-13.png). | Rebuilt stack and real PostgreSQL CRUD passed on 13 October. |
| M2 Tests | 10 | [17 tests](session21-final-devops-project/application/backend/tests/test_api.py), isolated SQLite fixtures and [pytest.ini](session21-final-devops-project/application/backend/pytest.ini). [Fresh passing output](session21-final-devops-project/evidence/recheck-api-tests-2026-10-13.txt), [terminal screenshot](session21-final-devops-project/screenshots/pytest-terminal.png). | All 17 pass. Coverage includes more than three endpoints. |
| M3 Git/GitHub | 5 | Public [repository](https://github.com/Json604/devops-heros), [history screenshot](session21-final-devops-project/screenshots/commit-history-terminal.png), meaningful commits, [.gitignore](.gitignore). | Repository/history present. Form submission remains outstanding. See history scan qualification below. |
| M4 Docker | 10 | [Backend Dockerfile](session21-final-devops-project/application/backend/Dockerfile), [multi-stage frontend Dockerfile](session21-final-devops-project/application/frontend/Dockerfile), non-root UIDs 10001/101, [Compose](session21-final-devops-project/docker-compose.yml), [build screenshot](session21-final-devops-project/screenshots/compose-build-terminal.png) and [fresh build output](session21-final-devops-project/evidence/recheck-compose-2026-10-13.txt). | Build and healthy frontend/backend/PostgreSQL verified. Local frontend uses 3100 because 3000 was occupied; default remains 3000. |
| M5 CI/CD | 15 | [Root workflow](.github/workflows/helpdesk.yml) triggers on main, tests/build gates, both image builds and SHA-tagged GHCR pushes. [Successful main run](https://github.com/Json604/devops-heros/actions/runs/38326250900), [package screenshot](session21-final-devops-project/screenshots/ghcr-backend.jpg). | Hosted execution verified through GitHub API. |
| M6 Security | 5 | Both images have Trivy HIGH/CRITICAL failure gates. [Pipeline screenshot](session21-final-devops-project/screenshots/main-trivy-gate.png), [scan explanation](session21-final-devops-project/security/README.md), fresh [backend](session21-final-devops-project/evidence/recheck-backend-scan-2026-10-13.txt) and [frontend](session21-final-devops-project/evidence/recheck-frontend-scan-2026-10-13.txt) scans. | Both fresh image scans passed the same gate. A clean scan is time- and database-dependent. |
| M7 Terraform/AWS | 15 | [HCL and example variables](session21-final-devops-project/terraform/), real [plan](session21-final-devops-project/evidence/aws-plan.txt), [apply](session21-final-devops-project/evidence/aws-apply.txt), [plan screenshot](session21-final-devops-project/screenshots/aws-plan-terminal.png), [VPC](session21-final-devops-project/screenshots/aws-eks-vpc.png), [EKS](session21-final-devops-project/screenshots/aws-eks-active.png), [destroy](session21-final-devops-project/evidence/aws-destroy.txt), [destroy transcript screenshot](session21-final-devops-project/screenshots/aws-destroy-recorded.png). | Real 20-resource lifecycle recorded. Fresh init/fmt/validate and mocked plan test pass. Fresh AWS redeployment, video capture and verified 20-resource teardown completed on 13 October; see the fresh evidence index below. |
| M8 Kubernetes/Helm | 15 | [Namespace/manifests](session21-final-devops-project/kubernetes/), [chart](session21-final-devops-project/helm/helpdesk/), [deployment evidence](session21-final-devops-project/evidence/eks-verification.txt), [Pods/Services/Helm screenshot](session21-final-devops-project/screenshots/eks-helm-gitops-terminal.png), [Ingress browser screenshot](session21-final-devops-project/screenshots/eks-ingress-release.png). | Recorded two backend and frontend replicas, ClusterIP Services and Ingress. Both base and production Helm lint pass. Completed migration Jobs are expected. |
| M9 Observability | 10 | [Helm values](session21-final-devops-project/monitoring/), [metrics screenshot](session21-final-devops-project/screenshots/eks-metrics-terminal.png), [UP targets](session21-final-devops-project/screenshots/eks-prometheus-targets.png), [populated Grafana](session21-final-devops-project/screenshots/eks-grafana.png). | Fresh EKS monitoring queries and browser captures confirm both backend targets UP and populated Grafana panels. |
| M10 Presentation/docs | 5 | Expanded [root README](README.md), complete [project guide](session21-final-devops-project/README.md), [12-slide PDF](demo/slides.pdf), [MP4 walkthrough](demo/presentation.mp4) and [chapters/transcript](demo/video-notes.md). | Both required artifacts present; synthetic narration and edited captures disclosed. |

### Path differences from the reference

This is a coursework monorepo. `backend/` and `frontend/` live under `session21-final-devops-project/application/`, and `k8s/` is named `kubernetes/`. The active workflow is at repository-root `.github/workflows/helpdesk.yml`. The root README now provides all required technical sections and clear links. The presentation artifacts live at repository-root `demo/`.

### GitOps evidence

Although GitOps has no separate module weight, the required video explicitly includes Argo CD. [The release record](session21-final-devops-project/gitops/README.md#recorded-eks-release-promotion) links the scanned image SHA, promotion commit, Synced/Healthy state and changed deployment/browser output.

### Secret scanning qualification

The full-history Gitleaks scan of 65 commits returned 12 findings in old Session 8 and 12 classroom examples. These are the same historical findings documented in the [existing review](session21-final-devops-project/evidence/history-secret-review.txt). The [fresh raw summary](session21-final-devops-project/evidence/recheck-secret-history-2026-10-13.txt) remains visible; this audit does not claim a zero-finding repository history. The separate [tracked capstone scan](session21-final-devops-project/evidence/recheck-secret-tracked-2026-10-13.txt) passed with no findings. A scan of the whole local directory also detected the intentionally ignored `.env`; `git ls-files` confirms it is untracked. No history rewrite or blanket suppression was performed. The capstone injects its actual database password outside Git; credentials, state and local variables remain ignored.

## Fresh 13 October execution

- [Recorded main pipeline](https://github.com/Json604/devops-heros/actions/runs/38326250900): tests, security, both SHA-tagged images and Kind deployment passed. [Push/CI transcript](session21-final-devops-project/evidence/recheck-push-and-ci-2026-10-13.txt), [scan summary](session21-final-devops-project/evidence/recheck-ci-security-summary-2026-10-13.txt).
- [Terraform apply](session21-final-devops-project/evidence/recheck-aws-apply-2026-10-13.txt): 20 resources created. [EKS Console](session21-final-devops-project/screenshots/recheck-eks-active-2026-10-13.png), [VPC/subnets](session21-final-devops-project/screenshots/recheck-vpc-subnets-2026-10-13.png).
- [GitOps release](session21-final-devops-project/evidence/recheck-gitops-2026-10-13.txt): Argo Synced/Healthy at promotion `400110b`, both images at verified `81797c5`. [Kubernetes](session21-final-devops-project/evidence/recheck-kubernetes-2026-10-13.txt) and [PostgreSQL CRUD](session21-final-devops-project/evidence/recheck-eks-crud-2026-10-13.txt) passed.
- [Prometheus targets](session21-final-devops-project/evidence/recheck-prometheus-targets-2026-10-13.json), [queries](session21-final-devops-project/evidence/recheck-monitoring-queries-2026-10-13.json), [Grafana screenshot](session21-final-devops-project/screenshots/recheck-grafana-2026-10-13.png).
- [Destroy output](session21-final-devops-project/evidence/recheck-aws-destroy-2026-10-13.txt), [completion screenshot](session21-final-devops-project/screenshots/recheck-destroy-2026-10-13.png) and [AWS cleanup checks](session21-final-devops-project/evidence/recheck-aws-cleanup-2026-10-13.json). Application PVCs were removed while the CSI driver was active; the data volume is gone. The empty ingress namespace required finalization after Kubernetes confirmed no remaining content or content finalizers. System PDBs were removed after application deletion to allow disposable worker teardown.

## Form submission remains with the student

Review the [video](demo/presentation.mp4), choose your actual Group A/B, and use your official full name. Numeric roll: `10121`; Scaler email: `kartikey.24bcs10121@sst.scaler.com`; GitHub URL: **https://github.com/Json604/devops-heros**. Submit only once by the earlier form deadline, **16 October 2026, 11:59 PM**. Do not infer the group from old coursework links. The audit does not submit the form or promise a grade.
