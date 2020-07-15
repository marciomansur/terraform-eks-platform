output "vpc" {
  value = aws_vpc.vpc
}

output "app_subnet_ids" {
  value = aws_subnet.app_private_subnet.*.id
}

output "db_subnet_ids" {
  value = aws_subnet.db_private_subnet.*.id
}
