data "archive_file" "terraform-aws-lambda-layer-builder" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/src/"
  output_path = "${path.module}/.build/terraform-aws-lambda-layer-builder.zip"
}