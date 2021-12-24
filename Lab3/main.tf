provider "aws" {
  region = "us-east-2"
  access_key = "AKIAU5756W5HA4WLSMNU"
  secret_key = "" 
}

data "aws_availability_zones" "available" {}

resource "aws_instance" "server" {
  ami                    = "ami-0fb653ca2d3203ac1"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.server.id]
  tags = {
    Name = "TestInstance"
  }
}

resource "aws_security_group" "server" {

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Created security group"
  }

}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "Subnet 1"
  }
}
