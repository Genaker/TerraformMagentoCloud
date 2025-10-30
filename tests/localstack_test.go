package tests

import (
    "os"
    "path/filepath"
    "testing"

    "github.com/gruntwork-io/terratest/modules/terraform"
    test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

// TestAwsDataModuleLocalStack runs the aws-data stack with terragrunt against LocalStack.
func TestAwsDataModuleLocalStack(t *testing.T) {
    t.Parallel()

    // Resolve path to the aws-data terragrunt folder in repo
    repoRoot, err := os.Getwd()
    if err != nil {
        t.Fatalf("getwd: %v", err)
    }
    // Current file is under tests/, go to production/aws-data
    tgDir := filepath.Clean(filepath.Join(repoRoot, "..", "magento-cloud-minimal", "production", "aws-data"))

    // LocalStack endpoint: default to Docker for Windows host alias on port 4567
    localstack := getenvDefault("LOCALSTACK_ENDPOINT", "http://host.docker.internal:4567")

    // Prepare env vars for terragrunt/terraform
    env := map[string]string{
        "USE_LOCALSTACK":        "true",
        "LOCALSTACK_ENDPOINT":   localstack,
        "AWS_ACCESS_KEY_ID":     getenvDefault("AWS_ACCESS_KEY_ID", "test"),
        "AWS_SECRET_ACCESS_KEY": getenvDefault("AWS_SECRET_ACCESS_KEY", "test"),
        "AWS_DEFAULT_REGION":    getenvDefault("AWS_DEFAULT_REGION", "ap-southeast-1"),
        // Force local backend under tests
        "TF_CLI_ARGS_init":      "-backend=false -reconfigure",
        // Speed up & avoid volume IO issues
        "TF_PLUGIN_CACHE_DIR":   "/tmp/tf-cache",
    }

    // Create plugin cache dir for the test run
    _ = os.MkdirAll("/tmp/tf-cache", 0o755)

    terraformOptions := &terraform.Options{
        TerraformDir:  tgDir,
        TerraformBinary: "terragrunt",
        NoColor:       true,
        EnvVars:       env,
        Vars:          map[string]interface{}{},
    }

    // Save options for debugging on failure
    defer test_structure.RunTestStage(t, "teardown", func() { terraform.Destroy(t, terraformOptions) })

    test_structure.RunTestStage(t, "init_apply", func() {
        terraform.InitAndApply(t, terraformOptions)
    })

    // Validate minimal expected outputs exist
    _ = terraform.Output(t, terraformOptions, "aws_region")
    _ = terraform.Output(t, terraformOptions, "available_aws_availability_zones_names")
}

func getenvDefault(key, def string) string {
    if v := os.Getenv(key); v != "" {
        return v
    }
    return def
}


