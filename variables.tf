variable "localip" {
    default = "76.24.28.162/32"
}

variable "aws_profile" {
    default = "linuxacademy"
}

variable "dbuser" {
    default = "dmorgan"
}

variable "dbpass" {
    default = "dmorgantest"
}

variable "public_key_path" {
    description = <<DESCRIPTION
 Path to the SSH public key.
 Ensure this keypair is added
 to your local SSH agent so provisioners
 can connect.

Example: ~/.ssh/my_key.pub
DESCRIPTION
    default = "~/.ssh/my_key.pub"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "my_key"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "s3_endpoint" {
  default = "com.amazonaws.us-east-1.s3"
}

variable "domain_name" {
  default = "linuxsuperhero"
}

variable "delegation_set" {
  default = "N3GTFFZI1MK1ON"
}

