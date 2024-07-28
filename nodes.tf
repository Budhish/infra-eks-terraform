resource "aws_key_pair" "mykey" {
  key_name   = "${var.keypair}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD1tNNKHZZK6cUwAXvOjIorBrUqyxqB+DRwEDVQ9D3aySbY0Yn5PJcuJXIj4+oRkii+3BtTFPs8QlXb7x9txmxRj6UACkjd0LVfhEI1VU6uTz8JoIarqBb0R2Ydl9blsz1n+ZVNKEGPHsfVJ6kPc8Qc8J1rcpuPCM8T/eRWvTy4tqF2irzO4YPDgsR3GgHAXSpDrVAkqxh03dg+jl4pBf4HVs0bonT6Swh0cOPpZuzKw9iwZOuUbZ2Y1fMrRbR/QQNFp5CwCddwXWdw/tNcbEjAel7MDoFVCzRAIC7fw3SUf7OMFOgmquT5xvl2O1ADk4Kus/S3/j6rb7azYuZ7u5yhvTLSRYdfVGP7gA+LdsnLOiG5HdTLZDm0TyubwWFramDo/MFR6dJcjnV65Li/J1HxFD4Cce0fSp98DsEG0Vw6jw+l0lOYPUiTLJnkONSSlaU9dEG4W56ym63iRDcl7I/FU4oqP2Mp1IU3F0W1aGmiCdyZeS6C9rA8EPVvm9HF3VbNFiWs4Og83Bkp4JPHTRFpHuUJdTZ3p7277vzoLjjpTGNO+XADAW0KKR7sKEXsRncEOqIR+f7/f7Kiz/4p4ahXgyjusmFZuNu6TBCkO5RM34BzzdcN1/32ABwIaPStLk6kYZeCQdCVCI29cdS/tkTdsBpwmyyak9maz14m+03IRQ== imported-openssh-key"
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