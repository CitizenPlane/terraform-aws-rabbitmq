resource "aws_security_group" "lb-external" {
  name        = "${var.name}-${var.environment}-lb-external"
  vpc_id      = var.vpc_id
  description = "Allows traffic from and to the EC2 instances of the ${var.name} Rabbitmq LB from outside"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.ingress_public_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = var.internet_public_cidr_blocks
  }

  tags = {
    Name        = "${var.name}-${var.environment}"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "rabbit-cluster" {
  name        = "${var.name}-${var.environment}-rabbit-cluster"
  vpc_id      = var.vpc_id
  description = "Allows traffic from and to the EC2 instances of the ${var.name} Rabbit Cluster"

  ingress {
    from_port = 5672
    to_port   = 5672
    protocol  = "tcp"

    cidr_blocks = var.ingress_public_cidr_blocks
  }

  ingress {
    from_port   = 15672
    to_port     = 15672
    protocol    = "tcp"
    cidr_blocks = var.ingress_public_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = var.internet_public_cidr_blocks
  }

  tags = {
    Name        = "${var.name}-${var.environment}"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "rabbit-node" {
  name        = "${var.name}-${var.environment}-rabbit-node"
  vpc_id      = var.vpc_id
  description = "Allows traffic from and to the EC2 instances of the ${var.name} Rabbit Nodes"

  ingress {
    from_port   = 4369
    to_port     = 4369
    protocol    = "tcp"
    cidr_blocks = var.ingress_private_cidr_blocks
  }

  ingress {
    from_port   = 25672
    to_port     = 25672
    protocol    = "tcp"
    cidr_blocks = var.ingress_private_cidr_blocks
  }

  ingress {
    from_port   = 35672
    to_port     = 35682
    protocol    = "tcp"
    cidr_blocks = var.ingress_private_cidr_blocks
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.internet_public_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = var.internet_public_cidr_blocks
  }
}
