provider "aws" {
    region = "us-east-1"
}

resource "aws_key_pair" "auth" {
    key_name	= "${var.key_name}"
    public_key	= "${file(var.public_key_path)}"
}
