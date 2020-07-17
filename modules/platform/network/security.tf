resource "aws_security_group" "vpc_security_group" {
  name   = "${var.cluster_name}-vpc-sg"
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

resource "aws_network_acl" "vpc_acl" {
  vpc_id = aws_vpc.vpc.id

  subnet_ids = concat(
    aws_subnet.public_subnets.*.id,
    aws_subnet.app_private_subnet.*.id,
    aws_subnet.db_private_subnet.*.id
  )

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = local.tags
}
