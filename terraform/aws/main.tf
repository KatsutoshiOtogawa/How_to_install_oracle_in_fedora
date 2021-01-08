terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "main_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "oracle_vpc"
    terraform = "How_to_install_oracle_in_fedora"
  }
}

resource "aws_internet_gateway" "main_gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "oracle_gw"
    terraform = "How_to_install_oracle_in_fedora"
  }
}

resource "aws_egress_only_internet_gateway" "egress_gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "oracle_routing"
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
    Name = "oracle_routing"
    terraform = "How_to_install_oracle_in_fedora"
  }
}

resource "aws_subnet" "main_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  #  = aws_internet_gateway.main_gw
  availability_zone = 'ap-northeast-1a'
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "oracle_subnet"
    terraform = "How_to_install_oracle_in_fedora"
  }
}

resource "aws_security_group" "web_server_sg" {
  name        = "web_server"
  description = "Allow http and https traffic."
  vpc_id      = aws_vpc.main_vpc.id
  tags = {
    Name = "oracle_sg"
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

resource "aws_security_group_rule" "outbound_oracle" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  security_group_id = aws_security_group.web_server_sg.id
}

resource "aws_eip" "main_eip" {
  vpc                       = true
  instance                  = aws_instance.How_to_install_oracle_in_fedora.id
  associate_with_private_ip = aws_instance.How_to_install_oracle_in_fedora.private_ip
  depends_on                = [aws_internet_gateway.main_gw]

  tags = {
      terraform = "How_to_install_oracle_in_fedora"
  }
}

# resource "aws_eip" "nat_eip" {
#   vpc                       = true
#   depends_on                = [aws_internet_gateway.main_gw]

#   tags = {
#       Name = "oracle_nat_ip"
#       terraform = "How_to_install_oracle_in_fedora"
#   }
# }

# resource "aws_nat_gateway" "main_nat" {
#   subnet_id     = aws_subnet.main_subnet.id
#   # allocation_id = aws_eip.main_eip.id
#   allocation_id = aws_eip.nat_eip.id
  

#   tags = {
#       Name = "oracle_nat"
#       terraform = "How_to_install_oracle_in_fedora"
#   }
# }

# resource "aws_spot_instance_request"

resource "aws_instance" "How_to_install_oracle_in_fedora" {
    
    # from marketplace https://alt.fedoraproject.org/cloud/
    # fedora33
    ami = "ami-0d3ac0b331a940336"
    instance_type = "t2.micro"
    private_ip = "10.0.2.5"
    # you use instance ssh-key name. check command *aws ec2 describe-key-pairs*.
    key_name = "id_rsa"

    # assign subnet to ec2
    subnet_id = aws_subnet.main_subnet.id
    
    tags = {
      Name = "oracle_instance"
      terraform = "How_to_install_oracle_in_fedora"
    }
}

resource "null_resource" "testinstance" {

  depends_on = [
    aws_instance.How_to_install_oracle_in_fedora
    # ,aws_nat_gateway.main_nat
  ]

  connection {
            # host = aws_eip.main_eip.public_ip
            # host = aws_instance.How_to_install_oracle_in_fedora.public_dns
            host = aws_instance.How_to_install_oracle_in_fedora.public_ip
            type = "ssh"
            user = "ec2_user"
            private_key = file("~/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    script = "./provision.sh"
  }
  provisioner "remote-exec" {
    script = "../../provision.sh"
    
  }
}

output "public_ip_address" {
  value = aws_instance.How_to_install_oracle_in_fedora.public_ip
}

output "public_dns_name" {
  value = aws_instance.How_to_install_oracle_in_fedora.public_dns
}

output "instance_id" {
  value = aws_instance.How_to_install_oracle_in_fedora.id
}