#!/usr/bin/env bash
# 查看采集流水线的运行状态：最近日志、健康文件、投递口待处理数、仓库位置与定时任务。
# 用法：bash automation/ai-playbook-status.sh [--log 40]
set -u

REPO="${AI_PLAYBOOK_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
LOGS="$REPO/automation/logs"
TAIL_N=25
[ "${1:-}" = "--log" ] && TAIL_N="${2:-25}"

echo "=== 最近一次运行日志 ==="
LOG=$(ls -1t "$LOGS"/collect-*.log 2>/dev/null | head -1)
if [ -z "$LOG" ]; then
  echo "还没有运行记录（$LOGS/collect-*.log）"
else
  echo "$LOG"
  grep -E '^(Starting|opencode rc|RESULT|another collect)' "$LOG" | tail -5
  HEALTH="${LOG%.log}.health"
  if [ -f "$HEALTH" ]; then
    echo "--- 产物健康检查（$HEALTH） ---"
    cat "$HEALTH"
  fi
  echo "--- 尾部 $TAIL_N 行 ---"
  tail -n "$TAIL_N" "$LOG"
fi

echo
echo "=== 台账最新条目（Sources/update-log.md） ==="
if [ -f "$REPO/Sources/update-log.md" ]; then
  grep -m1 '^## ' "$REPO/Sources/update-log.md" || echo "（台账还没有条目）"
else
  echo "找不到 $REPO/Sources/update-log.md"
fi

echo
echo "=== 投递口 .inbox 待归并 ==="
if [ -d "$REPO/Sources" ]; then
  find "$REPO/Sources" -path '*/.inbox/*' -name '*.md' 2>/dev/null | sed "s|$REPO/||" | sort | head -40
  printf '合计 %s 个投递文件\n' "$(find "$REPO/Sources" -path '*/.inbox/*' -name '*.md' 2>/dev/null | wc -l)"
else
  echo "找不到 $REPO/Sources"
fi

echo
echo "=== 周度分析 ==="
ls -1t "$REPO/outputs/weekly"/*.md 2>/dev/null | head -5 || echo "尚无产出"

echo
echo "=== 仓库位置 ==="
printf '%-40s %s  未推送:%s  未提交:%s\n' "$REPO" \
  "$(git -C "$REPO" log -1 --format='%h %ad %s' --date=short 2>/dev/null)" \
  "$(git -C "$REPO" log --oneline '@{u}..' 2>/dev/null | wc -l)" \
  "$(git -C "$REPO" status --porcelain 2>/dev/null | wc -l)"

echo
echo "=== 定时任务 ==="
crontab -l 2>/dev/null | grep -n 'ai-playbook' || echo "crontab 未安装本任务"
