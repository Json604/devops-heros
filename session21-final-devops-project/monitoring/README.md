# Monitoring and observability

**Name:** Kartikey
**Roll number:** 24bcs10121

The checked-in stack runs Prometheus and Grafana with ConfigMap provisioning. Prometheus scrapes `/metrics` and kubelet cAdvisor through the Kubernetes API using a dedicated read-only ServiceAccount. The dashboard contains request rate/count, CPU cores, memory bytes and application health.

```bash
kubectl create namespace monitoring
SECRET_FILE=$(mktemp)
openssl rand -hex 24 | tr -d '\n' > "$SECRET_FILE"
kubectl create secret generic grafana-admin -n monitoring --from-file=password="$SECRET_FILE"
rm "$SECRET_FILE"
kubectl apply -f monitoring/stack.yaml
kubectl rollout status -n monitoring deployment/prometheus
kubectl rollout status -n monitoring deployment/grafana
kubectl port-forward -n monitoring svc/prometheus 9090:9090
# Another terminal:
kubectl port-forward -n monitoring svc/grafana 3102:3000
```

Prometheus: `http://localhost:9090/targets`. Grafana: `http://localhost:3102/d/campus-helpdesk`. Both observed targets (`helpdesk` and `cadvisor`) were UP. Grafana's anonymous access is Viewer-only for this loopback lab; the admin password is generated, and no dashboard claims sample data as live metrics.

Useful queries:

```promql
up{job="helpdesk"}
sum(rate(http_requests_total{job="helpdesk"}[5m]))
sum(rate(container_cpu_usage_seconds_total{namespace="helpdesk",container!="",container!="POD"}[5m]))
sum(container_memory_working_set_bytes{namespace="helpdesk",container!="",container!="POD"})
```

`alerts.yml` defines application-down and high-error-rate conditions. Prometheus exposes Pending/Firing states in its Alerts page. Alert delivery to email/Slack is not configured. The alert lab temporarily scales the API to zero, records the Firing state, then restores it. `kubectl logs -n helpdesk -l app=helpdesk-backend` provides request logs; `kubectl top pods -n helpdesk` shows sampled resource usage.

Metrics are numeric time series useful for rates, trends and alerting. Logs are discrete records useful for individual events and error context. Traces connect spans across service boundaries and show where request time was spent. Common tools are Prometheus/Grafana for metrics, Loki or Elasticsearch for logs, and OpenTelemetry with Tempo/Jaeger for traces. This project demonstrates metrics and logs; distributed tracing is explained but no trace backend is claimed to be running.

Monitoring asks whether known health conditions hold. Observability helps investigate unknown causes by correlating telemetry with workload changes. Kubernetes adds node metrics, Pod/container metrics, events and readiness signals; HPA Metrics Server is distinct from Prometheus storage.

This lightweight stack uses ephemeral monitoring storage, appropriate for a short lab. For longer retention, add persistent volumes, backups and authenticated access. If using Prometheus Operator instead, enable the chart's optional ServiceMonitor only after installing its CRDs.

Before deliberately scaling the API to zero, pause Argo automated synchronization using the save/restore commands in [the troubleshooting guide](../troubleshooting/README.md), save the backend HPA manifest, and temporarily delete that HPA. Restore two backend replicas, reapply the saved HPA, and restore Argo synchronization after capturing the alert. Run this exercise separately from the troubleshooting challenge. [Recorded firing and recovery](../../session20-monitoring-observability-gitops/evidence/alert-demo.txt).

## EKS: Helm-managed Prometheus and Grafana

The live EKS run used kube-prometheus-stack **92.1.0** and Grafana chart **10.5.15**. Install the Operator and its CRDs before enabling Helpdesk's ServiceMonitor. The ServiceMonitor discovers both backend Pods; this avoids scraping only one load-balanced Service address.

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --version 92.1.0 -n monitoring --create-namespace \
  -f monitoring/prometheus-values.yaml --wait --timeout 8m
kubectl wait --for=condition=Established crd/servicemonitors.monitoring.coreos.com
```

Create `grafana-admin` in `monitoring` outside Git with `username` and `password` keys. Use a random password. Then:

```bash
helm upgrade --install grafana grafana/grafana --version 10.5.15 \
  -n monitoring -f monitoring/grafana-values.yaml \
  --set-file dashboards.coursework.helpdesk.json=monitoring/dashboard-eks.json \
  --wait --timeout 5m
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9191:9090
# Separate terminal:
kubectl port-forward -n monitoring svc/grafana 3192:80
```

The EKS dashboard selects `namespace="helpdesk",service="backend"` because the Operator generates `job="backend"`; the earlier raw stack used `job="helpdesk"`. Reusing the raw-stack selector would give empty request panels. Grafana's Prometheus datasource UID is explicitly set to match the dashboard.

Both backend targets were UP. Request counts/rates, CPU and memory panels contained live data. Counters reset when the release replaces Pods; the decrease in the request-count panel is expected, while `rate()` accounts for counter resets.

- [EKS target screenshot](../screenshots/eks-prometheus-targets.png)
- [EKS Grafana screenshot](../screenshots/eks-grafana.png)
- [Actual target response](../evidence/eks-prometheus-targets.json)
- [Actual metrics](../evidence/eks-metrics.txt)

Services remain ClusterIP and are accessed through loopback port-forwards. Anonymous Grafana access is read-only for the local lab. Monitoring storage is ephemeral and removed during teardown.
