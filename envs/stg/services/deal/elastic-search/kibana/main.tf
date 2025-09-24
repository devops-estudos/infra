// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

resource "kubernetes_manifest" "this" {
  manifest = yamldecode(file("./configs/kibana.yml"))
}
