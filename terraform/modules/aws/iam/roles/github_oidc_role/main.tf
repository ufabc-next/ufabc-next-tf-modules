resource "aws_iam_openid_connect_provider" "this" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  tags = var.tags
}

data "aws_iam_policy_document" "oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this.arn]
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test     = "StringLike"
      values   = ["repo:${var.github_organization}/${var.github_repo}:environment:${var.github_environment}"]
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}


resource "aws_iam_role" "this" {
  name               = "GitActionsOIDCRole-${var.github_environment}"
  assume_role_policy = data.aws_iam_policy_document.oidc.json

  tags = var.tags
}


data "aws_iam_policy_document" "permissions_policy" {
  dynamic "statement" {
    for_each = var.iam_policy_statements

    content {
      sid           = statement.value.sid
      effect        = statement.value.effect
      actions       = statement.value.actions
      not_actions   = lookup(statement.value, "not_actions", null)
      resources     = lookup(statement.value, "resources", null)
      not_resources = lookup(statement.value, "not_resources", null)

      dynamic "condition" {
        for_each = statement.value.condition != null ? statement.value.condition : []
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_iam_role_policy" "permissions_policy" {
  name = "GithubOIDCPolicy"
  role = aws_iam_role.this.name

  policy = data.aws_iam_policy_document.permissions_policy.json
}
