# Final capstone submission audit

**Reviewed 13 October 2026 · Kartikey · 24bcs10121**

**Status: not yet fully submission-ready.** The application and DevOps implementation have passing local checks and recorded successful cloud execution. The slide deck is now present. The mandatory live presentation video remains to be recorded and uploaded. No form submission has been made.

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
| M5 CI/CD | 15 | [Root workflow](.github/workflows/helpdesk.yml) triggers on main, tests/build gates, both image builds and SHA-tagged GHCR pushes. [Successful main run](https://github.com/Json604/devops-heros/actions/runs/37662449564), [package screenshot](session21-final-devops-project/screenshots/ghcr-backend.jpg). | Hosted execution verified through GitHub API. |
| M6 Security | 5 | Both images have Trivy HIGH/CRITICAL failure gates. [Pipeline screenshot](session21-final-devops-project/screenshots/main-trivy-gate.png), [scan explanation](session21-final-devops-project/security/README.md), fresh [backend](session21-final-devops-project/evidence/recheck-backend-scan-2026-10-13.txt) and [frontend](session21-final-devops-project/evidence/recheck-frontend-scan-2026-10-13.txt) scans. | Both fresh image scans passed the same gate. A clean scan is time- and database-dependent. |
| M7 Terraform/AWS | 15 | [HCL and example variables](session21-final-devops-project/terraform/), real [plan](session21-final-devops-project/evidence/aws-plan.txt), [apply](session21-final-devops-project/evidence/aws-apply.txt), [plan screenshot](session21-final-devops-project/screenshots/aws-plan-terminal.png), [VPC](session21-final-devops-project/screenshots/aws-eks-vpc.png), [EKS](session21-final-devops-project/screenshots/aws-eks-active.png), [destroy](session21-final-devops-project/evidence/aws-destroy.txt), [destroy transcript screenshot](session21-final-devops-project/screenshots/aws-destroy-recorded.png). | Real 20-resource lifecycle recorded. Fresh init/fmt/validate and mocked plan test pass. Fresh AWS redeployment and video capture are in progress after reauthentication. |
| M8 Kubernetes/Helm | 15 | [Namespace/manifests](session21-final-devops-project/kubernetes/), [chart](session21-final-devops-project/helm/helpdesk/), [deployment evidence](session21-final-devops-project/evidence/eks-verification.txt), [Pods/Services/Helm screenshot](session21-final-devops-project/screenshots/eks-helm-gitops-terminal.png), [Ingress browser screenshot](session21-final-devops-project/screenshots/eks-ingress-release.png). | Recorded two backend and frontend replicas, ClusterIP Services and Ingress. Both base and production Helm lint pass. Completed migration Jobs are expected. |
| M9 Observability | 10 | [Helm values](session21-final-devops-project/monitoring/), [metrics screenshot](session21-final-devops-project/screenshots/eks-metrics-terminal.png), [UP targets](session21-final-devops-project/screenshots/eks-prometheus-targets.png), [populated Grafana](session21-final-devops-project/screenshots/eks-grafana.png). | Recorded EKS monitoring evidence present; fresh local metrics endpoint verified. |
| M10 Presentation/docs | 5 | Expanded [root README](README.md), complete [project guide](session21-final-devops-project/README.md), [12-slide PDF](demo/slides.pdf) and [recording guide](demo/recording-guide.md). | **Incomplete: mandatory live MP4 missing. The rubric awards zero for M10 without it.** |

### Path differences from the reference

This is a coursework monorepo. `backend/` and `frontend/` live under `session21-final-devops-project/application/`, and `k8s/` is named `kubernetes/`. The active workflow is at repository-root `.github/workflows/helpdesk.yml`. The root README now provides all required technical sections and clear links. The presentation artifacts live at repository-root `demo/`.

### GitOps evidence

Although GitOps has no separate module weight, the required video explicitly includes Argo CD. [The release record](session21-final-devops-project/gitops/README.md#recorded-eks-release-promotion) links the scanned image SHA, promotion commit, Synced/Healthy state and changed deployment/browser output.

### Secret scanning qualification

The full-history Gitleaks scan of 65 commits returned 12 findings in old Session 8 and 12 classroom examples. These are the same historical findings documented in the [existing review](session21-final-devops-project/evidence/history-secret-review.txt). The [fresh raw summary](session21-final-devops-project/evidence/recheck-secret-history-2026-10-13.txt) remains visible; this audit does not claim a zero-finding repository history. The separate [tracked capstone scan](session21-final-devops-project/evidence/recheck-secret-tracked-2026-10-13.txt) passed with no findings. A scan of the whole local directory also detected the intentionally ignored `.env`; `git ls-files` confirms it is untracked. No history rewrite or blanket suppression was performed. The capstone injects its actual database password outside Git; credentials, state and local variables remain ignored.

## Required completion before submitting

1. Record and upload the presentation video under `demo/` or as a GitHub release asset. Present the slides first, then the codebase, newly triggered complete CI run, real Terraform/AWS proof, Argo sync, Kubernetes, Prometheus UP targets and live Grafana. Saved screenshots alone do not meet this requirement.
2. For a fresh live AWS segment, reauthenticate the `coursework` profile and redeploy using the existing guide. Record the actual environment and destroy it afterward. The login has been renewed for the fresh recording.
3. Verify the final video URL and all artifacts from public `main`. Update the video status in this audit and `demo/README.md` only after playback review.
4. Enter the correct official full name and Group A/B in the one-shot form. Numeric roll: `10121`; Scaler email: `kartikey.24bcs10121@sst.scaler.com`; repository: `https://github.com/Json604/devops-heros`. Submit only once after checking these fields.
