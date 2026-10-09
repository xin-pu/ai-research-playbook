# inference-stack-releases · 推理与基础栈发布动态

> 归属域：`Sources/05-code-oss`。提炼去向：未提炼（候选：`knowledge-base/references/开源框架版本参考`）。
> 本箱登记推理引擎与基础库的版本发布与破坏性变更；Agent 框架发布见 [agent-framework-releases-source.md](../agent-framework-releases/agent-framework-releases-source.md)。

## 证据索引

| 编号 | 主题 | 等级 | 获取日期 | 原件 | 状态 |
|---|---|---|---|---|---|
| E1 | vLLM v0.31.0（2026-10-05） | A | 2026-10-09 | — | 未提炼 |
| E2 | Transformers v5.19.0（2026-10-06） | A | 2026-10-09 | — | 未提炼 |
| E3 | Ollama v0.40.2（2026-10-08） | A | 2026-10-09 | — | 未提炼 |

## E1 · vLLM v0.31.0：FlashMLA mega attention 成为 SM100 默认

- 获取日期：2026-10-09
- 来源 URL：https://github.com/vllm-project/vllm/releases/tag/v0.31.0
- 本地原件：—
- 适用范围：一手来源（官方 release，2026-10-05）；717 commits / 307 贡献者（96 位新参与）；变更点以 release 正文为准。
- 证据等级：A
- 可提炼要点：
  1. DeepSeek-V4.1-Flash 性能路径：FlashMLA mega attention 配 V4.1 NVFP4 压缩 KV cache 在 SM100 上成为默认（#56935），DeepGEMM 稀疏 MQA logits 用于 indexer（#56254）。
  2. 发布节奏参照：v0.30.0（2026-09-22）→ v0.31.0（2026-10-05），两周一版；v0.30.0 引入 DeepSeek-V4.1-Flash 全 KV MXFP8 存储与异步 Engram 预取。
- 关闭条件：默认值变更对既有部署的迁移影响（是否需要改启动参数）未摘录；读 release 正文的 breaking 段落后可关。

## E2 · Transformers v5.19.0：EmbeddingGemma2 多模态嵌入模型

- 获取日期：2026-10-09
- 来源 URL：https://github.com/huggingface/transformers/releases/tag/v5.19.0
- 本地原件：—
- 适用范围：一手来源（官方 release，2026-10-06）；5.x 版本线的新模型增量登记，不覆盖训练侧 API 变更细节。
- 证据等级：A
- 可提炼要点：
  1. 新增 EmbeddingGemma2：多模态嵌入模型（release 含架构图与用法）——嵌入/检索方向的模型接入是本版主要增量。
  2. 版本节奏参照：5.x 线保持约每周一版的小步节奏；判断「模型是否已被框架支持」以该仓库 releases 为一手判据。
- 关闭条件：v5 主线的破坏性 API 变更清单未登记；缺从 4.x 迁移的口径，需另采迁移文档。

## E3 · Ollama v0.40.2：模型后台升级机制

- 获取日期：2026-10-09
- 来源 URL：https://github.com/ollama/ollama/releases/tag/v0.40.2
- 本地原件：—
- 适用范围：一手来源（官方 release，2026-10-08）；本地推理运行时的模型格式行为；不覆盖服务端集群部署。
- 证据等级：A
- 可提炼要点：
  1. 模型升级机制：旧版本下载的模型会在首次运行时**后台升级**以适配新 llama.cpp 性能与兼容性；Ollama 保留旧文件以保证可回退。
  2. 运维口径：本地推理环境的「模型文件」不是静态资产——版本升级会隐式改写模型产物，复现实验时必须记录 Ollama 版本。
- 关闭条件：升级对输出一致性（bit-level 可复现性）的影响未给；需实测同 prompt 升级前后差异。
