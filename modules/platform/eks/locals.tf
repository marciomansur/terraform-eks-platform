locals {
  tags = merge({
    Environment = var.env
    Region      = var.region
    Component   = "EKS"
    ManagedBy   = "Terraform"
  }, map("kubernetes.io/cluster/${var.cluster_name}", "shared"))
}
