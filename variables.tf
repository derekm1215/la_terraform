variable "localip" {}

variable "aws_profile" {}

variable "dbname" {}

variable "dbuser" {}

variable "dbpass" {}

variable "db_instance_class" {}

variable "dev_instance_type" {}

variable "lc_instance_type" {}

variable "dev_ami" {}

variable "elb_healthy_threshold" {}

variable "elb_unhealthy_threshold" {}

variable "elb_timeout" {}

variable "elb_interval" {}

variable "asg_max" {}

variable "asg_min" {}

variable "asg_grace" {}

variable "asg_hct" {}

variable "asg_cap" {}

variable "public_key_path" {
    description = <<DESCRIPTION
 Path to the SSH public key.
 Ensure this keypair is added
 to your local SSH agent so provisioners
 can connect.

Example: ~/.ssh/my_key.pub
DESCRIPTION
}

variable "key_name" {
  description = "Desired name of AWS key pair"
}

variable "aws_region" {
  description = "example: us-east-1"
}


variable "domain_name" {
  description = "Only enter the domain portion. Do not enter the TLD. example: linuxsuperhero"
}

variable "delegation_set" {
    description = <<DESCRIPTION
 This is obtained from
 aws route53 create-reusable-delegation-set --caller-reference 1234
 It will be a 14 digit alphanumeric string.
DESCRIPTION
}

