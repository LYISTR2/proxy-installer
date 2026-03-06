#!/usr/bin/env bash

reload_systemd() {
  systemctl daemon-reload
}

enable_now() {
  local service="$1"
  reload_systemd
  systemctl enable "$service" >/dev/null 2>&1 || true

  if systemctl is-active --quiet "$service"; then
    systemctl restart "$service"
  else
    systemctl start "$service"
  fi
}

service_status_brief() {
  local service="$1"
  systemctl --no-pager --full --lines=20 status "$service" || true
}

service_last_logs() {
  local service="$1"
  journalctl -u "$service" -n 50 --no-pager || true
}

service_is_active() {
  local service="$1"
  systemctl is-active --quiet "$service"
}

port_listening() {
  local port="$1"
  ss -lntup 2>/dev/null | awk '{print $5}' | grep -Eq "[:\.]${port}$"
}

print_runtime_check() {
  local service="$1"
  local port="$2"
  local proto="$3"
  local service_state="inactive"
  local port_state="not-detected"

  if service_is_active "$service"; then
    service_state="active"
  fi

  if port_listening "$port"; then
    port_state="listening"
  fi

  cat <<EOF

[Runtime Check]
Service     : ${service} (${service_state})
Port        : ${port}/${proto} (${port_state})
EOF
}

restart_service() {
  local service="$1"
  reload_systemd
  systemctl restart "$service"
}

show_installed_services() {
  systemctl --no-pager --full status \
    xray-vless-reality \
    hysteria2-server \
    shadowsocks-rust \
    trojan-go 2>/dev/null || true
}

uninstall_service_files() {
  local service="$1"
  local config_dir="$2"

  if systemctl list-unit-files | grep -q "^${service}\.service"; then
    systemctl disable --now "$service" || true
    rm -f "/etc/systemd/system/${service}.service"
    reload_systemd
  fi

  rm -rf "$config_dir"
  info "Removed ${service} and ${config_dir}"
}
