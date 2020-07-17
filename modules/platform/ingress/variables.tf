variable "cluster_name" {
  type        = "string"
  description = "If you're using Kubernetes or ECS, its name"
}

variable "region" {
  type        = "string"
  description = "Region where resources will be created"
}

variable "env" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "public_subnets_ids" {
  type = "list"
}

variable "worker_sg_id" {
  type        = "string"
  description = "Security group ID, used by Kubernetes nodes"
}

variable "lb_target_group_arn" {
  type        = "string"
  description = "Target Group's ARN pointing at the Kubernetes nodes"
}

variable "public_domain" {
  type = "string"
}
