resource "aws_instance" "reverse_proxy" {
  ami           = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "t2.micro"

# Scripts for installing ansible
#  provisioner "file" {
#    source = "script.sh"
#    destination = "/tmp/script.sh"
#  }
#  provisioner "remote-exec" {
#    inline = [
#      "chmod +x /tmp/script.sh",
#      "sudo /tmp/script.sh",
#   ]
#  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt install -y software-properties-common",
      "sudo apt-add-repository --yes --update ppa:ansible/ansible",
      "sudo apt install -y ansible",
    ]
  }

  # Scripts copying private key file - This is temporary solution
  provisioner "file" {
    source = "mykeypair"
    destination = "/home/ubuntu/mykeypair"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ubuntu/mykeypair",
    ]
  }

  provisioner "file" {
    source = "run_Ansible"
    destination = "/home/ubuntu"
  }
  
  connection {
    host = "${self.public_ip}"
    user = "${var.INSTANCE_USERNAME}"
    private_key = "${file("${var.PATH_TO_PRIVATE_KEY}")}"
  }

  # the VPC subnet
  subnet_id = "${aws_subnet.main-public-1.id}"

  # the security group
  vpc_security_group_ids = ["${aws_security_group.allow_http_ssh.id}"]

  # the public SSH key
  key_name = "${aws_key_pair.mykeypair.key_name}"
  tags = {
    Name = "Nginx_Reverse_Proxy"
  }
}

resource "aws_instance" "webserver" {
  ami           = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "t2.micro"

  # the VPC subnet
  subnet_id = "${aws_subnet.main-public-1.id}"

  # the security group
  vpc_security_group_ids = ["${aws_security_group.allow_http_ssh.id}"]

  # the public SSH key
  key_name = "${aws_key_pair.mykeypair.key_name}"
  
  tags = {
    Name = "Web_App_Server"
  }
}

resource "aws_instance" "database" {
  ami           = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "t2.micro"

  # the VPC subnet
  subnet_id = "${aws_subnet.main-private-1.id}"

  # the security group
  vpc_security_group_ids = ["${aws_security_group.allow-mysql.id}"]

  # the public SSH key
  key_name = "${aws_key_pair.mykeypair.key_name}"
  
  tags = {
    Name = "Database"
  }
}

