# mcp-server-ecosystem · MCP SDK 与服务端生态

> 归属域：`Sources/03-mcp`。提炼去向：未提炼（候选：`knowledge-base/references/开源框架版本参考`）。
> 本箱登记官方 SDK 发布、registry 与工作组仓库动态；spec 本体变更见 [mcp-spec-evolution-source.md](../mcp-spec-evolution/mcp-spec-evolution-source.md)。

## 证据索引

| 编号 | 主题 | 等级 | 获取日期 | 原件 | 状态 |
|---|---|---|---|---|---|
| E1 | Python SDK v2.3.0（2026-10-02） | A | 2026-10-09 | — | 未提炼 |
| E2 | TypeScript SDK 1.32.1（2026-10-05）与 1.3x 发布线 | A | 2026-10-09 | — | 未提炼 |
| E3 | Registry 仓库活跃与 Triggers & Events 工作组孵化 | A | 2026-10-09 | — | 未提炼 |

## E1 · Python SDK v2.3.0：依赖下限上调与事件体积限制

- 获取日期：2026-10-09
- 来源 URL：https://github.com/modelcontextprotocol/python-sdk/releases/tag/v2.3.0
- 本地原件：—
- 适用范围：一手来源（官方 release，2026-10-02）；包名 `mcp`，文档在 py.sdk.modelcontextprotocol.io；覆盖发布说明所列行为变化。
- 证据等级：A
- 可提炼要点：
  1. 行为变化：`httpx2>=2.10.0` 成为硬性下限（原 `>=2.5.0`），原因是新增的 `max_sse_event_size` 选项需要它——**升级即可能连带依赖下限变化**，部署锁定版本时要留意。
  2. 发布节奏：v2.2.0（2026-09-07）→ v2.3.0（2026-10-02），约四周一版；v2.2.0 起 HTTP 客户端只在端点 origin 内跟随重定向。
- 关闭条件：v2.3.0 完整变更条目（三项新选项的具体名称与默认值）未逐条摘录；读 release 正文补齐后可关。

## E2 · TypeScript SDK 1.32.x：与 spec 稳定版同步的小步发布线

- 获取日期：2026-10-09
- 来源 URL：https://registry.npmjs.org/@modelcontextprotocol/sdk
- 本地原件：—
- 适用范围：一手来源（npm registry 元数据）；覆盖发布时间线；不覆盖具体变更内容（见 GitHub releases）。
- 证据等级：A
- 可提炼要点：
  1. 时间线：1.30.0（2026-07-27，恰在 spec 2026-07-28 stable 前一天）→ 1.30.1（09-23）→ 1.31.0（09-28）→ 1.32.0（10-02）→ 1.32.1（10-05）。
  2. 节奏口径：SDK 在 spec 稳定版前后有对齐动作，之后进入约一周一版的小步发布；判断 SDK 健康度用 npm `time` 字段即可复现。
- 关闭条件：1.31/1.32 的功能增量未登记；下次采集补 GitHub releases 条目后可关。

## E3 · Registry 仓库与 Triggers & Events 工作组孵化

- 获取日期：2026-10-09
- 来源 URL：https://api.github.com/orgs/modelcontextprotocol/repos?sort=pushed
- 本地原件：—
- 适用范围：一手来源（GitHub org API，2026-10-09 拉取）；反映仓库活跃度与新工作组，不等于规范条款已进 spec。
- 证据等级：A
- 可提炼要点：
  1. 活跃度排序（pushed_at，2026-10-08~09）：kotlin-sdk、go-sdk、java-sdk、typescript-sdk（13.5k stars）、ruby-sdk 均在 48 小时内有推送，官方 SDK 覆盖六种语言。
  2. `modelcontextprotocol/registry`（7.3k stars，2026-10-08 推送）：社区驱动的 MCP server 注册服务，是「server 发现」路线的落地载体。
  3. `experimental-ext-triggers-events`（2026-10-08，33 stars）：Triggers & Events 工作组的孵化空间——**扩展类议题先进 experimental 仓库再进 spec** 是当前的演化路径信号。
- 关闭条件：registry 服务的正式化状态（是否进 spec/IA）未确认；跟踪 registry 仓库与 spec releases 交叉验证后可关。
