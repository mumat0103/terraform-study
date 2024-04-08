variable "region" {
  type = string
  default = "ap-northeast-2"
}

variable "awscli_profile" {
  type = string
  default = "mumat"
}

variable "bucket_name" {
  type = string
  default = "csk-terraform-test-bucket"
}