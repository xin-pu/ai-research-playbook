#!/usr/bin/env bash
# 复测采集服务器出口对各来源的可达性。
# 结果对应 .opencode/skills/ai-research-collect/SKILL.md 第 3.0.1 节的可达性表；
# 换服务器、或某个域长期采不到东西时，先跑这个脚本再改技能。
# 用法：bash automation/check-egress.sh
set -u

UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36"

fetch() {
  # $1=url $2=timeout
  curl -sS -o /dev/null -m "$2" -A "$UA" -L -w '%{http_code} %{time_total}s %{size_download}b' "$1" 2>/dev/null
}

usable() {
  local label=$1 url=$2 t=${3:-12}
  local out rc
  out=$(fetch "$url" "$t")
  rc=$?
  printf '%-24s %-30s %-56s rc=%s\n' "$label" "${out:-none}" "$(printf '%s' "$url" | cut -c1-56)" "$rc"
  case "${out:-}" in
    2* | 404) return 0 ;;
    *) return 1 ;;
  esac
}

echo "=== AI 系来源（SKILL 3.0.1 第 2 表，首测/复测） ==="
ok=0
fail=0
for spec in \
  "00-arxiv-api|http://export.arxiv.org/api/query?search_query=cat:cs.LG\&max_results=1\&sortBy=submittedDate\&sortOrder=descending|15" \
  "00-arxiv-list|https://arxiv.org/list/cs.LG/recent|15" \
  "00-arxiv-pdf|https://arxiv.org/pdf/2510.00001|60" \
  "00-openreview|https://api2.openreview.net/notes?limit=1|12" \
  "01-hf-papers|https://huggingface.co/papers|12" \
  "01-arxiv-csCL|https://arxiv.org/list/cs.CL/recent|15" \
  "02-langchain-blog|https://blog.langchain.dev/rss/|15" \
  "02-interconnects|https://www.interconnects.ai/feed|15" \
  "02-s2-api|https://api.semanticscholar.org/graph/v1/paper/search?query=LLM+agent\&limit=1|12" \
  "03-mcp-docs|https://modelcontextprotocol.io/|15" \
  "03-github-mcp|https://api.github.com/repos/modelcontextprotocol/specification/releases|15" \
  "03-github-a2a|https://api.github.com/repos/a2aproject/A2A/releases|15" \
  "04-swebench|https://www.swebench.com/|12" \
  "05-github-vllm|https://api.github.com/repos/vllm-project/vllm/releases?per_page=3|15" \
  "05-npm-mcp|https://registry.npmjs.org/@modelcontextprotocol/sdk|12" \
  "06-anthropic-news|https://www.anthropic.com/news|15" \
  "06-jiqizhixin|https://www.jiqizhixin.com/|12" \
  "06-semianalysis|https://newsletter.semianalysis.com/|15" \
  "search-bing|https://www.bing.com/search?q=GRPO+reinforcement+learning|15" \
  "ref-crossref|https://api.crossref.org/works?query.bibliographic=GRPO&rows=3|15"; do
  IFS='|' read -r label url t <<< "$spec"
  if usable "$label" "$url" "${t:-12}"; then ok=$((ok + 1)); else fail=$((fail + 1)); fi
done

echo
echo "=== 继承的不可达哨兵（短超时确认仍然不通，技能里禁止重试） ==="
for spec in \
  "raw.github|https://raw.githubusercontent.com/modelcontextprotocol/specification/main/README.md" \
  "jsdelivr|https://cdn.jsdelivr.net/gh/modelcontextprotocol/specification@main/README.md" \
  "google|https://www.google.com/search?q=GRPO" \
  "duckduckgo|https://lite.duckduckgo.com/lite/?q=GRPO" \
  "archive.org|https://web.archive.org/web/2026/https://modelcontextprotocol.io/" \
  "jina|https://r.jina.ai/https://modelcontextprotocol.io/" \
  "openai-news|https://openai.com/news/"; do
  IFS='|' read -r label url <<< "$spec"
  out=$(fetch "$url" 6)
  rc=$?
  code=${out%% *}
  if [ "$rc" -eq 0 ] && printf '%s' "$code" | grep -q '^2'; then
    printf '%-20s 现在可通了（%s）—— 需要把它移出不可达清单\n' "$label" "$out"
  else
    printf '%-20s 确认不可达 %s rc=%s\n' "$label" "${out:-none}" "$rc"
  fi
done

echo
printf '=== 汇总：可用来源 %s 正常 / %s 异常 ===\n' "$ok" "$fail"
[ "$fail" -eq 0 ] || echo "有来源不通：按 SKILL 3.0.1 的处理规则跳过并记日志；确认长期不可达的，回写技能可达性表。"
