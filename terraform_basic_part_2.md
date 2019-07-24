### Terraform Basic Part-2

#### Software Provisioning:

* There are 2 ways to **provision software** on your instance.
* You can build your **own custom AMI** and bundle your software image.
  * **Packer** is a great tool to do this.
* Another whay is to boot **standarized AMIs**, and then install the software on it you need.
    * Using file uploads
    * Using remote exec
    * Usinf automation tool like Chef, Puppet, Ansible etc.
    
* **Current state** for terraform with automation (Q4 2016)
  * **Chef is integrated** within terraform, you can add chef statements.
  * You can run **puppet agent** using remote-exec.
  
  * For Ansible, you can first run terraform, and **output** the IP addresses, then run **ansible-playbook** on those hosts.
    * This can be automated in a workflow script.
    * There are **3rd party initiatives** integrating Ansible with terraform

**File Uploads:**

    resource "aws_instance" "example" {
      ami = "${lookup(var.AMIS, var.AWS_REGION)}"
      instance_type = "t2.micro"
      
    provisioner "file" {
      source = "script.sh"
      destination = "/tmp/script.sh"
      }
    }
 
* File uploads is an **easy way** to upload a file or a script.
* Can be used in conjuction with **remote-exec** to execute a sctipt.
* The provisionar may use **SSH** (Linux hosts) or **WinRM** (on windows hosts)

* By-default type is SSH, To override the SSH defaults, you can use "connection"

      resource "aws_instance" "example" {
        ami = "${lookup(var.AMIS, var.AWS_REGION)}"
        instance_type = "t2.micro"
        
        provisioner "file" {
          source = "script.sh"
          destination = "/tmp/script.sh"
          connection {
            user = "${var.instance_username}"
            password = "${var.instance_password}"
          }
        }
      }
      
* When spinning up instances on AWS, **ec2-user** is the default user for Amazon Linux and **ubuntu** for Ubuntu Linux.
* Check in below conf file how we execute a script after uploaded script file i.e. in provisioner "file" & provisioner "remote-exec" section.
* Typically on AWS, you will use SSH keypairs.


File: instance.tf

    resource "aws_key_pair" "mykey" {
      key_name = "mykey"
      public_key = "ssh-rsa my-public-key"
    }

    resource "aws_instance" "example" {
      ami = "${lookup(var.AMIS, var.AWS_REGION)}"
      instance_type = "t2.micro"
      key_name = "${aws_key_pair.mykey.key_name}"

      provisioner "file" {
        source = "script.sh"
        destination = "/tmp/script.sh"
      }
      provisioner "remote-exec" {
        inline = [
          "chmod +x /tmp/script.sh",
          "sudo /tmp/script.sh arguments"
        ]
      }
      connection {
        host = "${self.public_ip}"
        user = "${var.INSTANCE_USERNAME}"
        private_key = "${file("${var.PATH_TO_PRIVATE_KEY}")}"
      }
    }

Note: Please note above, how we are using **mykey** and in connection using **private_key** instead of password.

