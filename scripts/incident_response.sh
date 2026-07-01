#!/bin/bash
# scripts/incident_response.sh
# 安全事件响应脚本
# 用法: bash incident_response.sh

echo "🚨 安全事件响应流程"
echo "========================================"

echo ""
echo "[Step 1] 凭证轮换"
echo "  → 请手动轮换所有可能泄露的API密钥"
echo "  → 优先更换：GitHub Token、Apple Developer 证书、OpenClaw配置"
echo ""

echo "[Step 2] 审查网关日志"
read -p "  网关日志路径 (默认 ~/.openclaw/logs/): " LOG_PATH
LOG_PATH="${LOG_PATH:-$HOME/.openclaw/logs/}"
if [ -d "$LOG_PATH" ]; then
  echo "  最近异常访问记录:"
  grep -i "unauthorized\|failed\|error" "$LOG_PATH"/*.log 2>/dev/null | tail -20
else
  echo "  ⚠️  日志目录不存在，跳过"
fi
echo ""

echo "[Step 3] 审计已安装技能"
echo "  已安装技能列表:"
ls ~/.qclaw/skills/ 2>/dev/null
echo ""
read -p "  有无可疑技能？(y/N): " SUSPICIOUS
if [ "$SUSPICIOUS" = "y" ]; then
  echo "  → 建议立即删除: rm -rf ~/.qclaw/skills/<可疑技能>"
fi
echo ""

echo "[Step 4] 重新安装（可选）"
echo "  如仍有疑虑，建议在干净环境重新安装OpenClaw"
echo ""

echo "========================================"
echo "✅ 应急响应完成"
echo "如情况严重，请同时："
echo "  1. 更改所有相关账户密码"
echo "  2. 联系 OpenClaw 官方支持"
echo "  3. 评估是否需要报警"
