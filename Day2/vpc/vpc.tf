resource "aws_vpc" "vpc" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Name" = "csk-vpc"
  }
}

resource "aws_internet_gateway" "ipw" { # 뒤에 있는 name은 테라폼 한정 이름
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "csk-ipw"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id                                      = aws_vpc.vpc.id
  cidr_block                                  = "192.168.0.0/24"
  availability_zone                           = "${var.region}a"
  enable_resource_name_dns_a_record_on_launch = true #ec2 인스턴스 만들어질 때, dns 네임 설정 가능
  map_public_ip_on_launch                     = true #ec2 인스턴스는 기본적으로 ip를 할당 받음
}

resource "aws_subnet" "subnet_c" {
  vpc_id                                      = aws_vpc.vpc.id
  cidr_block                                  = "192.168.1.0/24"
  availability_zone                           = "${var.region}c"
  enable_resource_name_dns_a_record_on_launch = true #ec2 인스턴스 만들어질 때, dns 네임 설정 가능
  map_public_ip_on_launch                     = true #ec2 인스턴스는 기본적으로 ip를 할당 받음
}

resource "aws_route_table" "public_route_table" { # 서브넷에 연결 해줘야함
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ipw.id
  }

  tags = {
    "Name" = "csk-public-route-table"
  }
}

# 서브넷과 라우트 테이블 연결
resource "aws_route_table_association" "public_subnet_a_public_route_table_association" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_c_public_route_table_association" {
  subnet_id      = aws_subnet.subnet_c.id
  route_table_id = aws_route_table.public_route_table.id
}
