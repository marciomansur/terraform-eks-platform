locals {
  tags = merge({
    Name        = var.cluster_name
    Environment = var.env
    Region      = var.region
    Component   = "vpc"
    ManagedBy   = "Terraform"
  }, map("kubernetes.io/cluster/${var.cluster_name}", "shared"))
}
