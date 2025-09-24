# backend.tf
generate_hcl "backend.tf" {
  stack_filter {
    project_paths = ["**/elastic-search/cluster"]
  }
  content {
    terraform {
      backend "remote" {
        organization = global.organization
        workspaces {
          name = "${global.name}-elastic-search-cluster"
        }
      }
    }
  }
}

# provider.tf
generate_hcl "provider.tf" {
  stack_filter {
    project_paths = ["**/elastic-search/cluster"]
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
    project_paths = ["**/elastic-search/cluster"]
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
    project_paths = ["**/elastic-search/cluster"]
  }
  content {
    resource "kubernetes_manifest" "this" {
      manifest = yamldecode(file("./configs/cluster.yml"))
    }
  }
}

generate_file "configs/cluster.yml" {
  stack_filter {
    project_paths = ["**/elastic-search/cluster"]
  }
  content = <<-EOF
  apiVersion: elasticsearch.k8s.elastic.co/v1
  kind: Elasticsearch
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
    nodeSets:
      - name: data
        count: ${global.data_node_count}
        config:
          node.store.allow_mmap: false
        volumeClaimTemplates:
          - metadata:
              name: elasticsearch-data
            spec:
              accessModes:
                - ReadWriteOnce
              resources:
                requests:
                  storage: 45Gi
              storageClassName: local-storage
        podTemplate:
          metadata:
            labels:
              elasticsearch.k8s.elastic.co/cluster-name: ${global.name}
          spec:
            topologySpreadConstraints:
              - maxSkew: 1
                topologyKey: kubernetes.io/hostname
                whenUnsatisfiable: DoNotSchedule
                labelSelector:
                  matchLabels:
                    elasticsearch.k8s.elastic.co/cluster-name: ${global.name}
            tolerations:
              - key: name
                operator: Equal
                value: ${global.name}
                effect: NoSchedule
  EOF
}