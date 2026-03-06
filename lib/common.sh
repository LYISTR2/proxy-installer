#!/usr/bin/env bash

PROXY_INSTALLER_HOME="/etc/proxy-installer"
BIN_DIR="/usr/local/bin"

info() {
  printf '[INFO] %s\n' "$*"
}

warn() {
  printf '[WARN] %s\n' "$*" >&2
}

error() {
  printf '[ERROR] %s\n' "$*" >&2
}

require_root() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    error "Please run as root"
    exit 1
  fi
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

ensure_dir() {
  mkdir -p "$1"
}

random_hex() {
  local len="${1:-16}"
  openssl rand -hex "$len"
}

random_uuid() {
  cat /proc/sys/kernel/random/uuid
}

public_ip() {
  curl -4 -fsS --max-time 10 https://api.ipify.org || true
}

public_ip_v6() {
  curl -6 -fsS --max-time 10 https://api64.ipify.org || true
}

default_server_host() {
  local ip4 ip6
  ip4="$(public_ip)"
  if [[ -n "$ip4" ]]; then
    echo "$ip4"
    return 0
  fi
  ip6="$(public_ip_v6)"
  if [[ -n "$ip6" ]]; then
    echo "$ip6"
    return 0
  fi
  hostname -I 2>/dev/null | awk '{print $1}' || true
}

pause_enter() {
  read -r -p "Press Enter to continue..." _
}

pick_port() {
  local prompt="$1"
  local default_port="$2"
  local port
  read -r -p "$prompt [$default_port]: " port
  port="${port:-$default_port}"
  if ! [[ "$port" =~ ^[0-9]+$ ]] || (( port < 1 || port > 65535 )); then
    error "Invalid port: $port"
    return 1
  fi
  echo "$port"
}

port_in_use() {
  local port="$1"
  ss -lntup 2>/dev/null | awk '{print $5}' | grep -Eq "[:\.]${port}$"
}

write_file() {
  local path="$1"
  shift
  cat > "$path"
}
