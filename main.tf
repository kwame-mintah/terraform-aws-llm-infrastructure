# The Availability Zones data source allows access to the list of AWS Availability Zones 
# which can be accessed by an AWS account within the region configured in the provider.
data "aws_availability_zones" "available_zones" {}

# Data source to get the access to the effective Account ID, User ID, and ARN 
# in which Terraform is authorized.
data "aws_caller_identity" "current_caller_identity" {}

locals {
  name_prefix = "${var.project_name}-${var.aws_region}-${var.env_prefix}"
}

resource "aws_instance" "ollama_instance" {
  ami           = "ami-075599e9cc6e3190d"
  instance_type = "g4dn.xlarge" # Smallest and cheapest instance with GPU
  tags = {
    Service = "Ollama"
  }
}
