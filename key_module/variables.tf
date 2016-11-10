variable "public_key_path" {
    description = <<DESCRIPTION
 Path to the SSH public key. 
 Ensure this keypair is added 
 to your local SSH agent so provisioners
 can connect.

Example: ~/.ssh/terrraform.pub
DESCRIPTION
}

variable "key_name" {
  description = "Desired name of AWS key pair"
}

variable "aws_region" {
  default = "us-east-1"
}
