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

The test uses `mock_provider "aws"` and `command = plan`, checking two public subnets, two desired workers and private API access. It does not create EKS or validate real account quotas. Provider initialization and tests passed locally; live provisioning remains pending.

For a real deployment, configure an authorized AWS profile and budget first:

```bash
cp terraform.tfvars.example terraform.tfvars
# Set admin_cidr to your public IP /32 and select a supported EKS version.
export AWS_PROFILE=coursework
aws sts get-caller-identity
terraform init
terraform plan -out=eks.tfplan
terraform apply eks.tfplan
terraform output
# Execute the printed configure_kubectl command.
kubectl apply -f ../kubernetes/storageclass-aws.yaml
```

The EKS API allows only the administrator /32 publicly, while workers use its private endpoint. Two public subnets avoid NAT Gateway charges for the lab, but EC2 workers, EKS, public IPv4 and EBS still incur charges. Workers use managed IAM policies; EBS CSI has a separate Pod Identity role. Install Metrics Server and an Ingress controller before enabling HPA/Ingress. For EKS use `helm/helpdesk/values-prod.yaml`, set real SHA image tags, and create the database Secret first. Configure registry pull credentials if GHCR packages are private.

Terraform state is local, sensitive and ignored by Git. A team deployment should use an encrypted, locked remote backend provisioned separately. Never commit `.tfstate`, plan files, AWS keys or kubeconfig. A provider lock file is committed for reproducibility.

Teardown after evaluation:

```bash
# Delete application-created LoadBalancer Services and PVCs deliberately first.
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
# Interactive equivalent: terraform destroy
```

Capture the real plan, AWS VPC/EKS Console, worker readiness, and destroy completion when authorized. No real AWS screenshots are included in this local run.
