#!/bin/bash
# scripts/backup_memory.sh
# WorkBuddy 记忆备份：打包「用户级长期记忆」+「工作区每日日志」
# 用法: bash backup_memory.sh
#
# 可用环境变量覆盖路径：
#   WORKBUDDY_MEMORY_FILE       长期记忆 MEMORY.md
#   WORKBUDDY_DAILY_MEMORY_DIR  工作区每日日志目录
#   WORKBUDDY_BACKUP_DIR        备份输出目录

# ---- WorkBuddy 路径解析 ----
WB_HOME="${HOME}/.workbuddy"
PERSONAL_DIR="${WORKBUDDY_PERSONAL_DIR:-$(ls -d "$WB_HOME"/user-*-personal 2>/dev/null | head -1)}"
MEMORY_FILE="${WORKBUDDY_MEMORY_FILE:-$PERSONAL_DIR/MEMORY.md}"
WORKSPACE="${WORKBUDDY_WORKSPACE:-$(ls -dt "$HOME"/WorkBuddy/*/ 2>/dev/null | head -1)}"
DAILY_MEMORY_DIR="${WORKBUDDY_DAILY_MEMORY_DIR:-${WORKSPACE%/}/.workbuddy/memory}"
BACKUP_DIR="${WORKBUDDY_BACKUP_DIR:-$WB_HOME/backups}"

mkdir -p "$BACKUP_DIR"
DATE=$(date +%Y%m%d_%H%M%S)
OUT="$BACKUP_DIR/memory_${DATE}.tar.gz"

SOURCES=()
[ -f "$MEMORY_FILE" ] && SOURCES+=("$MEMORY_FILE")
[ -d "$DAILY_MEMORY_DIR" ] && SOURCES+=("$DAILY_MEMORY_DIR")

if [ ${#SOURCES[@]} -eq 0 ]; then
  echo "⚠️ 未找到可备份的记忆文件（检查 $MEMORY_FILE 与 $DAILY_MEMORY_DIR）"
  exit 1
fi

tar czf "$OUT" "${SOURCES[@]}" 2>/dev/null

echo "✅ 备份完成: $OUT"
echo "  来源: ${SOURCES[*]}"
echo ""
echo "最近5次备份:"
ls -lh "$BACKUP_DIR" | grep memory_ | tail -5
