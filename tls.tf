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