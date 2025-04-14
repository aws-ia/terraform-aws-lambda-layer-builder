data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}
# tflint-ignore: terraform_unused_declarations
data "aws_iam_policy" "aws_lambda_basic_execution_role" {
  name = "AWSLambdaBasicExecutionRole"
}
# tflint-ignore: terraform_unused_declarations
data "aws_iam_policy" "aws_lambda_vpc_access_execution_role" {
  name = "AWSLambdaVPCAccessExecutionRole"
}