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
