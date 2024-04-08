data "aws_availability_zones" "region_azs" {
  state = "available"
  # Edge 서비스를 위한 AZ가 따로 있음. 그런거 필터해줘야함
  # 사용할 수 있는 AZ만 보여줌
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_ami" "ubuntu_ami" { #해당 리전의 우분투 AMI 최신 버전을 가져옴
  most_recent = true
  filter { # 이거는 필수 - 이미지를 가져오는 것
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server*"]
  }
  filter { # 얘는 없어도 되는데 혹시 모르니 넣자
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # 오너 정보가 없으면 신뢰할 수 없는 AMI를 가져올 수 있으니 지정해줘야 함
}
