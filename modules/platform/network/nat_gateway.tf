resource "aws_eip" "nat_ips" {
  count = length(var.azs)
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.azs)
  allocation_id = aws_eip.nat_ips.*.id[count.index]
  subnet_id     = aws_subnet.public_subnets.*.id[count.index]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_internet_gateway.vpc_internet_gateway]

  tags = local.tags
}
