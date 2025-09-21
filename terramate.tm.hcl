terramate {
  config {
    cloud {
      organization = "devops-estudos"
      location     = "us"
    }

    disable_safeguards = ["git"]

    experiments = [
      "scripts",
      "outputs-sharing"
    ]
  }
}

script "deploy" {
  description = "Run a Terraform/Tofu deployment"
  lets {
    provisioner = "terraform"
  }
  job {
    name        = "deploy"
    description = "Initialize, validate and deploy Terraform stacks"
    commands = [
      [let.provisioner, "init", "-lock-timeout=5m"],
      [let.provisioner, "validate"],
      [let.provisioner, "plan", "-out", "out.tfplan", "-lock=false", {
        enable_sharing = true
      }],
      [let.provisioner, "apply", "-input=false", "-auto-approve", "-lock-timeout=5m", "out.tfplan", {
        cloud_sync_deployment          = true
        cloud_sync_terraform_plan_file = "out.tfplan"
      }],
    ]
  }
}

sharing_backend "default" {
  type     = terraform
  filename = "sharing_generated.tf"
  command  = ["terraform", "output", "-json"]
}