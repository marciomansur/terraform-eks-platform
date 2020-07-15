resource "aws_security_group" "vpc_security_group" {
  name = "${var.name}-vpc-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = [local.vpc_cidr_block]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}
