[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)


---

## 📝 Table of Contents

- [About](#about)
- [Deployment](#deployment)
- [Usage](#usage)
- [Built Using](#built_using)
- [Working Snapshots](#work-pics)
- [Authors](#authors)

## 🧐 [About](#about)

This project is based on complete end-to-end automation using the clubbing of technologies - Ansible and Terraform. Main target is to deploy a webserver on EC2 instance, and make the architecture highly available using reliable AWS resources like s3 and CloudFront. Distinctly, this workflow has two parts - setting up the base architecture on AWS services and then deploying the webserver on this architecture.



## 🚀 [Deployment](#deployment) 

Deployment of the project has been made by integration of two automation tools - Terraform (HCL) and Ansible. 

The following architecture is setup using Terraform:-
1. Key pair and security group created
2. S3 created and uploaded an image into it, which makes the image highly available.
3. CloudFront created using the S3 domain to reduce latency.
4. Launched an EC2 instance.
5. Created an EBS volume and attached it to the instance.
6. Mounted the instance storage onto the EBS volume to ensure data availability.

Tasks carried out using Ansible are as follows:-
1. Mounted the document root of HTTPD webserver (/var/www/html) onto the EBS storage.
2. Installed and started the HTTPD webserver package.
3. Configured the configuration file (customized document root) of httpd using jinja template.
4. Copied the simple webpage to the document root directory.
5. Restart httpd idempotently (only when there's a change in the conf. file)


## 🎈 [Usage](#usage) 

The project can be utilised to setup a webserver on AWS with high availability using just a single command. 

To get a complete insight of the working of the project, go through this [article](https://saptarsiroy12.medium.com/automate-webhosting-by-integrating-ansible-with-terraform-3442cafcade8)!


## ⛏️ [Built Using](#built_using)

- [RHEL-8](https://www.redhat.com/en/enterprise-linux-8) - Base OS
- [AWS](https://aws.amazon.com/) - Architecture setup
- [Terraform](https://www.terraform.io/) - Infrastructure as a Code
- [Ansible](https://www.ansible.com/) - Configuration management


## 📊 [Working Snapshots](#work-pics)
<img src="https://raw.githubusercontent.com/SaptarsiRoy/terrafrom-ansible/main/.img/Screenshot%20from%202021-03-23%2012-22-00.png" height="300" width="500">
<br><br>
<img src="https://raw.githubusercontent.com/SaptarsiRoy/terrafrom-ansible/main/.img/Screenshot%20from%202021-03-23%2012-25-45.png" height="300" width="500">
<br><br>
<img src="https://raw.githubusercontent.com/SaptarsiRoy/terrafrom-ansible/main/.img/Screenshot%20from%202021-03-23%2012-25-39.png" height="300" width="500">


## ✍️ [Author]
 [Saptarsi Roy](https://www.linkedin.com/in/saptarsiroy/) - Do connect!
