#!/usr/bin/env bash
set -euo pipefail

apt-get update
apt-get install -y stunnel4 openssl jq

CERT_DIR=/workspace/certs
mkdir -p "$CERT_DIR"
if [ ! -f "$CERT_DIR/cert.pem" ]; then
    openssl req -x509 -nodes -days 825 \
        -newkey rsa:2048 \
        -keyout "$CERT_DIR/key.pem" \
        -out "$CERT_DIR/cert.pem" \
        -subj '/CN=textgen.runpod' \
        -addext 'subjectAltName=DNS:localhost,IP:127.0.0.1'
fi

cat >/etc/stunnel/stunnel.conf <<'EOS'
foreground = yes
pid =
[webui]
accept = 0.0.0.0:8443
connect = 127.0.0.1:7860
cert = $CERT_DIR/cert.pem
key  = $CERT_DIR/key.pem
sslVersion = TLSv1.2
EOS

nohup stunnel /etc/stunnel/stunnel.conf >/var/log/stunnel.log 2>&1 &
