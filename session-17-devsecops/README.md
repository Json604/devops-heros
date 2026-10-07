# Session 17: Complete CI/CD and DevSecOps

**Name:** Kartikey
**Roll number:** 24bcs10121

This session adds security gates and Kubernetes delivery to the Campus Helpdesk application, which continues into Session 21. The `application`, `security`, and `kubernetes` links point to the maintained project files in this repository; they are intentional shared source, not missing deliverables.

```text
Source -> API tests + frontend build -> Bandit SAST -> pip-audit / npm audit
       -> Gitleaks -> Docker build -> Trivy HIGH/CRITICAL gate
       -> GHCR SHA tags -> Kind Kubernetes + Helm -> HTTP verification
```

The active [workflow](../.github/workflows/helpdesk.yml) is mirrored in `.github/workflows/devsecops.yml`. Both images are scanned before either image is published. A nonzero scanner status blocks the job and every dependent publishing/deployment step. There is no `continue-on-error`, CVE exclusion list, or `--ignore-unfixed` bypass. PRs run checks and a disposable deployment without writing registry packages.

| Control | Tool | What it checks |
|---|---|---|
| SAST | Bandit | Risky Python source patterns. |
| SCA | pip-audit and npm audit | Known vulnerabilities in dependency versions. |
| Secret scan | Gitleaks | Credentials and token patterns in project files. |
| Container scan | Trivy | OS and language packages in backend and frontend images. |
| Security gate | Job exit status and `needs` | Blocks publication/deployment on failure. |

Use [application setup](../session21-final-devops-project/README.md) to reproduce the stack. [Security evidence](../session21-final-devops-project/evidence/) includes actual scan output. The pipeline archives test results and container scan reports, and emits `release-values.yaml` with immutable image tags for GitOps promotion.

The hosted Kubernetes environment is temporary and destroyed with the runner. It verifies CD without pretending to be a persistent cloud deployment. Persistent delivery is handled by the final project's Argo CD configuration.

Successful hosted run: [GitHub Actions — tests, security gates, GHCR and Kubernetes deployment](https://github.com/Json604/devops-heros/actions/runs/37625465559). Both final images had zero HIGH/CRITICAL findings in that run.
