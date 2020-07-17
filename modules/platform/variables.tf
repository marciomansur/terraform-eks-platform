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
  description = "List of availability zones to create the infrastructure"
}

variable "env" {
  type = "string"
}

variable "public_domain" {
  type = "string"
  description = "Domain to access cluster services. Must have a valid hosted zone"
}

variable "instance_type" {
  type        = "string"
  description = "Instance type of worker nodes"
}

variable "app_size" {}

variable "db_size" {}

variable "enable_ssh" {
  default     = false
  description = "Flag to enable SSH access to worker nodes"
}

variable "workstation_ip" {
  type        = "string"
  description = "IP from workstation to access the worker nodes"
  default     = null
}

variable "public_key_path" {
  type        = "string"
  description = "Public key created by the client to access the instances via SSH"
}
