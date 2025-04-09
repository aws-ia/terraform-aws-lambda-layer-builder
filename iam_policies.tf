###########################################
# Role Policies
###########################################

data "aws_iam_policy_document" "terraform-aws-lambda-layer-builder" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]
    resources = [
      var.s3_kms_key_arn != null ? var.s3_kms_key_arn : aws_kms_alias.terraform-aws-lambda-layer-builder.target_key_arn
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