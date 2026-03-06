#!/usr/bin/env bash

install_vless_reality() {
  install_base_packages
  install_xray
  ensure_dir "$PROXY_INSTALLER_HOME/vless-reality"

  local default_host domain port server_name input_sni uuid private_key public_key short_id
  local config_path service_path keypair_output xray_bin

  default_host="$(default_server_host)"
  read -r -p "Server IP or domain [${default_host}]: " domain
  domain="${domain:-$default_host}"

  if [[ -z "$domain" ]]; then
    error "Could not determine server IP/domain automatically"
    return 1
  fi

  server_name="www.cloudflare.com"
  read -r -p "Reality SNI target [${server_name}]: " input_sni
  server_name="${input_sni:-$server_name}"
  port="$(pick_port "Listen port" 443)"

  if port_in_use "$port"; then
    warn "Port $port already in use"
    return 1
  fi

  uuid="$(random_uuid)"
  short_id="$(openssl rand -hex 4)"

  xray_bin="$(command -v xray || true)"
  if [[ -z "$xray_bin" && -x /usr/local/bin/xray ]]; then
    xray_bin="/usr/local/bin/xray"
  fi
  if [[ -z "$xray_bin" && -x /usr/bin/xray ]]; then
    xray_bin="/usr/bin/xray"
  fi
  if [[ -z "$xray_bin" ]]; then
    error "xray binary not found after install"
    return 1
  fi

  keypair_output="$($xray_bin x25519 2>&1 || true)"
  private_key="$(sed -n -E 's/.*Private[Kk]ey: *//p' <<< "$keypair_output" | head -n1 | tr -d '\r')"
  public_key="$(sed -n -E 's/.*Public[Kk]ey: *//p' <<< "$keypair_output" | head -n1 | tr -d '\r')"

  # Xray v26+ output changed to: PrivateKey / Password / Hash32
  if [[ -z "$public_key" ]]; then
    public_key="$(sed -n -E 's/.*Password: *//p' <<< "$keypair_output" | head -n1 | tr -d '\r')"
  fi

  if [[ -z "$private_key" || -z "$public_key" ]]; then
    error "Failed to generate Reality key pair"
    warn "xray x25519 output was:"
    printf '%s\n' "$keypair_output" >&2
    return 1
  fi

  config_path="$PROXY_INSTALLER_HOME/vless-reality/config.json"
  service_path="/etc/systemd/system/xray-vless-reality.service"

  cat > "$config_path" <<EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "listen": "::",
      "port": ${port},
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "${server_name}:443",
          "xver": 0,
          "serverNames": ["${server_name}"],
          "privateKey": "${private_key}",
          "shortIds": ["${short_id}"]
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct"
    }
  ]
}
EOF

  if ! "$xray_bin" run -test -config "$config_path"; then
    error "Generated Xray config failed validation"
    return 1
  fi

  cat > "$service_path" <<EOF
[Unit]
Description=Xray VLESS Reality
After=network.target

[Service]
Type=simple
ExecStart=${xray_bin} run -config ${config_path}
Restart=on-failure
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

  if ! enable_now xray-vless-reality; then
    error "Failed to start xray-vless-reality"
    service_status_brief xray-vless-reality
    service_last_logs xray-vless-reality
    return 1
  fi

  info "xray-vless-reality started successfully"
  service_status_brief xray-vless-reality
  print_vless_reality_summary "$domain" "$port" "$uuid" "$public_key" "$short_id" "$server_name"
}
