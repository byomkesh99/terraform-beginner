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
In my case under user home directory /home/tuser hitting command wget https://releases.hashicorp.com/terraform/0.12.5/terraform_0.12.5_linux_amd64.zip . This will 
