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

# 追加语义：保留段落原有条目，仅在段末追加新行（同内容去重）。
# 旧实现用 in_section{next} 会丢弃整段历史条目，造成不可逆数据丢失。
TODAY=$(date +%Y-%m-%d)
MEMORY_FILE="$MEMORY_FILE" SECTION="$SECTION" CONTENT="$CONTENT" TODAY="$TODAY" \
awk '
  BEGIN {
    sec = "## " ENVIRON["SECTION"]
    bare = ENVIRON["CONTENT"]
    line = "- " bare " (" ENVIRON["TODAY"] ")"
  }
  $0 == sec {
    print; in_section = 1; inserted = 1; next
  }
  /^## / && in_section {
    # 离开段落前，若尚未追加重试（去重：正文已含 bare 则跳过）
    if (!appended) { print line; appended = 1 }
    in_section = 0
  }
  {
    print
    if (in_section && index($0, bare) > 0) duplicate = 1
  }
  END {
    if (!inserted) { print ""; print sec; print line; appended = 1 }
    else if (in_section && !appended && !duplicate) { print line }
  }
' "$MEMORY_FILE" > "${MEMORY_FILE}.tmp" && mv "${MEMORY_FILE}.tmp" "$MEMORY_FILE"

echo "✅ 已在段落末尾追加: $SECTION"
echo "   记忆文件: $MEMORY_FILE"
