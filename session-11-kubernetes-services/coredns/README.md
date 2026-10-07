# CoreDNS and Service discovery

**Kartikey — 24bcs10121**

CoreDNS is the DNS server used by this lab cluster. Its Kubernetes plugin watches API objects and answers queries for cluster Services and endpoints. The `kube-dns` Service gives Pods a stable DNS address even when CoreDNS Pods change.

A Pod sends a lookup to the nameserver in `/etc/resolv.conf`. For a cluster Service name, CoreDNS returns its ClusterIP, ready endpoint addresses for a headless Service, or the configured ExternalName alias. Queries outside the configured cluster zone are forwarded to upstream resolvers. Caching reduces repeated lookups. DNS supplies discovery; Service routing is a separate networking function.

## Configuration

The `coredns` ConfigMap in `kube-system` contains the Corefile. Common plugins include `kubernetes` (cluster zone), `forward` (upstream queries), `cache`, `errors`, `health`, `ready`, `loop` and `reload`. Inspect the actual Corefile before changing it; resolver addresses and cluster domains vary.

```bash
kubectl -n kube-system get configmap coredns -o yaml
kubectl -n kube-system get pods -l k8s-app=kube-dns -o wide
kubectl -n kube-system get service kube-dns
kubectl -n kube-system get endpointslices -l kubernetes.io/service-name=kube-dns
kubectl -n kube-system logs -l k8s-app=kube-dns --tail=50
kubectl exec curl-client -- cat /etc/resolv.conf
kubectl exec curl-client -- nslookup kubernetes.default.svc.cluster.local.
```

## Troubleshooting sequence

1. Check the query spelling, namespace and cluster domain. Compare short and absolute names.
2. Inspect the client resolver. With `ndots:5`, many external names first try search suffixes; a final dot avoids that expansion.
3. Check CoreDNS Pod readiness, the DNS Service and its EndpointSlices. No ready endpoints means DNS requests cannot reach a server.
4. Compare an internal query with an external query. Internal success with external failure points toward forwarding/upstream access.
5. Inspect CoreDNS logs and Corefile; check NetworkPolicies and UDP/TCP port 53 connectivity.
6. If DNS resolves but HTTP fails, inspect the application's Service selector, ready endpoints and target port instead of changing DNS.

The [recorded lab](../README.md#observed-lab-results) resolved both Service and external names. See [resolver configuration](../screenshots/08.1-resolv-conf.png) and [CoreDNS resolution](../screenshots/08.2-coredns-resolution.png). These commands are diagnostic guidance; they do not claim every possible fault was induced.

Reference: [Kubernetes DNS debugging](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/).
