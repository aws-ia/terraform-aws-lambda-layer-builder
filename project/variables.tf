#########################################
# Solution-Level Variables
#########################################
variable "lambda_function_architecture" {
  description = "Architecture for the Lambda Function / Layer being built"
  type        = string
  default     = "x86_64"

  validation {
    condition     = contains(["x86_64", "arm64"], var.lambda_function_architecture)
    error_message = "Valid values for var: lambda_function_architecture are (x86_64, arm64)."
  }
}
variable "lambda_function_runtime" {
  description = "Runtime for the Lambda Function / Layer being built"
  type        = string
  default     = "python3.10"

  validation {
    condition     = contains(["python3.9", "python3.10", "python3.11", "python3.12", "python3.13"], var.lambda_function_runtime)
    error_message = "Valid values for var: lambda_function_runtime are (python3.9, python3.10, python3.11, python3.12, python3.13)."
  }
}
variable "tags" {
  description = "Map of tags to apply to resources deployed by this solution."
  type        = map(any)
  default     = null
}

#########################################
# Label / Naming Variables
#########################################
variable "label_env" {
  description = "environment, e.g. 'sit', 'uat', 'prod' etc"
  type        = string
  default     = "test"
}


variable "label_id_order" {
  description = "The order in which the `id` is constructed."
  type        = list(string)
  default     = ["namespace", "env", "name"]
}
variable "label_namespace" {
  type        = string
  description = "namespace, which could be your organization name, e.g. amazon"
  default     = "my-aws-test-ns"

}

#########################################
# CloudWatch Variables
#########################################

variable "cloudwatch_log_group_retention" {
  description = "Amount of days to keep CloudWatch Log Groups for the Lambda function. 0 = Never Expire"
  type        = string
  default     = "0"

  validation {
    condition     = contains(["1", "3", "5", "7", "14", "30", "60", "90", "120", "150", "180", "365", "400", "545", "731", "1827", "3653", "0"], var.cloudwatch_log_group_retention)
    error_message = "Valid values for var: cloudwatch_log_group_retention are (1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0)."
  }
}

#########################################
# S3 Variables
#########################################
variable "s3_force_destroy" {
  description = "Set to true if you want to force delete S3 bucket created by this module (including contents of the bucket)"
  type        = bool
  default     = false
}

variable "create_s3_bucket" {
  description = "Determines whether to create an S3 bucket"
  type        = bool
  default     = true

  validation {
    condition     = contains([true, false], var.create_s3_bucket)
    error_message = "Valid values for var: create_s3_bucket are (true, false)."
  }
}

variable "s3_kms_key_arn" {
  description = "If `create_s3_bucket` is `false`, then this is the ARN of the KMS key used to encrypt objects in the existing `s3_bucket_name`"
  type        = string
  default     = null
}

#########################################
# VPC Variables
#########################################
variable "vpc_subnet_ids" {
  description = "VPC Subnets to place the Lambda function in"
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "VPC Security Groups to associate the Lambda function with"
  type        = list(string)
  default     = []
}