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

      
### Remote State:

* Terraform keeps the **remote state** of the infrastructure.
* It stores it in a file call **terraform.tfstate**.
* There is also backup of the previous state in **terraform.tfstate.backup**
* When you execute terraform **apply**, a new terraform.tfstate and backup is written.
* This is how terraform **keep track** of the remote state.
  * If the remote state changes and you hit terraform apply again, terraform will make changes to meet the **correct remote state** again.
  * e.g. you **terminate** an instance that is managed by terraform, after terraform apply it will be started again.
* You can keep the terraform.tfstate in **version control** e.g. Git.
* It gives you a **History** of your terraform.tfstate file (which is just a BIG JSON file).
* It allows you to collaborate with other team members.
  * Unfortulately (2 user in git) you can get conflicts when 2 people work at the same time, but pull the master file then push.
* Local state works well in the beginning, but when your project becomes bigger, you might want to store your state **Remote**.
* The **terraform state** can be saved remote, using **backend** functionality in terraform.
* The default is a **local backend** (the local terraform state filre).
* Other backend includes:
  * **S3** (with a locking machanism using dynamoDB)
  * **Consul** (with locking)
  * **terraform enterprise** (the commercial solution)
* Using the backend functionality has definately benefits:
  * Working in a team: it allows for **collaboration**, the remote state will be **available** for the whole team.
  * The state file is not stored locally. Possible **sensitive information** is now only stored in the remote state.
  * Some backends will enable **remote operations**. The terraform apply will then run completely remote. These are called **Enhenced Backends**, Refer: https://www.terraform.io/docs/backends/types/index.html 
* There are 2 steps to configure a remote state:
  * Add the backend code to a .tf file.
  * Run the initialization process.
  
* To configure a consul remote store, you can add a file backend.tf with the followings
 
        terraform{
          backend "consul"{
	    address = "demo.consul.io"  # hostname of consul cluster
	    path = "terraform/mypriject"
	  }
        }
* You can also store your state in S3:

          terraform {
	    backend "s3"{
	      bucket = "mybucket"
	      key = "terraform/myproject"
	      region = "ap-south-1"
	    }
	  }
	  
* When using an S3 remote state, it's best to configure the AWS credential using CLI.

        $ aws configure
	  AWS Access Key ID []: AWS Keys
	  AWS Secret Access Key []: AWS_Secret_Access_Key
	  Default regon name []: ap-south-1
	  Default output format [None]:
	  
* Next step, $ terraform init <-|   # It will ask for region if not mentioned in the file.

* Using a **remote store** for the terraform state it will ensure that you always have a **latest version** of the state.
* It avoids having to **commit** and **push** the terraform.tfstate to to version control.
* Terraform remote stores don't always support **locking**
  * The documentation always mentions if loacking is available for remote store.
* S3 and Consul supports it.
* You can also specify a (read-only) remote store directly in the .tf file.

          data "terraform_remote_state" "aws-state" {
	    backend = "s3"
	    config {
	      bucket = "terraform-state"
	      key = "terraform.tfstate"
	      access_key = "${var.AWS_ACCESS_KEY}"
	      secret_key = "${var.AWS_SECRET_KEY}"
	      region = "${var.AWS_REGION}"
	    }
	  }
* This is only useful as a read only feed from your remote file. Its data source
* Useful to generate outputs.

**Lets Do the practical which will be coping state file remote S3 bucket**

Steps:
1) Crate a S3 bucket, in this I have given name "terraformstate99"
2) In you Terraform Host activate AWS CLI.

       $ aws configure
         AWS Access Key ID []: AWS Keys
         AWS Secret Access Key []: AWS_Secret_Access_Key
         Default regon name []: ap-south-1
         Default output format [None]:
3) Create a file call "backend.tf" and then run terraform init - plan - apply, and then at last destroy.
   You can copy the content of **remote_State** directory attached in this Repo and can run it. Here is sample of backend.tf.
   
        terraform {
	   backend "s3" {
	   bucket = "terraformstate99"		# My S3 bucket name
	   key = "terraformfolder/tfstatefile"  # new folder and state file inside "terraformstate99" bucket
	   region = "ap-south-1"		# If you do not mention region then while "terraform init" it will ask region
	   }
         }


### Data Sources:

* For certain providers (like AWS), terraform provides datasources.
* Datasources provide you with dynamic information.
* A lot of data is available by AWS in a structured format using their API
* Terraform also exposes this information using data sources.
* Example:
  * List of AMIs
  * List of availability Zones.
* Another great example is the datasource that gives you all IP addresses **in use** by AWS.
* This is great if you want to filter traffic based on an AWS region.
  * e.g. allow all traffic from amazon instance in Europe.
* Filtering traffic in AWS can be done using **security group**
  * Incoming and outgoing traffic can be filtered by protocol like TCP, UDP, ICMP etc. IP range and port.
  * Similar to IP Tables or a firewall appliances.
  
Example: Filtering European Traffic.

       data "aws_ip_ranges" "european_ec2"{
	  regions = ["eu-west-1", "eu-central-1"]
	  services = ["ec2"]
       }

        resource "aws_security_group" "from_europe" {
	   name = "from_europe"

	   ingress {
	      from_port = "443"
	      to_port = "443"
	      protocol = "tcp"
	      cidr_blocks = ["${data.aws_ip_ranges.european_ec2.cidr_blocks}"]
	   }

	   tags {
		CreateDate = "${data.aws_ip_ranges.european_ec2.create_date}"
		SyncToken = "${data.aws_ip_ranges.european_ec2.sync_token}"
	    }
        }
Ref Link of Data Source: https://www.terraform.io/docs/providers/aws/

**You can try it, code uploaded in the directory call dataSources in this Repo** . And then check our SG inbound list & Tags.


### Template provider:

* The template provider can help creating **customized configuration files**
* You can build templates based on variables from terraform resource attributes (e.g. a public IP addresses)
* The result is a string that can be used as a variable in terraform.
  * The string contains a templete.
  * e.g. a configuration file
* This can be used to create generic templates or cloud init configs.
* In AWS, you can pass commands that need to be executed when the instance starts for first time.
* In AWS, thisis called "user-data"
* If you want to pass user-data that depends on other info in terraform (e.g. IP addresses), you can use the provider template.
* There's a seperate section on userdata in this course. It will come under section "Terraform with AWS"

* First you create a template file:

        #!/bin/bash
        echo "database-ip = ${myip}" >> /etc/myapp.config
	
* Then you create a template_file resource that will read the template file and replace ${myip} with the IP Address of an AWS instance created by terraform.

        data "template_file" "my-template" {
	  template = "${file(templates/init.tpl)}"
	  
	  vars {
	    myip = "${aws_instance.database1.private_ip}"
	  }
        }

* Then you can use the my-template resource when creating a new instance
          
	  Create a web server
	  resource "aws_instance" "web"{
	    # ...
	    user_data = "${data.template_file.mytemplate.rendered}"
	  }
	  
* When terraform runs, it will see that it first needs to spin up the databases1 instance, then generate the template, and only then spin up the web instances.
* The web instance will have the template injected in the user_data and when it launces, the user-data will create a file "/etc/myapp.config" with the IP address of the database.


### Other Providers:
* Terraform supports other cloud providers like
  * Google Cloud
  * Azure
  * Heroku
  * Digital Ocean
* And for on-premises / private cloud: use VMware vCloud / vSphere / OpenStack

* It also involve in 
  * Datadog - Monitoring
  * GitHub - version control
  * Mailgun - emailing (SMTP)
  * DNSSimple / DNSMadeEasy / UltraDNS - DNS provider
Full List: https://www.terraform.io/docs/providers/



### Modules:

* You can use modules to make your terraform more organized.
* Use **third party** modules
  * Modules from github
* **Reuse** parts of your code
  * e.g. to setup network in AWS - the Virtual Private Network (VPC)
  
* If you use module from github
  
        module "module-example" {
          source = "github.com/bdas99/terraform-module-example"
        }
* If you wanted to use module from local folder.

        module "module-example" {
	  source = "./module-example"
        }

* Pass arguments to module like region, ip-range, cluster-size etc.

        module "module-example" {
	  source = "./module-example"
	  region = "ap-south-1"
	  ip-range = "10.0.0.0/8"
	  cluster-size = "3"
         }


* Inside the module folder, you just have again terraform files: See the below module as example

File: module-example/vars.tf

        variable "region" {}  # the input parameters
	variable "ip-range" {}
	variable "cluster-size" {}

File: module-example/cluster.tf

        # vars can be used here
	resource "aws_instance" "instance-1" {...}
	resource "aws_instance" "instance-2" {...}
	resource "aws_instance" "instance-3" {...}

File: module-example/output.tf

        output "aws-cluster" {
	  value = "${aws_instance.instance-1.public_ip}, ${aws_instance.instance-2.public_ip}, ${aws_instance.instance-3.public_ip}"
	}
	
	
* Use the **output** from the module in the main part of your code:

         output "some-output" {
	   value = "${module.module-example.aws-cluster}"
	  }

We are using output resource here, but you can use the variables anywhere on the terraform code.


### External Module:

Try to run this external module: Steps -
1) Copy all the files from externalModule Repo to your terraform host.
2) Create keys - ssh-keygen -f mykey
3) Run terraform get - this will download the external module from git. https://github.com/wardviaene/terraform-consul-module
4) You can see those modules downloaded under .../.terraform/modules/consul
5) Now spin up instance, terraform init -> plan -> apply -> destroy (destroy will terminate full cluster)


### Terraform Command Overview:

* Terraform is very much focused on the resource definition.
* It has a **limited toolset** available to modigy, import, create these resource definition.
* There is an external tool called **terraforming** that you can use for now, but it will take you quite time to convert your current infrastructure to managed terraform infrastructure (https://github.com/dtan4/terraforming)

Commands:
terraform apply - Applies state
terraform destroy - Destroy all terraform managed state.
terraform fmt - Rewrite terraform configuration files to a canonical format and style.
terraform get - Download and update module
terraform graph - Create a visual re-presentation of a configuration or execution plan
terraform import [options] ADDRESS ID - Import will try and find the infrastructure resource identified with ID and import
                                        the state into terraform.tfstate with resource id ADDRESS.
terraform output [options] [NAME] - Output any of your resources. Using NAME will only output a specific resources.
terraform plan - It shows the chages to be made to the infrastructure.
terraform push - Push changes to Atlas, Hashicorp's Enterprise tool that can automatically run terraform from centralize server.
terraform refresh - Refresh the remote state. Can identify differences between state file and remote state.
terraform remote - Configure remote state storage.
terraform show - It will show human readable output from a state or a plan.
terraform state - Use this command for advance state management, e.g. Rename a resource with terraform state mv aws_instance.example aws_instance.production.
terraform taint - Manually mark resource as tainted, meaning it will be destructed and recreated at the next apply.
terraform validate - validate your terraform syntax
terraform untaint - undo a taint.


