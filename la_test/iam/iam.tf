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















