#!/bin/bash
# scripts/cleanup_old_memory.sh
# 清理过期记忆日志（保留最近90天）
# 用法: bash cleanup_old_memory.sh

WORKSPACE="$HOME/.qclaw/workspace-agent-37058ef3"
DAYS=90

echo "🗑️  清理 $DAYS 天前的日志..."

DELETED=$(find "$WORKSPACE/memory/" -name "*.md" -mtime +$DAYS 2>/dev/null)

if [ -z "$DELETED" ]; then
  echo "✅ 无过期日志需要清理"
  exit 0
fi

echo "将删除以下文件:"
echo "$DELETED"
echo ""
read -p "确认删除？(y/N): " confirm
if [ "$confirm" = "y" ]; then
  find "$WORKSPACE/memory/" -name "*.md" -mtime +$DAYS -delete
  echo "✅ 已删除 $(echo "$DELETED" | wc -l | tr -d ' ') 个文件"
else
  echo "已取消"
fi
