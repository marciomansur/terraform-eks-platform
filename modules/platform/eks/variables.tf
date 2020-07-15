variable "name" {
  type        = "string"
  description = "Name of current infrastructure platform"
}

variable "region" {
  type        = "string"
  description = "Region where resources will be created"
}

variable "instance_type" {
  type        = "string"
  description = "Kubernetes worker node instance type"
}

variable "env" {
  type = "string"
}

variable "key_pair_name" {
  type        = "string"
  description = "Key pair to access instances via SSH"
}

variable "workstation_ip" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "vpc_security_group_id" {
  type        = "string"
  description = "Security Group ID created for VPC hosts"
}

variable "app_subnet_ids" {
  type = "list"
}

variable "app_size" {}

variable "db_subnet_ids" {
  type = "list"
}

variable "db_size" {}
