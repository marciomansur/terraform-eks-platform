resource "aws_subnet" "app_private_subnet" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.app_cidr_blocks[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = local.tags
}

resource "aws_subnet" "db_private_subnet" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.db_cidr_blocks[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = local.tags
}

resource "aws_route_table" "app_route_tables" {
  count  = length(var.azs)
  vpc_id = aws_vpc.vpc.id

  route {
    nat_gateway_id = aws_nat_gateway.nat.*.id[count.index]
    cidr_block     = "0.0.0.0/0"
  }

  tags = local.tags
}

resource "aws_route_table" "db_route_tables" {
  count  = length(var.azs)
  vpc_id = aws_vpc.vpc.id
  tags = local.tags
}

resource "aws_route_table_association" "app_route_association" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.app_private_subnet.*.id[count.index]
  route_table_id = aws_route_table.app_route_tables.*.id[count.index]
}

resource "aws_route_table_association" "db_route_association" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.db_private_subnet.*.id[count.index]
  route_table_id = aws_route_table.db_route_tables.*.id[count.index]
}
