# Vault AWS Terraform Quickstart

This repo is meant to provision everything you need for a new Vault instance with a Route53 domain.

## Pre-reqs

    - Route53 Domain

    - Terraform

    - AWS Account

## Variables to include

You have a few variables required to run this code.

```terraform
variable "region" {
  description = "AWS Region to use for this Terraform"
  type        = string
}

variable "vpc_name" {
  description = "Name you wish to give the VPC"
  type        = string
}

variable "route_53_domain" {
  description = "Route53 domain you would like to use"
  type        = string
}
```

You can either update them within those blocks using `default =` within the blocks or create a `.tfvars` file that has values for all the variables.

Example:

```terraform
region = "us-west-2"
vpc_name = "vault-demo"
route_53_domain = "github.com"
```

## Running the terraform

1. Clone the repo

    ```console
    git clone https://github.com/b1tsized/vault-aws-terraform.git
    ```

2. `cd` into the directory of the repo.

3. Run `terraform init` within the directory

    ```console
    terraform init
    ```

4. Run `terraform apply -auto` after updating your variables.

    ```console
    terraform apply --auto-approve
    ```

5. Wait until the changes are applied. Server will automatically initialize and unseal. To be able to log in you'll need to ssh into the server and grab the root token from `/vault-keys`.

6. Check domain web address on port `8200`. E.G. `https://vault.github.com:8200/`
