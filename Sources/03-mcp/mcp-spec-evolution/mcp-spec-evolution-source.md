# mcp-spec-evolution · MCP 规范版本演进

> 归属域：`Sources/03-mcp`。提炼去向：未提炼（候选：`knowledge-base/solutions/04-MCP 与协议` 与 `references/MCP版本演进参考`）。
> 本箱只登记 spec 的稳定版/RC 发布与变更线索；SDK 与生态活动见 [mcp-server-ecosystem-source.md](../mcp-server-ecosystem/mcp-server-ecosystem-source.md)，A2A 等横向协议见 [agent-protocols-landscape-source.md](../agent-protocols-landscape/agent-protocols-landscape-source.md)。

## 证据索引

| 编号 | 主题 | 等级 | 获取日期 | 原件 | 状态 |
|---|---|---|---|---|---|
| E1 | 2026-07-28 修订版成为 stable | A | 2026-10-09 | `originals/github-mcp-spec-release-2026-07-28.json` | 未提炼 |
| E2 | 2026-07-28 RC（2026-05-29 发布）与版本节奏 | A | 2026-10-09 | — | 未提炼 |

## E1 · MCP 2026-07-28 修订版发布为 stable

- 获取日期：2026-10-09
- 来源 URL：https://github.com/modelcontextprotocol/modelcontextprotocol/releases/tag/2026-07-28
- 本地原件：`originals/github-mcp-spec-release-2026-07-28.json`（2,527 B，GitHub API 原始载荷）
- 适用范围：一手来源（官方 release）；覆盖 spec 发布状态本身；具体条款变更见官方 changelog 页面，本块未逐条摘录。
- 证据等级：A
- 可提炼要点：
  1. 时间线：`2026-07-28` 修订于 2026-07-28 16:47 UTC 发布为 **stable**，规范正文在 modelcontextprotocol.io/specification/2026-07-28，变更明细在其 `/changelog`。
  2. 版本节奏参照：上一个稳定版为 `2025-11-25`，即两个稳定版间隔约 8 个月；RC（2026-05-29）到 stable（2026-07-28）约 2 个月。
- 关闭条件：changelog 条款级差异尚未摘录（缺原件）；抓取 `modelcontextprotocol.io/specification/2026-07-28/changelog` 与 2025-11-25 对照后可关。

## E2 · 2026-07-28 RC 发布（2026-05-29）与稳定版序列

- 获取日期：2026-10-09
- 来源 URL：https://github.com/modelcontextprotocol/specification/releases
- 本地原件：—
- 适用范围：一手来源（官方 release 列表，经 api.github.com 获取）；覆盖已知稳定版与 RC 序列；不覆盖 draft 分支的日常提交。
- 证据等级：A
- 可提炼要点：
  1. 已登记序列：`2026-07-28`（stable，2026-07-28）、`2026-07-28-RC`（RC，2026-05-29，指向 draft 形式）、`2025-11-25`（stable，2025-11-25）。
  2. RC → stable 的既有模式：先发带 `-RC` 后缀的候选版并在官网以 draft 形式公布，约两个月后转正；判断「新版本出现」应盯 releases 列表而非每日 diff。
- 关闭条件：更早版本（2025-03-26 等）未列入，需翻完整 releases 列表补齐版本序列后可关。
