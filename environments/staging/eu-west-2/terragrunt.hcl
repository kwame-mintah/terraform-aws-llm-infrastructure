# Terragrunt will copy the Terraform files from the locations specified into this directory
terraform {
  source = "${get_path_to_repo_root()}//"
}

locals {
  environment = "staging"
}

include {
  path = find_in_parent_folders()
}

# These are inputs that need to be passed for the terragrunt configuration
inputs = {
  tags = {
    Terraform   = "true"
    Environment = "${local.environment}"
  }
}
