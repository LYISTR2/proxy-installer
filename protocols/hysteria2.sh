#!/usr/bin/env bash

install_hysteria2() {
  install_base_packages
  install_hysteria2_binary
  ensure_dir "$PROXY_INSTALLER_HOME/hysteria2"

  local default_host domain port password config_path service_path cert_path key_path
  default_host="$(default_server_host)"
  read -r -p "Server IP or domain [${default_host}]: " domain
  domain="${domain:-$default_host}"
  port="$(pick_port "Listen port" 8443)"

  if port_in_use "$port"; then
    warn "Port $port already in use"
    return 1
  fi

  password="$(random_hex 12)"
  cert_path="$PROXY_INSTALLER_HOME/hysteria2/server.crt"
  key_path="$PROXY_INSTALLER_HOME/hysteria2/server.key"
  config_path="$PROXY_INSTALLER_HOME/hysteria2/config.yaml"
  service_path="/etc/systemd/system/hysteria2-server.service"

  openssl req -x509 -nodes -newkey rsa:2048 -days 3650 \
    -keyout "$key_path" \
    -out "$cert_path" \
    -subj "/CN=${domain}" >/dev/null 2>&1

  cat > "$config_path" <<EOF
listen: :${port}
tls:
  cert: ${cert_path}
  key: ${key_path}
auth:
  type: password
  password: ${password}
masquerade:
  type: proxy
  proxy:
    url: https://www.cloudflare.com
    rewriteHost: true
EOF

  cat > "$service_path" <<EOF
[Unit]
Description=Hysteria2 Server
After=network.target

[Service]
Type=simple
ExecStart=${BIN_DIR}/hysteria server -c ${config_path}
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

  if ! enable_now hysteria2-server; then
    error "Failed to start hysteria2-server"
    service_status_brief hysteria2-server
    service_last_logs hysteria2-server
    return 1
  fi

  info "hysteria2-server started successfully"
  service_status_brief hysteria2-server
  print_hysteria2_summary "$domain" "$port" "$password"
  print_runtime_check "hysteria2-server" "$port" "udp"
}
