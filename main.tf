locals {
  lambda_powertools_layer_arn = "arn:aws:lambda:${data.aws_region.current.name}:017000801446:layer:AWSLambdaPowertoolsPythonV3-${replace(var.lambda_function_runtime, ".", "")}-${var.lambda_function_architecture}:7"
}
#tfsec:ignore:aws-lambda-enable-tracing
#tfsec:ignore:aws-s3-enable-bucket-logging
###################################################################
# Lambda - Lambda Layer Builder
###################################################################

#tfsec:ignore:aws-lambda-enable-tracing
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

############################################################################################################
# Generate customer-managed versions of AWSLambdaBasicExecutionRole, AWSLambdaVPCAccessExecutionRole
############################################################################################################
resource "aws_iam_policy" "aws_lambda_basic_execution" {
  name        = substr("${module.label.id}-aws-lambda-basic-execution", 0, 127)
  path        = "/"
  description = "Customer managed version of AWSLambdaBasicExecutionRole"

  policy = data.aws_iam_policy.aws_lambda_basic_execution_role.policy
  tags   = var.tags
}

resource "aws_iam_policy" "aws_lambda_vpc_access_execution" {
  name        = substr("${module.label.id}-aws-lambda-vpc-access-execution", 0, 127)
  path        = "/"
  description = "Customer managed version of AWSLambdaVPCAccessExecutionRole"

  policy = data.aws_iam_policy.aws_lambda_vpc_access_execution_role.policy
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



###################################################################
# S3 - S3 Bucket for Lambda Layer Builder
###################################################################

resource "aws_s3_bucket" "terraform_aws_lambda_layer_builder" {
  for_each = var.create_s3_bucket ? { "bucket" = local.bucket_name } : {}

  bucket_prefix = each.value
  force_destroy = var.s3_force_destroy

  tags = var.tags
}

# Logging bucket for S3 access logs
#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "access_logs" {
  for_each = var.create_s3_bucket ? { "bucket" = "${local.bucket_name}-logs" } : {}

  bucket_prefix = each.value
  force_destroy = var.s3_force_destroy

  tags = merge(var.tags, {
    Name = "S3 Access Logs"
  })
}

# Enable logging on the main bucket
resource "aws_s3_bucket_logging" "terraform_aws_lambda_layer_builder" {
  for_each = var.create_s3_bucket ? { "bucket" = local.bucket_name } : {}
  
  bucket = aws_s3_bucket.terraform_aws_lambda_layer_builder[each.key].id

  target_bucket = aws_s3_bucket.access_logs[each.key].id
  target_prefix = "log/"
}

# Public access block for logging bucket
resource "aws_s3_bucket_public_access_block" "access_logs" {
  for_each = var.create_s3_bucket ? { "bucket" = "${local.bucket_name}-logs" } : {}
  
  bucket = aws_s3_bucket.access_logs[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Encryption for logging bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  for_each = var.create_s3_bucket ? { "bucket" = "${local.bucket_name}-logs" } : {}
  
  bucket = aws_s3_bucket.access_logs[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_alias.terraform_aws_lambda_layer_builder.target_key_id
      sse_algorithm     = local.s3.terraform_aws_lambda_layer_builder.sse_algorithm
    }
  }
}

# Versioning for logging bucket
resource "aws_s3_bucket_versioning" "access_logs" {
  for_each = var.create_s3_bucket ? { "bucket" = "${local.bucket_name}-logs" } : {}
  
  bucket = aws_s3_bucket.access_logs[each.key].id
  
  versioning_configuration {
    status = local.s3.terraform_aws_lambda_layer_builder.versioning
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_aws_lambda_layer_builder" {
  for_each = var.create_s3_bucket ? { "bucket" = local.bucket_name } : {}
  bucket   = aws_s3_bucket.terraform_aws_lambda_layer_builder[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "terraform_aws_lambda_layer_builder" {
  for_each = var.create_s3_bucket ? { "bucket" = local.bucket_name } : {}
  bucket   = aws_s3_bucket.terraform_aws_lambda_layer_builder[each.key].id
  versioning_configuration {
    status = local.s3.terraform_aws_lambda_layer_builder.versioning
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_aws_lambda_layer_builder" {
  for_each = var.create_s3_bucket ? { "bucket" = local.bucket_name } : {}
  bucket   = aws_s3_bucket.terraform_aws_lambda_layer_builder[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_alias.terraform_aws_lambda_layer_builder.target_key_id
      sse_algorithm     = local.s3.terraform_aws_lambda_layer_builder.sse_algorithm
    }
  }
}

###################################################################
# KMS - KMS Key for Lambda Layer Builder
###################################################################

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

###################################################################
# Cloudwatch - CloudWatch Log Group for Lambda Layer Builder
###################################################################

resource "aws_cloudwatch_log_group" "terraform_aws_lambda_layer_builder" {
  name              = "${local.cloudwatch.lambda_log_group_prefix}/${local.lambda.function_name}"
  kms_key_id        = aws_kms_alias.terraform_aws_lambda_layer_builder.target_key_arn
  retention_in_days = var.cloudwatch_log_group_retention

  tags = var.tags
}
