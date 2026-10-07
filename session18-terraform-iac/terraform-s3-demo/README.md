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

Review both plans before applying. The bucket name must be globally unique; append your account ID if needed. AWS can charge for stored data and requests. Live apply and destroy remain pending AWS authentication. The account was identified in browser sign-in, but CLI authentication returned HTTP 400 and no usable local profile was created. Keep screenshots of the actual bucket and command results when completing that requirement.

Do not commit credentials, state or plan files. Terraform state maps resource addresses to real AWS objects and may contain sensitive values. This lab defaults to local state; team use should configure an encrypted remote backend with restricted access and locking. Do not delete state as a substitute for `terraform destroy`.

Versioning means cleanup must account for old object versions and delete markers. The project uses `force_destroy=false`; empty the bucket deliberately before destroying it.
