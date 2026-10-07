# GitOps deployment

**Name:** Kartikey
**Roll number:** 24bcs10121

Git contains the declared desired state. Argo CD reads it continuously, renders the Helm chart and compares it with the cluster. Automated synchronization applies changes; `selfHeal` repairs manual drift and `prune` removes resources deleted from desired state.

```bash
kubectl create namespace argocd
kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.5.4/manifests/install.yaml
bash scripts/create-secret.sh helpdesk
kubectl apply -f gitops/application.yaml
kubectl get application campus-helpdesk -n argocd
```

The local Application tracks the actual submission branch and uses the chart's locally loaded images. Keep the externally created database Secret in the namespace; it is deliberately outside Git. Argo renders Helm templates but owns reconciliation; stop manually running Helm upgrades on the same resources after this handoff.

For a published release, download the successful pipeline's `release-values.yaml`, review the SHA tags, update `helm/helpdesk/values.yaml` (or commit a dedicated values file and add it to `valueFiles`), then commit and push. Argo observes the Git change and deploys those scanned images. Do not use mutable `latest` tags. If GHCR images are private, create an image pull Secret out of band and set `imagePullSecrets`.

To verify drift correction, scale `helpdesk-frontend` manually to three replicas and watch it return to the two replicas declared in Git. The backend's replicas are deliberately omitted when HPA is enabled so GitOps does not fight the autoscaler. The migration Job is an Argo Sync hook with BeforeHookCreation cleanup, allowing migrations before readiness succeeds on each sync.

For a Git rollback, revert the release-tag commit and push. Database changes need a compatible migration strategy; reverting application images does not automatically reverse schema changes.

During the local run, Docker Desktop's upstream DNS intermittently returned NXDOMAIN for `github.com`, causing Argo `ComparisonError` while application Pods stayed healthy. A lookup against `1.1.1.1` succeeded. The dedicated lab cluster's CoreDNS forwarding was changed to `1.1.1.1 8.8.8.8`, then CoreDNS was restarted and both Applications refreshed. This changed only the newly created lab cluster, not the workstation DNS settings.

## Recorded EKS release promotion

The [main-branch pipeline](https://github.com/Json604/devops-heros/actions/runs/37659251965) successfully tested, scanned and published both images for commit `328f4c59f80884906604ab4b03fd345754bf1e00`. Its user-visible change replaced the header text with “Report campus IT issues and follow each request to resolution.”

Promotion commit `9d7f9c4eca33523505070b31f124023ddd6493f5` records these immutable tags in `helm/helpdesk/values-release.yaml`. `application-eks.yaml` tracks `main` and combines base, production and release values. It is a separate Application from the local Minikube demo.

```bash
kubectl apply -f gitops/application-eks.yaml
kubectl -n argocd get application campus-helpdesk-eks
kubectl -n helpdesk get deploy -o wide
```

Argo reported **Synced / Healthy** at the promotion commit. The EKS Deployments used both published SHA tags, and the browser through the Ingress hostname showed the new text while retaining the database ticket. Promotion is an explicit reviewed Git commit, not an automatic mutation by the build job. After Argo takes ownership, Helm release history records the initial bootstrap only; subsequent reconciliation belongs to Argo.

- [Release verification commands/output](../evidence/eks-release-verification.txt)
- [Argo state](../evidence/eks-gitops-release.json)
- [Deployed image specifications](../evidence/eks-deployments.json)
- [Updated application screenshot](../screenshots/eks-ingress-release.png)

The cloud Application was deleted before its namespace during cleanup so reconciliation could not recreate the resources. The PostgreSQL PVC/EBS volume was removed while the CSI driver was still running, before destroying EKS.
