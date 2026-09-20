# Session 12 — ConfigMaps, Secrets and Ingress

**Author:** Kartikey · **Enrollment:** 10121

Lab manifests live beside this README. Apply them to a running cluster; Terminal evidence from this run is linked below. Values in the example Secret are public lab-only credentials and must never be reused. Kubernetes Secret data is base64-encoded by the API representation; base64 is not encryption.

## ConfigMaps and Secret injection

`01-configmap/app-config.yaml` demonstrates five non-sensitive settings. `02-secret/db-secret.yaml` uses `stringData` so the sample plaintext credentials are encoded by the API on write. The full demo backend imports ConfigMap keys as environment variables and imports credentials from Secret keys.

```sh
kubectl apply -f 01-configmap/app-config.yaml
kubectl describe configmap yatri-app-config
kubectl get configmap yatri-app-config -o jsonpath='{.data.ENVIRONMENT}'; echo
kubectl apply -f 02-secret/db-secret.yaml
kubectl describe secret yatri-db-secret
kubectl get secret yatri-db-secret -o jsonpath='{.data.POSTGRES_PASSWORD}' | base64 --decode; echo
```

Environment variables are fixed when a container starts. Updating a ConfigMap does not rewrite an already-running process environment; recreate Pods with a rollout restart. Mounted ConfigMap volumes have different update behavior and may refresh eventually.

```sh
kubectl apply -f 04-full-demo/backend.yaml
kubectl rollout status deployment/yatri-backend
kubectl exec deploy/yatri-backend -- env | grep ENVIRONMENT
kubectl patch configmap yatri-app-config --type merge -p '{"data":{"ENVIRONMENT":"staging"}}'
kubectl exec deploy/yatri-backend -- env | grep ENVIRONMENT
kubectl rollout restart deployment/yatri-backend
kubectl rollout status deployment/yatri-backend
kubectl exec deploy/yatri-backend -- env | grep ENVIRONMENT
kubectl apply -f 04-full-demo/configmap.yaml
```

The trailing newline gotcha can be reproduced without storing a password:

```sh
echo "secretpassword" | xxd
echo "secretpassword" | base64
echo -n "secretpassword" | xxd
echo -n "secretpassword" | base64
```

The first byte stream includes `0a`; the `-n` form does not. Prefer `printf %s` for exact bytes.

## Enterprise secret flow

Committing Secret manifests exposes credentials to anyone with repository/history access; deleting a later revision does not remove old Git objects or copies. Rotation and least-privilege access become difficult. In production, use an external secret manager and short-lived access policies. External Secrets Operator (ESO) can read AWS Secrets Manager, Azure Key Vault, or Vault and reconcile selected values into Kubernetes Secrets. Vault Agent Injector can authenticate a Pod and render secrets into an in-memory shared volume. A CI pipeline can retrieve credentials from GitHub Actions Secrets or Azure DevOps Variable Groups at deploy time, pass them through protected pipeline inputs, and avoid committing the resulting value. Restrict pipeline logs, environment scope, and cluster RBAC; rotate exposed credentials.

```text
AWS Secrets Manager / Azure Key Vault / HashiCorp Vault
                         │ workload identity / scoped auth
                         ▼
         ESO controller or Vault Agent Injector
                         │ reconcile / render
                         ▼
          Kubernetes Secret or memory-backed file
                         │ RBAC-scoped Pod reference
                         ▼
                    Application Pod
```

## Ingress resource and controller

| Ingress resource | Ingress controller |
|---|---|
| Declarative API object containing hosts, paths, TLS secret references and backend Services. | Running proxy/controller (for example ingress-nginx) watching the API and configuring network traffic. |
| Stored by the API server; alone it does not route packets. | Implements the rules and serves the traffic. |

Path routing in `04-full-demo/ingress.yaml` maps `/` to the frontend and `/api/...` to the backend. `03-ingress/ingress-tls.yaml` combines host-based rules with path rules for two campus hostnames and references a TLS Secret.

```sh
minikube addons enable ingress
kubectl wait --namespace ingress-nginx --for=condition=Ready pod --selector=app.kubernetes.io/component=controller --timeout=180s
kubectl get pods,services -n ingress-nginx
```

The workstation mapping exercise is `MINIKUBE_IP=$(minikube ip); echo "$MINIKUBE_IP yatri.local" | sudo tee -a /etc/hosts`, then verify with `grep yatri.local /etc/hosts`. Remove the entry after the lab because the Minikube address can change. For local routing checks without a persistent hosts-file edit, pass `-H 'Host: yatri.local'` or use curl `--resolve`.

## End-to-end demo

```sh
bash 04-full-demo/run-demo.sh
kubectl get configmap,secret,ingress,deploy,svc,pods -l app=yatri-app
kubectl exec deploy/yatri-backend -- env | grep -E 'ENVIRONMENT|LOG_LEVEL|POSTGRES|DEFAULT_CURRENCY'
MINIKUBE_IP=$(minikube ip)
curl -s -H 'Host: yatri.local' "http://${MINIKUBE_IP}/" | grep -i title
curl -s -H 'Host: yatri.local' "http://${MINIKUBE_IP}/api/"
```

For host-based HTTPS, create a local self-signed certificate and TLS Secret (do not commit `tls.key`):

```sh
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj '/CN=campus.local/O=CampusDevOps'
kubectl create secret tls campus-tls-cert --cert=tls.crt --key=tls.key
kubectl apply -f 03-ingress/ingress-tls.yaml
MINIKUBE_IP=$(minikube ip)
curl -k --resolve "portal.campus.local:443:${MINIKUBE_IP}" https://portal.campus.local/
```

Clean the demo resources with `bash 04-full-demo/cleanup.sh`. The TLS Secret is intentionally not removed by this script because it is created separately.

## Observed lab results

`run-demo.sh` created the ConfigMap, Secret, two-replica frontend and backend Deployments, their ClusterIP Services, and `yatri-ingress`; both Deployments reached `2/2 Available`. `kubectl exec` showed the ConfigMap values and Secret credentials in the backend environment. After patching `ENVIRONMENT=staging`, the existing Pods still printed `ENVIRONMENT=production`; a rollout restart changed the new Pods to `ENVIRONMENT=staging`. The demo was restored to production before cleanup.

The frontend and backend manifests each use `---` to separate two YAML documents: a Deployment followed by its Service. `kubectl apply -f` processes both documents from one file, which keeps each small application pair together without combining their independent resource lifecycles.

Ingress controller readiness succeeded. With a local `kubectl port-forward`, Host-header requests to `yatri.local/` returned the Nginx welcome title and `/api/` returned the backend JSON. The campus TLS Ingress returned the frontend page and backend JSON over HTTPS after the self-signed certificate included SANs for both hosts. The initial CN-only certificate did not match those hostnames, so it was replaced with a SAN-bearing certificate before the successful check. The full demo cleanup script then deleted its app resources; the separately created campus Ingress and TLS Secret were also removed.

## Screenshots

These screenshots show the required terminal evidence from this cluster:

- [01-configmap-inspection.png](./screenshots/01-configmap-inspection.png), [02-configmap-live-update.png](./screenshots/02-configmap-live-update.png), [03-secret-decode.png](./screenshots/03-secret-decode.png), [04-trailing-newline.png](./screenshots/04-trailing-newline.png)
- [05-secret-management-architecture.png](./screenshots/05-secret-management-architecture.png), [06-configmap-secret-injection.png](./screenshots/06-configmap-secret-injection.png), [07-ingress-resource-controller.png](./screenshots/07-ingress-resource-controller.png), [08-ingress-controller-ready.png](./screenshots/08-ingress-controller-ready.png)
- [09-local-dns-resolution.png](./screenshots/09-local-dns-resolution.png), [10-path-routing.png](./screenshots/10-path-routing.png), [11-virtual-host-routing.png](./screenshots/11-virtual-host-routing.png), [12-hybrid-ingress-routing.png](./screenshots/12-hybrid-ingress-routing.png)
- [13-ingress-tls.png](./screenshots/13-ingress-tls.png), [14-full-demo-and-cleanup.png](./screenshots/14-full-demo-and-cleanup.png)

The `/etc/hosts` edit was not performed; local routing was verified with Host headers through port-forwarding.
