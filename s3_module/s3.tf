provider "aws" {
region = "us-east-1"
profile = "linuxacademy"
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



