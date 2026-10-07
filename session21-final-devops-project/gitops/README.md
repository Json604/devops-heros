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
