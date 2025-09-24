# backend.tf
generate_hcl "backend.tf" {
  stack_filter {
    project_paths = ["**/elastic-search/kibana"]
  }
  content {
    terraform {
      backend "remote" {
        organization = global.organization
        workspaces {
          name = "${global.name}-elastic-search-kibana"
        }
      }
    }
  }
}

# provider.tf
generate_hcl "provider.tf" {
  stack_filter {
    project_paths = ["**/elastic-search/kibana"]
  }
  content {
    provider "kubernetes" {
      host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
      cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
      token                  = data.aws_eks_cluster_auth.cluster_auth.token
    }
  }
}

# data.tf
generate_hcl "data.tf" {
  stack_filter {
    project_paths = ["**/elastic-search/kibana"]
  }
  content {
    data "terraform_remote_state" "eks" {
      backend = "remote"

      config = {
        organization = global.organization
        workspaces = {
          name = "${global.name}-eks"
        }
      }
    }

    data "aws_eks_cluster_auth" "cluster_auth" {
      name = data.terraform_remote_state.eks.outputs.cluster_name
    }
  }
}

# main.tf
generate_hcl "main.tf" {
  stack_filter {
    project_paths = ["**/elastic-search/kibana"]
  }
  content {
    resource "kubernetes_manifest" "this" {
      manifest = yamldecode(file("./configs/kibana.yml"))
    }
  }
}

generate_file "configs/kibana.yml" {
  stack_filter {
    project_paths = ["**/elastic-search/kibana"]
  }
  content = <<-EOF
  apiVersion: kibana.k8s.elastic.co/v1
  kind: Kibana
  metadata:
    name: ${global.name}
  spec:
    version: 9.1.4
    http:
      service:
        metadata:
          annotations:
            service.beta.kubernetes.io/aws-load-balancer-type: nlb
            service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
            service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
        spec:
          type: LoadBalancer
    count: 1
    elasticsearchRef:
      name: ${global.name}
  EOF
}