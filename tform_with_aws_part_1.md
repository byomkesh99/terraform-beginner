## Terraform with AWS Part -I:

### Introduction to VPC - Part-1

* On Amazon AWS, you have a default VPC (**Virtual Private Network**) created for you by AWS to launch instances in
* Up till now we used **default** VPC.
* VPC isolates the instances on a network level. Its like your **own private network** in the cloud.
* Best practice is to always launch your instances in a VPC.
    * the default VPC
    * or one you create yourself (managed by terraform)

* There is also **EC2-Classic**, which is basically one Big network where all AWS customers could launch their instances in.
* For smaller to medium setups, **one VPC** (per region) will be suitable for your needs.
* An instance launched in one VPC can never communicate with an instance in an other VPC using private IP Addresses.
  * They could communicate still, but using their public IP (but not recommended)
  * You could also link 2 VPC's, called VPC Peering.
  

### Introduction to VPC - Part-2

* On Amazon AWS, you start by creating your own **virtual private network** to deploy your instances (servers) / databases.
* This VPC uses the **10.0.0.0/16** addressing space, allowing you to use the IP addresses that start with "10.0.x.x"
* This VPC coveres the **ap-south-1 region**, which Amazon AWS Region in Mumbai.

Example-1:

![alt]()

**AWS Private Subnets Range**

| Range          | From        |  To             |
| -------------- |:-----------:|:---------------:|
| 10.0.0.0/8     | 10.0.0.0    | 10.255.255.255  |
| 172.16.0.0/12  | 172.16.0.0  | 172.31.255.255  |
| 192.168.0.0/16 | 192.168.0.0 | 192.168.255.255 |


### Introduction to VPC - Part-3

Look at the above image -

* ALL AZ's are having Public and Private subnets
* Instances started in subnet **main public-3** will have IP address **10.0.3.x** and will be launched in the ap-south-1c AZ.
* An instance launched in **main-private-1** will have an IP address **10.0.4.x** and will reside in Amazon's ap-south-1a AZ.
* All public subnets will attached with Internet-gateway (IGW).
* Private instances will not have any connection to Internet directly, NAT gateway allow to route traffic to Internet.
* 


