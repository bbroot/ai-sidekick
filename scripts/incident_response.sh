#!/bin/bash
# scripts/incident_response.sh
# 安全事件响应脚本（已适配 WorkBuddy）
# 用法: bash incident_response.sh

echo "🚨 安全事件响应流程"
echo "========================================"

echo ""
echo "[Step 1] 凭证轮换"
echo "  → 请手动轮换所有可能泄露的 API 密钥"
echo "  → 优先更换：GitHub Token、Open Platform Token、各 Connector 授权"
echo "  → 建议每 90 天轮换一次；凭证用环境变量/keychain，不硬编码"
echo ""

echo "[Step 2] 审查会话与日志"
read -p "  日志目录路径 (默认 ~/.workbuddy/logs/): " LOG_PATH
LOG_PATH="${LOG_PATH:-$HOME/.workbuddy/logs/}"
if [ -d "$LOG_PATH" ]; then
  echo "  最近异常记录:"
  grep -i "unauthorized\|failed\|error" "$LOG_PATH"/*.log 2>/dev/null | tail -20
else
  echo "  ⚠️  日志目录不存在，跳过（若有 WorkBuddy 会话导出，可手动检查）"
fi
echo ""

echo "[Step 3] 审计已安装技能"
echo "  用户级技能列表 (~/.workbuddy/skills/):"
ls "$HOME/.workbuddy/skills/" 2>/dev/null
echo ""
read -p "  有无可疑技能？(y/N): " SUSPICIOUS
if [ "$SUSPICIOUS" = "y" ]; then
  echo "  → 可在设置中禁用，或移除目录 ~/.workbuddy/skills/<可疑技能>"
fi
echo ""

echo "[Step 4] 重新安装（可选）"
echo "  如仍有疑虑，建议在干净环境重新安装 WorkBuddy"
echo ""

echo "========================================"
echo "✅ 应急响应完成"
echo "如情况严重，请同时："
echo "  1. 更改所有相关账户密码"
echo "  2. 撤销并重新授权相关 Connector"
echo "  3. 评估是否需要报警"
