locals {
  cluster_name = "${var.name}-${var.env}-cluster"

  tags = merge({
    Name        = "${var.name}-${var.region}-${var.env}-eks"
    Environment = var.env
    Region      = var.region
    Component   = "EKS"
    ManagedBy   = "Terraform"
  }, map("kubernetes.io/cluster/${local.cluster_name}", "shared"))
}
