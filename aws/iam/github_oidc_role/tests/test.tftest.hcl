
provider "aws" {
  region = "us-east-1"
}

mock_provider "aws" {}

override_data {
  target = data.aws_iam_policy_document.oidc
  values = {
    json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":\"sts:AssumeRoleWithWebIdentity\",\"Effect\":\"Allow\",\"Principal\":{\"Federated\":\"arn:aws:iam::000000000000:oidc-provider/token.actions.githubusercontent.com\"},\"Condition\":{\"StringEquals\":{\"token.actions.githubusercontent.com:aud\":\"sts.amazonaws.com\"},\"StringLike\":{\"token.actions.githubusercontent.com:sub\":\"repo:ufabc-next/ufabc-next-app:environment:dev\"}}}]}"
  }
}

override_data {
  target = data.aws_iam_policy_document.permissions_policy
  values = {
    json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"S3List\",\"Effect\":\"Allow\",\"Action\":[\"s3:ListAllMyBuckets\"],\"Resource\":[\"*\"]}]}"
  }
}

variables {
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
    "Owner"     = "Test"
  }
}

run "github_oidc_role" {
  command = apply

  assert {
    condition     = aws_iam_role.this.name == "GitActionsOIDCRole-dev"
    error_message = "Role name is incorrect"
  }

  assert {
    condition     = jsondecode(aws_iam_role.this.assume_role_policy).Statement[0].Principal.Federated == "arn:aws:iam::000000000000:oidc-provider/token.actions.githubusercontent.com"
    error_message = "Assume role policy principal is incorrect"
  }

  assert {
    condition     = jsondecode(aws_iam_role.this.assume_role_policy).Statement[0].Condition.StringLike["token.actions.githubusercontent.com:sub"] == "repo:ufabc-next/ufabc-next-app:environment:dev"
    error_message = "Assume role policy condition is incorrect"
  }

  assert {
    condition     = jsondecode(aws_iam_role_policy.permissions_policy.policy).Statement[0].Action[0] == "s3:ListAllMyBuckets"
    error_message = "IAM policy statement is incorrect"
  }

  assert {
    condition     = output.role_name == "GitActionsOIDCRole-dev"
    error_message = "Output role_name is incorrect"
  }

  assert {
    condition     = output.role_arn == aws_iam_role.this.arn
    error_message = "Output role_arn is incorrect"
  }
}
