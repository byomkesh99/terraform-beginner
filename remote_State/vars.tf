variable "AWS_REGION" {
  default = "ap-south-1"
}
variable "AMIS" {
  type = "map"
  default = {
    ap-south-1 = "ami-04125d804acca5692"
    us-east-1 = "ami-035b3c7efe6d061d5"
  }
}
