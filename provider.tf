# Configure the AWS Provider
provider "aws" {
  region              = var.aws_region
  allowed_account_ids = var.allowed_account_ids
}
