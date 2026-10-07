# Kubernetes volumes

**Name:** Kartikey  
**Roll number:** 24bcs10121

| Object | Purpose | Lifetime / limitations |
|---|---|---|
| `emptyDir` | Share scratch files between containers in one Pod. | Survives a container restart; removed when the Pod is deleted. `medium: Memory` uses RAM. |
| `hostPath` | Mount a directory from the node. | Data depends on that node; rescheduling elsewhere changes the filesystem. Broad host access is risky. |
| PersistentVolume (PV) | Cluster-scoped provisioned storage with capacity, access modes and reclaim policy. | Independent of an individual Pod. `Retain` requires manual recovery; `Delete` can delete backing storage. |
| PersistentVolumeClaim (PVC) | Namespaced request for storage. | Binds to a matching PV; a Pod mounts the claim. |
| StorageClass | Describes a provisioner, parameters, reclaim policy and binding mode. | A default class can satisfy PVCs without explicitly naming a class. |
| Dynamic provisioning | Provisioner creates storage when a PVC needs it. | Requires a working storage driver; `WaitForFirstConsumer` delays allocation until placement is known. |

```bash
kubectl apply -f ../01-volumes/emptydir-pod.yaml
kubectl describe pod emptydir-demo
kubectl apply -f ../01-volumes/hostpath-pod.yaml
kubectl get pv,pvc,storageclass
kubectl explain persistentvolume.spec
kubectl explain persistentvolumeclaim.spec
kubectl apply -f ../02-persistent-storage/pv.yaml
kubectl apply -f ../02-persistent-storage/pvc.yaml
kubectl apply -f ../02-persistent-storage/pod.yaml
```

Inspect each manifest's resource name before using `exec`. The static PV example uses node-local storage, suitable for a single-node learning cluster. Dynamic provisioning is demonstrated by the mini-project's PVC and Minikube's `standard` class. A real multi-node application should use a CSI driver and the correct access mode.

`ReadWriteOnce` allows a volume to be mounted read/write on one **node**, not necessarily one Pod. The two mini-project Pods can share it on single-node Minikube. This is not a portable multi-node shared-write design; use RWX-capable storage or separate claims for that case. The final project instead keeps PostgreSQL on one StatefulSet replica with its own PVC, while stateless API replicas share the database through its Service.

Reference: [Kubernetes volumes](https://kubernetes.io/docs/concepts/storage/volumes/) and [persistent volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/).
