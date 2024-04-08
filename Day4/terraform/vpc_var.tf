variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["192.168.0.0/24", "192.168.1.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["192.168.10.0/24", "192.168.11.0/24"]
}
