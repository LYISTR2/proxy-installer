#!/usr/bin/env bash

print_vless_reality_summary() {
  local domain="$1" port="$2" uuid="$3" public_key="$4" short_id="$5" server_name="$6"
  local link_domain="$domain"
  if [[ "$link_domain" == *:* ]]; then
    link_domain="[$link_domain]"
  fi

  local name="vless-reality-${domain//:/-}-${port}"
  local vless_link="vless://${uuid}@${link_domain}:${port}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${server_name}&fp=chrome&pbk=${public_key}&sid=${short_id}&type=tcp&headerType=none#${name}"

  cat <<EOF
==== VLESS Reality ====

[Share Link]
${vless_link}

[Manual Config]
Type        : VLESS
Address     : ${domain}
Port        : ${port}
UUID        : ${uuid}
Flow        : xtls-rprx-vision
Transport   : tcp
Security    : reality
SNI         : ${server_name}
Fingerprint : chrome
Public Key  : ${public_key}
Short ID    : ${short_id}

[Client Notes]
- NekoBox / v2rayN / v2rayNG: import the share link directly.
- If direct import fails, create a VLESS node manually with the fields above.
- Network=tcp, TLS/REALITY enabled, packet encoding left default.
EOF
}

print_hysteria2_summary() {
  local domain="$1" port="$2" password="$3"
  local link_domain="$domain"
  if [[ "$link_domain" == *:* ]]; then
    link_domain="[$link_domain]"
  fi
  local name="hy2-${domain//:/-}-${port}"
  local hy2_link="hy2://${password}@${link_domain}:${port}/?sni=${domain}&insecure=1#${name}"
  cat <<EOF
==== Hysteria2 ====

[Share Link]
${hy2_link}

[Manual Config]
Type        : Hysteria2
Address     : ${domain}
Port        : ${port}
Password    : ${password}
Transport   : udp
TLS         : self-signed
SNI         : ${domain}
AllowInsecure: true

[Client Notes]
- NekoBox / sing-box / Hiddify: import the share link directly.
- This v0.1 setup uses a self-signed certificate, so clients usually need Allow Insecure enabled.
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
