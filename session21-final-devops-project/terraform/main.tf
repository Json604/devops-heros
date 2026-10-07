resource "aws_vpc" "lab" {
  cidr_block           = "10.21.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "kartikey-devops" }
}
resource "aws_internet_gateway" "lab" {
  vpc_id = aws_vpc.lab.id
}
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.21.${count.index + 1}.0/24"
  availability_zone       = "${var.aws_region}${count.index == 0 ? "a" : "b"}"
  map_public_ip_on_launch = true
  tags                    = { "kubernetes.io/role/elb" = "1" }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab.id
  }
}
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
resource "aws_iam_role" "cluster" {
  name_prefix        = "helpdesk-cluster-"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "eks.amazonaws.com" }, Action = "sts:AssumeRole" }] })
}
resource "aws_iam_role_policy_attachment" "cluster" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_eks_cluster" "helpdesk" {
  name     = var.cluster_name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.cluster.arn
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
  vpc_config {
    subnet_ids              = aws_subnet.public[*].id
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = [var.admin_cidr]
  }
  depends_on = [aws_iam_role_policy_attachment.cluster, aws_route_table_association.public]
}
resource "aws_iam_role" "node" {
  name_prefix        = "helpdesk-node-"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }] })
}
resource "aws_iam_role_policy_attachment" "node" {
  for_each   = toset(["AmazonEKSWorkerNodePolicy", "AmazonEKS_CNI_Policy", "AmazonEC2ContainerRegistryReadOnly"])
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.helpdesk.name
  node_group_name = "helpdesk-workers"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_subnet.public[*].id
  instance_types  = ["t3.medium"]
  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }
  update_config { max_unavailable = 1 }
  depends_on = [aws_iam_role_policy_attachment.node]
}
resource "aws_eks_addon" "identity" {
  cluster_name = aws_eks_cluster.helpdesk.name
  addon_name   = "eks-pod-identity-agent"
  depends_on   = [aws_eks_node_group.main]
}
resource "aws_iam_role" "ebs" {
  name_prefix        = "helpdesk-ebs-"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "pods.eks.amazonaws.com" }, Action = ["sts:AssumeRole", "sts:TagSession"] }] })
}
resource "aws_iam_role_policy_attachment" "ebs" {
  role       = aws_iam_role.ebs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
resource "aws_eks_pod_identity_association" "ebs" {
  cluster_name    = aws_eks_cluster.helpdesk.name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs.arn
  depends_on      = [aws_eks_addon.identity, aws_iam_role_policy_attachment.ebs]
}
resource "aws_eks_addon" "ebs" {
  cluster_name = aws_eks_cluster.helpdesk.name
  addon_name   = "aws-ebs-csi-driver"
  depends_on   = [aws_eks_node_group.main, aws_eks_pod_identity_association.ebs]
}
