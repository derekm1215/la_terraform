provider "aws" {
region = "${var.aws_region}"
profile = "${var.aws_profile}"
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

# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"
}

# Create an internet gateway to give our subnet access to the open internet
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
}

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

resource "aws_default_route_table" "private" {
    default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"
    tags {
        Name = "private"
    }
}

# Create a public subnet
resource "aws_subnet" "public" {
  vpc_id= "${aws_vpc.vpc.id}"
  cidr_block= "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1d"

  tags {
    Name = "public"
  }
}

#Associate public subnet with public route table

resource "aws_route_table_association" "public_assoc" {
    subnet_id = "${aws_subnet.public.id}"
    route_table_id = "${aws_route_table.public.id}"
}

#Associate private1 subnet with public route table

resource "aws_route_table_association" "private1_assoc" {
    subnet_id = "${aws_subnet.private1.id}"
    route_table_id = "${aws_route_table.public.id}"
}


#Associate private2 subnet with public route table

resource "aws_route_table_association" "private2_assoc" {
    subnet_id = "${aws_subnet.private2.id}"
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

#create S3 VPC endpoint
resource "aws_vpc_endpoint" "private-s3" {
    vpc_id = "${aws_vpc.vpc.id}"
    service_name = "com.amazonaws.${var.aws_region}.s3"
    route_table_ids = ["${aws_vpc.vpc.main_route_table_id}", "${aws_route_table.public.id}"]
    policy = <<POLICY
{
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
        }
    ]
}
POLICY
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

#Public security group to access SSH from only your IP and HTTP
resource "aws_security_group" "public" {
  name= "sg_public"
  description = "Used for public instances"
  vpc_id      = "${aws_vpc.vpc.id}"


# SSH access from your local ip $(curl canhazip.com) for an easy way to find it. 
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
cidr_blocks  = ["0.0.0.0/0"]
 }
}

#RDS Security Group
resource "aws_security_group" "RDS" {
  name= "sg_rds"
  description = "Used for DB instances"
  vpc_id      = "${aws_vpc.vpc.id}"

# SQL access from public security group
ingress {
from_port    = 3306
to_port      = 3306
protocol     = "tcp"
security_groups  = ["${aws_security_group.public.id}", "${aws_security_group.private.id}"]
 }
}

resource "aws_db_instance" "db" {
    allocated_storage 		= 10
    engine			= "mysql"
    engine_version		= "5.6.27"
    instance_class		= "${var.db_instance_class}"
    name			= "${var.dbname}"
    username			= "${var.dbuser}"
    password			= "${var.dbpass}"
    db_subnet_group_name        = "rds_subnetgroup"                                                                                         vpc_security_group_ids      = ["${aws_security_group.RDS.id}"]

}

# Create AWS key pair from local key

resource "aws_key_pair" "auth" {
    key_name    = "${var.key_name}"
    public_key  = "${file(var.public_key_path)}"
}


# Create S3 buckets code and media

resource "aws_s3_bucket" "code" {  
    bucket = "${var.domain_name}_code1115"  
    acl = "private"  
    force_destroy = true
tags {  
Name = "code bucket"  
  
  }  
}  
  
resource "aws_s3_bucket" "media" {
bucket = "${var.domain_name}_media1115"
acl = "private"
force_destroy = true

tags {
Name = "media bucket"
  }
}


# Create the master dev server

resource "aws_instance" "dev" {
  instance_type = "${var.dev_instance_type}"
  ami = "${var.dev_ami}"
  tags {
      Name = "dev"
  }

  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.public.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.s3_access.id}"

# We send the pubIP and code bucket info of the instance to the aws_hosts file for use with Ansible

  provisioner "local-exec" {
      command = "cat <<EOF > aws_hosts 
[dev] 
${aws_instance.dev.public_ip}
[dev:vars]
s3code=${aws_s3_bucket.code.bucket}
EOF"
  }


  subnet_id = "${aws_subnet.public.id}"

# Ansible Playbook for software install
  provisioner "local-exec" {
      command = "sleep 6m && ansible-playbook -i aws_hosts wordpress.yml"
  }
}

# Create the load balancer

resource "aws_elb" "prod" {
  name = "${var.domain_name}-prod-elb"    
  subnets = ["${aws_subnet.private1.id}", "${aws_subnet.private2.id}"]
  security_groups = ["${aws_security_group.public.id}"]
  listener { 
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = "${var.elb_healthy_threshold}"
    unhealthy_threshold = "${var.elb_unhealthy_threshold}"
    timeout = "${var.elb_timeout}"
    target = "HTTP:80/"
    interval = "${var.elb_interval}"
  }

  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400
  
  tags {
    Name = "${var.domain_name}-prod-elb"
  }
}


resource "random_id" "ami" {
 byte_length = 8
}

resource "aws_ami_from_instance" "golden" {
    name = "ami-${random_id.ami.b64}"
    source_instance_id = "${aws_instance.dev.id}"
    provisioner "local-exec" {
      command = "cat <<EOF > userdata
#!/bin/bash
/usr/bin/aws s3 sync s3://${aws_s3_bucket.code.bucket} /var/www/html/
/bin/touch /var/spool/cron/root
sudo /bin/echo '*/5 * * * * aws s3 sync s3://${aws_s3_bucket.code.bucket} /var/www/html/' >> /var/spool/cron/root
EOF"
 }
}

# Create Launch configuration from dev ami

resource "aws_launch_configuration" "lc" {
    name_prefix   = "lc-"
    image_id      = "${aws_ami_from_instance.golden.id}"
    instance_type = "${var.lc_instance_type}"
    security_groups = ["${aws_security_group.private.id}"]
    iam_instance_profile = "${aws_iam_instance_profile.s3_access.id}"
    key_name = "${aws_key_pair.auth.id}"
    user_data = "${file("userdata")}"
    lifecycle {
      create_before_destroy = true
    }
}

resource "random_id" "asg" {
 byte_length = 8
}


resource "aws_autoscaling_group" "asg" {
    availability_zones = ["${var.aws_region}a", "${var.aws_region}c"]
    name = "asg-${aws_launch_configuration.lc.id}" 
    max_size = "${var.asg_max}"
    min_size = "${var.asg_min}"
    health_check_grace_period = "${var.asg_grace}"
    health_check_type = "${var.asg_hct}"
    desired_capacity = "${var.asg_cap}"
    force_delete = true
    load_balancers = ["${aws_elb.prod.id}"]
    vpc_zone_identifier = ["${aws_subnet.private1.id}", "${aws_subnet.private2.id}"]
    launch_configuration = "${aws_launch_configuration.lc.name}"
    
    tag {
      key = "Name"
      value = "asg-instance"
      propagate_at_launch = true
    }

    lifecycle {
      create_before_destroy = true
    }
}


resource "aws_route53_zone" "primary" {
    name = "${var.domain_name}.com"
    delegation_set_id = "${var.delegation_set}"
}


resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name = "www.${var.domain_name}.com"
  type = "A"

  alias { 
    name = "${aws_elb.prod.dns_name}"
    zone_id = "${aws_elb.prod.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "dev" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name = "dev.${var.domain_name}.com"
  type = "A"
  ttl = "300"
  records = ["${aws_instance.dev.public_ip}"]
}

resource "aws_route53_record" "db" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name = "db.${var.domain_name}.com"
  type = "CNAME"
  ttl = "300"
  records = ["${aws_db_instance.db.address}"]
}








