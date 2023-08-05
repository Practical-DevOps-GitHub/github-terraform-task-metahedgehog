#setting variables
variable "PAT" {
  default = "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"
}

variable "DEPLOY_KEY" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvOOSSnMQ+6lDXgPsn0Q/cTWwteUa8GxFdyJ2cSkwFfRtC0uOsiMlPzjW5z5QYKAyKPcpAIJj4hLLSfA3RA3HOtJzDA1PJ1OeWWY8K+tZaSpnT+jg+IFDlfntGj4j+UW0Rfs9c2mnlc9Vs2OmEiQ5SoJdG3oC0rN30IdAFzsOaB3yA3mCkixskLantMJc0AKDBu1mxthILK+usho/H5/Im4jr5uPPEKvg0Nf8eRpMaJeOCibnrKf7WlwYJuWfxrwDxuWNaxyAtWqCpcOBlN8lcBnBjSAXUKE8pouYCSOoFR1rC8WV2eSHZ/f/txYQBHYGwezYoMOonr5zhUmRpwXhQ0/UjAqUGMaD4lh9dq8FM5tiFstb3DwypNytgupi9yqhV+4QfiDuCDcaONk3bWmhLv5QmxOPdxoZKz8yLdApcRsFTDCjCflznV2QTIkKZ4nYo5yNwqBTMqgw+uwni72A6l2Iv+J2nE+ZF28Rmh9PyeBECcp24Lr7bIurigfA0Uw2kx1zj4QSM9c7ucaLAhsamaCcNkOAgHh1vinLU9Mzh8nQrOog5uLiNMREuJEgJD6S4RS25URhB5F5sF0O9YucNxeLrymPdIo+q60ERmfH/r+7AYQn2zx/lYyHnkqguIrBGOWpWy3+rIx4dN1MQjUo4EzeQ4g12Yl5VQ2KH7s2o5Q== danostpav@gmail.com"
}

variable "DISCORD_WEBHOOK_URL" {
  default = "https://discord.com/api/webhooks/1137463345327378523/YcCnqDIxi9iNVfvjY5DRcz7ufAYG12ZX9XyouYNXghGqzE5qg83wgNxImw8XgV0BcpDT"
}

variable "REPOSITORY" {
  default = "github-terraform-task-metahedgehog"
}

variable "GITHUB_OWNER" {
  default = "Practical-DevOps-GitHub"
}

provider "github" {
  token = var.PAT
  owner = var.GITHUB_OWNER
}

resource "github_actions_secret" "pat" {
  repository      = var.REPOSITORY
  secret_name     = "PAT"
  plaintext_value = var.PAT
}

#adding a collaborator
resource "github_repository_collaborator" "softservedata_collaborator" {
  repository = var.REPOSITORY
  username   = "softservedata"
  permission = "push"
}

#adding a branch "develop"
resource "github_branch" "develop" {
  repository = var.REPOSITORY
  branch     = "develop"
}

#setting the branch "develop" as a default one
resource "github_branch_default" "default"{
  repository = var.REPOSITORY
  branch     = "develop"
}

#rules for "main"
resource "github_branch_protection" "main" {
  repository_id = var.REPOSITORY
  pattern = "main"
  allows_deletions = false

  required_pull_request_reviews {
    dismissal_restrictions = [github_repository_collaborator.softservedata_collaborator.id]
    dismiss_stale_reviews  = false
    required_approving_review_count = 0
    require_code_owner_reviews = true
  }
}

#rules for "develop"
resource "github_branch_protection" "develop" {
  repository_id = var.REPOSITORY
  pattern = "develop"
  allows_deletions = false

  required_pull_request_reviews {
    dismissal_restrictions = [github_repository_collaborator.softservedata_collaborator.id]
    dismiss_stale_reviews  = false
    required_approving_review_count = 2
  }
}

#creating markdown for PR
resource "github_repository_file" "pull_request_template" {
  repository = var.REPOSITORY
  file  = ".github/pull_request_template.md"
  content = "Describe your changes\n\n ##Issue ticket number and link\n\n ##Checklist before requesting a review\n- I have performed a self-review of my code\nIf it is a core feature, I have added thorough tests\nDo we need to implement analytics?\nWill this be part of a product update? If yes, please write one phrase about this update "
}

#adding a DEPLOY_KEY
resource "github_repository_deploy_key" "deploy_key" {
  repository = var.REPOSITORY
  title      = "DEPLOY_KEY"
  key        = var.DEPLOY_KEY
}

#setting up a Discord Webhook
resource "github_repository_webhook" "discord_webhook" {
  repository = var.REPOSITORY
  events     = ["pull_request"]
  
  configuration {
    url          = var.DISCORD_WEBHOOK_URL
    content_type = "json"
  }
}
