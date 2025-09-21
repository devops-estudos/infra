generate_hcl "_terramate_generated_versions.tf" {
  content {
    terraform {
      required_version = ">= 1.3.2"

      required_providers {
        github = {
          source  = "integrations/github"
          version = "6.6.0"
        }
        argocd = {
          source  = "argoproj-labs/argocd"
          version = "7.11.0"
        }
      }
    }

  }
}