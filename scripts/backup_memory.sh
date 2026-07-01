#!/bin/bash
# memory/backup_memory.sh
# 记忆系统备份脚本
# 用法: bash backup_memory.sh

WORKSPACE="$HOME/.qclaw/workspace-agent-37058ef3"
BACKUP_DIR="$HOME/.qclaw/backups"
mkdir -p "$BACKUP_DIR"

DATE=$(date +%Y%m%d_%H%M%S)

tar czf "$BACKUP_DIR/memory_${DATE}.tar.gz" \
  "$WORKSPACE/MEMORY.md" \
  "$WORKSPACE/memory/" 2>/dev/null

echo "✅ 备份完成: $BACKUP_DIR/memory_${DATE}.tar.gz"
echo ""
echo "最近5次备份:"
ls -lh "$BACKUP_DIR" | grep memory_ | tail -5
