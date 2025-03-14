package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestVariablesValidation(t *testing.T) {
    t.Run("valid_lambda_architecture", func(t *testing.T) {
        terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
            TerraformDir: "../",
            Vars: map[string]interface{}{
                "lambda_function_architecture": "x86_64",
            },
        })
        
        terraform.Init(t, terraformOptions)
        terraform.Plan(t, terraformOptions)
    })

    t.Run("invalid_lambda_architecture", func(t *testing.T) {
        terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
            TerraformDir: "../",
            Vars: map[string]interface{}{
                "lambda_function_architecture": "invalid_arch",
            },
        })
        
        _, err := terraform.InitAndPlanE(t, terraformOptions)
        assert.Error(t, err)
    })

    t.Run("valid_lambda_runtime", func(t *testing.T) {
        terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
            TerraformDir: "../",
            Vars: map[string]interface{}{
                "lambda_function_runtime": "python3.13",
            },
        })
        
        terraform.Init(t, terraformOptions)
        terraform.Plan(t, terraformOptions)
    })

    t.Run("invalid_lambda_runtime", func(t *testing.T) {
        terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
            TerraformDir: "../",
            Vars: map[string]interface{}{
                "lambda_function_runtime": "python2.7",
            },
        })
        
        _, err := terraform.InitAndPlanE(t, terraformOptions)
        assert.Error(t, err)
    })

    t.Run("valid_cloudwatch_retention", func(t *testing.T) {
        terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
            TerraformDir: "../",
            Vars: map[string]interface{}{
                "cloudwatch_log_group_retention": "30",
            },
        })
        
        terraform.Init(t, terraformOptions)
        terraform.Plan(t, terraformOptions)
    })

    t.Run("s3_bucket_name_validation", func(t *testing.T) {
        terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
            TerraformDir: "../",
            Vars: map[string]interface{}{
                "s3_bucket_name": "",
            },
        })
        
        _, err := terraform.InitAndPlanE(t, terraformOptions)
        assert.Error(t, err)
    })
}

func TestRequiredVariables(t *testing.T) {
    t.Run("required_label_variables", func(t *testing.T) {
        terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
            TerraformDir: "../",
            Vars: map[string]interface{}{
                "label_env":       "prod",
                "label_namespace": "myapp",
            },
        })
        
        terraform.Init(t, terraformOptions)
        terraform.Plan(t, terraformOptions)
    })
}
