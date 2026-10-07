output "cluster_name" { value = aws_eks_cluster.helpdesk.name }
output "vpc_id" { value = aws_vpc.lab.id }
output "configure_kubectl" { value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.helpdesk.name}" }
