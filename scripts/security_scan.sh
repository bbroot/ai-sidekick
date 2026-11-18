#!/bin/bash
# scripts/security_scan.sh
# 第三方Skill安全扫描脚本
# 用法: bash security_scan.sh /path/to/skill

TARGET="${1:-.}"

echo "🔍 安全扫描: $TARGET"
echo "========================================"

# 1. 恶意代码模式
echo "  [1/5] 检查恶意代码模式..."
MALICIOUS=$(grep -rE "eval\(|exec\(|system\(|popen\(|subprocess|os\.system" \
  --include="*.py" --include="*.sh" "$TARGET" 2>/dev/null)
if [ -n "$MALICIOUS" ]; then
  echo "  ⚠️  发现可疑代码模式:"
  echo "$MALICIOUS" | head -5
else
  echo "  ✅ 无恶意代码模式"
fi

# 2. 网络请求
echo "  [2/5] 检查网络请求..."
NETWORK=$(grep -rE "curl|wget|requests\.(post|get)|http\.(post|request)" \
  --include="*.py" --include="*.sh" --include="*.js" "$TARGET" 2>/dev/null)
if [ -n "$NETWORK" ]; then
  echo "  ⚠️  发现网络请求（确认是否为正常用途）:"
  echo "$NETWORK" | head -5
else
  echo "  ✅ 无网络请求"
fi

# 3. 系统级操作
echo "  [3/5] 检查系统级操作..."
SYSOP=$(grep -rE "\/etc\/|\/root\/|~\/.ssh|chmod\s+0|sudo\s+rm" \
  --include="*.py" --include="*.sh" "$TARGET" 2>/dev/null)
if [ -n "$SYSOP" ]; then
  echo "  ⚠️  发现系统级操作（确认必要性）:"
  echo "$SYSOP" | head -5
else
  echo "  ✅ 无系统级操作"
fi

# 4. 权限声明
echo "  [4/5] 检查权限声明文件..."
if [ -f "$TARGET/policies/permission_manifest.md" ]; then
  echo "  ✅ 权限声明文件存在"
else
  echo "  ⚠️  缺少权限声明文件 (policies/permission_manifest.md)"
fi

# 5. 凭证存储
echo "  [5/5] 检查凭证存储..."
CREDS=$(grep -rE "api[_-]?key|password|secret|token" \
  --include="*.yaml" --include="*.json" --include="*.sh" \
  --include="*.py" "$TARGET" 2>/dev/null | grep -vE "^[^:]*:[[:space:]]*#")
if [ -n "$CREDS" ]; then
  echo "  ⚠️  发现凭证相关字段（确认是否为占位符）:"
  echo "$CREDS" | head -5
else
  echo "  ✅ 无硬编码凭证"
fi

echo "========================================"
echo "✅ 扫描完成"
echo "提示: 如有⚠️项，请在安装前人工审查"
