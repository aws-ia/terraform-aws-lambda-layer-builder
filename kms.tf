resource "aws_kms_key" "terraform_aws_lambda_layer_builder" {
  description             = local.kms.description
  policy                  = data.aws_iam_policy_document.kms_terraform_aws_lambda_layer_builder.json
  tags                    = var.tags
  enable_key_rotation     = true
  deletion_window_in_days = 7  # Minimum waiting period before deletion
}

resource "aws_kms_alias" "terraform_aws_lambda_layer_builder" {
  name          = local.kms.alias
  target_key_id = aws_kms_key.terraform_aws_lambda_layer_builder.key_id
}

data "aws_iam_policy_document" "kms_terraform_aws_lambda_layer_builder" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.id}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"] #checkov:skip=CKV_AWS_111,CKV_AWS_356,CKV_AWS_109: Default AWS KMS Key Policy
  }
  statement {
    sid    = "Allow CloudWatch Logs access"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:${data.aws_partition.current.id}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}
