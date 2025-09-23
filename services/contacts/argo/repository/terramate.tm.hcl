stack {
  name        = "services/contacts/argo/repository"
  description = "Contacts service Argo repository"

  tags = [
    "services",
    "contacts",
    "argo",
    "repository",
  ]
  id = "381db786-7fe7-4fa3-8e76-143d77d4e785"
}

globals {
  repository_url = "https://github.com/devops-estudos/${global.name}.git"
}