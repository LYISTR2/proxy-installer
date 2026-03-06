#!/usr/bin/env bash

print_vless_reality_summary() {
  local domain="$1" port="$2" uuid="$3" public_key="$4" short_id="$5" server_name="$6"
  local link_domain="$domain"
  if [[ "$link_domain" == *:* ]]; then
    link_domain="[$link_domain]"
  fi
  local vless_link="vless://${uuid}@${link_domain}:${port}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${server_name}&fp=chrome&pbk=${public_key}&sid=${short_id}&type=tcp&headerType=none#vless-reality"
  cat <<EOF
==== VLESS Reality ====
Address     : ${domain}
Port        : ${port}
UUID        : ${uuid}
Flow        : xtls-rprx-vision
Public Key  : ${public_key}
Short ID    : ${short_id}
SNI         : ${server_name}
Transport   : tcp
Security    : reality
Link        : ${vless_link}
EOF
}

print_hysteria2_summary() {
  local domain="$1" port="$2" password="$3"
  cat <<EOF
==== Hysteria2 ====
Address   : ${domain}
Port      : ${port}
Password  : ${password}
Transport : udp
EOF
}

print_shadowsocks_summary() {
  local method="$1" password="$2" port="$3" host="$4"
  cat <<EOF
==== Shadowsocks ====
Address  : ${host}
Port     : ${port}
Method   : ${method}
Password : ${password}
EOF
}

print_trojan_summary() {
  local domain="$1" port="$2" password="$3"
  cat <<EOF
==== Trojan ====
Address  : ${domain}
Port     : ${port}
Password : ${password}
EOF
}
