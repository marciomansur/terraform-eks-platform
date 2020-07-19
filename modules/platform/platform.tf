//resource "aws_key_pair" "cluster_key_pair" {
//  count      = var.enable_ssh == true ? 1 : 0
//  key_name   = "${var.cluster_name}-key-pair"
//  public_key = file(var.public_key_path)
//
//  lifecycle {
//    create_before_destroy = true
//  }
//}

module "network" {
  source = "./network"

  cluster_name = var.cluster_name
  azs          = var.azs
  env          = var.env
  region       = var.region
}

module "eks" {
  source = "./eks"

  cluster_name = var.cluster_name
  region       = var.region
  env          = var.env

  vpc_id                = module.network.vpc_id
  vpc_security_group_id = module.network.vpc_security_group_id
  app_subnet_ids        = module.network.app_subnet_ids
  db_subnet_ids         = module.network.db_subnet_ids

  instance_type = var.instance_type
  app_size      = var.app_size
  db_size       = var.db_size

  enable_ssh     = var.enable_ssh
  workstation_ip = var.workstation_ip
}

module "ingress" {
  source = "./ingress"

  cluster_name  = var.cluster_name
  env           = var.env
  region        = var.region
  public_domain = var.public_domain

  lb_target_group_arn = module.eks.lb_target_group_arn
  worker_sg_id        = module.eks.worker_sg_id
  public_subnets_ids  = module.network.public_subnet_ids
  vpc_id              = module.network.vpc_id
}

output "cluster_kubeconfig" {
  value = module.eks.cluster_kubeconfig
}
