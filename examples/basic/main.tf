module "terraform_aws_lambda_layer_builder" {
  source = "../.."

  label_env        = "dev"
  label_namespace  = "aws"
  s3_force_destroy = true
}