
provider "aws" {
  region = "us-east-1"
}

module "github_oidc_role" {
  source = "../"

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
    "ManagedBy" = "Terraform",
    "Owner"     = "Example"
  }
}
