resource "aws_s3_bucket" "s3_bucket" { # "{1}" "{2}" / 1번에는 어떤 리소스인지 정의
  bucket = var.bucket_name
  force_destroy = true # 삭제할 때 버킷을 비우고 삭제함
}