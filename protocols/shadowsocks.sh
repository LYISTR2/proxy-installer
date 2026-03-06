#!/usr/bin/env bash

install_shadowsocks() {
  install_base_packages
  install_shadowsocks_rust
  ensure_dir "$PROXY_INSTALLER_HOME/shadowsocks"

  local default_host host port method password config_path service_path ssserver_bin
  default_host="$(default_server_host)"
  read -r -p "Server IP or domain [${default_host}]: " host
  host="${host:-$default_host}"
  port="$(pick_port "Listen port" 8388)"

  if port_in_use "$port"; then
    warn "Port $port already in use"
    return 1
  fi

  method="2022-blake3-aes-128-gcm"
  password="$(openssl rand -base64 16 | tr -d '\n')"
  config_path="$PROXY_INSTALLER_HOME/shadowsocks/config.json"
  service_path="/etc/systemd/system/shadowsocks-rust.service"
  ssserver_bin="$(command -v ssserver || true)"

  if [[ -z "$ssserver_bin" ]]; then
    error "ssserver binary not found after install"
    return 1
  fi

  cat > "$config_path" <<EOF
{
  "server": "::",
  "server_port": ${port},
  "method": "${method}",
  "password": "${password}",
  "mode": "tcp_and_udp"
}
EOF

  cat > "$service_path" <<EOF
[Unit]
Description=Shadowsocks Rust
After=network.target

[Service]
Type=simple
ExecStart=${ssserver_bin} -c ${config_path}
Restart=on-failure
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

  if ! enable_now shadowsocks-rust; then
    error "Failed to start shadowsocks-rust"
    service_status_brief shadowsocks-rust
    service_last_logs shadowsocks-rust
    return 1
  fi

  info "shadowsocks-rust started successfully"
  service_status_brief shadowsocks-rust
  print_shadowsocks_summary "$method" "$password" "$port" "$host"
}
