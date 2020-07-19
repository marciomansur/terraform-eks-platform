locals {
  vpc_cidr_block = "20.10.0.0/16"

  public_cidr_blocks = ["20.10.1.0/24", "20.10.2.0/24", "20.10.3.0/24"]
  app_cidr_blocks    = ["20.10.11.0/24", "20.10.12.0/24", "20.10.13.0/24"]
  db_cidr_blocks     = ["20.10.21.0/24", "20.10.22.0/24", "20.10.23.0/24"]

  tags = merge({
    Environment = var.env
    Region      = var.region
    Component   = "vpc"
    ManagedBy   = "Terraform"
  }, map("kubernetes.io/cluster/${var.cluster_name}", "shared"))
}
