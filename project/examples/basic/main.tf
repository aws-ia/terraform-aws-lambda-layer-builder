module "terraform-aws-lambda-layer-buidler" {
  source = "../.."

  label_env        = "dev"
  label_namespace  = "aws"
  s3_bucket_name   = "example"
  s3_force_destroy = true
}