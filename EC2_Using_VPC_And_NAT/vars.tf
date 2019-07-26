variable "AWS_REGION" {
  default = "ap-south-1"
}
variable "PATH_TO_PRIVATE_KEY" {
  default = "mykeypair"
}
variable "PATH_TO_PUBLIC_KEY" {
  default = "mykeypair.pub"
}
variable "AMIS" {
  type = "map"
  default = {
    ap-south-1 = "ami-0d2692b6acea72ee6"
    ap-south-1 = "ami-04125d804acca5692"
    us-west-1 = "ami-068670db424b01e9a"
  }
}
