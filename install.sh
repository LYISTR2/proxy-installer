#!/usr/bin/env bash
set -euo pipefail

bootstrap_if_needed() {
  local current_script script_dir
  current_script="${BASH_SOURCE[0]}"
  script_dir="$(cd "$(dirname "$current_script")" 2>/dev/null && pwd || true)"

  if [[ -n "$script_dir" && -f "$script_dir/lib/common.sh" && -f "$script_dir/protocols/vless_reality.sh" ]]; then
    return 0
  fi

  local tmp_dir repo_url tarball_url
  tmp_dir="$(mktemp -d)"
  repo_url="https://github.com/LYISTR2/proxy-installer.git"
  tarball_url="https://codeload.github.com/LYISTR2/proxy-installer/tar.gz/refs/heads/main"

  echo "[INFO] Bootstrap mode: downloading full repository..."

  if ! command -v git >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
      apt-get update >/dev/null 2>&1 && apt-get install -y git >/dev/null 2>&1 || true
    elif command -v apk >/dev/null 2>&1; then
      apk add --no-cache git >/dev/null 2>&1 || true
    fi
  fi

  if command -v git >/dev/null 2>&1; then
    git clone --depth=1 "$repo_url" "$tmp_dir/proxy-installer" >/dev/null 2>&1 || true
  fi

  if [[ ! -f "$tmp_dir/proxy-installer/install.sh" ]]; then
    mkdir -p "$tmp_dir/proxy-installer"
    curl -fsSL "$tarball_url" | tar -xz --strip-components=1 -C "$tmp_dir/proxy-installer" || {
      echo "[ERROR] Failed to download repository via git and tarball fallback." >&2
      echo "[ERROR] Please check network access to github.com / codeload.github.com." >&2
      exit 1
    }
  fi

  exec bash "$tmp_dir/proxy-installer/install.sh" "$@"
}

bootstrap_if_needed "$@"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=lib/system.sh
source "$SCRIPT_DIR/lib/system.sh"
# shellcheck source=lib/service.sh
source "$SCRIPT_DIR/lib/service.sh"
# shellcheck source=lib/output.sh
source "$SCRIPT_DIR/lib/output.sh"
# shellcheck source=protocols/vless_reality.sh
source "$SCRIPT_DIR/protocols/vless_reality.sh"
# shellcheck source=protocols/hysteria2.sh
source "$SCRIPT_DIR/protocols/hysteria2.sh"
# shellcheck source=protocols/shadowsocks.sh
source "$SCRIPT_DIR/protocols/shadowsocks.sh"
# shellcheck source=protocols/trojan.sh
source "$SCRIPT_DIR/protocols/trojan.sh"

main_menu() {
  while true; do
    if [[ -n "${TERM:-}" ]]; then
      clear || true
    fi
    echo "==== Proxy Installer ===="
    echo "1) Install VLESS Reality"
    echo "2) Install Hysteria2"
    echo "3) Install Shadowsocks"
    echo "4) Install Trojan"
    echo "5) Show installed services"
    echo "6) Uninstall a service"
    echo "0) Exit"
    echo
    read -r -p "Choose an option: " choice

    case "$choice" in
      1) install_vless_reality ; pause_enter ;;
      2) install_hysteria2 ; pause_enter ;;
      3) install_shadowsocks ; pause_enter ;;
      4) install_trojan ; pause_enter ;;
      5) show_installed_services ; pause_enter ;;
      6) uninstall_menu ; pause_enter ;;
      0) exit 0 ;;
      *) warn "Invalid option"; pause_enter ;;
    esac
  done
}

uninstall_menu() {
  echo "Available services:"
  echo "1) xray-vless-reality"
  echo "2) hysteria2-server"
  echo "3) shadowsocks-rust"
  echo "4) trojan-go"
  read -r -p "Choose a service to uninstall: " choice

  case "$choice" in
    1) uninstall_service_files "xray-vless-reality" "/etc/proxy-installer/vless-reality" ;;
    2) uninstall_service_files "hysteria2-server" "/etc/proxy-installer/hysteria2" ;;
    3) uninstall_service_files "shadowsocks-rust" "/etc/proxy-installer/shadowsocks" ;;
    4) uninstall_service_files "trojan-go" "/etc/proxy-installer/trojan" ;;
    *) warn "Invalid option" ;;
  esac
}

main() {
  require_root
  detect_system
  main_menu
}

main "$@"
