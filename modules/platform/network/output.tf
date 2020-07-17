output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_security_group_id" {
  value = aws_security_group.vpc_security_group.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets.*.id
}

output "app_subnet_ids" {
  value = aws_subnet.app_private_subnet.*.id
}

output "db_subnet_ids" {
  value = aws_subnet.db_private_subnet.*.id
}
