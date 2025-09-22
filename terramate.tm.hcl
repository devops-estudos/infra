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

globals {
  organization = "devops-studies"
}

import {
  source = "./modules/vpc/generate.tm.hcl"
}

import {
  source = "./modules/eks/generate.tm.hcl"
}

import {
  source = "./modules/eks/addons/generate.tm.hcl"
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
      [let.provisioner, "init", "-reconfigure", "-lock-timeout=5m"],
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