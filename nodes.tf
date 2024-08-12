resource "aws_key_pair" "mykey" {
  key_name   = "${var.keypair}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDdLWGzKk16WyBgH0R7A+EheF9ZZHBSmNjQwFCYtr1kN10sOULUIHfaS1P69NAvsNQkDNOrNiO4eZ1cxkZOQLvAKix6H/ohf+/5QkoQhUCvVh9AmQb9btoHLfP3HSUZaE3lIx8GqbjxZtDDhhHlNtGEAUyUsPtMPYZ1K3rHfFa8KgQg/mCE3DTJgN2kjVAdYMn8IVoRPkEnf2RHFzh0SJddJq7ZaKx3cvamc0vqFNEMBuRQIRvQ/TEXO+ErM/M1UUzZubjrOvoFvxwheHfquA2wQ5sLwHguHW8TEFNem2JmI4K6VvIeChHdn+yWQDQMyPAZSLckp142UL7ZWhbxiJIR imported-openssh-key"
}

resource "aws_iam_role" "nodes" {
  name = "eks-node-group-nodes"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "private-nodes"
  node_role_arn   = aws_iam_role.nodes.arn
  remote_access {
    ec2_ssh_key = "${var.keypair}"
  }  

  subnet_ids = aws_subnet.private_subnets.*.id

  capacity_type  = "${var.private_nodes_capacity}"
  instance_types = ["${var.private_nodes_type}"]

  scaling_config {
    desired_size = var.private_nodes_des
    max_size     = var.private_nodes_max
    min_size     = var.private_nodes_min
  }

  update_config {
    max_unavailable = 1
  }

  labels = var.private_nodes_labels

  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}


resource "aws_eks_node_group" "public-nodes" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "public-nodes"
  node_role_arn   = aws_iam_role.nodes.arn
  remote_access {
    ec2_ssh_key = "${var.keypair}"
  }  

  subnet_ids = aws_subnet.public_subnets.*.id

  capacity_type  = "${var.public_nodes_capacity}"
  instance_types = ["${var.public_nodes_type}"]

  scaling_config {
    desired_size = var.public_nodes_des
    max_size     = var.public_nodes_max
    min_size     = var.public_nodes_min
  }

  update_config {
    max_unavailable = 1
  }

  labels = var.public_nodes_labels


  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}