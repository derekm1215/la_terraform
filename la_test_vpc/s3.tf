variable "aws_region" {}


provider "aws" {
region = "${var.aws_region}"
profile = "linuxacademy"
}

resource "aws_vpc" "vpc" {
    cidr_block = "10.1.0.0/16"
}


resource "aws_default_route_table" "default" {
    default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"
    tags {
        Name = "default"
    }
}

resource "aws_vpc_endpoint" "private-s3" {
    vpc_id = "${aws_vpc.vpc.id}"
    service_name = "com.amazonaws.${var.aws_region}.s3"
    route_table_ids = ["${aws_vpc.vpc.main_route_table_id}"]
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
