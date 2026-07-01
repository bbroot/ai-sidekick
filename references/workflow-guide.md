# 工作流构建完整指南

---

## 一、工作流设计原则

1. **原子化**：每步只做一件事，输出明确
2. **可中断**：任意步骤失败都能报告当前状态
3. **文件传递**：用文件而非脑内存传递状态
4. **显式确认**：高危步骤前必须用户确认

---

## 二、标准化工作流模板

### 模板 A：新项目初始化

```markdown
## 新项目初始化工作流

### Step 1：背景调研
→ 读取 USER.md
→ 读取 MEMORY.md 相关项目段落
→ 如果是新领域，网络搜索快速调研

### Step 2：建立项目档案
→ 创建 memory/YYYY-MM-DD.md
→ 记录：项目名称、目标、技术栈、关键约束
→ 在 MEMORY.md 建立项目段落

### Step 3：任务拆解
→ 将项目拆解为 N 个阶段
→ 每个阶段定义：输入 → 动作 → 输出
→ 输出项目计划（markdown 列表）

### Step 4：执行第一阶段
→ 逐个子任务执行
→ 每完成一个子任务，写入日志文件

### Step 5：复盘
→ 整理遇到的问题和解决方案
→ 更新 MEMORY.md
→ 汇报进度
```

### 模板 B：代码修改工作流

```markdown
## 代码修改工作流

### Step 1：理解现状
→ 读取目标文件
→ 确认修改范围
→ 如果影响多个文件，列出所有涉及文件

### Step 2：制定修改方案
→ 描述要改什么
→ 描述怎么改
→ 描述改后预期行为
→ 如有风险，明确说明

### Step 3：执行修改
→ 使用 edit 工具做精确替换
→ 不重写整个文件（除非必要）

### Step 4：验证
→ 构建/测试
→ 如失败，分析原因，修复
→ 如成功，继续下一步

### Step 5：提交
→ git add + commit
→ commit message 描述修改内容
→ 记录到当日日志
```

### 模板 C：问题排查工作流

```markdown
## 问题排查工作流

### Step 1：收集信息
→ 错误信息原文
→ 相关日志
→ 最近的操作记录

### Step 2：定位根因
→ 假设可能原因（通常 2-3 个）
→ 逐一排查，从最可能的原因开始
→ 找到根因后停止，不要过度排查

### Step 3：修复
→ 最小改动原则
→ 先在测试环境验证

### Step 4：复盘
→ 记录问题原因
→ 记录修复方法
→ 如有必要，更新 MEMORY.md 或 Skill 避免同类问题
```

---

## 三、复杂任务拆解方法

### 横向拆解（并发执行）

适合多个独立子任务：

```
Task A ─┐
Task B ─┼─→ 汇总 → 交付
Task C ─┘
```

在 OpenClaw 中：使用 `sessions_spawn` 并行启动子任务，再汇总结果。

### 纵向拆解（顺序执行）

适合有依赖关系的任务：

```
Step 1 → Step 2 → Step 3 → 交付
```

每个 Step 的输出是下一步的输入，写入文件传递。

### 漏斗拆解（渐进澄清）

适合需求不明确的任务：

```
模糊需求 → 提问澄清 → 确认理解 → 执行
```

---

## 四、Cron 定时任务配置

### 常用场景

| 场景 | cron 表达式 | 时区 |
|------|------------|------|
| 每天早9点提醒 | `0 9 * * *` | Asia/Shanghai |
| 每周一早上 | `0 9 * * 1` | Asia/Shanghai |
| 每30分钟健康检查 | `*/30 * * * *` | Asia/Shanghai |
| 每月1号 | `0 0 1 * *` | Asia/Shanghai |

### 配置示例

```bash
# 创建每日提醒
cron add \
  --name "daily-checkin" \
  --schedule '{"kind":"cron","expr":"0 9 * * *","tz":"Asia/Shanghai"}' \
  --payload '{"kind":"agentTurn","message":"检查今日任务并提醒"}' \
  --sessionTarget "isolated"
```

> 详细配置参考 `qclaw-cron-skill`（必须先读取）

---

## 五、Sub-Agent 并行工作流

### 适用场景

- 多个独立任务可以同时执行
- 一个任务需要多个信息源同时查询
- 大任务可以拆分为多个子任务

### 用法

```bash
# 并行查询多个信息源
sessions_spawn "查询GitHub issue列表" \
  --runtime subagent \
  --mode run \
  --task "用curl调用GitHub API获取用户bbroot的issue列表..."

sessions_spawn "查询最新构建状态" \
  --runtime subagent \
  --mode run \
  --task "检查本地构建目录的最新产物..."
```

### 注意事项

- 子任务独立运行，不共享上下文
- 汇总阶段需要将各子任务结果合并
- 异常处理：任何子任务失败不影响其他任务，但汇总时要报告失败

---

## 六、工作流状态文件

复杂任务使用状态文件跟踪进度：

```bash
# .workflow-state.json
{
  "task": "NotePro v1.2.3 发布",
  "currentStep": 3,
  "steps": [
    {"n": 1, "name": "构建.app", "status": "done"},
    {"n": 2, "name": "签名验证", "status": "done"},
    {"n": 3, "name": "打包.pkg", "status": "in_progress"},
    {"n": 4, "name": "上传App Store", "status": "pending"},
    {"n": 5, "name": "验证构建", "status": "pending"}
  ],
  "lastUpdated": "2026-07-01T13:30:00+08:00"
}
```
