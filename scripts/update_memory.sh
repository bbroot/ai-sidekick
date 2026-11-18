#!/bin/bash
# scripts/update_memory.sh
# 快速更新 WorkBuddy 用户级长期记忆 MEMORY.md 的指定段落
# 用法: bash update_memory.sh <段落名> <新内容>
#
# 可用环境变量覆盖路径：
#   WORKBUDDY_MEMORY_FILE       长期记忆 MEMORY.md
#   WORKBUDDY_PERSONAL_DIR      用户级 personal 目录

# ---- WorkBuddy 路径解析 ----
WB_HOME="${HOME}/.workbuddy"
PERSONAL_DIR="${WORKBUDDY_PERSONAL_DIR:-$(ls -d "$WB_HOME"/user-*-personal 2>/dev/null | head -1)}"
MEMORY_FILE="${WORKBUDDY_MEMORY_FILE:-$PERSONAL_DIR/MEMORY.md}"

SECTION="$1"
CONTENT="$2"

if [ -z "$SECTION" ] || [ -z "$CONTENT" ]; then
  echo "用法: bash update_memory.sh <段落名> <新内容>"
  echo "示例: bash update_memory.sh NotePro '版本1.2.3，App Store审核中'"
  echo "当前记忆文件: $MEMORY_FILE"
  exit 1
fi

if [ ! -f "$MEMORY_FILE" ]; then
  echo "⚠️ 记忆文件不存在：$MEMORY_FILE"
  echo "   请先创建，或用 WORKBUDDY_MEMORY_FILE 指定正确路径"
  exit 1
fi

# 用 awk 重写段落，再用 mv 落盘（跨平台，避免 macOS 专属的 sed -i ''）
TODAY=$(date +%Y-%m-%d)
MEMORY_FILE="$MEMORY_FILE" SECTION="$SECTION" CONTENT="$CONTENT" TODAY="$TODAY" \
awk '
  BEGIN {
    mem = ENVIRON["MEMORY_FILE"]; sec = "## " ENVIRON["SECTION"]
    line = "- " ENVIRON["CONTENT"] " (" ENVIRON["TODAY"] ")"
  }
  $0 == sec {
    print; print line; in_section = 1; inserted = 1; next
  }
  /^## / && in_section { in_section = 0 }
  in_section { next }
  { print }
  END {
    if (!inserted) { print ""; print sec; print line }
  }
' "$MEMORY_FILE" > "${MEMORY_FILE}.tmp" && mv "${MEMORY_FILE}.tmp" "$MEMORY_FILE"

echo "✅ 已更新段落: $SECTION"
echo "   记忆文件: $MEMORY_FILE"
