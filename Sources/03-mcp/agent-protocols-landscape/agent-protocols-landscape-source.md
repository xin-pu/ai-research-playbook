# agent-protocols-landscape · Agent 协议横向对照（A2A 与 MCP 的分界）

> 归属域：`Sources/03-mcp`。提炼去向：未提炼（候选：`knowledge-base/maps/01-Agent工具链地图` 与 `solutions/04-MCP 与协议`）。
> 本箱登记与 MCP 处于不同层次的 Agent 间协议（A2A 等）的版本与边界事实；MCP 本体见 [mcp-spec-evolution-source.md](../mcp-spec-evolution/mcp-spec-evolution-source.md)。

## 证据索引

| 编号 | 主题 | 等级 | 获取日期 | 原件 | 状态 |
|---|---|---|---|---|---|
| E1 | A2A v1.0.0：breaking changes 清单与范围重构 | A | 2026-10-09 | `originals/github-a2a-release-v1.0.0.json` | 未提炼 |
| E2 | A2A v1.0.1：HTTP 绑定 MIME 类型修正 | A | 2026-10-09 | — | 未提炼 |

## E1 · A2A v1.0.0（2026-03-12）：应用协议与传输映射分离

- 获取日期：2026-10-09
- 来源 URL：https://github.com/a2aproject/A2A/releases/tag/v1.0.0
- 本地原件：`originals/github-a2a-release-v1.0.0.json`（14,915 B，GitHub API 原始载荷）
- 适用范围：一手来源（官方 release）；A2A 协议 1.0 语义；与 MCP 的对照只做层次定位，不做兼容性断言。
- 证据等级：A
- 可提炼要点：
  1. 1.0.0 是从 v0.3.0 起的破坏性收敛：合并 `TaskPushNotificationConfig` 与 `PushNotificationConfig`、请求中删除重复 ID、枚举格式按 ADR-001 ProtoJSON 对齐、统一美式 `canceled` 拼写、`extendedAgentCard` 移入 `AgentCapabilities`。
  2. 范围重构的定位声明：**把应用协议定义与到传输的映射分离**（large refactor of specification to separate application protocol definition from mapping to transports），并移除 a2a URL HTTP 绑定里的 `v1s`。
  3. 授权与发现的现代化：OAuth 去掉 implicit/password、加入 device code 与 PKCE；新增 `tasks/list` 带过滤与分页；gRPC 通过 scope 字段原生支持多租户。
- 关闭条件：A2A 与 MCP 的互操作/分层关系尚无同源材料支撑（缺对照论文或联合文档）；本块只登记 A2A 自身事实。

## E2 · A2A v1.0.1（2026-05-28）：HTTP 绑定 MIME 类型偏好

- 获取日期：2026-10-09
- 来源 URL：https://github.com/a2aproject/A2A/releases/tag/v1.0.1
- 本地原件：—
- 适用范围：一手来源（官方 release，补丁版）；仅 HTTP 绑定的媒体类型与缺陷修复。
- 证据等级：A
- 可提炼要点：
  1. v1.0.1 主要修复：HTTP 绑定优先使用 `application/a2a+json`（#1753）——1.0.x 线是**在不破坏协议语义的前提下修绑定细节**的节奏。
  2. 版本节奏参照：v1.0.0（2026-03-12）→ v1.0.1（2026-05-28），补丁间隔约 2.5 个月；上一主线版本为 v0.3.0（2025-07-30）。
- 关闭条件：v1.0.1 之后的新提交（1.1 草案）未查；下次采集复查 releases 列表。
