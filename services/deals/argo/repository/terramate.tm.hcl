stack {
  name        = "services/contacts/argo/repository"
  description = "Contacts service Argo repository"

  tags = [
    "services",
    "contacts",
    "argo",
    "repository",
  ]
  id = "1c66a394-07d6-4a07-b1fe-5a10f62771aa"
}

globals {
  repository_url = "https://github.com/devops-estudos/${global.name}.git"
}