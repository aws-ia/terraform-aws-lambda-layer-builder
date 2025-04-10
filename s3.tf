resource "aws_s3_bucket" "terraform-aws-lambda-layer-builder" {
  for_each = var.create_s3_bucket ? { "bucket" = local.bucket_name } : {}

  bucket_prefix = each.value
  force_destroy = var.s3_force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "terraform-aws-lambda-layer-builder" {
  for_each = var.create_s3_bucket ? { "bucket" = local.bucket_name } : {}
  bucket   = aws_s3_bucket.terraform-aws-lambda-layer-builder[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "terraform-aws-lambda-layer-builder" {
  for_each = var.create_s3_bucket ? { "bucket" = local.bucket_name } : {}
  bucket   = aws_s3_bucket.terraform-aws-lambda-layer-builder[each.key].id
  versioning_configuration {
    status = local.s3.terraform-aws-lambda-layer-builder.versioning
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform-aws-lambda-layer-builder" {
  #checkov:skip=CKV2_AWS_67: KMS Key rotation is optional, if dictated by customer policies
  for_each = var.create_s3_bucket ? { "bucket" = local.bucket_name } : {}
  bucket   = aws_s3_bucket.terraform-aws-lambda-layer-builder[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_alias.terraform-aws-lambda-layer-builder.target_key_id
      sse_algorithm     = local.s3.terraform-aws-lambda-layer-builder.sse_algorithm
    }
  }
}