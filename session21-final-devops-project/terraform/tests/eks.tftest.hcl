mock_provider "aws" {}
variables { admin_cidr = "203.0.113.10/32" }
run "eks_architecture" {
  command = plan
  assert {
    condition     = length(aws_subnet.public) == 2 && aws_eks_node_group.main.scaling_config[0].desired_size == 2
    error_message = "Two public subnets and two workers are required."
  }
  assert {
    condition     = aws_eks_cluster.helpdesk.vpc_config[0].endpoint_private_access
    error_message = "Worker nodes need private API access."
  }
}
