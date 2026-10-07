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
