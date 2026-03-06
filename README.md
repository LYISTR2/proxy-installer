# proxy-installer

轻量一键代理安装脚本。目标很简单：

- **少协议**
- **好维护**
- **结构清楚**
- **装完就能复制到主流客户端里用**

这个项目现在不是面板，也不是“大杂烩神脚本”，而是一个偏 **MVP / 原型** 的安装器。

---

## 当前支持的协议

v0.1 当前已实机验证过：

- **VLESS Reality**
- **Hysteria2**
- **Shadowsocks 2022**
- **Trojan**

每个协议当前都包含：

- 安装
- 生成服务端配置
- 写入 systemd 服务
- 启动服务
- 输出客户端可导入信息
  - 分享链接
  - 手动参数
- 输出基础运行时检查
  - 服务状态
  - 端口监听

---

## 支持系统

当前 v0.1 仅支持：

- Debian
- Ubuntu

已知**暂不支持**：

- Alpine Linux
- CentOS / Rocky / AlmaLinux

> 说明：Alpine 不是不能做，而是目前还没进入 v0.1 主线。

---

## 推荐使用方式

### 方式 1：先 clone 再执行（更稳）

```bash
git clone https://github.com/LYISTR2/proxy-installer.git
cd proxy-installer
chmod +x install.sh
bash install.sh
```

这是**更推荐**的方式，因为你可以先看代码，再运行。

### 方式 2：一键执行（更快）

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/LYISTR2/proxy-installer/main/install.sh)
```

> 注意：这种方式本质上是远程拉脚本直接执行，方便，但天然有风险。

---

## 使用效果

安装成功后，脚本会输出：

### 1. Share Link
给 NekoBox / v2rayN / v2rayNG / sing-box / Hiddify / Shadowrocket 等客户端直接导入。

### 2. Manual Config
如果某个客户端不认链接，就可以按参数手填：

- 地址
- 端口
- UUID / 密码
- SNI
- Public Key
- Short ID
- Flow
- TLS / Reality 相关参数

### 3. Runtime Check
安装后会额外输出：

- 服务是否 active
- 端口是否在监听

---

## 协议说明

### VLESS Reality
当前输出：
- `vless://` 分享链接
- 手动配置参数
- 运行时检查

注意：
- 当前默认走 `tcp + reality`
- 默认会生成 Reality 所需参数
- 更适合主流 Xray 系客户端

### Hysteria2
当前输出：
- `hy2://` 分享链接
- 手动配置参数
- 运行时检查

注意：
- 当前使用**自签名证书**
- 客户端通常需要开启 `Allow Insecure`

### Shadowsocks 2022
当前输出：
- `ss://` 分享链接
- 手动配置参数
- 运行时检查

注意：
- 当前实现的是 **SS2022**
- 当前 method：`2022-blake3-aes-128-gcm`
- 不是旧版 AEAD 方案

### Trojan
当前输出：
- `trojan://` 分享链接
- 手动配置参数
- 运行时检查

注意：
- 当前同样使用**自签名证书**
- 客户端通常需要开启 `Allow Insecure`

---

## 项目结构

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

---

## 设计原则

- 先做少，先做稳
- 每个协议独立模块
- 安装逻辑和协议逻辑分开
- 不把 realm、限速、面板、系统优化脚本混进第一版
- 优先让“装完能用”，再追求“大而全”

---

## 已知限制

### 1. 证书目前主要是自签名
这意味着：

- Hysteria2 需要 `insecure=1`
- Trojan 通常需要 `allowInsecure=1`

这适合：
- 快速测试
- 临时使用
- 自己验证脚本流程

不太适合：
- 严格生产环境
- 对 TLS 完整性要求高的场景

### 2. 远程一键执行有天然风险
下面这种命令很方便：

```bash
bash <(curl -fsSL ...)
```

但本质上就是“远程下载后直接执行”。
如果你在意安全，建议始终：

- 先 `git clone`
- 先看代码
- 再执行

### 3. 仍然依赖部分上游安装逻辑
当前部分组件仍会依赖官方发布方式或安装入口。后续计划逐步统一成：

- 直接下载 release 二进制
- 自己写 service
- 减少外部安装脚本依赖

### 4. 客户端兼容性还在继续打磨
当前分享链接已经可用，但还没有做到：

- 每个客户端逐个版本全面验证
- 对每个客户端做专项优化输出

所以当前状态是：

- **已经能用**
- **还值得继续精修**

---

## 安全说明

这个项目当前没有刻意做危险行为，但你仍然应该注意：

- 请在**纯净服务器**上使用
- 请确认脚本来源可信
- 不要在不了解的情况下直接公网暴露服务
- 对自签名证书方案要有心理预期
- 装完后建议自己复查：
  - 配置文件
  - systemd 服务
  - 监听端口
  - 防火墙

---

## 当前进度

目前已经实机打通过：

- VLESS Reality
- Hysteria2
- Shadowsocks 2022
- Trojan

也就是说，这个仓库现在已经不只是“想法”，而是一个**能跑的原型**。

---

## 后续计划

更合理的下一阶段不是继续乱加协议，而是：

- 统一输出格式
- 完善 README 和使用说明
- 继续做安全/可靠性收口
- 减少对外部安装脚本的依赖
- 后续再考虑 Alpine / 更多系统支持
- 条件成熟后再考虑 Realm、限速、端口转发等扩展能力

---

## 免责声明

这个项目更适合：

- 自己折腾
- 测试部署
- 学习脚本结构
- 快速验证协议搭建流程

如果你要把它直接当生产系统用：

**请自己审代码、自己测、自己兜底。**
