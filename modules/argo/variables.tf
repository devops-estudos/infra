variable "repositories" {
  type = map(object({
    name = string
    type = optional(string, "git")
    repo = string
  }))
}

variable "applications" {
  type = map(object({
    name = string
    repo = string
    path = optional(string, "services/{{application}}")
  }))
}