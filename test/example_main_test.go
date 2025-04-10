package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	// Add this import
)

// You must set these environment variables for this test
const (
	label_env        = "test"
	label_namespace  = "example"
	s3_force_destroy = true
)

func TestVariablesValidation(t *testing.T) {
	// Generate and validate bucket name once at the start
	//prefix := "terraform-aws-lambda-layer-builder"
	//bucketName := generateTimestampBucketName(prefix)
	//s3_bucket_name, err := validateS3BucketName(bucketName)
	//if err != nil {
	//	t.Fatalf("Failed to validate bucket name: %v", err)
	//}

	t.Run("valid_lambda_architecture", func(t *testing.T) {
		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: "../",
			Vars: map[string]interface{}{
				"lambda_function_architecture": "x86_64",
				//"s3_bucket_name":               s3_bucket_name,
			},
		})

		terraform.Init(t, terraformOptions)
		terraform.Plan(t, terraformOptions)
	})

	t.Run("valid_lambda_runtime", func(t *testing.T) {
		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: "../",
			Vars: map[string]interface{}{
				"lambda_function_runtime": "python3.13",
				//"s3_bucket_name":          s3_bucket_name,
			},
		})

		terraform.Init(t, terraformOptions)
		terraform.Plan(t, terraformOptions)
	})

}

// Helper functions remain the same
//func generateTimestampBucketName(prefix string) string {
//	var sb strings.Builder
//	sb.WriteString(prefix)
//	sb.WriteString("-")
//	sb.WriteString(time.Now().UTC().Format("20060102-150405"))
//	return sb.String()
//}

//func validateS3BucketName(name string) (string, error) {
//	name = strings.ToLower(name)

//	if len(name) < 3 || len(name) > 63 {
//		return "", fmt.Errorf("bucket name must be between 3 and 63 characters")
//	}

//	if name[0] == '-' || name[0] == '.' || name[len(name)-1] == '-' || name[len(name)-1] == '.' {
//		return "", fmt.Errorf("bucket name must start and end with letter or number")
//	}

//	validBucketRegex := regexp.MustCompile(`^[a-z0-9][a-z0-9.-]*[a-z0-9]$`)
//	if !validBucketRegex.MatchString(name) {
//		return "", fmt.Errorf("bucket name contains invalid characters")
//	}

//	name = strings.ReplaceAll(name, "_", "-")

//	return name, nil
//}

func TestExamplesLambdaLayerBasic(t *testing.T) {
	// You must set these environment variables for this test

	labelEnv := label_env
	labelNamespace := label_namespace
	s3ForceDestroy := s3_force_destroy

	// Generate random bucket name
	//rawBucketName := generateTimestampBucketName("lmbd-lyr-tests")
	//s3_bucket_name, err := validateS3BucketName(rawBucketName)
	//if err != nil {
	//	t.Fatalf("Error validating bucket name: %v", err)
	//}

	// Log the bucket name that will be used
	//t.Logf("Using bucket name: %s", s3_bucket_name)

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/basic",
		Vars: map[string]interface{}{
			"label_env":       labelEnv,
			"label_namespace": labelNamespace,
			//"s3_bucket_name":   s3_bucket_name,
			"s3_force_destroy": s3ForceDestroy,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
	terraform.ApplyAndIdempotent(t, terraformOptions)
}
