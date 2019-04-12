resource "aws_lb" "lb_internal" {
  name            = "${var.name}-int"
  internal        = true
  security_groups = ["${var.alb_security_group}"]
  subnets         = ["${var.subnet_ids}"]

  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false
  idle_timeout                     = 60

  tags {}
}

resource "aws_lb" "lb_internal_net" {
  name               = "${var.name}-net-int"
  internal           = true
  load_balancer_type = "network"
  subnets            = ["${var.subnet_ids}"]

  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false
  idle_timeout                     = 60

  tags {}
}

resource "aws_lb_listener" "mgmt_internal" {
  load_balancer_arn = "${aws_lb.lb_internal.arn}"
  port              = "443"
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = "${var.certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.backend_mgmt_internal.arn}"
  }
}

resource "aws_lb_target_group" "backend_mgmt_internal" {
  name     = "${var.name}-https-int"
  port     = 15672
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "4"
    timeout             = "2"
    interval            = "30"
    port                = "15672"
    path                = "/api/aliveness-test/%2F"
    protocol            = "HTTP"
    matcher             = "401"
  }
}

resource "aws_autoscaling_attachment" "mgmt_https_internal-internal" {
  autoscaling_group_name = "${var.autoscaling_group}"
  alb_target_group_arn   = "${aws_lb_target_group.backend_mgmt_internal.arn}"
}

resource "aws_lb_listener" "rabbitmq_internal" {
  load_balancer_arn = "${aws_lb.lb_internal_net.arn}"
  port              = "5672"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.rabbitmq_internal.arn}"
  }
}

resource "aws_lb_target_group" "rabbitmq_internal" {
  name     = "${var.name}-rabbit-int"
  port     = 5672
  protocol = "TCP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    interval            = "30"
    port                = "5672"
    protocol            = "TCP"
  }
}

resource "aws_autoscaling_attachment" "rabbitmq_internal-internal" {
  autoscaling_group_name = "${var.autoscaling_group}"
  alb_target_group_arn   = "${aws_lb_target_group.rabbitmq_internal.arn}"
}
