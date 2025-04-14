module "terraform_aws_lambda_layer_builder" {
  # source = "git://github.com/aws-ia/terraform-aws-lambda-layer-builder.git?ref=main"
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
