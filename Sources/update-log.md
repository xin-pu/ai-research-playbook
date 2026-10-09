# 采集台账

> 最新条目在最上方。采集任务每天 09:00 运行（云服务器 cron），每周日 00:30 追加周度分析；本文件同时作为去重依据，采集前先查最近条目。
>
> 台账只记流水：哪天动了哪个箱、加了几块、亮点与失败；不复制箱内容。落盘规则见 [归箱规则.md](归箱规则.md)。

## 2026-10-09（首轮采集 · 本机人工主流程）

- **建库**：七个编号域骨架、治理规则（AGENTS / 归箱规则 / web-sources）、`automation/` 定时脚本与采集技能就位。
- **首轮真实采集**（通道 `bash` + `curl`，本机出口）：12 箱、30 证据块、10 资讯条目、6 份原件（4 × arXiv PDF + 2 × GitHub release JSON）。
- **各域增量**：00-rl +2 箱 6 块（policy-optimization、rlhf-preference-optimization）｜01-dl +1 箱 3 块（moe-routing）｜02-agent +2 箱 5 块（agent-safety-monitoring、agent-memory-state）｜03-mcp +3 箱 7 块（mcp-spec-evolution、mcp-server-ecosystem、agent-protocols-landscape）｜04-benchmarks +1 箱 3 块（agent-benchmarks）｜05-code-oss +2 箱 6 块（inference-stack-releases、agent-framework-releases）｜06-news +1 箱 10 条（news-2026-10）。
- **亮点**：MCP spec `2026-07-28` stable 的版本节奏与 RC→stable 模式；GRPO 系熵坍缩与 rollout 选择的可操作结论；工具层固定（MCP server）作为评测控制变量的范式。
- **失败与缺口**：`openai.com/news` 403、机器之心 JS 渲染未取到条目（已登记进 06-news 失效与缺口）；arXiv API 在并发查询时超时，改为顺序 + `id_list` 批量后稳定；MCP changelog 条款级差异缺原件（mcp-spec-evolution#E1 关闭条件）。
- 分析产出：`outputs/weekly/2026-10-09-采集分析.md`。
