# agent-framework-releases · Agent 框架发布动态

> 归属域：`Sources/05-code-oss`。提炼去向：未提炼（候选：`knowledge-base/references/开源框架版本参考`）。
> 本箱登记 Agent 框架与其模型伙伴包的版本发布；推理栈见 [inference-stack-releases-source.md](../inference-stack-releases/inference-stack-releases-source.md)，MCP SDK 见 [../03-mcp/mcp-server-ecosystem/mcp-server-ecosystem-source.md](../../03-mcp/mcp-server-ecosystem/mcp-server-ecosystem-source.md)。

## 证据索引

| 编号 | 主题 | 等级 | 获取日期 | 原件 | 状态 |
|---|---|---|---|---|---|
| E1 | langchain 1.4.4（2026-10-08） | A | 2026-10-09 | — | 未提炼 |
| E2 | langchain-openai 1.7.0：支持 decisions API | A | 2026-10-09 | — | 未提炼 |
| E3 | openai-agents-python v0.23.1（2026-10-02） | A | 2026-10-09 | — | 未提炼 |

## E1 · langchain 1.4.4：摘要中间件的上下文溢出重试

- 获取日期：2026-10-09
- 来源 URL：https://github.com/langchain-ai/langchain/releases/tag/langchain%3D%3D1.4.4
- 本地原件：—
- 适用范围：一手来源（官方 release，2026-10-08）；Python 包 `langchain` 1.4.x 线；同日另有 langchain-openai 1.7.0（见 E2）。
- 证据等级：A
- 可提炼要点：
  1. 主要变更：`SummarizationMiddleware` 在摘要步骤遇到上下文溢出时重试（#41159）——中间件链在长上下文下的失败恢复是当前修复重点。
  2. 发布节奏：1.4.3 → 1.4.4 为补丁级日更节奏，其余多为依赖抬升；判断框架能力变化要看 feat 提交而非补丁号。
- 关闭条件：1.4.x 线的 feat 增量未汇总；下次采集按 `feat:` 前缀筛 releases 补齐。

## E2 · langchain-openai 1.7.0：接入 decisions API

- 获取日期：2026-10-09
- 来源 URL：https://github.com/langchain-ai/langchain/releases/tag/langchain-openai%3D%3D1.7.0
- 本地原件：—
- 适用范围：一手来源（官方 release，2026-10-08）；OpenAI 伙伴包对新模型接口的适配。
- 证据等级：A
- 可提炼要点：
  1. 新增：支持 decisions API（#41154）——模型侧新接口在伙伴包先行落地，主框架随后跟进，这是「上游 API → 伙伴包 → 主框架」的传播顺序样本。
  2. 同步抬升 langgraph-sdk 至 0.4.6，说明伙伴包发布同时牵动编排层依赖。
- 关闭条件：decisions API 本身的用途与语义未登记（缺上游文档原件）；抓取 OpenAI 官方文档对应页后可关。

## E3 · openai-agents-python v0.23.1：发布测试恢复

- 获取日期：2026-10-09
- 来源 URL：https://github.com/openai/openai-agents-python/releases/tag/v0.23.1
- 本地原件：—
- 适用范围：一手来源（官方 release，2026-10-02）；0.23.x 线补丁版。
- 证据等级：A
- 可提炼要点：
  1. 修复：恢复 release tests 并刷新必需的 readiness 检查（#5278）——上游曾出现发布门禁缺失的窗口，引用该版本区间需注意测试覆盖状态。
  2. 版本节奏：0.23.0 → 0.23.1 补丁间隔短，框架仍处快速迭代期，锁定版本升级应读 release notes 而非只看 minor 号。
- 关闭条件：0.23.x 的功能增量与 readiness 检查内容未摘录；读 release 正文后可关。
