variable "cluster_name" {
  type        = string
  description = "If you're using Kubernetes or ECS, its name"
}

variable "region" {
  type        = string
  description = "Region where resources will be created"
}

variable "instance_type" {
  type        = string
  description = "Kubernetes worker node instance type"
}

variable "env" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_security_group_id" {
  type        = string
  description = "Security Group ID created for VPC hosts"
}

variable "app_subnet_ids" {
  type = list(string)
}
variable "app_subnet_cidr" {
  type = list(string)
}

variable "app_size" {}

variable "db_subnet_cidr" {
  type = list(string)
}
variable "db_subnet_ids" {
  type = list(string)
}

variable "db_size" {}

variable "enable_ssh" {
  default     = false
  description = "Flag to enable SSH access to worker nodes"
}

variable "key_pair_name" {
  type        = string
  description = "Key pair to access instances via SSH"
  default     = null
}

variable "workstation_ip" {
  type        = string
  description = "IP from workstation to access the worker nodes"
  default     = null
}
