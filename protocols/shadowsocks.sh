#!/usr/bin/env bash

install_shadowsocks() {
  install_base_packages
  install_shadowsocks_rust
  ensure_dir "$PROXY_INSTALLER_HOME/shadowsocks"

  local host port method password config_path service_path
  read -r -p "Server IP or domain [$(public_ip)]: " host
  host="${host:-$(public_ip)}"
  port="$(pick_port "Listen port" 8388)"

  if port_in_use "$port"; then
    warn "Port $port already in use"
    return 1
  fi

  method="2022-blake3-aes-128-gcm"
  password="$(openssl rand -base64 16 | tr -d '\n')"
  config_path="$PROXY_INSTALLER_HOME/shadowsocks/config.json"
  service_path="/etc/systemd/system/shadowsocks-rust.service"

  cat > "$config_path" <<EOF
{
  "server": "0.0.0.0",
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
ExecStart=/usr/bin/ssserver -c ${config_path}
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

  enable_now shadowsocks-rust
  print_shadowsocks_summary "$method" "$password" "$port" "$host"
}
