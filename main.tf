module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_instance" "vault" {

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  key_name                    = aws_key_pair.vault_generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.vault_sg.id]
  subnet_id                   = module.vpc.public_subnets[0]
  user_data                   = templatefile("${path.module}/templates/vault_install.tftpl", { VAULT_DOMAIN_ADDRESS = "vault.${var.route_53_domain}", DOMAIN_ADDRESS = "${var.route_53_domain}" })
  tags = {

    Name      = "vault-server-tf"
    Terraform = "true"

  }
}