# Terraform S3 demo

**Name:** Kartikey
**Roll number:** 24bcs10121

Files: `provider.tf` declares the AWS provider and region; `variables.tf` defines inputs; `terraform.tfvars` contains non-secret lab settings; `main.tf` creates the bucket and controls; `outputs.tf` exports bucket identifiers. The dependency graph is inferred from resource references.

## Safe local checks

```bash
terraform init -backend=false
terraform fmt -check
terraform validate
terraform test
```

`tests/storage.tftest.hcl` uses a mocked AWS provider. It verifies that the planned bucket blocks public access and enables versioning, without connecting to an AWS account. This is not evidence of a real bucket.

## Complete AWS workflow

Configure an authorized AWS profile outside the repository, then run:

```bash
export AWS_PROFILE=coursework
aws sts get-caller-identity
terraform init
terraform fmt
terraform validate
terraform plan -out=lab.tfplan
terraform apply lab.tfplan
terraform show
terraform output
terraform state list
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
# Equivalent interactive cleanup:
# terraform destroy
```

Review both plans before applying. The bucket name must be globally unique; append your account ID if needed. AWS can charge for stored data and requests. Live execution and cleanup are recorded below.

Do not commit credentials, state or plan files. Terraform state maps resource addresses to real AWS objects and may contain sensitive values. This lab defaults to local state; team use should configure an encrypted remote backend with restricted access and locking. Do not delete state as a substitute for `terraform destroy`.

Versioning means cleanup must account for old object versions and delete markers. The project uses `force_destroy=false`; empty the bucket deliberately before destroying it.

## Live AWS execution

Executed on 7 October 2026 in `ap-south-1` using temporary AWS CLI browser-login credentials.

Bucket: `kartikey-24bcs10121-devops-lab`.

| Step | Actual result |
|---|---|
| init / fmt / validate | Provider initialized, formatting check passed, configuration valid |
| plan | 5 additions; no changes or deletions |
| apply | 5 resources created |
| show / output | Bucket ARN/name and live configuration recorded |
| verification | Versioning enabled; SSE-S3 encryption; public access blocked |
| destroy plan / apply | Reviewed deletion-only plan; all 5 resources destroyed |
| post-cleanup | Bucket absent from AWS; no resources remaining in Terraform state |

Cleanup used `terraform plan -destroy -out=destroy.tfplan` followed by `terraform apply destroy.tfplan`, the reviewed-plan equivalent of `terraform destroy`.

Evidence: [preflight](../evidence/aws-preflight.txt), [plan](../evidence/aws-plan.txt), [apply](../evidence/aws-apply.txt), [show](../evidence/aws-show.txt), [outputs](../evidence/aws-output.txt), [versioning check](../evidence/aws-verification.json), [destroy plan](../evidence/aws-destroy-plan.txt), [destruction](../evidence/aws-destroy.txt), [AWS cleanup checks](../evidence/aws-cleanup.json).

![Bucket in AWS Console](../screenshots/aws-s3-bucket.jpg)

![Captured Terraform lifecycle output](../screenshots/aws-lifecycle.jpg)

The Console image was captured while the bucket existed; the bucket was subsequently deleted. The lifecycle image displays recorded command output and is labeled accordingly.
