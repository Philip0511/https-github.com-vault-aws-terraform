resource "aws_security_group" "vault_sg" {

  name        = "vault_sg"
  vpc_id      = module.vpc.vpc_id
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