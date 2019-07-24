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
