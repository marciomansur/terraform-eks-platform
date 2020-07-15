variable "name" {
  type        = "string"
  description = "Name of current infrastructure platform"
}

variable "cluster_name" {
  type        = "string"
  description = "If you're using Kubernetes or ECS, its name"
}

variable "region" {
  type        = "string"
  description = "Region where resources will be created"
}

variable "azs" {
  type        = "list"
  description = "List of availability to create the VPC"
}

variable "env" {
  type = "string"
}
