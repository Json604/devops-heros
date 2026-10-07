mock_provider "aws" {}
run "private_versioned_bucket" {
  command = plan
  assert {
    condition     = aws_s3_bucket_public_access_block.lab.block_public_acls && aws_s3_bucket_public_access_block.lab.restrict_public_buckets
    error_message = "The bucket must block public access."
  }
  assert {
    condition     = aws_s3_bucket_versioning.lab.versioning_configuration[0].status == "Enabled"
    error_message = "Versioning must be enabled."
  }
}
