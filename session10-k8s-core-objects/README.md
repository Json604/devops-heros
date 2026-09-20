# Session 10 — Kubernetes Pods, Controllers and Deployment Strategies

**Author:** Kartikey · **Enrollment:** 10121

This folder contains manifests for the Session 10 exercises. Use a running Minikube cluster and run commands from this folder unless a command includes another path. Transient states such as `ContainerCreating` and error transitions can be too brief to capture with a single `get`; use `kubectl get pods -w` and retain the terminal transcript. A manifest being accepted only proves API validation, not that its image can start.

## Cluster check

```sh
kubectl version --output=yaml
kubectl cluster-info
kubectl get nodes -o wide
```

## Pods and lifecycle

`pod.yml` runs standalone Nginx. Apply, inspect (`kubectl get pods -o wide`, `kubectl logs nginx-pod`), and delete it. `pod-invalid-image.yml` intentionally uses a nonexistent tag; inspect `kubectl describe pod` events to see the kubelet's image-pull failure. `hello.yml` runs a short BusyBox batch command (`restartPolicy: Never`); watch it progress to `Succeeded`.

The `pod-lifecycle/` directory contains twelve focused manifests: running, unschedulable pending, succeeded, failed, CrashLoopBackOff, image pull backoff, readiness, liveness, startup probe, init container, app plus sidecar, and graceful termination. Apply one at a time, inspect its events/status/logs, and delete it before proceeding. Some states require watching or waiting (for example, startup/liveness probes); see each manifest's comments and probe timings.

## Controllers

- `replicaset.yml`: three Nginx replicas; delete one Pod and observe a replacement.
- `statefulset.yml`: two ordinal MySQL Pods and per-Pod PVCs. Verify `mysql-0`, `mysql-1` and claims; image startup requires the registry and may take time.
- `daemonset/node-agent-ds.yaml`: one node-exporter Pod per eligible node.
- `01-rolling-update/`: v1 to v2 rollout with `maxSurge: 1`, `maxUnavailable: 0`, then `rollout undo`.
- `02-blue-green/`: two versions with a Service selector cutover and rollback.
- `03-canary/`: stable and canary versions share a Service; replica counts approximate endpoint selection ratios, not guaranteed request percentages.
- `04-recreate/`: service interruption while the old replica set terminates before the new one starts.
- `troubleshooting/`: broken image rollout plus selector validation example and corrected manifest.

Troubleshooting commands (keep the healthy baseline backend running before Drill 1):

```sh
kubectl apply -f troubleshooting/broken-image.yaml
kubectl rollout status deployment/yatri-backend --timeout=30s || true
kubectl get pods -l app=yatri-app,tier=backend
kubectl rollout undo deployment/yatri-backend
kubectl rollout status deployment/yatri-backend
kubectl apply -f troubleshooting/selector-mismatch.yaml  # expected API validation failure
kubectl apply -f troubleshooting/selector-mismatch-fixed.yaml
kubectl delete -f troubleshooting/selector-mismatch-fixed.yaml
```

## Concepts

### Port names

`containerPort` documents the port a container process listens on. A Service's `targetPort` selects that destination port on a Pod; Service `port` is the port clients use on the Service IP; `nodePort` exposes a high port on each node for a NodePort Service. Typical path: `client → nodeIP:30080 → serviceIP:8080 → podIP:80`.

### Labels and selectors

Labels are key/value metadata on objects. Selectors are queries matching labels; Services use them to build endpoints and workload controllers use them to manage Pods. A controller's selector must match its Pod template labels.

### Deployment strategies

- **RollingUpdate:** replace replicas gradually; `maxSurge` bounds extra Pods and `maxUnavailable` bounds unavailable desired replicas.
- **Recreate:** terminate old replicas before creating the new version; this creates downtime.
- **Blue/green:** keep two complete versions and switch a Service selector. Rollback is another selector switch, with roughly double capacity during coexistence.
- **Canary:** run a small new-version replica pool beside stable replicas. A basic Service spreads connections among endpoints; replica ratio is only an approximation of request share.

With four replicas, `maxSurge: 1` permits up to five total Pods and `maxUnavailable: 0` requires all four desired replicas to remain available during the rollout. Percentages round up for surge and down for unavailable. Requests are scheduler placement minima; limits are runtime ceilings. CPU over limit is throttled; memory over limit can cause OOM termination. `1 GB = 1,000,000,000 bytes`; `1 GiB = 1,073,741,824 bytes`.

## Exercise commands

```sh
kubectl apply -f pod.yml
kubectl get pods -o wide
kubectl logs nginx-pod
kubectl delete -f pod.yml

kubectl apply -f pod-lifecycle/06-imagepullbackoff.yaml
kubectl get pod lifecycle-image-error -w
kubectl describe pod lifecycle-image-error
kubectl delete -f pod-lifecycle/06-imagepullbackoff.yaml

kubectl apply -f 01-rolling-update/deployment-v1.yaml
kubectl apply -f 01-rolling-update/service.yaml
kubectl rollout status deployment/app-rolling
kubectl apply -f 01-rolling-update/deployment-v2.yaml
kubectl rollout status deployment/app-rolling
kubectl rollout history deployment/app-rolling
kubectl rollout undo deployment/app-rolling
kubectl delete -f 01-rolling-update/service.yaml -f 01-rolling-update/deployment-v1.yaml
```

For the ReplicaSet, wait on `.status.readyReplicas` rather than `kubectl rollout status` (that command does not implement ReplicaSet status): `kubectl wait --for=jsonpath='{.status.readyReplicas}'=3 rs/nginx-rs --timeout=120s`.

Clean up each applied manifest after its exercise. For StatefulSet storage, deleting the StatefulSet does not necessarily delete its PVCs; inspect and remove the lab's claims explicitly when finished.

## Observed lab results

The Minikube node reported `Ready` on Kubernetes `v1.37.0`. The Nginx Pod became `1/1 Running`, and the BusyBox batch Pod was observed by `kubectl get pods -w` moving through `Pending`, `ContainerCreating`, `Running`, and `Completed`; its log was `hello-from-busybox`. The impossible memory request produced a `FailedScheduling` event (`Insufficient memory`). The invalid Nginx tag produced both `ErrImagePull` and `ImagePullBackOff` events. The init container completed before its app container, and the sidecar Pod reached `2/2 Running`.

The liveness probe emitted `Unhealthy` and `Killing` events and the Pod restart count reached `1`. The lifecycle manifest pass also observed: `01-running` as `1/1 Running`; `02-pending` with `FailedScheduling` / `Insufficient memory`; `03-succeeded` as `Completed` with `succeeded` in its log; `04-failed` as `Error` with exit output `failing`; `05-crashloopbackoff` with restart/backoff events; `06-imagepullbackoff` progressing through `ErrImagePull` and `ImagePullBackOff`; `07-readiness` as `Running 0/1` before becoming `1/1`; `09-startup` as `1/1 Running` after its eight-second bootstrap; `10-init-container` as `1/1 Running` after the setup init container; and `11-multi-container` as `2/2 Running` with `sidecar-alive` logs. Deleting `12-termination` printed `received SIGTERM` and `shutdown-complete` before the pod was removed. The MySQL StatefulSet reached `2/2 Running`; `data-mysql-0` and `data-mysql-1` were both `Bound` PVCs. The node-exporter DaemonSet reached `1/1` desired/current/ready on the single Minikube node. ReplicaSet deletion was followed by a replacement while the ready replica count returned to three.

The rolling update completed at revisions 1 and 2, and `rollout undo` restored the earlier revision. Blue/green requests returned `BLUE v1`, then `GREEN v2`, then `BLUE v1` after rollback. The canary sample returned both `STABLE v1` and `CANARY v2` with nine stable and one canary endpoint; the exercise then scaled to seven/three and back to nine/zero. During the Recreate update, the traffic loop recorded `[OUTAGE] no ready endpoint` between `VERSION: v1` and `VERSION: v2 (UPGRADED)`. The broken-image drill showed two old backend Pods still running beside one `ErrImagePull` Pod; rollback restored the working revision. The invalid selector manifest was rejected with `selector does not match template labels`, and the corrected manifest was accepted.

## Screenshot evidence

Capture genuine terminal screenshots in `screenshots/` showing both the command and the observed output. The captures below show terminal commands and observed results:

- [01-cluster-health.png](./screenshots/01-cluster-health.png), [02-nginx-pod-operations.png](./screenshots/02-nginx-pod-operations.png), [03-imagepullbackoff-error.png](./screenshots/03-imagepullbackoff-error.png), [04-pod-lifecycle-stages.png](./screenshots/04-pod-lifecycle-stages.png)
- [05-lifecycle-probes-crashloop.png](./screenshots/05-lifecycle-probes-crashloop.png), [05-lifecycle-init-multicontainer.png](./screenshots/05-lifecycle-init-multicontainer.png), [06-controllers-rs-statefulset.png](./screenshots/06-controllers-rs-statefulset.png), [07-daemonset-verification.png](./screenshots/07-daemonset-verification.png)
- [08-rolling-update-and-rollback.png](./screenshots/08-rolling-update-and-rollback.png), [09-troubleshooting-drills.png](./screenshots/09-troubleshooting-drills.png), [11-blue-green-cutover.png](./screenshots/11-blue-green-cutover.png), [12-canary-traffic-split.png](./screenshots/12-canary-traffic-split.png), [13-recreate-downtime-outage.png](./screenshots/13-recreate-downtime-outage.png)
