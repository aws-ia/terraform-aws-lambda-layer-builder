module "terraform-aws-lambda-layer-builder" {
  source = "../.."

  label_env        = "dev"
  label_namespace  = "aws"
  s3_force_destroy = true
}