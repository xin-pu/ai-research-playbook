#!/usr/bin/env bash
# AI 研究知识库 —— 定时采集入口。
#   ai-playbook-daily.sh daily    每天 09:00（cron）：采集 → .inbox 投递 → 提交推送
#   ai-playbook-daily.sh weekly   每周日 00:30（cron）：采集 + 周度分析 + 汇报邮件
#   ai-playbook-daily.sh dry      手动只读巡检：验证锁、日志、健康检查链路，不写库不发信
#
# 判据用产物，不用 opencode 的退出码：opencode run 只要有一次工具调用报错就返回 1，
# 而采集环节撞 403 / 超时属于常态，据此判失败会天天误报（沿用 optical-module-playbook
# 工作流 2026-10-09 的实测结论）。
set -u
export PATH="$HOME/.opencode/bin:$PATH"
[ -f "$HOME/.secrets/qwen.env" ] && { set -a; . "$HOME/.secrets/qwen.env"; set +a; }

MODE="${1:-daily}"
case "$MODE" in
  daily|weekly|dry) ;;
  *) echo "用法: $0 [daily|weekly|dry]"; exit 64 ;;
esac

REPO="${AI_PLAYBOOK_DIR:-$HOME/ai-research-playbook}"
CFG="$REPO/automation/config.json"
LOGS="$REPO/automation/logs"
STAMP="${AI_PLAYBOOK_STAMP:-$(date +%Y-%m-%d_%H%M%S)}"

[ -d "$REPO" ] || { echo "缺少仓库 $REPO"; exit 1; }
mkdir -p "$LOGS"
LOG="$LOGS/collect-$MODE-$STAMP.log"
HEALTH="$LOGS/collect-$MODE-$STAMP.health"
cd "$REPO" || exit 1

# 自更新：每轮先把仓库拉到最新再重新执行自己。
# 这样做是因为 bash 从磁盘增量读取脚本文件，直接在脚本里 git pull 可能把正在执行的
# 文件改掉；pull 后立刻 exec 重新打开新文件即可规避（AI_PLAYBOOK_NO_PULL=1 可跳过）。
if [ "${AI_PLAYBOOK_NO_PULL:-0}" != "1" ]; then
  git pull --ff-only >>"$LOG" 2>&1 || echo "git pull failed (continuing, 技能内会重试)" | tee -a "$LOG"
  AI_PLAYBOOK_NO_PULL=1 AI_PLAYBOOK_STAMP="$STAMP" exec bash "$0" "$@"
fi

# 独立锁：只防止本任务自身重叠，不影响同一台服务器上的其它 playbook 任务
exec 9> "$REPO/automation/.collect.lock"
if ! flock -n 9; then
  echo "another collect run is active, skipped at $STAMP" | tee -a "$LOG"
  exit 0
fi

echo "Starting collect [$MODE] at $STAMP" | tee -a "$LOG"

REPORT_TO=$(jq -r '.reportTo // empty' "$CFG" 2>/dev/null || true)

# ------------------------------------------------------------ 选择提示词
if [ "$MODE" = "dry" ]; then
  PROMPT="Load the ai-research-collect skill, but run INSPECTION-ONLY mode (section 7): do NOT write anything under Sources or outputs, do NOT commit or push, do NOT send any email. Instead: (1) probe each collection source in Sources/web-sources.md from the server egress using bash+curl only and summarise reachability; (2) list .inbox delivery files pending merge and the last entry of Sources/update-log.md; (3) check that git status of $REPO is clean outside Sources/**/.inbox/** and outputs/weekly/**; (4) write your findings as a Chinese markdown report to $LOGS/dry-report-$STAMP.md and nothing else. Reply in Chinese."
elif [ "$MODE" = "weekly" ]; then
  PROMPT="Load the ai-research-collect skill and run the FULL weekly workflow (unattended mode: do not ask for confirmation; refresh the repository, collect new public sources from the last 7 days into the .inbox delivery boxes using bash+curl only, commit and push, write this week's analysis document to outputs/weekly/$(date +%F)-采集分析.md, then send the report email to the address in automation/config.json). Reply in Chinese."
else
  PROMPT="Load the ai-research-collect skill and run the DAILY collection workflow (unattended mode: do not ask for confirmation; collect sources from the last 24 hours into the .inbox delivery boxes using bash+curl only, then commit and push. No weekly analysis, no email in daily mode. If there is nothing new, do not create any file and just report 本轮无新增). Reply in Chinese."
fi

START=$(date +%s)
opencode run --standalone --auto "$PROMPT" 2>&1 | tee -a "$LOG"
AGENT_RC=${PIPESTATUS[0]}
echo "opencode rc: $AGENT_RC (工具报错即非零，不作为本轮判据)" | tee -a "$LOG"

# ------------------------------------------------------------ 产物健康检查
: > "$HEALTH"
healthy=1
note() { printf '%s\n' "$1" | tee -a "$HEALTH"; }

# 通用判据：仓库边界干净 + 已推送
LEAK=$(git status --porcelain 2>/dev/null | grep -vE 'Sources/[^ ]*\.inbox/|outputs/weekly/' | wc -l)
if [ "$LEAK" -eq 0 ]; then
  note "PASS 仓库边界干净：改动只出现在 Sources/**/.inbox/** 与 outputs/weekly/**"
else
  note "FAIL 仓库出现 $LEAK 项越界改动（技能只允许写投递口与 outputs/weekly）"
  healthy=0
fi

UNPUSHED=$(git rev-list --count '@{u}..HEAD' 2>/dev/null || echo "?")
if [ "$UNPUSHED" = "0" ]; then
  note "PASS 内容仓库无未推送提交（HEAD $(git log -1 --format=%h 2>/dev/null)）"
elif [ "$UNPUSHED" = "?" ]; then
  note "INFO 无法确定上游（首次部署或未设 upstream），跳过推送判据"
else
  note "FAIL 内容仓库有 $UNPUSHED 个未推送提交（推送未成功，需人工处理）"
  healthy=0
fi

NEW_INBOX=$(find "$REPO/Sources" -path '*/.inbox/*' -name '*.md' -newermt "@$START" 2>/dev/null | wc -l)
note "INFO 本轮新增投递文件 $NEW_INBOX 个（0 也可能是因为确实没有新内容）"

if [ "$MODE" = "dry" ]; then
  DRY_REPORT="$LOGS/dry-report-$STAMP.md"
  if [ -f "$DRY_REPORT" ]; then
    note "PASS 巡检报告已生成：$DRY_REPORT"
  else
    note "FAIL 没有本轮巡检报告 $DRY_REPORT"
    healthy=0
  fi
elif [ "$MODE" = "weekly" ]; then
  WEEKLY=$(find "$REPO/outputs/weekly" -name "$(date +%F)-*.md" -newermt "@$START" 2>/dev/null | wc -l)
  if [ "$WEEKLY" -ge 1 ]; then
    note "PASS 本轮写出周度分析 $WEEKLY 份"
  else
    note "FAIL 本轮没有写 outputs/weekly/$(date +%F)-采集分析.md"
    healthy=0
  fi
fi

DIRTY=$(git status --porcelain 2>/dev/null | wc -l)
[ "$DIRTY" -eq 0 ] || note "INFO 仓库有 $DIRTY 项未提交改动（可能是他方正在编辑，本任务不触碰）"

# ------------------------------------------------------------ 失败告警
if [ "$healthy" -eq 1 ]; then
  if [ "$MODE" = "weekly" ]; then
    note "RESULT 本轮健康（汇报邮件由技能步骤发出）"
  else
    note "RESULT 本轮健康"
  fi
  echo "RESULT: healthy (agent rc=$AGENT_RC)" | tee -a "$LOG"
  exit 0
fi

note "RESULT 本轮不健康（agent rc=$AGENT_RC）"
echo "RESULT: UNHEALTHY" | tee -a "$LOG"

if [ "$MODE" = "dry" ]; then
  # 巡检档验证的是脚本链路本身，不额外发信
  exit 2
fi

if [ -n "$REPORT_TO" ]; then
  opencode run --standalone --auto \
    "读取 $HEALTH 的内容，用 ms365 给 $REPORT_TO 发一封告警邮件：主题「【AI研究知识库采集】$(date +%F) $MODE 运行异常」，正文用简洁的正式书面语，把 health 文件里的 FAIL 与 INFO 逐条列出，并说明本轮日志为 $LOG。不要执行其他步骤，发完即止。" \
    2>&1 | tee -a "$LOG"
else
  echo "reportTo 为空，跳过告警邮件（见 automation/config.json）" | tee -a "$LOG"
fi
exit 2
