variable "github_environment" {
  type        = string
  description = "GitHub environment name, the permissions will be limited to this environment"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name that the workflow will be runned"
}


variable "github_organization" {
  type        = string
  description = "GitHub organization name"
}



variable "iam_policy_statements" {
  description = "A list of iam policy statement objects"
  type = list(object({
    sid           = optional(string)
    effect        = optional(string, "Allow")
    actions       = list(string)
    not_actions   = optional(list(string))
    resources     = optional(list(string))
    not_resources = optional(list(string))
    condition = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })))
  }))

  default = []
}

variable "tags" {
  type        = map(string)
  description = "Tags, all of the tags are applied to all of the AWS resources"
  default     = {}
}
