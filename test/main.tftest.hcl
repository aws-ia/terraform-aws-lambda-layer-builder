# tests/main.tftest.hcl

variables {
  label_env        = "dev"
  label_namespace  = "aws"
  #s3_bucket_name   = "XXXXXXX"
  s3_force_destroy = true
}

run "verify_module_configuration" {
  command = plan

  assert {
    condition     = var.label_env == "dev"
    error_message = "Environment label must be 'dev'"
  }

  assert {
    condition     = var.label_namespace == "aws"
    error_message = "Namespace must be 'aws'"
  }

  #assert {
  #  condition     = var.s3_bucket_name != ""
  #  error_message = "S3 bucket name cannot be empty"
  #}
}

run "verify_s3_bucket_configuration" {
  command = plan

  assert {
    condition     = var.s3_force_destroy == true
    error_message = "S3 force_destroy must be set to true for test environments"
  }
}

run "verify_resource_creation" {
	command = plan
  
	assert {
	  condition = length(planned_values.root_module.child_modules) > 0
	  error_message = "No resources planned for creation"
	}
  }

