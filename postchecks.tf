resource "null_resource" "postchecks" {
 provisioner "local-exec" {
    command = "/bin/bash postinstall.sh ${var.cluster_name}"
  }
  depends_on = [
      aws_eks_node_group.public-nodes,
      aws_eks_node_group.private-nodes,
      aws_eks_cluster.eks-cluster
  ]
}