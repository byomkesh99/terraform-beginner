#variable "AWS_ACCESS_KEY" {}
#variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
  default = "ap-south-1"
}
variable "PATH_TO_PRIVATE_KEY" {
  default = "mykeypair"
}
variable "PATH_TO_PUBLIC_KEY" {
  default = "mykeypair.pub"
}
variable "INSTANCE_USERNAME" {
  default = "ubuntu"
}
variable "AMIS" {
  type = "map"
  default = {
    ap-south-1 = "ami-03dcedc81ea3e7e27"
    ap-south-1 = "ami-009110a2bf8d7dd0a"
    us-west-1 = "ami-068670db424b01e9a"
  }
}
