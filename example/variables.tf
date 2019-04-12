variable "ssh_key_name" {
  description = "The aws ssh key name used to connect to any ec2 instances"
}

variable "profile" {
  description = "aws local profile to use"
}

variable "environment" {
  description = "type of environment you are deployubg (eg: dev, prod, staging)"
}

variable "cluster_name" {
  description = "Name of your deployment (eg: intercloud)"
}

variable "desired_capacity" {
  description = "Default size of your manager swarm (1, 3, 5)"
}

variable "root_volume_size" {
  description = "Size of the filesystem mounted on `/`"
}

variable "rabbit_volume_size" {
  description = "Size of the docker filesystem mount point"
}

variable "image_id" {
  description = "Aws ami to be used by ec2 instances"
}

variable "instance_ebs_optimized" {
  description = "Enable instance with optimized hard drive"
}

variable "associate_public_ip_address" {
  description = "Enable public ip on manager"
}

variable "az_count" {
  default     = 3
  description = "availability zone number"
}

variable "instance_type" {}

variable "erl_secret_cookie" {
  description = "Used by rabbitmq to join a cluster"
}

variable "aws_access_key" {
  description = "Used by rabbitmq to describe autoscaling group"
}

variable "aws_secret_key" {
  description = "Used by rabbitmq to describe autoscaling group"
}

variable "cluster_fqdn" {
  description = "a subdomain for your route53 dns"
}

variable "ingress_private_cidr_blocks" {
  type = "list"
}

variable "ingress_public_cidr_blocks" {
  type = "list"
}

variable "internet_public_cidr_blocks" {
  type = "list"
}

variable "external_subnets" {
  description = "A list of one or more availability zones for the ASG"
  type        = "list"
}

variable "vpc_id" {}
variable "region" {}

variable "certificate_arn" {}

variable "subnet_ids" {
  type = "list"
}

variable "domain_name" {}
