output "cluster_kubeconfig" {
  value = data.template_file.generate_eks_kubeconfig.rendered

  depends_on = [aws_eks_cluster.cluster]
}

output "lb_target_group_arn" {
  value = aws_lb_target_group.cluster_tg.arn
}

output "worker_sg_id" {
  value = aws_security_group.worker_node_security_group.id
}
