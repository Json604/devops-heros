mock_provider "aws" {}
variables { allowed_http_cidr = "203.0.113.10/32" }
run "network_and_compute" {
  command = plan
  assert {
    condition     = length(aws_subnet.public) == 2
    error_message = "Two subnets are required."
  }
  assert {
    condition     = aws_instance.web.metadata_options[0].http_tokens == "required"
    error_message = "IMDSv2 must be required."
  }
}
