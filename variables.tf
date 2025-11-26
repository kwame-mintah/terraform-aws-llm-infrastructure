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

variable "env_prefix" {
  description = <<-EOF
  The prefix added to resources in the environment.

EOF

  type = string
  validation {
    condition     = contains(["dev", "staging", "prod", "sandbox"], var.env_prefix)
    error_message = "The env_prefix value must be either: dev, staging, prod or sandbox."
  }
}

variable "project_name" {
  description = <<-EOF
  The name of the project.

EOF

  type = string
}

variable "additional_developer_access_ip_addresses" {
  description = <<-EOF
  Map of developer name and their IP address to access
  various resources.

EOF

  type    = map(string)
  default = {}
}