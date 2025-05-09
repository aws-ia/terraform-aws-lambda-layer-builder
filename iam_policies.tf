###########################################
# Role Policies
###########################################
#checkov:skip=CKV_AWS_290:Required for multiple deployment types
#checkov:skip=CKV_AWS_355:Required for multiple deployment types
data "aws_iam_policy_document" "terraform_aws_lambda_layer_builder" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]
    resources = [
      var.s3_kms_key_arn != null ? var.s3_kms_key_arn : aws_kms_alias.terraform_aws_lambda_layer_builder.target_key_arn
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:CreateMultipartUpload"
    ]
    resources = [
      "arn:aws:s3:::${local.target_s3_bucket}/*"
    ]
  }
}

###########################################
# Trust Policies
###########################################

data "aws_iam_policy_document" "lambda_trust_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}