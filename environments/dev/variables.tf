variable "profile" {
  type        = string
  description = "Your profile name, set up locally, to access AWS"
}

variable "name" {
  type        = string
  description = "Platform domain name"
}

variable "region" {
  type        = string
  description = "Region where resources will be created"
}

variable "azs" {
  type        = list(string)
  description = "List of availability zones to create the infrastructure"
}

variable "env" {
  type = string
}

variable "public_domain" {
  type        = string
  description = "Domain to access cluster services. Must have a valid hosted zone"
}

variable "instance_type" {
  type        = string
  description = "Instance type of worker nodes"
}

variable "app_size" {}

variable "db_size" {}

variable "enable_ssh" {
  default = false
}
