output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.terraform_aws_lambda_layer_builder.arn
}