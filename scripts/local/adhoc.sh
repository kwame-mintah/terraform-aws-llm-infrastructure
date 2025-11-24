#!/bin/bash
# Output private key to ssh locally
terragrunt output -raw tls_ollama_developer_private_key > ~/.ssh/llm-infrastructure-eu-west-2-dev-*.pem
# Tail logs for ollama service
sudo journalctl -u ollama -f
