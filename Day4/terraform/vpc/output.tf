output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = tolist(aws_subnet.pubilc_subnet[*].id)
}

output "private_subnet_ids" {
  value = tolist(aws_subnet.private_subnet[*].id)
}
