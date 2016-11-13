provider "aws" {
    region = "us-east-1"
  }


resource "aws_key_pair" "auth" {
key_name    = "dmorgantest4"
public_key  = "${file("~/.ssh/dmorgantest3.pub")}"
}


resource "aws_instance" "test" {
  instance_type = "t2.micro"
  ami = "ami-b73b63a0"
  key_name = "${aws_key_pair.auth.id}"
  provisioner "local-exec" {
      command = "echo [dev] > ~/la_terraform/aws_hosts && echo ${aws_instance.test.public_ip} >> ~/la_terraform/aws_hosts"
  }
}
