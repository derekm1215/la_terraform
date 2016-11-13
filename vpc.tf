provider "aws" {
region = "us-east-1"
profile = "linuxacademy"
}
resource "aws_iam_instance_profile" "s3_access" {
    name = "s3_access"
    roles = ["${aws_iam_role.s3_access.name}"]
}

resource "aws_iam_role_policy" "s3_access_policy" {
    name = "s3_access_policy"
    role = "${aws_iam_role.s3_access.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "s3_access" {
    name = "s3_access"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
  },
      "Effect": "Allow",
      "Sid": ""
      }
    ]
}
EOF
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

#Associate public subnet with public route table

resource "aws_route_table_association" "a" {
    subnet_id = "${aws_subnet.public.id}"
    route_table_id = "${aws_route_table.public.id}"
}


# Create a private subnet
resource "aws_subnet" "private1" {
  vpc_id= "${aws_vpc.vpc.id}"
  cidr_block= "10.1.2.0/24"
  map_public_ip_on_launch = false
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

resource "aws_db_subnet_group" "rds_subnetgroup" {
  name = "rds_subnetgroup"
    subnet_ids = ["${aws_subnet.RDS1.id}", "${aws_subnet.RDS2.id}", "${aws_subnet.RDS3.id}"]
    
  tags {
    Name = "RDS Subnet Group"
  }
}

#Public security group to access SSH,HTTP
resource "aws_security_group" "Public" {
  name= "sg_public"
  description = "Used for public instances"
  vpc_id      = "${aws_vpc.vpc.id}"


# SSH access from your local ip curl canhazip.com for an easy way to find it. 
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

#Private Security Group
resource "aws_security_group" "private" {
  name        = "sg_private"
  description = "Used for private instances"
  vpc_id      = "${aws_vpc.vpc.id}"
  

# Access from other security groups

ingress {
from_port    = 0
to_port      = 0
protocol     = "-1"
cidr_blocks  = ["10.1.0.0/16"]
}

egress {
from_port    = 0
to_port      = 0
protocol     = "-1"
cidr_blocks  = ["10.1.0.0/16"]
 }
}

#RDS Security Group
resource "aws_security_group" "RDS" {
  name= "sg_rds"
  description = "Used for DB instances"
  vpc_id      = "${aws_vpc.vpc.id}"

# SQL access from Public security group
ingress {
from_port    = 3306
to_port      = 3306
protocol     = "tcp"
security_groups  = ["${aws_security_group.Public.id}", "${aws_security_group.private.id}"]
 }
}

resource "aws_db_instance" "dmorgantest" {
    allocated_storage 		= 10
    engine			= "mysql"
    engine_version		= "5.6.27"
    instance_class		= "db.t1.micro"
    name			= "dmorgandb"
    username			= "${var.dbuser}"
    password			= "${var.dbpass}"
    db_subnet_group_name        = "rds_subnetgroup"
    vpc_security_group_ids      = ["${aws_security_group.RDS.id}"]
   # parameter_group_name	= "default.mysql5.6"
}


# Create S3 buckets code and media

resource "aws_key_pair" "auth" {
    key_name    = "${var.key_name}"
    public_key  = "${file(var.public_key_path)}"
}

resource "aws_s3_bucket" "la_code" {  
    bucket = "la_code1110"  
    acl = "private"  
  
tags {  
Name = "code bucket"  
  
}  
}  
  
resource "aws_s3_bucket" "la_media" {  
    bucket = "la_media1110"  
    acl = "private"  
  
tags {  
Name = "media bucket"  
    }  
}


# Create the master dev server

resource "aws_instance" "golden" {
  instance_type = "t2.micro"
  ami = "ami-b73b63a0"

  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.Public.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.s3_access.id}"
  provisioner "local-exec" {
      command = "echo [dev] > ~/la_terraform/aws_hosts && echo ${aws_instance.golden.public_ip} >> ~/la_terraform/aws_hosts"
  }

# We're going to launch the dev server into a public subnet for setup.
# Production servers in autoscaling group will be launched into private subnets.
  subnet_id = "${aws_subnet.public.id}"

# Ansible Playbook for software install
  provisioner "local-exec" {
      command = "sleep 6m && ansible-playbook -i ~/la_terraform/aws_hosts wordpress.yml"
  }
}


# Create the load balancer

resource "aws_elb" "prod" {
  name = "dmorgansite-prod-elb"    
  subnets = ["${aws_subnet.public.id}"]
  security_groups = ["${aws_security_group.Public.id}"]
  listener { 
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400
  
  tags {
    Name = "dmorgansite-prod-elb"
  }
}

resource "aws_ami_from_instance" "golden" {
    name = "golden-image"
    source_instance_id = "${aws_instance.golden.id}"
}

resource "aws_launch_configuration" "dmorgantest_lc" {
    name_prefix   = "dmorgantest_lc-"
    image_id      = "${aws_ami_from_instance.golden.id}"
    instance_type = "t2.micro"
    security_groups = ["${aws_security_group.private.id}"]
    iam_instance_profile = "${aws_iam_instance_profile.s3_access.id}"
    key_name = "${aws_key_pair.auth.id}"
    user_data = "${file("userdata")}"
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "dmorgantest_asg" {
    availability_zones = ["us-east-1a", "us-east-1c"]
    name = "dmorgantest_asg" 
    max_size = 1
    min_size = 1
    health_check_grace_period = 300
    health_check_type = "ELB"
    desired_capacity = 1
    force_delete = true
    load_balancers = ["${aws_elb.prod.id}"]
    vpc_zone_identifier = ["${aws_subnet.private1.id}", "${aws_subnet.private2.id}"]
    launch_configuration = "${aws_launch_configuration.dmorgantest_lc.name}"
    
    tag {
      key = "Name"
      value = "dmorgantestweb"
      propagate_at_launch = true
    }

    lifecycle {
      create_before_destroy = true
    }
}










