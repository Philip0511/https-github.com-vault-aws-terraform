# Vault AWS Terraform Quickstart

This repo is meant to provision everything you need for a new Vault instance with a Route53 domain. 

## Pre-reqs

    - Route53 Domain

    - Terraform

    - AWS Account

## Things to update

### Updating And Importing Route53 Zone

Inside of the folder you'll need to run `terrafrom import aws_route53_zone.vault_zone {ZoneID}`, which will look something like this. `terrafrom import aws_route53_zone.vault_zone Z10382751R1PQTSM488845`. The Zone ID can be found in the Hosted Zones Menu in Route53 or by running `aws route53 list-hosted-zones`. It will return a code block like this.

```
{
            "Id": "/hostedzone/Z10382751R1PQTSM488845",
            "Name": "example.com.",
            "CallerReference": "60b810f1-52cd-49da-y614-6b7b9527a858",
            "Config": {
                "Comment": "",
                "PrivateZone": false
            },
```

_You can grab the value in the ID that trails `/hostedzone/`._

This section will need to have the domain updated to the correct one.

```
resource "aws_route53_zone" "vault_zone" {

  name = "example.com"

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
