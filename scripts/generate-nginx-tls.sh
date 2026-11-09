#!/usr/bin/env bash
# Create a self-signed certificate for local HTTPS on the Nginx front door.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TLS_DIR="${ROOT}/nginx/tls"
mkdir -p "${TLS_DIR}"
openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout "${TLS_DIR}/key.pem" \
  -out "${TLS_DIR}/cert.pem" \
  -days 825 \
  -subj "/CN=localhost/O=homelab-monitoring/C=XX"
chmod 600 "${TLS_DIR}/key.pem"
echo "Wrote ${TLS_DIR}/cert.pem and ${TLS_DIR}/key.pem"
echo "Copy nginx/conf.d/ssl.conf.example to nginx/conf.d/ssl.conf, then:"
echo "  docker compose up -d nginx"
