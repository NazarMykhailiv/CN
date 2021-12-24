provider "aws" {
  region = "us-east-2"
  access_key = "AKIAU5756W5HA4WLSMNU"
  secret_key = ""
}

data "aws_availability_zones" "available"{}

data "aws_ami" "latest_ubuntu"{
  owners=["339298137934"]
  most_recent = true
  filter{
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}


resource "aws_security_group" "MyUbuntu"{
  name = "Dynamic Security Group"

  dynamic "ingress"{
    for_each = var.allow_ports
    content{
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress{
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Dynamics"
    owner = "Nazar Mykhailiv"
  }
}

resource "aws_launch_configuration" "MyUbuntu" {
  name_prefix = "MyUbuntuServer-H-LC-"
  image_id   = data.aws_ami.latest_ubuntu.id
  instance_type = var.instance_type
  security_groups = [aws_security_group.MyUbuntu.id]
  user_data = "${file("user_data.sh")}"

  lifecycle{
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "MyUbuntu" {
  name                    = "ASG -${aws_launch_configuration.MyUbuntu.name}"
  launch_configuration    = aws_launch_configuration.MyUbuntu.name
  min_size                = 2
  max_size                = 2
  min_elb_capacity        = 2
  vpc_zone_identifier     = [aws_default_subnet.default_az1.id,aws_default_subnet.default_az2.id]
  health_check_type       = "ELB"
  load_balancers          = [aws_elb.MyUbuntu.name]

  dynamic "tag"{
    for_each = {
      Name = "ASG Server"
      Owner = "Nazar Mykhailiv"
      TAGKEY = "TAGVALUE"
    }
    content{
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }
  lifecycle{
  create_before_destroy = true
  }
}

resource "aws_elb" "MyUbuntu"{
  name  = "MyUbuntuServer-ha-elb"
  availability_zones = [data.aws_availability_zones.available.names[0],data.aws_availability_zones.available.names[1]]
  security_groups     =[aws_security_group.MyUbuntu.id]
  listener{
    lb_port     = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
    } 
    health_check{
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 10
    }
    tags = {
      Name = "MyUbuntuServer"

    }

}

resource "aws_default_subnet" "default_az1"{
  availability_zone = data.aws_availability_zones.available.names[0]

}
resource "aws_default_subnet" "default_az2"{
  availability_zone = data.aws_availability_zones.available.names[1]

}
