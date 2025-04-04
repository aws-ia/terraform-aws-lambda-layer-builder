data "archive_file" "terraform-aws-lambda-layer-builder" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/src/"
  output_path = "${path.module}/.build/python-lambda-layer-builder.zip"
}