#!/bin/bash
# scripts/update_memory.sh
# 快速更新MEMORY.md指定段落
# 用法: bash update_memory.sh <段落名> <新内容>

WORKSPACE="$HOME/.qclaw/workspace-agent-37058ef3"
MEMORY_FILE="$WORKSPACE/MEMORY.md"

SECTION="$1"
CONTENT="$2"

if [ -z "$SECTION" ] || [ -z "$CONTENT" ]; then
  echo "用法: bash update_memory.sh <段落名> <新内容>"
  echo "示例: bash update_memory.sh NotePro '版本1.2.3，App Store审核中'"
  exit 1
fi

# 简单实现：在对应段落后追加或更新
TODAY=$(date +%Y-%m-%d)
TEMP_FILE="$MEMORY_FILE.tmp"

if grep -q "## $SECTION" "$MEMORY_FILE"; then
  # 段落存在，替换其内容
  awk -v section="## $SECTION" -v content="$CONTENT ($TODAY)" '
    BEGIN { in_section=0 }
    $0 == section { in_section=1; print; next }
    /^## / && in_section { in_section=0 }
    in_section { next }
    { print }
  ' "$MEMORY_FILE" > "$TEMP_FILE"
  # 简化版：在段落后插入
  sed -i '' "/^## $SECTION$/a\\- $CONTENT ($TODAY)" "$MEMORY_FILE"
  echo "✅ 已更新段落: $SECTION"
else
  # 段落不存在，追加
  echo -e "\n## $SECTION\n- $CONTENT ($TODAY)" >> "$MEMORY_FILE"
  echo "✅ 已新增段落: $SECTION"
fi
