# 每日采集源清单

> 采集任务按本清单巡检。优先级固定：`00-rl` > `01-dl` > `02-agent` > `03-mcp` > `04-benchmarks` > `05-code-oss` > `06-news`。搜索时在关键词后加时间限定；已登记进 [update-log.md](update-log.md) 的内容跳过。
>
> 采集通道只用 `bash` + `curl`。可达性以服务器出口为准，换机器或某域长期采不到时先跑 `automation/check-egress.sh` 复测并回写技能的可达性表。

## 00-rl（强化学习，最高优先级）

结构化接口（首选，可按日期排序、可判重）：

- arXiv API：`http://export.arxiv.org/api/query?search_query=<查询>&sortBy=submittedDate&sortOrder=descending&max_results=20`
  - 查询示例：`cat:cs.LG+AND+abs:"reinforcement learning"`、`cat:cs.AI+AND+abs:"RLHF"`、`abs:"policy optimization"+AND+cat:cs.LG`
- arXiv 列表页兜底：`https://arxiv.org/list/cs.LG/recent`、`https://arxiv.org/list/cs.AI/recent`
- 原件下载：`https://arxiv.org/pdf/<id>`

站点与关键词：

- OpenReview（NeurIPS/ICML/ICLR 讨论与 camera-ready）：`https://api2.openreview.net/notes?...`，可达性待服务器复测，403 挑战页出现即跳过不重试。
- 关键词：`RLHF` / `GRPO` / `reward model` / `policy optimization` / `exploration sparse reward` / `world model RL` / `agentic RL` / `scalable oversight`
- 相关机构博客：`https://www.anthropic.com/research`、`https://openai.com/index/`（403 时只登记索引页标题）

## 01-dl（深度学习与模型架构）

结构化接口：

- arXiv API：`cat:cs.LG` / `cat:cs.CL` / `cat:cs.CV`，按 `submittedDate` 倒序，配合 `abs:"mixture of experts"`、`abs:"state space model"`、`abs:"diffusion"` 等
- Crossref（定位已知文献，不用于计数）：`https://api.crossref.org/works?query.bibliographic=<词>&rows=5`

站点与关键词：

- Hugging Face Daily Papers：`https://huggingface.co/papers`（本机不可达；服务器可达性以 check-egress 为准）
- Papers with Code / 社区榜单：只登记标题与链接，C 级。
- 关键词：`transformer long context` / `mixture of experts routing` / `diffusion transformer` / `quantization LLM` / `LoRA fine-tuning` / `knowledge distillation`
- 官方博客：`https://www.anthropic.com/news`、`https://openai.com/news/`、`https://deepmind.google/discover/blog/`

## 02-agent（LLM Agent）

结构化接口：

- arXiv API：`cat:cs.AI+AND+abs:"LLM agent"`、`abs:"tool use"+AND+cat:cs.CL`、`cat:cs.MA+AND+abs:"multi-agent"`
- GitHub API：`https://api.github.com/repos/<org>/<repo>/releases?per_page=5`、`commits?per_page=5`

站点与关键词：

- `https://blog.langchain.dev/rss/`（RSS 可直取）
- `https://www.interconnects.ai/feed`（substack 自定义域，可直取）
- `https://www.anthropic.com/engineering`、`https://openai.github.io/openai-agents-python/`
- 关键词：`LLM agent planning` / `function calling evaluation` / `multi-agent orchestration` / `agent memory` / `agentic benchmark`

## 03-mcp（MCP 与协议生态）

结构化接口（首选）：

- GitHub API（服务器上 `raw.githubusercontent.com` 不通，取文件内容一律走 `api.github.com` + `Accept: application/vnd.github.raw`）：
  - `https://api.github.com/repos/modelcontextprotocol/specification/releases`
  - `https://api.github.com/orgs/modelcontextprotocol/repos?sort=pushed&per_page=20`
  - `https://api.github.com/repos/modelcontextprotocol/servers/commits?per_page=5`
  - `https://api.github.com/repos/a2aproject/A2A/releases`
- npm/pypi 发布节奏：`https://registry.npmjs.org/@modelcontextprotocol/sdk`、`https://pypi.org/pypi/mcp/json`

站点与关键词：

- 规范文档站：`https://modelcontextprotocol.io/`（版本页与 changelog）
- 关键词：`MCP specification version` / `MCP registry` / `MCP OAuth resource server` / `streamable HTTP transport` / `MCP tools discovery` / `A2A protocol`

## 04-benchmarks（评测基准）

- arXiv API：`abs:"benchmark"+AND+abs:"agent"`、`abs:"SWE-bench"`、`abs:"tool use benchmark"`
- 站点：`https://www.swebench.com/`、`https://www.gaia-benchmark.com/`、`https://tau-bench.com/`
- GitHub API：基准仓库的 releases 与 leaderboard 更新
- 关键词：`agent benchmark contamination` / `reasoning benchmark` / `long context evaluation`

## 05-code-oss（开源实现动态）

- GitHub API releases/commits（每域主用路径）：
  - `vllm-project/vllm`、`huggingface/transformers`、`pytorch/pytorch`
  - `langchain-ai/langchain`、`run-llama/llama_index`、`openai/openai-agents-python`
  - `ollama/ollama`、`modelcontextprotocol/python-sdk`、`modelcontextprotocol/typescript-sdk`
- `https://registry.npmjs.org/<pkg>`、`https://pypi.org/pypi/<pkg>/json`：发布节奏
- 关键词：`release`、`breaking change`、`new API`

## 06-news（行业资讯）

- `https://www.anthropic.com/news` ｜ `https://openai.com/news/` ｜ `https://deepmind.google/discover/blog/`
- `https://newsletter.semianalysis.com/`（substack 自定义域，可直取）
- 中文：`https://www.jiqizhixin.com`（机器之心）｜ `https://www.qbitai.com`（量子位）｜ 知乎话题（登录墙，仅登记标题与链接）
- 关键词：`开源模型发布` / `融资 收购 AI` / `Agent 产品发布` / `MCP 生态`
- 资讯类按月成箱：`06-news/news-YYYY-MM.md`

## 通用口径

- 关键词检索只用 `curl` 抓 Bing（带 `-L`）；`websearch`/`webfetch` 走模型供应商通道，不经过服务器出口，不作为采集依据。
- 每域每轮至多 6 个来源，全轮至多 12 个投递文件、25 个证据块、5 份原件（配额见采集技能）。
- 单次采集总时长控制在 15 分钟内；单个来源失败一次即跳过，不重试整轮。
