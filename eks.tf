resource "aws_iam_role" "eksrole" {
  name = "eks-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eksrole.name
}

resource "aws_eks_cluster" "eks-cluster" {
  name     = "${var.cluster_name}"
  role_arn = aws_iam_role.eksrole.arn
  
  vpc_config {
    subnet_ids = concat(aws_subnet.public_subnets.*.id,aws_subnet.private_subnets.*.id)
  }

  depends_on = [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy]
}
