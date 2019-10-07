# Template use at launch to install docker
# It will also lauch each docker container that are used to manage the state of our cluster
# This is use to pass required settings from terraform template directly in the ED2 instance
data "template_file" "rabbit-node" {
  template = file("${path.module}/user_data/rabbitmq.sh")

  vars = {
    AWS_REGION        = var.region
    VPC_ID            = var.vpc_id
    ERL_SECRET_COOKIE = var.erl_secret_cookie
    AWS_ACCESS_KEY    = var.aws_access_key
    AWS_SECRET_KEY    = var.aws_secret_key
    RABBITMQ_VERSION  = var.rabbitmq_version
    ERLANG_VERSION    = var.erlang_version
    CLUSTER_NAME      = "${var.cluster_fqdn}-${var.name}-${var.environment}"
  }
}

resource "aws_launch_configuration" "rabbit-node" {
  name_prefix = "${var.name}-${var.environment}-rabbit-"

  image_id      = var.image_id
  instance_type = var.instance_type
  ebs_optimized = var.instance_ebs_optimized

  iam_instance_profile = aws_iam_instance_profile.ProxyInstanceProfile.name
  key_name             = var.ssh_key_name

  security_groups = [
    aws_security_group.rabbit-cluster.id,
    aws_security_group.rabbit-node.id,
  ]

  # User Data is what's run at start from the template file previously rendered
  user_data                   = data.template_file.rabbit-node.rendered
  associate_public_ip_address = var.associate_public_ip_address

  # root
  root_block_device {
    volume_type = "gp2"
    volume_size = var.root_volume_size
  }

  # rabbit
  ebs_block_device {
    device_name = "/dev/xvdcz"
    volume_type = "gp2"
    volume_size = var.rabbit_volume_size
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "rabbit-node" {
  name = "${var.name}-${var.environment}-rabbit"

  launch_configuration = aws_launch_configuration.rabbit-node.name
  vpc_zone_identifier  = var.external_subnets
  min_size             = var.autoscaling_min_size
  max_size             = var.autoscaling_max_size
  desired_capacity     = var.desired_capacity
  termination_policies = ["OldestLaunchConfiguration", "Default"]

  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.name}-${var.environment}-rabbit"
    propagate_at_launch = true
  }

  tag {
    key                 = "Cluster"
    value               = "${var.name}-${var.environment}-cluster"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "rabbit-node-scale-up" {
  name                   = "${var.name}-${var.environment}-rabbit-node-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.rabbit-node.name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "rabbit-node-scale-down" {
  name                   = "${var.name}-${var.environment}-rabbit-node-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.rabbit-node.name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_lifecycle_hook" "rabbit-node-upgrade" {
  name                   = "${var.name}-${var.environment}-rabbit-node-upgrade-hook"
  autoscaling_group_name = aws_autoscaling_group.rabbit-node.name
  default_result         = "CONTINUE"
  heartbeat_timeout      = 2000
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
}
