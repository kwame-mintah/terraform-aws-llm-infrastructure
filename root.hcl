locals {
  project_name = "terraform-aws-template"
  aws_region   = "eu-west-2"
  # Could use `find_in_parent_folders()` if file was in the parent directory.
  account     = read_terragrunt_config("account.hcl")
  environment = read_terragrunt_config("environment.hcl")

  account_id       = local.account.locals.account_id
  account_name     = local.account.locals.account_name
  environment_name = local.environment.locals.environment_name
}

# Generate the AWS Provider configuration
# When using this terragrunt config, terragrunt will generate the file "provider.tf" with the aws provider block before
# calling to terraform. Note that this will overwrite the `provider.tf` file if it already exists.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region              = "${local.aws_region}"
  allowed_account_ids = ["${local.account_id}"]
}
EOF
}


# Generate the Remote AWS S3 Bucket for store the state file.
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "tfstate-${local.project_name}-${local.aws_region}-${local.environment_name}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "lock-${local.project_name}-${local.aws_region}-${local.environment_name}"
    s3_bucket_tags = {
      "Account name" = "${local.account_name}"
      "Project name" = "${local.project_name}"
    }
  }
  generate = {
    path      = "backend_override.tf"
    if_exists = "overwrite_terragrunt"
  }
}


#-------------------------------------------------------------------------------------------
# GLOBAL INPUTS
# These inputs apply to all terragrunt configurations in this subfolder. 
# There will be automatically merged into the child `terragrunt.hcl` using `include {}` block.
#-------------------------------------------------------------------------------------------
inputs = {
  aws_region          = "${local.aws_region}"
  allowed_account_ids = "${local.account_id}"
  project_name        = "${local.project_name}"
}