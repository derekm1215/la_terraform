provider "aws" {
    region = "us-east-1"
}

resource "aws_key_pair" "auth" {
    key_name    = "${var.key_name}"
    public_key  = "${file(var.public_key_path)}"
}

resource "aws_instance" "golden_ami" {
instance_type = "t2.micro"
ami = "ami-fce3c696"

key_name = "${aws_key_pair.auth.id}"
vpc_security_group_ids = ["${aws_security_group.Public.id}"]

# We're going to launch into the public subnet for this.
# Normally, in production environments, webservers would be in
# private subnets.
subnet_id = "${aws_subnet.public.id}"


# Ansible Playbook
provisioner "local-exec" {
inline = [
"ssh-agent bash
ssh-add ~/.ssh/dmorgantest
echo 'this is where we run Ansible'"
]
    }
}
