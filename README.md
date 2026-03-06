# proxy-installer

轻量一键代理安装脚本，当前目标是做一个 **少协议、好维护、结构清楚** 的安装器。

## 当前版本目标

v0.1 先支持：

- VLESS Reality
- Hysteria2
- Shadowsocks
- Trojan

每个协议只做 4 件事：

- 安装
- 生成服务端配置
- 配置 systemd
- 输出客户端所需核心参数

## 支持系统

- Debian
- Ubuntu

## 使用方法

```bash
chmod +x install.sh
./install.sh
```

## 目录结构

```text
proxy-installer/
├── install.sh
├── lib/
│   ├── common.sh
│   ├── output.sh
│   ├── service.sh
│   └── system.sh
├── protocols/
│   ├── hysteria2.sh
│   ├── shadowsocks.sh
│   ├── trojan.sh
│   └── vless_reality.sh
└── templates/
```

## 设计原则

- 先做少，先做稳
- 每个协议独立模块
- 不把 realm、限速、面板、优化脚本混进第一版
- 安装逻辑和协议逻辑分开

## 已知限制

- 目前证书使用自签名，适合测试和快速部署，不适合严格生产环境
- 端口冲突只做了基础检测
- v0.1 重点是把结构立起来，不是一步到位做全能面板

## 下一步建议

- 给每个协议补分享链接输出
- 加更严格的系统兼容检查
- 增加卸载后的二进制清理选项
- 给 VLESS Reality 增加更完整的参数可配项
