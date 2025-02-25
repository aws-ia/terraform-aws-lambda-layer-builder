resource "aws_cloudwatch_log_group" "python_lambda_layer_builder" {
  name              = "${local.cloudwatch.lambda_log_group_prefix}/${local.lambda.function_name}"
  kms_key_id        = aws_kms_alias.python_lambda_layer_builder.target_key_arn
  retention_in_days = var.cloudwatch_log_group_retention

  tags = var.tags
}
