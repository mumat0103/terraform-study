resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
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
  count = length(var.public_subnet_cidrs)

  vpc_id                                      = aws_vpc.vpc.id
  cidr_block                                  = var.public_subnet_cidrs[count.index] #count 의 index. 첫번째면 0, 두번째면 1 이런식
  availability_zone                           = var.region_azs[count.index]
  enable_resource_name_dns_a_record_on_launch = true
  map_public_ip_on_launch                     = true

  tags = {
    "Name" = "${var.prefix}-vpc-public-subnet-${substr(var.region_azs[count.index], -1, 1)}" # 불러온 az의 맨 마지막에서 1글자만 가져온다는 뜻
  }
}

resource "aws_subnet" "private_subnet" {
  count                                       = length(var.private_subnet_cidrs)
  vpc_id                                      = aws_vpc.vpc.id
  cidr_block                                  = var.private_subnet_cidrs[count.index]
  availability_zone                           = var.region_azs[count.index]
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    "Name" = "${var.prefix}-vpc-private-subnet-${substr(var.region_azs[count.index], -1, 1)}"
  }
}

resource "aws_eip" "nat_gateway_eip" {
  count  = length(var.private_subnet_cidrs)
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat_gateway_eip[count.index].id
  subnet_id     = aws_subnet.pubilc_subnet[count.index].id

  tags = {
    "Name" = "${var.prefix}-vpc-nat-gateway-${substr(var.region_azs[count.index], -1, 1)}"
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
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id #a, b, c로 올라가니까 딱 맞게 들어감
  }

  tags = {
    "Name" = "${var.prefix}-vpc-private-route-table-${substr(var.region_azs[count.index], -1, 1)}"
  }
}

resource "aws_route_table_association" "public_subnet_route_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.pubilc_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_route_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}
