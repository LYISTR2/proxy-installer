#!/usr/bin/env bash

OS_ID=""
OS_VERSION_ID=""
PKG_INSTALL=""

_detect_apt_system() {
  PKG_INSTALL="apt-get install -y"
}

detect_system() {
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_ID="${ID:-}"
    OS_VERSION_ID="${VERSION_ID:-}"
  fi

  case "$OS_ID" in
    ubuntu|debian)
      _detect_apt_system
      ;;
    *)
      error "Unsupported system: ${OS_ID:-unknown}. Only Debian/Ubuntu are supported in v0.1"
      exit 1
      ;;
  esac
}

install_base_packages() {
  info "Installing base packages"
  apt-get update
  eval "$PKG_INSTALL curl wget tar gzip unzip openssl ca-certificates jq systemd iproute2"
}

install_xray() {
  if command_exists xray; then
    info "xray already installed"
    return 0
  fi

  info "Installing xray"
  bash <(curl -fsSL https://github.com/XTLS/Xray-install/raw/main/install-release.sh) install
}

install_hysteria2_binary() {
  if command_exists hysteria; then
    info "hysteria already installed"
    return 0
  fi

  info "Installing hysteria2"
  bash <(curl -fsSL https://get.hy2.sh/)
}

install_shadowsocks_rust() {
  if command_exists ssserver; then
    info "shadowsocks-rust already installed"
    return 0
  fi

  info "Installing shadowsocks-rust"
  eval "$PKG_INSTALL shadowsocks-rust"
}

install_trojan_go() {
  if command_exists trojan-go; then
    info "trojan-go already installed"
    return 0
  fi

  local tmp_dir archive url latest
  tmp_dir="$(mktemp -d)"
  latest="$(curl -fsSL https://api.github.com/repos/p4gefau1t/trojan-go/releases/latest | jq -r '.tag_name')"
  url="https://github.com/p4gefau1t/trojan-go/releases/download/${latest}/trojan-go-linux-amd64.zip"

  info "Installing trojan-go ${latest}"
  curl -fsSL "$url" -o "$tmp_dir/trojan-go.zip"
  unzip -qo "$tmp_dir/trojan-go.zip" -d "$tmp_dir"
  install -m 0755 "$tmp_dir/trojan-go/trojan-go" "$BIN_DIR/trojan-go"
  rm -rf "$tmp_dir"
}
