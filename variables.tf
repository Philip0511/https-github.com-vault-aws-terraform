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
      description = "http"
    },

    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "https"
    },
    {
      from_port   = 8200
      to_port     = 8200
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "Vault UI"
    },

    {
      from_port   = 8500
      to_port     = 8500
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "Consol UI"
    },

    {
      from_port   = 8501
      to_port     = 8501
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "Consol Gossip"
    }
  ]

}