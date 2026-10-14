# Changelog

本文件记录 **shadowrocket-sync** 的用户可见变更（功能、行为、兼容性）。  
格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，版本号遵循 [SemVer](https://semver.org/lang/zh-CN/)。

如何维护：

- 每次发版在本节上方新增 `## [x.y.z] - YYYY-MM-DD`
- 分类使用：`Added` / `Changed` / `Fixed` / `Removed` / `Security`
- 写「提供了什么能力 / 修了什么问题」，避免只列文件名

---

## [Unreleased]

<!-- 下一版开发中的条目先写在这里，发版时挪到带版本号的小节 -->

### Added

### Changed

### Fixed

---

## [1.0.0] - 2026-10-14

首个公开版本：本机同步脚本 + 永久 override + Gist 双格式发布。

### Added

- **上游自动合并**：从 Johnshall forever 拉取 `sr_top500_banlist_ad.conf`，与本地 override 合成完整 Shadowrocket 配置。
- **App Store / Apple 强制直连**（`apple.override.conf`）  
  - 置顶 `USER-AGENT` / `DOMAIN-SUFFIX` / `DOMAIN-KEYWORD` 直连规则  
  - 扩展 `skip-proxy`（apple / icloud / mzstatic / aaplimg / cdn-apple 等）  
  - 将上游「苹果 CDN → Proxy」段改写为 `direct`  
  - 目标：开着 VPN 时 App Store 更新尽量不走节点流量
- **AI 分流永久规则**（`ai.override.conf`）  
  - Google Gemini / AI Studio、OpenAI、Claude、Cursor 等 → `Proxy`  
  - DeepSeek、火山、月之暗面、智谱、硅基流动、通义等 → `direct`
- **自定义 Host**（`host.override.conf`，本机文件）：合并进生成配置的 `[Host]`。
- **双格式产物**  
  - `out/flyint.conf`：Shadowrocket  
  - `out/flyint.yaml`：Clash / Mihomo（Loyalsoldier rule-providers + 置顶 Apple/AI 规则）
- **可选 Clash 节点订阅**：`subscription.url` → YAML `proxy-providers`。
- **Gist 发布**  
  - `setup-gist.sh`：创建 secret Gist 并写入 `config.env`  
  - `sync.sh` / `publish.sh`：用 `gh api` 更新 `flyint.conf` + `flyint.yaml`
- **macOS 定时任务**：`install-launchd.sh` + LaunchAgent 模板，默认每天 09:10 执行 sync（目录勿放在 `Downloads`，避免 TCC 导致任务失败）。
- **公开仓库安全默认**：`.gitignore` 排除 `config.env`、真实 Host、订阅 URL、`out/`、日志；提供 `*.example` 模板。

### Notes

- 客户端订阅地址为 Gist raw URL，由本机 `config.env` 保存，不写入公开 README。
- DNS 在合成配置中固定为 `8.8.8.8, 1.1.1.1, 223.5.5.5`（覆盖上游 DoH 行，便于兼容）。
