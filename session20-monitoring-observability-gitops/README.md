# Session 20: Monitoring, observability and GitOps

**Name:** Kartikey  
**Roll number:** 24bcs10121

The monitoring demo uses the final project's running helpdesk so CPU, memory, request and health data come from a real application. [Monitoring manifests, queries and startup commands](../session21-final-devops-project/monitoring/README.md), [actual target results](evidence/prometheus-targets.json).

## Three pillars

- Metrics: numeric observations over time, such as request rate, error rate, CPU and memory; useful for dashboards and alerts.
- Logs: timestamped application or system events; useful for understanding one failure and its context.
- Traces: spans linked to one distributed request; useful for separating database time, network time and service processing time.

Prometheus/Grafana, Loki/Elasticsearch and OpenTelemetry/Jaeger/Tempo are common tools for these pillars. Kubernetes adds events, resource conditions and per-container telemetry. HPA's Metrics Server supplies resource metrics for autoscaling but is not a historical monitoring database. Observability combines evidence to explain why behavior changed, rather than only reporting that a health check failed.

## GitOps demo

`gitops/app/` declares an Nginx Deployment with two replicas and a Service. `gitops/application.yaml` points Argo CD at this exact repository and submission branch.

```bash
kubectl apply -f gitops/application.yaml
kubectl get application session20-web -n argocd
kubectl get pods,svc -n gitops-lab
kubectl scale deployment/gitops-web -n gitops-lab --replicas=3
kubectl get deployment/gitops-web -n gitops-lab --watch
```

The intended state remains two replicas in Git. Self-heal restores two after the manual scale creates drift. To deliberately change the deployment, edit the YAML, commit, push and let Argo reconcile. This makes Git the source of truth, with reviewable history and reversion. Secrets are generated outside Git; encoded Secret data is not protected merely because it is base64.

The final application's [GitOps guide](../session21-final-devops-project/gitops/README.md) connects scanned image tags to Helm deployment. See `evidence/` and `screenshots/` for recorded monitoring and reconciliation output.
