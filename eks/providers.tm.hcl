generate_hcl "providers.tf" {
  content {
    provider "aws" {
      region = "us-east-1"

      default_tags {
        tags = {
          Environment = "${global.environment}"
          CreatedBy   = "terramate"
          ManagedBy   = "terramate"
          Terraform   = "true"
        }
      }
    }
  }
}