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
In my case under user home directory /home/tuser hitting command wget https://releases.hashicorp.com/terraform/0.12.5/terraform_0.12.5_linux_amd64.zip . This will download the terraform zip file, unzip it by using unzip terraform_0.12.5_linux_amd64.zip and then you will get file "terraform". This "terraform" file you have to use for all the operations henceforth. So it need to add it either on </home/tuser/bin> dir or add the current current path to profile.

Example: mkdir /home/tuser/bin 
         mv terraform //home/tuser/bin     # Note: tuser is a user of my Linux Box
         OR
         $ export PATH=/home/tuser/terraform:$PATH
         $ source ~/.bash_profile
         
Now test it with the following command:
$ terraform -help or -version  # see the output


