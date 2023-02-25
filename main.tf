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
