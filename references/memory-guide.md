# 记忆系统最佳实践

OpenClaw Agent 的记忆系统分为三层：会话记忆 → 短期记忆 → 长期记忆。

---

## 三层架构

```
会话上下文（LLM 自身）
    ↓ 提取写入
每日日志 memory/YYYY-MM-DD.md（短期）
    ↓ 定期整理
MEMORY.md（长期）
```

---

## 每日日志（memory/YYYY-MM-DD.md）

### 什么时候写

- 每个重要会话结束时
- 做出关键决策时
- 发现重要问题时
- 用户透露重要信息时

### 格式规范

```markdown
# 2026-07-01 日志

## 📋 决策记录
- 决策1：...（原因：...）
- 决策2：...

## 🐛 问题与解决
- 问题：...
  原因：...
  解决：...

## 👤 用户偏好
- 喜欢简洁汇报，不喜欢废话
- 技术问题喜欢直接给方案

## 📝 备注
- 下次继续：...
```

### 命名规范

- 文件名：`YYYY-MM-DD.md`（日期为会话主要发生的日期）
- 时区：统一用 Asia/Shanghai

---

## 长期记忆（MEMORY.md）

### 位置

workspace 根目录：`~/.qclaw/workspace-agent-37058ef3/MEMORY.md`

### 何时更新

| 事件 | 操作 |
|------|------|
| 新项目启动 | 在 MEMORY.md 建立项目段落 |
| 技术选型决策 | 记录决策和原因 |
| 踩坑记录 | 详细写问题 + 原因 + 解决 |
| 用户偏好 | 即时更新 |
| API key / 凭证位置变更 | 立即更新 TOOLS.md |
| 安全事件 | 立即记录 + 触发安全响应 |

### 精简规则

MEMORY.md **不应**越来越大。每次更新时：
1. 检查是否有旧信息可以合并或删除
2. 如果某条目超过 3 个月没用，考虑删除
3. 将高频知识迁移到 Skill 中，减少每次读取开销

### 结构建议

```markdown
# MEMORY.md

## 用户身份与偏好
- 禁止AI出现循环思考
- 用户有苹果开发者账号
- 用户明确要求不新生成icon

## 经验与决策
- app上传前必须添加ITSAppUsesNonExemptEncryption=false
- 证书问题优先检查embedded.provisionprofile

## 安全规则
- API Key只用keychain，不记录在文件

## 项目状态
## 当前项目：NotePro
- 状态：App Store审核中
- 最新版本：1.2.3
```

---

## 记忆读取规则

| 场景 | 读取内容 |
|------|----------|
| 主会话启动 | SOUL.md + USER.md + MEMORY.md + 今日/昨日日志 |
| 群聊/共享会话 | SOUL.md + USER.md（禁止加载 MEMORY.md） |
| HEARTBEAT | HEARTBEAT.md（禁止加载 MEMORY.md） |
| 子Agent | 仅 AGENTS.md |

---

## 备份策略

```bash
# scripts/backup_memory.sh
WORKSPACE="$HOME/.qclaw/workspace-agent-37058ef3"
BACKUP_DIR="$HOME/.qclaw/backups"
mkdir -p "$BACKUP_DIR"
DATE=$(date +%Y%m%d_%H%M%S)
tar czf "$BACKUP_DIR/memory_${DATE}.tar.gz" \
  "$WORKSPACE/MEMORY.md" \
  "$WORKSPACE/memory/"
echo "备份完成: $BACKUP_DIR/memory_${DATE}.tar.gz"
ls -lh "$BACKUP_DIR" | tail -5
```

---

## 过期清理

每 90 天执行一次清理：
```bash
# 删除 90 天前的日志（保留最近 90 天）
find ~/.qclaw/workspace-agent-37058ef3/memory/ \
  -name "*.md" -mtime +90 -delete
```

---

## 冲突处理

如果文件记录与实际不符（例：用户口头说改了密码但 MEMORY.md 没更新）：
→ 以用户最新的口头/书面指示为准，立即更新文件
→ 不以旧文件内容对抗新指示
