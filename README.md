# shadowrocket-sync

把 [Johnshall forever](https://github.com/Johnshall/Shadowrocket-ADBlock-Rules-Forever) 的 Shadowrocket 黑名单规则，与本地**永久自定义**合并后，发布为双端可用的远程订阅：

| 产物 | 用途 |
|------|------|
| `flyint.conf` | Shadowrocket「远程文件」订阅 |
| `flyint.yaml` | Clash / Mihomo / Clash Verge 规则配置 |

上游规则可以天天变；你的 AI 分流、App Store 直连、Host/DNS **不会被上游覆盖**。

更新记录见 [CHANGELOG.md](./CHANGELOG.md)。

---

## 提供了什么能力

### 1. 上游规则自动跟随

- 默认拉取：`sr_top500_banlist_ad.conf`（GFW 黑名单 + 广告过滤，其余直连）
- 每次 `sync.sh` 重新下载最新上游，再叠本地 override
- macOS 可装 LaunchAgent：**每天 09:10** 自动 sync 并推到 Gist

### 2. 三层永久 override（优先级从高到低）

| 文件 | 作用 |
|------|------|
| `apple.override.conf` | App Store / Apple 更新 / iCloud CDN → **强制直连**，避免更新走 VPN 流量 |
| `ai.override.conf` | Gemini / Google / OpenAI / Claude / Cursor → **Proxy**；DeepSeek / 通义等 → **direct** |
| `host.override.conf` | 自定义 `[Host]`（如特定域名走指定 DNS） |

规则插入顺序：`[Rule]` 顶部先 Apple，再 AI，再上游全文。Shadowrocket / Clash 都是**先匹配先生效**。

### 3. App Store 不走代理（开箱即用）

除置顶 `direct` 规则外，`sync.sh` 还会：

- 扩展 `skip-proxy`（`*.apple.com`、`*.mzstatic.com`、`*.aaplimg.com` 等）
- 把上游「苹果域名及其 CDN 代理」整段改成 **direct**

开着 VPN 更新 App 时，主体流量走直连而不是节点。

### 4. 双格式一键发布

一次 `sync.sh` 同时生成：

- Shadowrocket `.conf`（完整规则 + Host）
- Clash `.yaml`（Loyalsoldier rule-providers + 本地 AI/Apple 置顶规则；可选节点订阅）

并用 `gh` 推到你的 **secret Gist**（手机/电脑只订阅 raw URL）。

### 5. 本机敏感信息不进 Git

公开仓库只含脚本与示例；下列文件在 `.gitignore` 中，仅本机存在：

- `config.env`（Gist ID / raw URL）
- `subscription.url`（节点订阅，可选）
- `host.override.conf`（可能含内网 DNS）
- `out/`、日志

---

## 整体流程

```text
                    ┌─────────────────────────────────────┐
                    │  Johnshall forever (GitHub raw)     │
                    └─────────────────┬───────────────────┘
                                      │ curl
                                      ▼
┌──────────────┐   merge    ┌──────────────────┐   PATCH   ┌─────────────┐
│ apple/ai/    │ ─────────► │ sync.sh          │ ───────► │ secret Gist │
│ host override│            │ → out/flyint.*   │          │ .conf+.yaml │
└──────────────┘            └──────────────────┘          └──────┬──────┘
                                                                 │
                    手机 Shadowrocket / Clash Verge 订阅 raw URL ◄─┘
```

1. **Mac**：定时或手动跑 `sync.sh` → 更新 Gist  
2. **手机 / Clash**：订阅 Gist raw 地址，客户端「自动更新」（建议 24h）  
3. 改分流：只改 `*.override.conf`，再跑 `sync.sh`（不要手改 `out/` 或 Gist 网页）

---

## 目录说明

```text
shadowrocket-sync/
├── sync.sh                 # 主流程：拉上游 → 合并 → 写 out → 推 Gist
├── publish.sh              # 仅把已有 out/ 推到 Gist（不重新拉上游）
├── setup-gist.sh           # 首次：创建 secret Gist 并写 config.env
├── install-launchd.sh      # 安装 macOS 每日 09:10 任务
├── apple.override.conf     # App Store / Apple 直连（可提交）
├── ai.override.conf        # AI 网站分流（可提交）
├── host.override.conf.example
├── config.env.example
├── subscription.url.example
├── launchd/
│   └── com.longyun.shadowrocket-sync.plist.template
├── out/                    # 生成物（gitignore）
├── CHANGELOG.md
└── README.md
```

本机首次需要自行准备（不提交）：

```bash
cp host.override.conf.example host.override.conf
cp subscription.url.example subscription.url   # 可选
# config.env 由 ./setup-gist.sh 生成，或从 example 复制后填写
```

---

## 依赖

| 工具 | 用途 |
|------|------|
| `zsh` + `python3` | 跑 `sync.sh` |
| `curl` | 拉上游 |
| [`gh`](https://cli.github.com/) | 登录 GitHub，读写 Gist（需 `gist` scope） |
| `jq` | 组装 Gist API body |

```bash
gh auth login -h github.com -p https -w -s gist
# macOS 若缺 jq：brew install jq
```

---

## 快速开始

```bash
git clone https://github.com/longyunBegin/shadowrocket-sync.git
cd shadowrocket-sync

cp host.override.conf.example host.override.conf
# 按需编辑 apple.override.conf / ai.override.conf / host.override.conf

gh auth login -h github.com -p https -w -s gist
./setup-gist.sh          # 创建 Gist + config.env，并跑一遍 sync
./install-launchd.sh     # 可选：每天 09:10 自动更新
```

### 客户端怎么填

**Shadowrocket**

1. 配置 → 右上角 `+` → 类型选 **远程文件**  
2. URL 填 `setup-gist.sh` / `sync.sh` 打印的 `.../raw/flyint.conf`  
3. 打开自动更新（建议 24 小时）→ 立即更新一次  

**Clash Verge / Mihomo**

1. 订阅 / 配置 URL 填 `.../raw/flyint.yaml`  
2. 若未配置 `subscription.url`：YAML 里只有规则，需在客户端另加节点订阅，策略组名保持 `PROXY`  
3. 若已在 `subscription.url` 写了节点链接：sync 后的 YAML 会带 `proxy-providers`

> 公开 README **不写死**你的 Gist 地址。secret Gist 的 raw URL 相当于密钥，勿发到 Issue / 截图。

---

## 日常使用

### 改规则后发布

```bash
# 例如：给某个站强制代理
# 编辑 ai.override.conf 增加一行 DOMAIN-SUFFIX,example.com,Proxy

./sync.sh
```

成功时日志大致为：`ok conf` → `ok yaml` → `published OK`。

### 只重新推送、不拉上游

```bash
./publish.sh
```

### 查看定时任务

```bash
launchctl list | grep shadowrocket
tail -f sync.log
```

### 推荐改哪些文件

| 需求 | 改哪里 |
|------|--------|
| App Store 仍走代理 / 要放宽直连 | `apple.override.conf` |
| ChatGPT / Claude / Gemini 等 | `ai.override.conf` |
| 自定义 DNS / Host | `host.override.conf` |
| Clash 节点订阅 | `subscription.url` |
| 换 Gist | `config.env` 或重跑 `setup-gist.sh`（会新建 Gist） |

---

## 规则优先级说明（确定性）

对 Shadowrocket `flyint.conf`：

1. `apple.override.conf` 全部规则（多为 `direct`）  
2. `ai.override.conf`（`Proxy` / `direct`）  
3. 上游 Johnshall 全文（含广告 `Reject`、GFW `Proxy`）  
4. 未命中规则时按上游黑名单哲学：不在列表则直连  

对 Clash `flyint.yaml`：

1. 同样的 Apple / AI DOMAIN 规则置顶  
2. 再接 Loyalsoldier 的 `lancidr` / `reject` / `gfw` / `proxy` / `direct` / `cncidr`  
3. `GEOIP,CN,DIRECT` → `MATCH,DIRECT`  

因此：**AI 域名不会被「国内直连」误伤**；**Apple 更新不会被上游「苹果 CDN → Proxy」拖进节点**。

---

## 安全与隐私

- 仓库是 **public**：不要提交真实订阅链接、`config.env`、内网 Host。  
- 发布面建议用 **secret Gist**（知道 URL 即可读；不是企业级私密）。  
- `gh` token 只留在本机 keychain；CI 若要用，单独建只含 `gist` 权限的 token。

---

## 故障排查

| 现象 | 处理 |
|------|------|
| `WARN: cannot publish` / gh 未登录 | `gh auth login -h github.com -p https -w -s gist` |
| LaunchAgent 失败、`can't open input file` | 不要把仓库放在 `~/Downloads`；用 `./install-launchd.sh` 重装 |
| 手机规则很旧 | Mac 上看 `sync.log` 是否 `published OK`；手机点「立即更新」 |
| App Store 仍走代理 | 确认订阅已更新到含 `local Apple/App Store DIRECT` 的版本；看客户端连接列表策略是否为 DIRECT |
| Clash 没有节点 | 填写 `subscription.url` 后重新 `./sync.sh`，或在客户端单独加订阅 |

---

## 版本与更新日志

功能变更、行为变化记在 **[CHANGELOG.md](./CHANGELOG.md)**。

约定：

- 用户可见能力变化 → 必写 CHANGELOG  
- 仅文档/注释 → 可只改 README  
- 版本号采用 `MAJOR.MINOR.PATCH`（见 CHANGELOG 顶部）

---

## License / 致谢

- 上游规则：[Johnshall/Shadowrocket-ADBlock-Rules-Forever](https://github.com/Johnshall/Shadowrocket-ADBlock-Rules-Forever)  
- Clash rule-providers：[Loyalsoldier/clash-rules](https://github.com/Loyalsoldier/clash-rules)  

本仓库脚本与 override 以仓库内声明为准；使用上游内容请遵守其许可。
