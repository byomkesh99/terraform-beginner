resource "aws_security_group" "allow-all" {
  vpc_id = "${aws_vpc.main.id}"
  name = "allow-all"
  description = "security group that allows ssh and all egress traffic"
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 0
      to_port = 65535
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  } 
tags = {
    Name = "allow-all"
  }
}

# Allowing http ports
resource "aws_security_group" "allow_http_ssh" {
  vpc_id = "${aws_vpc.main.id}"
  name = "allow_http_ssh"
  description = "security group that allows http and all egress traffic"
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  } 
  
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  } 
  tags = {
    Name = "allow_http_ssh"
  }
}

# Allowing mysql ports
resource "aws_security_group" "allow-mysql" {
  vpc_id = "${aws_vpc.main.id}"
  name = "allow-mysql"
  description = "security group that allows mysql and all egress traffic"
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      security_groups = ["${aws_security_group.allow_http_ssh.id}"]
  } 
  
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      security_groups = ["${aws_security_group.allow_http_ssh.id}"]
  } 
  
  tags = {
    Name = "allow-mysql"
  }
}
