provider "aws" {

  region = "us-east-2"

}

resource "aws_vpc" "vault_vpc" {

  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"
  tags = {
    Name      = "vault_vpc"
    Terraform = "true"
  }
}

resource "aws_subnet" "vault_vpc_pub_subnet" {

  vpc_id                  = aws_vpc.vault_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  tags = {
    Name      = "vault_vpc_public_subnet_1"
    Terraform = "true"
  }

}

resource "aws_internet_gateway" "vault_vpc_igw" {

  vpc_id = aws_vpc.vault_vpc.id
  tags = {
    Name      = "vault_vpc_igw"
    Terraform = "true"
  }

}

resource "aws_route_table" "vault_public_crt" {
  vpc_id = aws_vpc.vault_vpc.id

  route {

    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vault_vpc_igw.id

  }

  tags = {
    Name      = "vault_public_crt"
    Terraform = "True"
  }
}

resource "aws_route_table_association" "vault_public_crta" {

  subnet_id      = aws_subnet.vault_vpc_pub_subnet.id
  route_table_id = aws_route_table.vault_public_crt.id

}

resource "aws_security_group" "vault_sg" {

  name        = "vault_sg"
  vpc_id      = aws_vpc.vault_vpc.id
  description = "Sec Group for Vault"

}

resource "aws_security_group_rule" "ingress_rules" {

  count = length(var.sg_ingress_rules)

  type              = "ingress"
  from_port         = var.sg_ingress_rules[count.index].from_port
  to_port           = var.sg_ingress_rules[count.index].to_port
  protocol          = var.sg_ingress_rules[count.index].protocol
  cidr_blocks       = [var.sg_ingress_rules[count.index].cidr_block]
  description       = var.sg_ingress_rules[count.index].description
  security_group_id = aws_security_group.vault_sg.id

}

resource "aws_security_group_rule" "egress_rules" {

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vault_sg.id

}

variable "sg_ingress_rules" {

  type = list(object({

    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
    description = string

  }))

  default = [

    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "ssh"
    },

    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "Web traffic for certbot"
    },

    {
      from_port   = 8200
      to_port     = 8200
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "Consul UI"
    },

    {
      from_port   = 8500
      to_port     = 8500
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "Vault UI"
    },

    {
      from_port   = 8501
      to_port     = 8501
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "Vault Cluster"
    }
  ]

}

resource "tls_private_key" "vault_key" {

  algorithm = "RSA"
  rsa_bits  = 4096

}

resource "aws_key_pair" "vault_generated_key" {

  key_name   = "terraform_gen_vault_key"
  public_key = tls_private_key.vault_key.public_key_openssh

}

resource "local_file" "priv_key" {

  content         = tls_private_key.vault_key.private_key_pem
  filename        = "vault_priv_key.pem"
  file_permission = "0600"

}

resource "local_file" "pub_key" {

  content         = tls_private_key.vault_key.public_key_openssh
  filename        = "vault_pub_key.pub"
  file_permission = "0600"

}

data "aws_ami" "ubuntu" {

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "vault" {

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  key_name                    = aws_key_pair.vault_generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.vault_sg.id]
  subnet_id                   = aws_subnet.vault_vpc_pub_subnet.id
  tags = {

    Name      = "vault-server-tf"
    Terraform = "true"

  }
}

data "aws_route53_zone" "vault_zone" {

  name = "example.com." # Needs to be updated with domain in Route53

}

resource "aws_route53_record" "vault_dns" {

  zone_id = data.aws_route53_zone.vault_zone.id
  name    = "vault"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.vault.public_ip]

}

resource "null_resource" "vault_install" {

  triggers = {

    public_ip = aws_instance.vault.public_ip

  }

  depends_on = [aws_route53_record.vault_dns]

  provisioner "file" {

    source      = "vault-install.sh"
    destination = "~/vault-install.sh"

  }

  connection {

    type        = "ssh"
    host        = aws_instance.vault.public_ip
    user        = "ubuntu"
    port        = 22
    private_key = tls_private_key.vault_key.private_key_pem
    agent       = true

  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod +x vault-install.sh",
      "sudo ~/vault-install.sh"
    ]

  }

}