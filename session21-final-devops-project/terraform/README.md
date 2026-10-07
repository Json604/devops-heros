# AWS EKS infrastructure

**Name:** Kartikey
**Roll number:** 24bcs10121

Local checks (no AWS account needed):

```bash
terraform init -backend=false
terraform fmt -check
terraform validate
terraform test
```

The test uses `mock_provider "aws"` and `command = plan`, checking two public subnets, two desired workers and private API access. It does not create EKS or validate real account quotas. Provider initialization and tests passed locally. A separate real AWS run provisioned the cluster and deployed the application on 7 October 2026.

For a real deployment, configure an authorized AWS profile and budget first:

```bash
cp terraform.tfvars.example terraform.tfvars
# Set admin_cidr to your public IP /32 and select a supported EKS version.
export AWS_PROFILE=coursework AWS_REGION=ap-south-1
aws sts get-caller-identity
terraform init
terraform plan -out=eks.tfplan
terraform apply eks.tfplan
terraform output
# Execute the printed configure_kubectl command.
kubectl apply -f ../kubernetes/storageclass-aws.yaml
```

The EKS API allows only the administrator /32 publicly, while workers use its private endpoint. Two public subnets avoid NAT Gateway charges for the lab, but EC2 workers, EKS, public IPv4 and EBS still incur charges. Workers use managed IAM policies; EBS CSI has a separate Pod Identity role. Install Metrics Server and an Ingress controller before enabling HPA/Ingress. Install the Prometheus Operator/ServiceMonitor CRD using the [Helm monitoring guide](../monitoring/README.md#eks-helm-managed-prometheus-and-grafana) before production values enable ServiceMonitor. For EKS combine `helm/helpdesk/values-prod.yaml` with the verified SHA tags in `values-release.yaml`, and create the database Secret first. Configure registry pull credentials if GHCR packages are private.

Terraform state is local, sensitive and ignored by Git. A team deployment should use an encrypted, locked remote backend provisioned separately. Never commit `.tfstate`, plan files, AWS keys or kubeconfig. A provider lock file is committed for reproducibility.

Teardown after evaluation:

```bash
# Delete application-created LoadBalancer Services and PVCs deliberately first.
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
# Interactive equivalent: terraform destroy
```

## Live AWS execution

Region: `ap-south-1`; Kubernetes: `1.35`; managed workers: two `t3.medium` nodes. The reviewed plan added 20 resources and changed no existing infrastructure. Both workers became Ready, EBS CSI provisioned PostgreSQL storage, and Helpdesk ran with two backend and frontend replicas. API access was restricted to the administrator /32. Public logs replace that personal address with `<ADMIN_IPV4>/32`.

- [Real plan](../evidence/aws-plan.txt) and [apply](../evidence/aws-apply.txt)
- [Worker/application verification](../evidence/eks-verification.txt)
- [EKS Console screenshot](../screenshots/aws-eks-active.png)
- [VPC and two subnets](../screenshots/aws-eks-vpc.png)
- [Saved-plan terminal screenshot](../screenshots/aws-plan-terminal.png)

The initial installation used Helm; Argo subsequently reconciled the published release from Git. The application namespace and its EBS volume were removed before Terraform teardown, while the storage driver was still running. Monitoring/Argo/Ingress namespaces were also removed to release workloads before worker termination. No NAT Gateway, Elastic IP or public LoadBalancer was created.

During final-node draining, the CoreDNS PodDisruptionBudget reported zero allowed disruptions while its replacement Pod was Pending. After application and monitoring removal, the budget was deleted specifically for teardown of this disposable cluster. This is not a normal running-cluster configuration change; it allowed the final DNS Pod to be evicted before deleting the cluster.

Cleanup completed: [20 resources destroyed](../evidence/aws-destroy.txt), with [empty Terraform state and AWS absence checks](../evidence/aws-cleanup.json).
