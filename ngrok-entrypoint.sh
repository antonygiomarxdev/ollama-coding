#!/bin/sh
set -e
if [ -n "$NGROK_DOMAIN" ]; then
  exec ngrok http --url="$NGROK_DOMAIN" ollama:11434
else
  exec ngrok http ollama:11434
fi
