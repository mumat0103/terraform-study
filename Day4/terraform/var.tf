variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "awscli_profile" {
  type    = string
  default = "mumat"
}

variable "prefix" {
  type    = string
  default = "csk"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "node_count" {
  type    = number
  default = 2
}
