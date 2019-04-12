provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

module "alb" {
  source = "../rabbitmq-alb"

  # # General settings
  environment = "${var.environment}"
  name        = "${var.cluster_name}"

  internal    = false
  domain_name = "${var.domain_name}"
  datacenter  = "${var.region}"
  

  cluster_fqdn = "${var.cluster_fqdn}"

  # # Network
  subnet_ids = "${var.subnet_ids}"

  # # Autoscaling target group
  # # Note: only the servers need an ALB (only the servers expose an UI)
  autoscaling_group = "${module.rabbit.autoscaling_group}"

  allowed_inbound_cidr_blocks = "${var.public_cidr_block}"
  alb_security_group = "${module.rabbit.security_group_id}"

  # # External Settings
  certificate_arn = "${var.certificate_arn}"
  vpc_id          = "${var.vpc_id}"
}

module "rabbit" {
  source = "../"

  name         = "${var.cluster_name}"
  environment  = "${var.environment}"

  erl_secret_cookie = "${var.erl_secret_cookie}"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"

  cluster_fqdn = "${var.cluster_fqdn}"

  region                   = "${var.region}"
  ssh_key_name             = "${var.ssh_key_name}"
  desired_capacity = "${var.desired_capacity}"
  instance_ebs_optimized   = "${var.instance_ebs_optimized}"

  vpc_id             = "${var.vpc_id}"
  external_subnets   = "${var.external_subnets}"

  root_volume_size   = "${var.root_volume_size}"
  rabbit_volume_size = "${var.rabbit_volume_size}"

  associate_public_ip_address = "${var.associate_public_ip_address}"

  image_id = "${var.image_id}"

  ingress_private_cidr_blocks = "${var.ingress_private_cidr_blocks}"
  ingress_public_cidr_blocks  = "${var.ingress_public_cidr_blocks}"
  internet_public_cidr_blocks = "${var.internet_public_cidr_blocks}"

  instance_type    = "${var.instance_type}"

  az_count = "${var.az_count}"

  cpu_high_limit    = "70"
  cpu_low_limit     = "20"
  memory_high_limit = "70"
  memory_low_limit  = "20"
}
