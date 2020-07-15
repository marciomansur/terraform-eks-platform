output "cluster_kubeconfig" {
  value = data.template_file.generate_eks_kubeconfig.rendered

  depends_on = [aws_eks_cluster.cluster]
}
