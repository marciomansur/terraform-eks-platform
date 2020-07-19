resource "aws_security_group" "cluster_alb_sg" {
  name        = "${var.cluster_name}-public"
  description = "Allow public traffic for EKS load balancer"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_lb" "cluster_alb" {
  name               = "${var.cluster_name}-alb"
  subnets            = var.public_subnets_ids
  security_groups    = [var.worker_sg_id, aws_security_group.cluster_alb_sg.id]
  load_balancer_type = "application"
  ip_address_type    = "ipv4"

  enable_deletion_protection = true

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

resource "aws_lb_listener" "cluster_alb_http" {
  load_balancer_arn = aws_lb.cluster_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "cluster_alb_https" {
  load_balancer_arn = aws_lb.cluster_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = aws_acm_certificate_validation.cluster_cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = var.lb_target_group_arn
  }
}
