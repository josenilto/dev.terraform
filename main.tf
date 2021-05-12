provider "aws" {
    profile = "default"
    region = "us-east-2"
}

resource "aws_intance" "dev"{
    ami = "ami-00399ec92321828f5"
    instance_type= "t2.micro"
    key
    tags = {
        Name = "DEV1"
    }
}