#########################################
# Solution-Level Variables
#########################################
variable "lambda_function_architecture" {
  description = "Architecture for the Lambda Function / Layer being built (x86_64 or arm64)"
  type        = string
  default     = "x86_64"
  validation {
    condition     = contains(["x86_64", "arm64"], var.lambda_function_architecture)
    error_message = "Architecture must be either 'x86_64' or 'arm64'."
  }
}


variable "lambda_function_runtime" {
  description = "Runtime for the Lambda Function / Layer being built (python3.9-3.13)"
  type        = string
  default     = "python3.13"
  validation {
    condition     = can(regex("^python3\\.(9|10|11|12|13)$", var.lambda_function_runtime))
    error_message = "Runtime must be one of: python3.9, python3.10, python3.11, python3.12, python3.13"
  }
}

variable "tags" {
  description = "Map of tags to apply to resources"
  type        = map(string) # More specific type than map(any)
  default     = {}          # Empty map instead of null
}

variable "region" {
  type        = string
  description = "AWS region to deploy the resources"
  default     = "us-east-1"
}

#########################################
# Label / Naming Variables
#########################################
variable "label_env" {
  description = "Environment identifier (e.g., 'sit', 'uat', 'prod')"
  type        = string
  default     = "test"

  validation {
    condition     = length(var.label_env) > 0
    error_message = "Environment identifier cannot be empty."
  }
}

variable "label_id_order" {
  description = "The order in which the ID is constructed"
  type        = list(string)
  default     = ["namespace", "env", "name"]

  validation {
    condition     = length(var.label_id_order) > 0
    error_message = "ID order list cannot be empty."
  }
}

variable "label_namespace" {
  description = "Namespace identifier (e.g., organization name)"
  type        = string
  default     = "aws_my_test"

  validation {
    condition     = length(var.label_namespace) > 0
    error_message = "Namespace cannot be empty."
  }
}

#########################################
# CloudWatch Variables
#########################################
variable "cloudwatch_log_group_retention" {
  description = "CloudWatch Log Group retention in days (0 = Never Expire)"
  type        = number # Changed to number for better type safety
  default     = 0
  validation {
    condition     = can(index([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.cloudwatch_log_group_retention))
    error_message = "Invalid retention period. Must be one of: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  }
}

#########################################
# S3 Variables
#########################################
variable "s3_force_destroy" {
  description = "Enable forced deletion of S3 bucket and its contents"
  type        = bool
  default     = false
}

variable "create_s3_bucket" {
  description = "Controls S3 bucket creation"
  type        = bool
  default     = true
}

variable "s3_kms_key_arn" {
  description = "KMS key ARN for S3 bucket encryption"
  type        = string
  default     = null

  validation {
    condition     = var.s3_kms_key_arn == null || can(regex("^arn:aws:kms:", var.s3_kms_key_arn))
    error_message = "KMS key ARN must be a valid AWS KMS ARN format."
  }
}

#########################################
# VPC Variables
#########################################
variable "vpc_subnet_ids" {
  description = "List of VPC subnet IDs for Lambda function"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.vpc_subnet_ids) == 0 || alltrue([for id in var.vpc_subnet_ids : can(regex("^subnet-", id))])
    error_message = "All subnet IDs must begin with 'subnet-'."
  }
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs for Lambda function"
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.vpc_security_group_ids) == 0 || alltrue([for id in var.vpc_security_group_ids : can(regex("^sg-", id))])
    error_message = "All security group IDs must begin with 'sg-'."
  }
}
