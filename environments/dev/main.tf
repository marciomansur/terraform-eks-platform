module "platform" {
  source = "../../modules/platform"

  cluster_name = "${var.name}-${var.env}-cluster"
  env          = var.env
  region       = var.region
  azs          = var.azs

  app_size      = var.app_size
  db_size       = var.db_size
  instance_type = var.instance_type
  public_domain = var.public_domain
}

output "cluster_kubeconfig" {
  value = module.platform.cluster_kubeconfig
}
