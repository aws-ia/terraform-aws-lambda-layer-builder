resource "aws_cloudwatch_log_group" "terraform-aws-lambda-layer-builder" {
  name              = "${local.cloudwatch.lambda_log_group_prefix}/${local.lambda.function_name}"
  kms_key_id        = aws_kms_alias.terraform-aws-lambda-layer-builder.target_key_arn
  retention_in_days = var.cloudwatch_log_group_retention

  tags = var.tags
}
