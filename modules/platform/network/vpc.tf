resource "aws_vpc" "vpc" {
  cidr_block           = local.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

resource "aws_internet_gateway" "vpc_internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = local.tags
}
