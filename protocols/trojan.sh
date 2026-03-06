#!/usr/bin/env bash

install_trojan() {
  install_base_packages
  install_trojan_go
  ensure_dir "$PROXY_INSTALLER_HOME/trojan"

  local default_host domain port password config_path service_path cert_path key_path trojan_bin
  default_host="$(default_server_host)"
  read -r -p "Server IP or domain [${default_host}]: " domain
  domain="${domain:-$default_host}"
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
  trojan_bin="$(command -v trojan-go || true)"

  if [[ -z "$trojan_bin" ]]; then
    error "trojan-go binary not found after install"
    return 1
  fi

  openssl req -x509 -nodes -newkey rsa:2048 -days 3650 \
    -keyout "$key_path" \
    -out "$cert_path" \
    -subj "/CN=${domain}" >/dev/null 2>&1

  cat > "$config_path" <<EOF
{
  "run_type": "server",
  "local_addr": "::",
  "local_port": ${port},
  "remote_addr": "www.apple.com",
  "remote_port": 443,
  "password": ["${password}"],
  "ssl": {
    "cert": "${cert_path}",
    "key": "${key_path}",
    "sni": "${domain}"
  }
}
EOF

  cat > "$service_path" <<EOF
[Unit]
Description=Trojan-Go Server
After=network.target

[Service]
Type=simple
ExecStart=${trojan_bin} -config ${config_path}
Restart=on-failure
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

  if ! enable_now trojan-go; then
    error "Failed to start trojan-go"
    service_status_brief trojan-go
    service_last_logs trojan-go
    return 1
  fi

  info "trojan-go started successfully"
  service_status_brief trojan-go
  print_trojan_summary "$domain" "$port" "$password"
  print_runtime_check "trojan-go" "$port" "tcp"
}
