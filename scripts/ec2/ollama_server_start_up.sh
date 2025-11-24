#!/bin/bash

# Manual install of Ollama
# https://docs.ollama.com/linux#manual-install
curl -fsSL https://ollama.com/install.sh | sh

# Change host from localhost to 0.0.0.0
# https://github.com/koalaman/shellcheck/wiki/SC2129
sudo bash -c '{
  echo "[Service]";
  echo "Environment=\"OLLAMA_HOST=0.0.0.0\"";
  echo "Environment=\"OLLAMA_PORT=11434\"";
  echo "Environment=\"OLLAMA_KEEP_ALIVE=60m\"";
} >> /etc/systemd/system/ollama.service'

# Reload systemd, enable and start ollama server 
sudo systemctl stop ollama && \
sudo systemctl daemon-reload && \
sudo systemctl enable ollama && \
sudo systemctl start ollama && \

# Pull model needed
ollama pull gemma3n:e4b
