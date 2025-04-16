data "archive_file" "terraform_aws_lambda_layer_builder" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/src/"
  output_path = "${path.module}/.build/terraform_aws_lambda_layer_builder.zip"
}