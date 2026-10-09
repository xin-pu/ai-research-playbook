---
name: AI 研究知识库采集
description: 巡检 ai-research-playbook 采集源清单、按归箱规则把新增公开资料投递到各域 .inbox、按周生成采集分析文档并发送汇报邮件。当用户要求 AI 研究知识库采集、论文巡检、MCP/Agent 资料收集、周度分析时使用。
---

# AI 研究知识库采集（ai-research-collect）

在云服务器上无人值守跑完一条链：**采集 → 投递 → 提交推送 →（每周）分析 → 邮件汇报**。采集只写投递口与 `outputs/weekly/`，合箱、导航页、`update-log.md` 由人工主流程维护。

## 配置

- 配置文件：`automation/config.json`
  - `repoDir`：仓库工作副本（服务器为 `$HOME/ai-research-playbook`）
  - `reportTo`：汇报与告警收件人
- cron 入口：`automation/ai-playbook-daily.sh daily|weekly|dry`
- 部署手册：`automation/00-定时采集部署.md`

## 硬性边界

| 允许 | 禁止 |
| --- | --- |
| 写 `Sources/<域>/.inbox/*.md` 与 `.inbox/originals/*` | 改 `knowledge-base/`、`AGENTS.md`、`Sources/归箱规则.md`、`Sources/web-sources.md` |
| 写并新增 `outputs/weekly/YYYY-MM-DD-采集分析.md` | 改各域导航页、`Sources/update-log.md`（合箱是主流程的事） |
| 改域内 `.inbox` 投递文件 | 改 `automation/` 脚本与本技能 |
| `git push`（快进） | `--force`、rebase 冲突时强行覆盖、删除他人文件 |

理由：本仓库同时被本机 Obsidian 会话编辑，采集代理按 `Sources/归箱规则.md` 第 9 节只投 `.inbox`，正式正文与导航由人工合箱。

## 工作流程

### 1. 刷新仓库

```bash
cd "$REPO"                       # config.repoDir
git fetch origin --prune
git pull --rebase origin master 2>/dev/null || git pull --rebase
git status --porcelain           # 非空说明有他方未提交改动，记录到报告，不要清理
```

任何一步失败：跳过提交步骤（第 4 步），只做采集与分析，并在汇报「失败与风险」里写清原因。

### 2. 读规范（每次都要读，不要凭记忆）

- `Sources/归箱规则.md`：三层模型、第 5 节开箱门槛与分裂阈值、第 6 节证据块模板（七字段逐字）、第 8 节禁止项、第 9 节投递口协议、第 11 节落盘后自检
- `Sources/web-sources.md`：域清单与优先级（`00-rl` 最高）、接口端点、关键词
- `AGENTS.md`：语言与风格、目录权威关系、证据分级（A/B/C 与 preprint 口径）

### 3. 巡检采集

时间窗：**daily 档最近 24 小时，weekly 档最近 7 天**。域优先级 `00` → `06`，配额上限：**每域至多 6 个来源、全轮至多 12 个投递文件、25 个证据块、5 份原件**。

#### 3.0 采集通道：只用 `bash` + `curl`

| 通道 | 实测结论 |
| --- | --- |
| `websearch` 工具 | 走模型供应商的检索后端，与服务器出口无关 → **禁用**，检索一律 curl 打 Bing（带 `-L`） |
| `webfetch` 工具 | 走供应商代理，对多个站点 403 且链接会过期 → **不用于采集**；curl 拿回的二进制需要读文本时交给 `pdftotext`/`grep` |
| `bash` + `curl` | 唯一可靠通道；可达性按 3.0.1 判断 |

`opencode run` 在**任意一次工具调用报错**时都会以退出码 1 收尾（哪怕整轮已完成），所以采到 403/超时属于预期，不要因为退出码非零就重跑整轮或中止后续步骤。

#### 3.0.1 服务器出口可达性

本表已在 **2026-10-09 由 `automation/check-egress.sh` 在服务器上实测回写**（同一台阿里云服务器，optical 工作流的继承结论同日复测仍成立）。遇到新的长期失败先跑该脚本再改本表。

**可用**（实测 HTTP 码与耗时）：

| 来源 | 实测 |
| --- | --- |
| `http://export.arxiv.org/api/query?...`（arXiv API，00/01/02/04 域首选） | 可达；注意并发查询会超时，**逐条顺序 + `id_list` 批量** |
| `https://arxiv.org/list/<cat>/recent`、`https://arxiv.org/pdf/<id>` | 200；PDF 约 30s（`-m 120`） |
| `https://api.github.com/...`（repos、orgs、releases、commits、contents + `Accept: application/vnd.github.raw`） | 03/05 域首选，约 1s |
| `https://registry.npmjs.org/<pkg>`、`https://pypi.org/pypi/<pkg>/json` | 05 域发布节奏 |
| `https://modelcontextprotocol.io/`、`https://www.swebench.com/` | 200 |
| `https://www.anthropic.com/news` | 200；列表页结构：`<li><a href="/news/<slug>"><time>…</time>…<span …__title…>标题</span>` |
| `https://blog.langchain.dev/rss/`、`https://www.interconnects.ai/feed`、`https://newsletter.semianalysis.com/` | RSS/自定义域 substack 可直取；`*.substack.com` 通配域仍不通 |
| `https://www.jiqizhixin.com/` | 200 但首页为 JS 渲染，未取到结构化条目，暂不作条目源 |
| `https://www.bing.com/search?q=<编码>` | 关键词检索唯一通道，必须带 `-L`；`after:` 日期限定基本失效，不能当判据 |
| `https://api.crossref.org/works?...` | 只用于定位已知文献，**不用于「本周新增」计数** |

**不可达，禁止浪费超时**（失败一次即跳过，不重试）：

| 来源 | 实测 |
| --- | --- |
| `https://api2.openreview.net/...` | 403 挑战页 |
| `https://api.semanticscholar.org/...` | 400/429（无 API key 不可用），不重试 |
| `https://huggingface.co/papers` | 连接超时（12s 无响应） |
| `https://openai.com/news/` | 403，跳过并登记 |
| `raw.githubusercontent.com`、`cdn.jsdelivr.net`、`google.com`、`lite/html.duckduckgo.com`、`web.archive.org`、`r.jina.ai` | 短超时确认仍全部不通 |
| `ieeexplore.ieee.org` | 无浏览器 UA 返回 418，带 UA 可通但不做条目源 |

抓取通则：`curl -sS -L -m 20 -A "$UA"`（UA 用常见 Chrome 串）；下原件时提高到 `-m 120`；单次采集总时长 ≤ 15 分钟，超时即跳过该条并记录。**不要因个别来源不可达而中止整轮。**

对每个域：

1. 抓来源页：优先结构化接口（arXiv API、GitHub API、npm/pypi），按 `web-sources.md` 的清单与关键词。
2. 判重：`grep -rInF "<候选 URL>" Sources/ | head`，另查 `update-log.md`；arXiv 用不带 vN 的 ID 查（`grep -rInF "2510.01234"`）。命中即已登记，跳过。
3. 判开箱门槛（归箱规则第 5 节）：≥1 份公开原件，或 ≥3 条相互独立来源，或层次与既有箱不同。三条都不满足 → 不建证据块，只在投递文件末尾的「台账登记」小节写标题与链接。
4. 下载公开原件到 `Sources/<域>/.inbox/originals/arxiv-<id>-<slug>.pdf`（仅公开直链；>50MB 只登记链接）。`file` 确认真 PDF，`pdftotext -l 15 <文件> -` 抽正文用于提炼。**不下载付费墙/登录墙内容。**
5. 每个主题写一个投递文件：`Sources/<域>/.inbox/collect-YYYYMMDD-<主题slug>.md`，首行为 `# 投递：<主题>`，其内是一个或多个完整证据块，严格用第 6 节模板：

```markdown
## E<n> · <一句话主题>

- 获取日期：YYYY-MM-DD
- 来源 URL：<https://arxiv.org/abs/2510.01234>
- 本地原件：`Sources/<域>/.inbox/originals/<文件>.pdf`（无原件写「—」）
- 适用范围：preprint，未经同行评议；<覆盖什么、不覆盖什么>
- 证据等级：A|B|C
- 可提炼要点：
  1. <可核对的事实>
  2. <可核对的事实>
- 关闭条件：<还缺什么才能关>
```

七个字段逐字用上述标签，缺信息写「公开资料未给」，不猜、不留空。C 级不得作为定量结论来源；arXiv 预印本按 A 级但「适用范围」必须以 `preprint` 开头；要点用自己的话概括，不整段复制原文。

6. 落盘后自检（归箱规则第 11 节）：七字段计数一致；投递文件只落在 `.inbox` 内；未改动导航页、`update-log.md`、`web-sources.md`。

### 4. 提交并推送

```bash
cd "$REPO"
git add -A Sources outputs/weekly
git -c core.quotepath=off status --porcelain=v1   # 只允许出现 Sources/**/.inbox/** 与 outputs/weekly/**
git commit -m "docs(sources): add YYYY-MM-DD collector inbox round" -m "N inbox files, M evidence blocks across domains ...; weekly analysis written to outputs/weekly."
git pull --rebase
git push
```

- 提交信息用英文 conventional commits；正文简述投递文件数、证据块数、覆盖域。
- 出现冲突：`git rebase --abort`，保留本地提交，汇报里写「推送未成功，需人工合箱」，**不要强推**。
- 推送成功记录 `git rev-parse --short HEAD`，写进汇报「运行记录」。
- **daily 档本轮无新增时不产生空提交**：没有投递文件就不提交，汇报写「本轮无新增」。

### 5. 写周度分析（仅 weekly 档）

新建 `outputs/weekly/YYYY-MM-DD-采集分析.md`（日期为运行日）：

```markdown
# YYYY-MM-DD 周度采集分析

> 本轮自动采集结果与知识库影响评估。证据层来源：`Sources/<域>/.inbox/collect-YYYYMMDD-*.md`。正式结论仍以 `knowledge-base/solutions` 为准，本文不改动任何正文。

## 1. 采集概况
## 2. 新增证据清单
## 3. 知识库影响评估
## 4. 建议增补内容
## 5. 不建议采纳项
## 6. 待人工决定
```

- 第 1 节：巡检来源数、投递文件与证据块数、等级分布、台账登记（含不可达站点与去重复查）、自检结果。
- 第 2 节：`编号 | 域/投递文件 | 主题 | 等级 | 来源 | 本地原件` 表格。
- 第 3 节：`文档/章节 | 是否受影响 | 建议动作 | 依据证据` 表格；章节状态见 `knowledge-base/solutions/00-正式正文导航.md`，正文未开启的章写「待开启（条件）」。
- 第 4 节：可直接粘贴的段落草稿，逐条标注等级与 URL；只有 A/B 级可进草稿。
- 第 5 节：C 级、单一来源、与既有口径冲突的项及原因。
- 第 6 节：开箱门槛未过、需人工合箱、需补采的清单。

### 6. 发送汇报邮件（仅 weekly 档）

1. 用 ms365 `send-mail`：收件人 `automation/config.json` 的 `reportTo`（为空则发给当前登录用户）。
2. 主题：`【AI研究知识库采集】YYYY-MM-DD（新增 N 证据块 · 投递 M 文件 · 等级 A x / B x / C x）`。
3. 正文为正式书面语 HTML：采集概况、新增证据清单（主题/来源/等级/落盘位置，≤10 行）、影响评估结论 2~5 行、需人工处理（合箱、缺原件、不可达源）、失败与风险、运行记录（commit 短哈希、分析文件路径）。无 emoji、无测试性标注。
4. **无人值守运行时直接发送，不等待确认**；采集或推送失败也必须发信，把失败写进「失败与风险」。
5. daily 档**不发邮件**（脚本只在产物健康检查不通过时告警）。

### 7. 巡检档（dry，仅 `ai-playbook-daily.sh dry` 调用）

只做只读核对：采集源可达性（curl 逐个探测并汇总）、待合箱 `.inbox` 清单、仓库边界是否干净；把结果写成中文 markdown 报告到 `automation/logs/dry-report-<时间戳>.md`。**不写 `Sources`、不写 `outputs`、不提交、不发邮件。**

### 8. 收尾

向调用方汇报：投递文件与证据块数、各域覆盖、分析文件路径、commit 短哈希、是否发信成功、不可达与去重复查统计。
