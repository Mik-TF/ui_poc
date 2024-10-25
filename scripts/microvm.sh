#!/bin/bash

# Check if domain argument is provided
if [ -z "$1" ]; then
    cat <<-EOF

Attention! Set a domain with the following command:

make microvm domain="example.com"

EOF
    exit 1
fi

domain=$1

cat <<-EOF

Welcome to the Dashboard UI Installer!

The provided domain is: $domain.
This will install the UI for a micro VM running on the TFGrid with an IPv4 address.
Make sure to point the DNS A record of your domain to the IPv4 address of the micro VM.

EOF

sleep 3

apt update && apt install -y git nano curl python3 python-is-python3 python3-venv python3-pip

apt install -y debian-keyring debian-archive-keyring
apt install -y apt-transport-https
echo "deb [trusted=yes] https://releases.caddyserver.com/deb/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/caddy.list
apt update
apt install -y caddy

cat <<EOF >> /etc/zinit/caddy.yaml
exec: caddy reverse-proxy --from ${domain} --to :8000
EOF

zinit monitor caddy

chmod +x /root/ui_poc/scripts/webserver.sh

cat <<EOF >> /etc/zinit/webserver.yaml
exec: bash /root/ui_poc/scripts/webserver.sh
EOF

zinit monitor webserver

zinit