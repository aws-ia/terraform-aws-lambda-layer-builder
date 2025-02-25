data "archive_file" "python_lambda_layer_builder" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/src/"
  output_path = "${path.module}/.build/python-lambda-layer-builder.zip"
}