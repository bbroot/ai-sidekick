#!/bin/bash
# scripts/cleanup_old_memory.sh
# 清理 WorkBuddy 工作区过期记忆日志（保留最近 90 天）
# 用法: bash cleanup_old_memory.sh
#
# 可用环境变量覆盖路径：
#   WORKBUDDY_DAILY_MEMORY_DIR  工作区每日日志目录
#   WORKBUDDY_WORKSPACE         工作区根目录

# ---- WorkBuddy 路径解析 ----
WB_HOME="${HOME}/.workbuddy"
WORKSPACE="${WORKBUDDY_WORKSPACE:-$(ls -dt "$HOME"/WorkBuddy/*/ 2>/dev/null | head -1)}"
DAILY_MEMORY_DIR="${WORKBUDDY_DAILY_MEMORY_DIR:-${WORKSPACE%/}/.workbuddy/memory}"
DAYS="${WORKBUDDY_LOG_RETENTION_DAYS:-90}"

echo "🗑️  清理 $DAYS 天前的日志: $DAILY_MEMORY_DIR"

if [ ! -d "$DAILY_MEMORY_DIR" ]; then
  echo "⚠️ 目录不存在，跳过: $DAILY_MEMORY_DIR"
  exit 0
fi

DELETED=$(find "$DAILY_MEMORY_DIR" -name "*.md" -mtime +$DAYS 2>/dev/null)

if [ -z "$DELETED" ]; then
  echo "✅ 无过期日志需要清理"
  exit 0
fi

echo "将删除以下文件:"
echo "$DELETED"
echo ""
read -p "确认删除？(y/N): " confirm
if [ "$confirm" = "y" ]; then
  find "$DAILY_MEMORY_DIR" -name "*.md" -mtime +$DAYS -delete
  echo "✅ 已删除 $(echo "$DELETED" | wc -l | tr -d ' ') 个文件"
else
  echo "已取消"
fi
