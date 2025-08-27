
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../"
}

inputs = {
  github_organization = "ufabc-next"
  github_repo         = "ufabc-next-app"
  github_environment  = "dev"

  iam_policy_statements = [
    {
      sid       = "S3List",
      effect    = "Allow",
      actions   = ["s3:ListAllMyBuckets"],
      resources = ["*"]
    }
  ]

  tags = {
    "ManagedBy" = "Terragrunt",
    "Owner"     = "Example"
  }
}
