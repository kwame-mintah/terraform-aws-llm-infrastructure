variable "allowed_account_ids" {
  description = <<-EOF
  List of allowed AWS account IDs to prevent you
  from mistakenly using an incorrect one.

EOF

  type = list(string)
}

variable "aws_region" {
  description = <<-EOF
  The AWS region.

EOF

  type = string
}
