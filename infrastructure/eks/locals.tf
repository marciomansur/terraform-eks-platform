locals {
  cluster_name = "${var.name}-cluster"

  tags = merge({
    Name        = "${var.name}-${var.region}-${var.env}-vpc"
    Environment = var.env
    Region      = var.region
    Component   = "EKS"
    ManagedBy   = "Terraform"
  }, map("kubernetes.io/cluster/${local.cluster_name}", "shared"))
}
