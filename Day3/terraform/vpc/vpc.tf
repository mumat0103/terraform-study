resource "aws_vpc" "vpc" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true

  tags = {
    "Name" = "${var.prefix}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.prefix}-vpc-igw"
  }
}

resource "aws_subnet" "pubilc_subnet" {
  vpc_id                                      = aws_vpc.vpc.id
  cidr_block                                  = "192.168.0.0/24"
  availability_zone                           = "${var.region}a"
  enable_resource_name_dns_a_record_on_launch = true
  map_public_ip_on_launch                     = true

  tags = {
    "Name" = "${var.prefix}-vpc-public-subnet-a"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                                      = aws_vpc.vpc.id
  cidr_block                                  = "192.168.10.0/24"
  availability_zone                           = "${var.region}a"
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    "Name" = "${var.prefix}-vpc-private-subnet-a"
  }
}

resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.pubilc_subnet.id

  tags = {
    "Name" = "${var.prefix}-vpc-nat-gateway-a"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = "${var.prefix}-vpc-public-route-table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    "Name" = "${var.prefix}-vpc-private-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_route_association" {
  subnet_id      = aws_subnet.pubilc_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_route_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}
