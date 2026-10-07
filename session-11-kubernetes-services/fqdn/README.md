# Fully qualified domain names in Kubernetes

**Kartikey — 24bcs10121**

An FQDN identifies a name through its complete DNS hierarchy. A Kubernetes Service normally has the name `<service>.<namespace>.svc.<cluster-domain>`. In this lab the cluster domain is `cluster.local`; it is configurable, not universal.

For the ClusterIP exercise, `web-service-clusterip.default.svc.cluster.local` resolves to the Service's stable virtual IP. A Pod in `default` can use `web-service-clusterip`; a Pod in another namespace should use `web-service-clusterip.default` or the complete name. The client's `/etc/resolv.conf` contains search suffixes used to expand short names. A trailing dot explicitly makes a query absolute.

```bash
kubectl exec curl-client -- cat /etc/resolv.conf
kubectl exec curl-client -- nslookup web-service-clusterip.default.svc.cluster.local.
kubectl exec curl-client -- wget -qO- http://web-service-clusterip.default.svc.cluster.local:8080/
```

DNS resolves a name to an address; it does not open a port or repair a Service selector. After resolution, the Service forwards traffic to ready Pod endpoints on its configured target port.

A headless Service returns Pod addresses instead of a virtual IP. With a StatefulSet, a member is reachable as `web-stateful-0.web-service-headless.default.svc.cluster.local`. ExternalName instead supplies a CNAME, and HTTP Host/TLS names still need to match the external server.

The executed lookup and HTTP results are recorded in the [main lab](../README.md#observed-lab-results), with [Service DNS evidence](../screenshots/02.2-clusterip-dns-curl.png) and [headless DNS evidence](../screenshots/06.1-headless-dns.png).

Reference: [Kubernetes DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/).
