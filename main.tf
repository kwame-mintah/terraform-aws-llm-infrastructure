# The Availability Zones data source allows access to the list of AWS Availability Zones 
# which can be accessed by an AWS account within the region configured in the provider.
data "aws_availability_zones" "available_zones" {}

# Data source to get the access to the effective Account ID, User ID, and ARN 
# in which Terraform is authorized.
data "aws_caller_identity" "current_caller_identity" {}

data "http" "aws_check_ip" {
  url = "https://checkip.amazonaws.com/"
}

locals {
  name_prefix     = "${var.project_name}-${var.aws_region}-${var.env_prefix}"
  user_ip_address = chomp(data.http.aws_check_ip.response_body)
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
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.sg_ollama_server.id]

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
  vpc_id      = aws_vpc.main.id

  tags = {
    Name    = "${local.name_prefix}-ollama-security-group"
    Service = "Ollama Server"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_tcp_ipv4" {
  security_group_id = aws_security_group.sg_ollama_server.id
  cidr_ipv4         = "${local.user_ip_address}/32"
  to_port           = 22
  from_port         = 22
  ip_protocol       = "tcp"
}
