############################################################################################################
# Generate customer-managed versions of AWSLambdaBasicExecutionRole, AWSLambdaVPCAccessExecutionRole
############################################################################################################
resource "aws_iam_policy" "aws_lambda_basic_execution" {
  name        = substr("${module.label.id}-aws-lambda-basic-execution", 0, 127)
  path        = "/"
  description = "Customer managed version of AWSLambdaBasicExecutionRole"

  policy = data.aws_iam_policy.AWSLambdaBasicExecutionRole.policy
  tags   = var.tags
}

resource "aws_iam_policy" "aws_lambda_vpc_access_execution" {
  name        = substr("${module.label.id}-aws-lambda-vpc-access-execution", 0, 127)
  path        = "/"
  description = "Customer managed version of AWSLambdaVPCAccessExecutionRole"

  policy = data.aws_iam_policy.AWSLambdaVPCAccessExecutionRole.policy
  tags   = var.tags
}

###################################################################
# Lambda - Lambda Layer Builder
###################################################################

resource "aws_iam_role" "terraform_aws_lambda_layer_builder" {
  name_prefix        = local.iam.terraform_aws_lambda_layer_builder.name_prefix
  assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "terraform_aws_lambda_layer_builder" {
  name_prefix = local.iam.terraform_aws_lambda_layer_builder.name_prefix
  role        = aws_iam_role.terraform_aws_lambda_layer_builder.id
  policy      = data.aws_iam_policy_document.terraform_aws_lambda_layer_builder.json
}

resource "aws_iam_role_policy_attachment" "terraform_aws_lambda_layer_builder" {
  count      = length(local.iam.lambda_managed_policy_arns)
  role       = aws_iam_role.terraform_aws_lambda_layer_builder.name
  policy_arn = local.iam.lambda_managed_policy_arns[count.index]
}