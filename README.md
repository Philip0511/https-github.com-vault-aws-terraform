# Vault AWS Terraform Quickstart

This repo is meant to provision everything you need for a new Vault instance with a Route53 domain. 

## Pre-reqs

    - Route53 Domain

    - Terraform

    - AWS Account

## Things to update

### Updating And Importing Route53 Zone

This section will need to have the domain updated to the correct one.

```
resource "aws_route53_zone" "vault_zone" {

  name = "example.com."

}
```
For example:

```
resource "aws_route53_zone" "vault_zone" {

  name = "github.com."

}
```

### Updating Domain Within Script

Inside the vault-install.sh script you'll need to update this variable to match the domain update within Route53 and brackets will need to be reomved.

```
export VAULT_DOMAIN_ADDRESS=vault.{{example.com}}
echo "export VAULT_DOMAIN_ADDRESS=vault.{{example.com}}" >> ~./bashrc
```

For Example:

```
export VAULT_DOMAIN_ADDRESS=vault.github.com
echo "export VAULT_DOMAIN_ADDRESS=vault.github.com" >> ~./bashrc
```
