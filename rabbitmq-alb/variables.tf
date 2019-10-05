# Variables from provider

variable "name" {
  description = "ELB name, e.g cdn"
}

variable "subnet_ids" {
  type        = "list"
  description = "Comma separated list of subnet IDs"
}

variable "environment" {
  description = "Environment tag, e.g prod"
}

variable "internal" {
  description = "Is the ELB is internal? [boolean] "
}

variable "certificate_arn" {
  description = "Certificate for the current domain name"
}

variable "vpc_id" {
  description = "VPC to target for instance group"
}

variable "autoscaling_group" {
  description = "autoscaling group for target group"
}

variable "domain_name" {
  description = "domaine name for the alb dns record egress"
}

variable "cluster_fqdn" {}

variable "alb_security_group" {}
