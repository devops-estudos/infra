stack {
  name        = "envs/stg/eks/elastic-search/deals/cluster"
  description = "Elasticsearch cluster for deals"

  tags = [
    "envs",
    "stg",
    "eks",
    "elastic-search",
    "deals",
  ]
  id = "0b2995cf-6640-4ef3-9776-6293101e0384"
}

globals {
  name            = "deals"
  data_node_count = 2
}