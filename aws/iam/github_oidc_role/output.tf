
output "role_arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of the role."
  value       = aws_iam_role.this.name
}

output "role_unique_id" {
  description = "Stable and unique string identifying the role."
  value       = aws_iam_role.this.unique_id
}