module "vpc" {                   # 폴더 이름과 관계 없음
  source               = "./vpc" #vpc 폴더에서 모듈을 가져오겠다.
  region               = var.region
  prefix               = var.prefix
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  region_azs           = data.aws_availability_zones.region_azs.names
}

module "ec2" {
  source             = "./ec2"
  prefix             = var.prefix
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  instance_type      = var.instance_type
  ubuntu_ami         = data.aws_ami.ubuntu_ami
  node_count         = var.node_count
  depends_on         = [module.vpc]
}
