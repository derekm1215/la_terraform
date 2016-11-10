provider "aws" {
region = "us-east-1"
profile = "linuxacademy"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"
}

# Create an internet gateway to give our subnet access to the open internet
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
}

# Give the VPC internet access on its main route table
# resource "aws_route" "internet_access" {
#  route_table_id= "${aws_vpc.vpc.id}"
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id= "${aws_internet_gateway.internet-gateway.id}"
#}

resource "aws_route_table" "public" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
	 cidr_block = "0.0.0.0/0"
	 gateway_id= "${aws_internet_gateway.internet-gateway.id}"
	 }

    tags {
        Name = "public"
    }
}


# Create a public subnet
resource "aws_subnet" "public" {
  vpc_id= "${aws_vpc.vpc.id}"
  cidr_block= "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

  tags {
    Name = "Public"
  }
}

# Create a private subnet
resource "aws_subnet" "private1" {
  vpc_id= "${aws_vpc.vpc.id}"
  cidr_block= "10.1.2.0/24"
  map_public_ip_on_launch = true
   availability_zone = "us-east-1a"

  tags {
    Name = "Private1"
  }
}

# Create a private subnet
resource "aws_subnet" "private2" {
  vpc_id= "${aws_vpc.vpc.id}"
  cidr_block= "10.1.3.0/24"
  map_public_ip_on_launch = false
   availability_zone = "us-east-1c"

  tags {
    Name = "Private2"
  }
}

# Create RDS Subnet 1
resource "aws_subnet" "RDS1" {
  vpc_id= "${aws_vpc.vpc.id}"
  cidr_block= "10.1.4.0/24"
  map_public_ip_on_launch = false
   availability_zone = "us-east-1a"

  tags {
    Name = "RDS1"
  }
}

# Create RDS subnet 2
resource "aws_subnet" "RDS2" {
  vpc_id= "${aws_vpc.vpc.id}"
  cidr_block= "10.1.5.0/24"
  map_public_ip_on_launch = false
   availability_zone = "us-east-1c"

  tags {
    Name = "RDS2"
  }
}

# Create RDS subnet 3
resource "aws_subnet" "RDS3" {
  vpc_id= "${aws_vpc.vpc.id}"
  cidr_block= "10.1.6.0/24"
  map_public_ip_on_launch = false
   availability_zone = "us-east-1d"

  tags {
    Name = "RDS3"
  }
}

#Our default security group to access SSH,HTTP
resource "aws_security_group" "Public" {
  name= "sg_public"
  description = "Used for public instances"
  vpc_id      = "${aws_vpc.vpc.id}"


# SSH access from anywhere
ingress {
from_port    = 22
to_port      = 22
protocol     = "tcp"
cidr_blocks  = ["${var.localip}"]
 }

# HTTP access from the VPC
ingress {
from_port    = 80
to_port      = 80
protocol     = "tcp"
cidr_blocks  = ["0.0.0.0/0"]
 } 


# Outbound internet access
egress {
from_port    = 0
to_port      = 0
protocol     = "-1" # all protocols
cidr_blocks  = ["0.0.0.0/0"]
 }
}






