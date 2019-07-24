# terraform-beginner

Terraform -
* Infrastrucure as code.
* Automation of your infrastructure.
* Keep your infratructure in a certain state(complaint)
    * E.g. 2 web instance with 2 volumes, and 1 load balancer.
* Make your infrastructure auditable
    * You can keep your infrastructure change history in a version control system like GIT.

* Ansible, Chef, Puppet, Saltstack have a focus on automating the installation and configuration of software.
    * Keeping the machines in compliance in a certain state.

* Terraform can automate provisioning of the infrastructure itself.
    e.g. Using the AWS, Digital Ocean, Azure API's
  
* Works well with automation software like ansible to install software after the infrastructure is provisioned.


### Terraform Installation:

For Linux only:
Go to https://www.terraform.io/ site, click on DOWNLOAD -> for Linux select the architechture 32/64 bit as per your system arc.
In my case under user home directory /home/tuser hitting command 

wget https://releases.hashicorp.com/terraform/0.12.5/terraform_0.12.5_linux_amd64.zip 

This will download the terraform zip file, unzip it by using unzip terraform_0.12.5_linux_amd64.zip and then you will get file "terraform". This "terraform" file you have to use for all the operations henceforth. So it need to add it either on </home/tuser/bin> dir or add the current current path to profile.

Example: 

    $ mkdir /home/tuser/bin 
    $ mv terraform //home/tuser/bin     # Note: tuser is a user in my Linux Box
    OR
    $ export PATH=/home/tuser/terraform:$PATH
    $ source ~/.bash_profile
         
Now test it with the following command:

$ terraform -help or -version  # see the output


### Terraform Basics:
* Spinning up an instance on AWS. The following things are needed for it.
  * Open AWS Account (Free Tier: https://aws.amazon.com/console/). 
  * Create IAM admin user
  * Create terraform file to spin up t2.micro instance
  * Run terraform apply
  
Now we spin up new EC2 instance by using terraform. 
We need one IAM user (system-admin or network-admin role is enough, not require AdministratorAccess) for "Access Key" and "Secret Access Key" to kickstart EC2 instance.
I have created one user call tform given role of "network-admin". Use this link to know different Job Function "https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_job-functions.html".

Example-1
This is the sample TF file to spin up EC2.

      provider "aws" {
         access_key = "ACCESS_KEY_HERE"
         secret_key = "SECRET_KEY_HERE"
         region     = "us-east-1"
      }

      resource "aws_instance" "example" {
         ami           = "ami-0d729a60"
         instance_type = "t2.micro"
      }

Now put the Access Key, Secret Access Key, Region you wanted to put, ami-id and then run the following command:

* terraform init     # when every there is change in your conf file you must run this "init" command
* terraform plan -out out.terraform      # See the changes
* terraform apply out.terraform          # spin up EC2 instance, it will take some time
* terraform destroy                      # destroy the EC2 instance, i.e. terminating EC2 in this case.

See the bellow out of terraform plan. 

        $terraform plan
        Refreshing Terraform state in-memory prior to plan...
        The refreshed state will be used to calculate this plan, but will not be
        persisted to local or remote state storage.
        
        
        ------------------------------------------------------------------------
        
        An execution plan has been generated and is shown below.
        Resource actions are indicated with the following symbols:
        + create
        
        Terraform will perform the following actions:
        
        # aws_instance.tform_example will be created
        + resource "aws_instance" "tform_example" {
            + ami                          = "ami-0b99c7725b9484f9e"
            + arn                          = (known after apply)
            + associate_public_ip_address  = (known after apply)
            + availability_zone            = (known after apply)
            + cpu_core_count               = (known after apply)
            + cpu_threads_per_core         = (known after apply)
            + get_password_data            = false
            + host_id                      = (known after apply)
            + id                           = (known after apply)
            + instance_state               = (known after apply)
            + instance_type                = "t2.micro"
            + ipv6_address_count           = (known after apply)
            + ipv6_addresses               = (known after apply)
            + key_name                     = (known after apply)
            + network_interface_id         = (known after apply)
            + password_data                = (known after apply)
            + placement_group              = (known after apply)
            + primary_network_interface_id = (known after apply)
            + private_dns                  = (known after apply)
            + private_ip                   = (known after apply)
            + public_dns                   = (known after apply)
            + public_ip                    = (known after apply)
            + security_groups              = (known after apply)
            + source_dest_check            = true
            + subnet_id                    = (known after apply)
            + tenancy                      = (known after apply)
            + volume_tags                  = (known after apply)
            + vpc_security_group_ids       = (known after apply)
        
            + ebs_block_device {
                + delete_on_termination = (known after apply)
                + device_name           = (known after apply)
                + encrypted             = (known after apply)
                + iops                  = (known after apply)
                + snapshot_id           = (known after apply)
                + volume_id             = (known after apply)
                + volume_size           = (known after apply)
                + volume_type           = (known after apply)
                }
        
            + ephemeral_block_device {
                + device_name  = (known after apply)
                + no_device    = (known after apply)
                + virtual_name = (known after apply)
                }
        
            + network_interface {
                + delete_on_termination = (known after apply)
                + device_index          = (known after apply)
                + network_interface_id  = (known after apply)
                }
        
            + root_block_device {
                + delete_on_termination = (known after apply)
                + iops                  = (known after apply)
                + volume_id             = (known after apply)
                + volume_size           = (known after apply)
                + volume_type           = (known after apply)
                }
            }
        
        Plan: 1 to add, 0 to change, 0 to destroy.
        
        ------------------------------------------------------------------------

If you do only "terraform apply" i.e. apply shortcut then this will do "terraform plan -out file; terraform apply file; rm file". You will not going to know the the type of changes you did in a recent change.

So always do "terraform init; terraform plan -out out.terraform; terraform apply out.terraform"

*** DO NOT *** Apply "terraform destroy" directly in the Production, it will destroy/terminate all the resources in your Infrastructure.


### Variables in Terraform:

* Everything in one file is not great.
* Use variables to *Hide Secret*
  * Your AWS credential should not be in the git repository.
  * so that variables mentioned in the files should not be committed in the git repo.
* Use variables for elements that *might change*
  * AMI's are different per region.
* Use variables to make it yourself easier to re-use terraform file.

If you look at above mentioned Example-1 file then you will see "provider" & "resource" type mentioned in single file.
Now we are separating them below:

Resource Details: instance.tf
		
      resource "aws_instance" "example" {
		  ami           = "${lookup(var.AMIS, var.AWS_REGION)}"
		  instance_type = "t2.micro"
		}

Provider Details: provider.tf

    provider "aws" {
		    access_key = "${var.AWS_ACCESS_KEY}"
		    secret_key = "${var.AWS_SECRET_KEY}"
		    region = "${var.AWS_REGION}"
	  }

Variables: vars.tf

    variable "AWS_ACCESS_KEY" {}  # {} means no values here
	 variable "AWS_SECRET_KEY" {}
	 variable "AWS_REGION" { default = "ap-south-1" } # Here values mentioned as region
	 variable "AMIS" {
		  type = "map"
		  default = {
		    ap-south-1 = "ami-0d2692b6acea72ee6"
		    us-east-1 = "ami-035b3c7efe6d061d5
		    us-west-1 = "ami-068670db424b01e9a"
		  }
		}

Real Values: terraform.tfvrs

    AWS_ACCESS_KEY = ""		# Here we will mention the real values of access key
    AWS_SECRET_KEY = ""		# Here we will mention the real values of secret access key
    AWS_REGION = ""		# If we mention nothing/remove this line then default Region pick from vars.tf file
    				# Or you can mention the specific region


Note: Always keep terraform.tfvrs under .gitignore file so that you avoid to pass the real creds to Public

FOI: https://cloud-images.ubuntu.com/locator/ - All Ubuntu AMI images details. In search type "aws <your region>"
     your region = ap-south-1 or us-east-1 or us-west-1 ... etc.
	
Once the above configuration part done, the do the following to start/stop ec2 instance

    $ terraform init
    $ terraform plan -out out.terraform	 # out.terraform - is a binary file
    $ terraform apply out.terraform	 # It takes time to start EC2 isnatnce
    $ terraform show			 # it will display all details which we see in the description part of EC2 Dashboard.
    $ terraform destroy			 # Terminate the EC2 in your infrastructure
