output "vpc_id" {
  value = aws_vpc.new-vpc.id
}

output "private_subnets" {
  value = aws_subnet.private_subnets[*].id
}

output "public_subnets" {
  value = aws_subnet.public_subnets[*].id
}

output "default_security_group_id" {
  value = aws_security_group.default.id
}