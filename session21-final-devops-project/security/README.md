# Security scanning

**Name:** Kartikey
**Roll number:** 24bcs10121

```bash
bandit -r application/backend/app -ll
pip-audit -r application/backend/requirements.txt
(cd application/frontend && npm audit --audit-level=high)
gitleaks dir application --redact
trivy image --scanners vuln --severity HIGH,CRITICAL --exit-code 1 campus-helpdesk-backend:local
trivy image --scanners vuln --severity HIGH,CRITICAL --exit-code 1 campus-helpdesk-frontend:local
```

Bandit checks source patterns, dependency audits check published advisories, Gitleaks looks for credential patterns, and Trivy inventories OS/language packages in built images. These checks cover different failure modes. A clean scan means no matching findings in that database at that time, not a guarantee that the application is vulnerability-free.

The first hosted image gate rejected the Python Debian image because of high-severity OS package findings, including util-linux and Perl packages. The runtime was changed to Python Alpine to reduce the affected OS package surface; the gate was not disabled or weakened. The final scan reports record the result after rebuilding.

`trivy.yaml`, `bandit.yaml`, and `gitleaks.toml` document the policy. The workflow uses the corresponding explicit flags, defaults and HIGH/CRITICAL failure threshold. No real Secret manifest is committed. `.env`, private keys, Terraform state and kubeconfigs are ignored by Git. The PostgreSQL password is generated locally and injected by Secret reference.

For example, the initial scan reported **CVE-2026-9538** in `perl-base`, described as denial of service through crafted Archive::Tar headers. The gate inventories installed OS packages even when the Python application does not directly call them. The Alpine runtime removed that affected package; the rebuilt backend and frontend both passed the same HIGH/CRITICAL threshold. See [initial report](../evidence/container-backend-initial.txt) and [hosted scan summary](../evidence/ci-security-summary.txt).
