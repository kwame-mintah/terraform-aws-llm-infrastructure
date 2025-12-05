# The Availability Zones data source allows access to the list of AWS Availability Zones 
# which can be accessed by an AWS account within the region configured in the provider.
data "aws_availability_zones" "available_zones" {}

# Data source to get the access to the effective Account ID, User ID, and ARN 
# in which Terraform is authorized.
data "aws_caller_identity" "current_caller_identity" {}

data "http" "aws_check_ip" {
  url = "https://checkip.amazonaws.com/"
}

# data "http" "github_ip_addresses" {
#   url = "https://api.github.com/meta"
# }

locals {
  name_prefix = "${var.project_name}-${var.aws_region}-${var.env_prefix}"
  developer_access = merge({
    me = chomp(data.http.aws_check_ip.response_body)
    }, var.additional_developer_access_ip_addresses
  )
  long_form_environment_name = {
    "dev"  = "development"
    "stg"  = "staging"
    "prod" = "production"
  }
}

resource "aws_resourcegroups_group" "project_resource_group" {
  name = "${local.name_prefix}-resource-group"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "Project",
      "Values": ["terraform-aws-llm-infrastructure"]
    },
    {
      "Key": "Environment",
      "Values": ["${local.long_form_environment_name[var.env_prefix]}"]
    }
  ]
}
JSON
  }
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
  ami                    = "ami-075599e9cc6e3190d"
  instance_type          = "g4dn.xlarge" # Smallest and cheapest instance with GPU
  key_name               = aws_key_pair.ollama_developer.key_name
  monitoring             = true
  ebs_optimized          = true
  subnet_id              = aws_subnet.main_subnet.id
  vpc_security_group_ids = [aws_security_group.sg_ollama_server.id]

  user_data_base64 = base64encode(templatefile("${path.module}/scripts/ec2/install_ollama_server.sh", {
    ollama_model = var.ollama_default_model_installed
  }))

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size = 16 # Increase as needed depending on the model size
    encrypted   = true
  }
  tags = {
    Name    = "${local.name_prefix}-ollama"
    Service = "Ollama Server"
  }
}

resource "aws_security_group" "sg_ollama_server" {
  name        = "${local.name_prefix}-ollama-security-group"
  description = "Allow traffic from specific source to Ollama server"
  vpc_id      = aws_vpc.main_vpc.id

  tags = {
    Name    = "${local.name_prefix}-ollama-security-group"
    Service = "Ollama Server"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_tcp_for_users" {
  for_each          = tomap(local.developer_access)
  description       = "Allow SSH access to EC2 instances for ${each.key}"
  security_group_id = aws_security_group.sg_ollama_server.id
  cidr_ipv4         = "${each.value}/32"
  to_port           = 22
  from_port         = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ollama_server_communication_for_users" {
  for_each          = tomap(local.developer_access)
  description       = "Allow access to Ollama server for ${each.key}"
  security_group_id = aws_security_group.sg_ollama_server.id
  cidr_ipv4         = "${each.value}/32"
  to_port           = 11434
  from_port         = 11434
  ip_protocol       = "tcp"
}

# Allow internet access as per AWS architecture recommendation, rather than whitelisting
# Each IP address from each CDN, as this could change:
# https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/using-nat-gateway-for-centralized-egress.html
resource "aws_vpc_security_group_egress_rule" "allow_outbound_https_access" {
  description       = "Allow internet access to various resources" # (developer.download.nvidia.com) / (release-assets.githubusercontent.com) / (github.com) / (ollama.com)
  security_group_id = aws_security_group.sg_ollama_server.id
  cidr_ipv4         = "0.0.0.0/0"
  to_port           = 443
  from_port         = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_outbound_http_access" {
  description       = "Allow internet access to HTTP"
  security_group_id = aws_security_group.sg_ollama_server.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}
