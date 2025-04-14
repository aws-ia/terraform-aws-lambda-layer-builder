locals {
  lambda_powertools_layer_arn = "arn:aws:lambda:${data.aws_region.current.name}:017000801446:layer:AWSLambdaPowertoolsPythonV3-${replace(var.lambda_function_runtime, ".", "")}-${var.lambda_function_architecture}:7"
}

###################################################################
# Lambda - Lambda Layer Builder
###################################################################
#tfsec:ignore:aws-lambda-enable-tracing
# tflint-ignore: aws_lambda_function_invalid_runtime
resource "aws_lambda_function" "terraform_aws_lambda_layer_builder" {
  #checkov:skip=CKV_AWS_115:Concurrent execution limit not required
  #checkov:skip=CKV_AWS_272:Code signing not required
  #checkov:skip=CKV_AWS_116:DLQ is not required
  #checkov:skip=CKV_AWS_50:X-ray tracing is not required

  filename         = data.archive_file.terraform_aws_lambda_layer_builder.output_path
  function_name    = local.lambda.function_name
  description      = local.lambda.description
  role             = aws_iam_role.terraform_aws_lambda_layer_builder.arn
  handler          = local.lambda.handler
  kms_key_arn      = aws_kms_alias.terraform_aws_lambda_layer_builder.target_key_arn
  layers           = [local.lambda_powertools_layer_arn]
  source_code_hash = data.archive_file.terraform_aws_lambda_layer_builder.output_base64sha256

  architectures = local.lambda.architectures
  # tflint-ignore: aws_lambda_function_invalid_runtime
  runtime       = var.lambda_function_runtime

  timeout     = local.lambda.timeout
  memory_size = local.lambda.memory_size

  tags = var.tags
  environment {
    variables = {
      s3_bucket_name      = local.target_s3_bucket
      lambda_architecture = var.lambda_function_architecture
      lambda_runtime      = var.lambda_function_runtime
    }
  }

  vpc_config {
    subnet_ids         = var.vpc_subnet_ids
    security_group_ids = var.vpc_security_group_ids
  }

  depends_on = [aws_cloudwatch_log_group.terraform_aws_lambda_layer_builder]
}