terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.10.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Input Variables
variable "vpc_id" {
  type    = string
  default = "	vpc-08deb7a1655ddf9e8" # Replace with the actual VPC ID
}

variable "security_group_id" {
  type    = string
  default = "sg-0321c7a8eb1f4b69b" # Replace with the actual security group ID
}

variable "public_subnet_id" {
  type    = string
  default = "subnet-02a378398b9885f73" # Replace with the actual public subnet ID
}

data "aws_ami" "amzlinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*"] #	amzn2-ami-kernel-5.10-hvm-2.0.20230727.0-x86_64-gp2
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Canonical
}

resource "aws_instance" "web" {
  #count         = "2"
  ami           = data.aws_ami.amzlinux.id
  instance_type = "t2.micro"
  key_name      = "demo-kp"
  user_data     = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install nginx -y
  sudo systemctl start nginx
  sudo systemctl enable nginx
  sudo echo '<h1>Hello All & Welcome to Devops Class-Terraform </h1>' > /usr/share/nginx/html/index.html
  sudo echo '<h2>This server was launched using terraform and nginx as the webserverAll </h2>' >> /usr/share/nginx/html/index.html
  EOF
  #/usr/share/nginx/html
  vpc_security_group_ids      = [var.security_group_id] # Attach the specified security group
  subnet_id                   = var.public_subnet_id    # Use the specified public subnet
  associate_public_ip_address = true

  tags = {
    Name = "HelloWorld-svr"
  }
}
