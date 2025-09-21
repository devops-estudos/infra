generate_hcl "_terramate_generated_backend.tf" {
  content {
    backend "remote" {
      organization = "${global.organization}"
      workspaces {
        name = "${global.environment}"
      }
    }
  }
}