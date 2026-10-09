#!/usr/bin/env bash
# 幂等安装本仓库的两条定时任务（每日 09:00 采集 / 每周日 00:30 周度分析）。
# 用法：bash automation/install-cron.sh
set -u

REPO="${AI_PLAYBOOK_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
LOGS="$REPO/automation/logs"
mkdir -p "$LOGS"

DAILY="0 9 * * *"
WEEKLY="30 0 * * 0"
SCRIPT="$REPO/automation/ai-playbook-daily.sh"

# 注意：去重键必须包含运行模式（daily/weekly 用同一个脚本，只按脚本路径判重会漏装第二条）
entries=(
  "$DAILY $SCRIPT daily >> $LOGS/cron.log 2>&1"
  "$WEEKLY $SCRIPT weekly >> $LOGS/cron.log 2>&1"
)

current=/tmp/ai-playbook-crontab.current
crontab -l > "$current" 2>/dev/null || : > "$current"
added=0

for e in "${entries[@]}"; do
  # 第 6 字段是脚本路径，第 7 字段是运行模式；按「路径+模式」整串判重
  key=$(printf '%s\n' "$e" | awk '{print $6 " " $7}')
  if grep -qF "$key" "$current"; then
    echo "已存在 : $e"
  else
    printf '%s\n' "$e" >> "$current"
    echo "新装   : $e"
    added=$((added + 1))
  fi
done

if [ "$added" -gt 0 ]; then
  cp "$current" "$LOGS/crontab.bak.$(date +%Y%m%d%H%M%S)"
  crontab "$current"
fi

echo "--- crontab now ---"
crontab -l | grep 'ai-playbook' || echo "（没有本任务条目）"
