resource "aws_security_group" "sg-new" {
  name        = "${var.project}-${var.environment}-new"
  description = "Allow all traffic"
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.project}-${var.environment}"
  public_key = tls_private_key.key.public_key_openssh
  provisioner "local-exec" {
    command = "echo '${tls_private_key.key.private_key_pem}' > ./testkey.pem ; chmod 400 ./testkey.pem"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ./testkey.pem"
  }
  tags = {
    "Name" = "${var.project}-${var.environment}"
  }
}

resource "aws_instance" "frontend" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.ami-id.id
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg-new.id]
  tags = {
    "Name" = "${var.project}-${var.environment}-frontend"
  }
}

#====================datasource code

data "aws_ami" "ami-id" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${var.project}-${var.environment}-*"]
  }

  filter {
    name   = "tag:project"
    values = [var.project]
  }

  filter {
    name   = "tag:env"
    values = [var.environment]
  }
}

#==================variable code

variable "project" {
  type    = string
  default = "packer"
}

variable "environment" {
  type    = string
  default = "production"
}

variable "instance_type" {
  type    = string
   default = "t2.micro"
}

variable "access_key" {
  type = string
  default = "AKIATX7C434IADZZGZWK"
}

variable "secret_key" {
  type = string
  default = "Hf4Xq5k/EH/HbrUAvRvi/tOMCcwpyssO7JPZwtpZ"
}

variable "region" {
  type = string
  default = "ap-south-1"
}

#=================provider code
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

#=================output code
output "Webserver_Public_IP" {
  value = aws_instance.frontend.public_ip
}

output "Website_URL" {
  value = "http://${aws_instance.frontend.public_dns}"
}
