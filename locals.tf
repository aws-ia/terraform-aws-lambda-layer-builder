locals {
  cloudwatch = {
    lambda_log_group_prefix = "/aws/lambda"
  }
  iam = {
    lambda_managed_policy_arns = length(var.vpc_subnet_ids) > 0 ? [aws_iam_policy.aws_lambda_basic_execution.arn, aws_iam_policy.aws_lambda_vpc_access_execution.arn] : [aws_iam_policy.aws_lambda_basic_execution.arn]
    terraform_aws_lambda_layer_builder = {
      name_prefix = substr(module.label.id, 0, 36)
    }
  }
  kms = {
    alias       = substr(replace("alias/${module.label.id}-${var.lambda_function_runtime}-${var.lambda_function_architecture}", ".", "_"), 0, 255)
    description = substr(replace("KMS Key for ${module.label.id}-${var.lambda_function_runtime}-${var.lambda_function_architecture} solution", ".", "_"), 0, 8191)
  }
  lambda = {
    architectures = [var.lambda_function_architecture]
    description   = "Creates Lambda layers for ${var.lambda_function_runtime} (${var.lambda_function_architecture})"
    function_name = substr(replace("${module.label.id}-${var.lambda_function_runtime}-${var.lambda_function_architecture}", ".", "_"), 0, 63)
    handler       = "lambda_function.lambda_handler"
    memory_size   = 10240
    # runtime       = var.lambda_function_runtime
    storage       = var.lambda_ephemeral_storage
    timeout       = 900
  }
  s3 = {
    terraform_aws_lambda_layer_builder = {
      sse_algorithm = "aws:kms"
      versioning    = "Enabled"
    }
  }
  solution_name    = "terraform_aws_lambda_layer_builder"
  random_suffix = random_string.bucket_suffix.result
  bucket_name = "tf-aws-lambda-layer-${local.random_suffix}"
  target_s3_bucket = var.create_s3_bucket ? aws_s3_bucket.terraform_aws_lambda_layer_builder["bucket"].id : local.bucket_name

}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

