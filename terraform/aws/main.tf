terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

data "template_file" "user_data" {
  template = file("../../provision.sh")
  vars = {
    ORACLE_PASSWORD = ""
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "main_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    terraform = "How_to_install_oracle_in_fedora"
  }
}

resource "aws_internet_gateway" "main_gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    terraform = "How_to_install_oracle_in_fedora"
  }
}

resource "aws_egress_only_internet_gateway" "egress_gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "main_route" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.egress_gw.id
  }

  tags = {
    terraform = "How_to_install_oracle_in_fedora"
  }
}

resource "aws_subnet" "main_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    terraform = "How_to_install_oracle_in_fedora"
  }
}

resource "aws_security_group" "web_server_sg" {
  name        = "web_server"
  description = "Allow http and https traffic."
  vpc_id      = aws_vpc.main_vpc.id
  tags = {
    terraform = "How_to_install_oracle_in_fedora"
  }
}

resource "aws_security_group_rule" "inbound_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  security_group_id = aws_security_group.web_server_sg.id
}

resource "aws_security_group_rule" "inbound_oracle" {
  type        = "ingress"
  from_port   = 1521
  to_port     = 1521
  protocol    = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  security_group_id = aws_security_group.web_server_sg.id
}

resource "aws_eip" "main_eip" {
  vpc                       = true
  instance                  = aws_instance.How_to_install_oracle_in_fedora.id
  # associate_with_private_ip = "10.0.0.12"
  depends_on                = [aws_internet_gateway.main_gw]

  tags = {
      project = "How_to_install_oracle_in_fedora"
    }
}

resource "aws_instance" "How_to_install_oracle_in_fedora" {
    
    # from marketplace https://alt.fedoraproject.org/cloud/
    # fedora33
    ami = "ami-0d3ac0b331a940336"
    instance_type = "t2.micro"
    # you use instance ssh-key name. check command *aws ec2 describe-key-pairs*.
    key_name = "aws.rsa"

    # assign subnet to ec2
    subnet_id = aws_subnet.main_subnet.id

    # user_data = file("../provision.sh")
    # user_data = data.template_file.user_data.rendered
    user_data = <<END
#!/bin/bash
    dnf install -y python3
    dnf install -y https://s3.region.amazonaws.com/amazon-ssm-region/latest/linux_amd64/amazon-ssm-agent.rpm
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
END
    tags = {
      project = "How_to_install_oracle_in_fedora"
      Name = "Oracle instance"
    }
    
}

output "public_ip_address" {
  value = aws_eip.main_eip.public_ip
}

output "public_dns_name" {
  value = aws_eip.main_eip.public_dns
}

output "instance_id" {
  value = aws_instance.How_to_install_oracle_in_fedora.id
}