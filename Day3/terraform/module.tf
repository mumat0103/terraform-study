module "vpc" {     # 폴더 이름과 관계 없음
  source = "./vpc" #vpc 폴더에서 모듈을 가져오겠다.
  region = var.region
  prefix = var.prefix
}

module "ec2" {
  source            = "./ec2"
  prefix            = var.prefix
  vpc_id            = module.vpc.vpc_id
  private_subnet_id = module.vpc.private_subnet_id
  instance_type     = var.instance_type
  depends_on        = [module.vpc]
}
