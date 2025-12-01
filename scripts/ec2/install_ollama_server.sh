#!/bin/bash
set -e

exec > /var/log/user-data.log 2>&1

echo "Starting Ollama installation..."

# Install Ollama
curl -fsSL https://ollama.com/install.sh | bash

echo "Configuring Ollama to listen on 0.0.0.0..."

# Modify systemd unit to expose Ollama externally
sudo bash -c '{
  echo ""
  echo "[Service]"
  echo "Environment=\"OLLAMA_HOST=0.0.0.0\""
  echo "Environment=\"OLLAMA_PORT=11434\""
  echo "Environment=\"OLLAMA_KEEP_ALIVE=60m\""
} >> /etc/systemd/system/ollama.service'

# Reload systemd to pick up changes
systemctl daemon-reload

# Restart Ollama with new configuration
systemctl restart ollama

echo "Ollama configuration complete."

# Pull model if provided by Terraform
if [ -n "${ollama_model}" ]; then
  echo "Pulling model ${ollama_model}..."
  ollama pull "${ollama_model}"
fi

echo "User data script finished."
