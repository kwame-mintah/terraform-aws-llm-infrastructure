# The Availability Zones data source allows access to the list of AWS Availability Zones 
# which can be accessed by an AWS account within the region configured in the provider.
data "aws_availability_zones" "available_zones" {}

# Data source to get the access to the effective Account ID, User ID, and ARN 
# in which Terraform is authorized.
data "aws_caller_identity" "current_caller_identity" {}

locals {
  name_prefix = "${var.project_name}-${var.aws_region}-${var.env_prefix}"
}

resource "tls_private_key" "ollama_developer_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ollama_developer" {
  key_name_prefix = "${local.name_prefix}-ollama"
  public_key      = trimspace(tls_private_key.ollama_developer_ssh_key.public_key_openssh)
}

resource "aws_instance" "ollama_instance" {
  ami           = "ami-075599e9cc6e3190d"
  instance_type = "g4dn.xlarge" # Smallest and cheapest instance with GPU
  key_name      = aws_key_pair.ollama_developer.key_name
  monitoring    = true
  ebs_optimized = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }
  tags = {
    Name    = "${local.name_prefix}-ollama"
    Service = "Ollama Server"
  }
}
