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

Now we are going to spin up EC2 instance with Keyfile: mykey, script: to install ngnix. 
You have to generate SSH keys and add inbound connection in your security group for now.

Generating SSH key - 
 
     ssh-keygen -f mykey   # Without passphrase, just hit Enter
     
 Security Group:
 Login to AWS console -> Under EC2 Dashboard panel select "Security Group(SG)" -> Select Default SG -> Under Inbound click Edit -> Add All TCP - TCP - 0-65535 - 171.34.x.x/32 (To get your Public IP hit "what is my ip address in google.com")
 
 Keep all the following files under one directory and spin up EC2 instance. The run the following commands.
 
    $ terraform init
    $ terraform plan -out out.terraform
    $ terrsform apply "out.terraform"  # watch the outputs
    $ terraform show   # note the Pub IP of EC2 instance
    $ terraform destroy # Terminate your instance
 
 File: instance.tf
 
    resource "aws_key_pair" "mykey" {
         key_name = "mykey"
         public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
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
          "sudo /tmp/script.sh"
        ]
      }
      connection {
        host = "${self.public_ip}"
        user = "${var.INSTANCE_USERNAME}"
        private_key = "${file("${var.PATH_TO_PRIVATE_KEY}")}"
      }
    }

File: provider.tf

    provider "aws" {
		        access_key = "${var.AWS_ACCESS_KEY}"
		        secret_key = "${var.AWS_SECRET_KEY}"
		        region = "${var.AWS_REGION}"
		    }

File: vars.tf

    variable "AWS_ACCESS_KEY" {}
    variable "AWS_SECRET_KEY" {}
    variable "AWS_REGION" {
       default = "ap-south-1"
    }
    variable "AMIS" {
      type = "map"
      default = {
        ap-south-1 = "ami-04125d804acca5692"
        us-east-1 = "ami-035b3c7efe6d061d5"
        us-west-1 = "ami-068670db424b01e9a"
      }
     }

    variable "PATH_TO_PRIVATE_KEY" {
      default = "mykey"
    }
    variable "PATH_TO_PUBLIC_KEY" {
      default = "mykey.pub"
    }
    variable "INSTANCE_USERNAME" {
      default = "ubuntu"
    }

File: Script.sh

    #!/bin/bash

    # sleep until instance is ready
    until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
       sleep 1
    done

    # install nginx
    apt-get update
    apt-get -y install nginx

    # make sure nginx is started
    service nginx start

File: terrsform.tfvars (This file should **NOT** share in PUBLIC. I shared the false one for understanding)

    AWS_ACCESS_KEY = "AKJKDNWKSMLL235K3"
    AWS_SECRET_KEY = "ekjfwecwnbwjfo384kfnewflwfwefjwelkj"
    
If everything fine, then hit the new EC2 Public IP in browser and you will see the welcome page of NGINX


### Creating Windows Instance 
(I will fillup this part later on)


### Outputting attributes:

* Terraform keeps **attributes** of all the **resources** you create.
  * e.g. the **aws_instance** resource has the **attribute public_ip**
* Those attributes can be **queried** & **outputted**
* This can be useful just to output valuable information or to feed information to external software.
* Use "output" to display the public IP address of an AWS resource:

      resource "aws_instance" "example" {
        ami = "${lookup(var.AMIS, var.AWS_REGION)}"
        instance_type = "t2.micro"
      }
      output "ip" {
        value = "${aws_instance.example.public_ip}"
      }
      
* You can refer to any attribute by specifying the following elements in your variable:
  * The resource type: aws_instance
  * The resource name: example
  * The attribute name: public_ip
  
Refer Terraform Documenation section for lists of attributes.

* You can also use the attributes in a script to get the private IP's in your local box:

      resource "aws_instance" "example" {
          ami = "${lookup(var.AMIS, var.AWS_REGION)}"
          instance_type = "t2.micro"
          provisioner "local-exec" {
	    command = "echo ${aws_instance.example.private_ip} >> private_ips.txt"
          }
      }
* Useful for instance to start automation script after infrastructure provisioning.
* You can populate the IP addresses in an **Ansible host** file
* OR another possibility: execute a script (with attributes as argument) which will take care of a **mapping**
  of resource name and the IP address.
  
Lets spin up 1 EC2 instance and see the output. vars.tf/provider.tf/terraform.tfvars file will be same as above.

File: instance.tf (with output_attribute files)

      resource "aws_instance" "example" {
        ami = "${lookup(var.AMIS, var.AWS_REGION)}"
        instance_type = "t2.micro"
        provisioner "local-exec" {
           command = "echo ${aws_instance.example.private_ip} >> private_ips.txt"   ## Redirected Private IP file
        }
      }
      output "ip" {
        value = "${aws_instance.example.public_ip}"
      }
      
Output: It will look like as below.. ..

      aws_instance.example (local-exec): Executing: ["/bin/sh" "-c" "echo 172.31.23.159 >> private_ips.txt"]
      aws_instance.example: Creation complete after 32s [id=i-0a18c4d930172fbc8]

      Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

      Outputs:

      ip = 13.234.59.204
      [tuser@baspa outputting_Attributes]$ ls
      instance.tf  private_ips.txt  provider.tf  terraform.tfstate  terraform.tfvars  vars.tf
      [tuser@baspa outputting_Attributes]$ cat private_ips.txt  (This file can be use as inventory in Ansible)
      172.31.23.159

      
