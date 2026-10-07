# Session 19: Cloud infrastructure with Terraform

**Name:** Kartikey
**Roll number:** 24bcs10121

```mermaid
flowchart TD
  T[Terraform AWS provider] --> V[VPC 10.21.0.0/16]
  V --> S[Two public subnets in separate AZs]
  V --> I[Internet Gateway and route table]
  S --> E[EC2 Nginx web server]
  G[Security Group: HTTP from administrator /32] --> E
  T --> B[Private encrypted versioned S3 bucket]
```

The project provisions a VPC, two subnets, an Internet Gateway, a default route, route associations, an HTTP Security Group, an Amazon Linux EC2 instance and an S3 bucket. Terraform references establish dependencies: EC2 needs a subnet/security group and waits for outbound routing before installing Nginx. The provider manages AWS API calls; variables supply region, bucket name, allowed client address and instance size. Outputs expose VPC ID, URL and bucket name.

```bash
cp terraform.tfvars.example terraform.tfvars
# Replace the documentation IP with your current public IPv4 /32.
export AWS_PROFILE=coursework
aws sts get-caller-identity
terraform init
terraform fmt -check
terraform validate
terraform plan -out=cloud.tfplan
terraform apply cloud.tfplan
terraform output
terraform state list
curl "$(terraform output -raw web_url)"
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

EC2 user data installs and starts Nginx; wait for initialization before testing. On failure inspect EC2 status, cloud-init logs, route associations and the current allowed client IP. There is deliberately no open SSH rule. State is local for this exercise and must be protected and retained until cleanup. The state and plan files are ignored by Git.

## Validation and execution status

`terraform init`, `validate`, and `terraform test` passed locally. [Mocked architecture test](evidence/terraform-test.txt) checks subnet count and IMDSv2. The mocks produce no AWS resources. Live plan/apply/destroy, AWS Console screenshots and HTTP evidence from EC2 remain pending because no paid AWS deployment was authorized.

The `/32` input is validated to prevent accidentally opening HTTP to the whole internet. The example `203.0.113.10/32` is a documentation address, not a usable deployment setting. Both EC2 and public IPv4 allocation may incur charges; destroy the real stack after its evaluation.

## Screenshot evidence

![Recorded assignment evidence](screenshots/session19.jpg)

Command-output screenshots display the captured transcripts; the full text files are retained in `evidence/`. GitHub and application screenshots capture their live pages.
