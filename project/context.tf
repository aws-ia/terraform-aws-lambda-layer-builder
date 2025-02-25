module "label" {
  source = "git::https://github.com/aws-ia/terraform-aws-label.git?ref=570bb71fe79d8ee215280dd52c7432e3502be4b1" # v0.0.6

  account   = data.aws_caller_identity.current.account_id
  env       = var.label_env
  id_order  = var.label_id_order
  name      = local.solution_name
  namespace = var.label_namespace
}