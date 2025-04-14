module "terraform_aws_lambda_layer_builder" {
  source = "./"
  label_env        = "dev"
  label_namespace  = "aws"
  s3_force_destroy = true

  # Additional recommended variables
  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "terraform_aws_lambda_layer_builder"
  }
}
