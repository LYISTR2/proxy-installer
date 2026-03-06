#!/usr/bin/env bash

install_trojan() {
  install_base_packages
  install_trojan_go
  ensure_dir "$PROXY_INSTALLER_HOME/trojan"

  local domain port password config_path service_path cert_path key_path
  read -r -p "Server IP or domain [$(public_ip)]: " domain
  domain="${domain:-$(public_ip)}"
  port="$(pick_port "Listen port" 4433)"

  if port_in_use "$port"; then
    warn "Port $port already in use"
    return 1
  fi

  password="$(random_hex 12)"
  cert_path="$PROXY_INSTALLER_HOME/trojan/server.crt"
  key_path="$PROXY_INSTALLER_HOME/trojan/server.key"
  config_path="$PROXY_INSTALLER_HOME/trojan/config.json"
  service_path="/etc/systemd/system/trojan-go.service"

  openssl req -x509 -nodes -newkey rsa:2048 -days 3650 \
    -keyout "$key_path" \
    -out "$cert_path" \
    -subj "/CN=${domain}" >/dev/null 2>&1

  cat > "$config_path" <<EOF
{
  "run_type": "server",
  "local_addr": "0.0.0.0",
  "local_port": ${port},
  "password": ["${password}"],
  "ssl": {
    "cert": "${cert_path}",
    "key": "${key_path}"
  }
}
EOF

  cat > "$service_path" <<EOF
[Unit]
Description=Trojan-Go Server
After=network.target

[Service]
Type=simple
ExecStart=${BIN_DIR}/trojan-go -config ${config_path}
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

  enable_now trojan-go
  print_trojan_summary "$domain" "$port" "$password"
}
