output "availability_zones" {
  description = <<-EOF
    List of the Availability Zone names available to the account.

EOF

  value = data.aws_availability_zones.available_zones.names
}

output "current_caller_identity" {
  description = <<-EOF
    AWS Account ID number of the account that owns or contains the 
    calling entity.

EOF

  value = data.aws_caller_identity.current_caller_identity.account_id
}

output "tls_ollama_developer_public_key" {
  description = <<-EOF
    Public key data in PEM (RFC 1421) format for connecting to the EC2
    instance hosting the Ollama server.

EOF

  value = tls_private_key.ollama_developer_ssh_key.public_key_pem
}

output "tls_ollama_developer_private_key" {
  description = <<-EOF
    Private key data in PEM (RFC 1421) format for connecting to the EC2
    instance hosting the Ollama server.

EOF

  value     = tls_private_key.ollama_developer_ssh_key.private_key_pem
  sensitive = true
}

output "ec2_ollama_server_instance_public_dns" {
  description = <<-EOF
    Public key data in PEM (RFC 1421) format for connecting to the EC2
    instance hosting the Ollama server.

EOF

  value = aws_instance.ollama_instance.public_dns
}
