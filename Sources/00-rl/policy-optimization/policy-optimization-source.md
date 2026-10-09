# policy-optimization · 策略优化算法（PPO/GRPO/RLVR 系）

> 归属域：`Sources/00-rl`。提炼去向：未提炼（候选：`knowledge-base/solutions/01-强化学习方法`，开启条件见 [solutions/00-正式正文导航](../../../knowledge-base/solutions/00-正式正文导航.md)）。
> 本箱收录 LLM 推理后训练中策略优化算法的变体、稳定性问题与训练范式对比；RLHF/偏好优化见 [rlhf-preference-optimization-source.md](../rlhf-preference-optimization/rlhf-preference-optimization-source.md)。

## 证据索引

| 编号 | 主题 | 等级 | 获取日期 | 原件 | 状态 |
|---|---|---|---|---|---|
| E1 | GRPODropout：rollout 级选择性丢弃缓解熵坍缩 | A | 2026-10-09 | `originals/arxiv-2610.11854-grpo-dropout.pdf` | 未提炼 |
| E2 | Fed-GRPO：用奖励统计做联邦聚合信号 | A | 2026-10-09 | — | 未提炼 |
| E3 | Residual Advantage：把师生概率残差变成有界步骤奖励 | A | 2026-10-09 | — | 未提炼 |

## E1 · GRPODropout：选择性丢弃高概率正优势 rollout 缓解熵坍缩

- 获取日期：2026-10-09
- 来源 URL：https://arxiv.org/abs/2610.11854
- 本地原件：`originals/arxiv-2610.11854-grpo-dropout.pdf`（456,437 B，已校验 `%PDF-`）
- 适用范围：preprint，未经同行评议；针对 GRPO 类在线 RL 的 LLM 推理后训练；不覆盖离线方法与多模态训练。
- 证据等级：A
- 可提炼要点：
  1. 熵坍缩（policy entropy collapse）被归因为「哪些 rollout 参与更新」这一此前较少被操作的自由度：同一采样预算下并非所有 rollout 都对更新有正贡献，选择性排除一部分反而提升学习。
  2. GRPODropout 在标准更新前移除少量**高概率、正优势**的 rollout 并对保留项优势重新居中；只改 rollout 用法，计算开销可忽略，并给出 rollout 级理论分析指导阈值选择。
  3. 实验口径：相对原版 GRPO 用更少 rollout 样本取得更高准确率且保持更高 actor 熵；代码开源（github.com/hexuandeng/GRPODropout）。
- 关闭条件：原件已入库；需读正文第 3~4 节补齐阈值选取口径与基线配置后可关。

## E2 · Fed-GRPO：奖励统计作为联邦训练的零成本信号

- 获取日期：2026-10-09
- 来源 URL：https://arxiv.org/abs/2610.11502
- 本地原件：—
- 适用范围：preprint，未经同行评议；受隐私/合规约束不能集中访问训练数据的 GRPO 场景；实验限于数学推理任务。
- 证据等级：A
- 可提炼要点：
  1. 现有 GRPO 方法隐含「集中访问训练数据」假设；Fed-GRPO 直接复用 GRPO 训练自然产生的奖励统计（均值/标准差）作为聚合、本地训练与通信的零成本信号。
  2. 三个机制：按奖励标准差加权客户端聚合、按本地-全局奖励差距重加权各客户端目标、按更新信息量分配通信带宽（自适应稀疏通信）。
  3. 数学推理实验中优于 FedAvg、接近集中式训练；通信可无损减少 32×，紧带宽下最高 621× 压缩且精度仅温和下降。
- 关闭条件：缺非数学领域（代码/多模态）验证与掉队客户端鲁棒性数据；有后续版本或复现后可关。

## E3 · Residual Advantage：师生概率残差作为有界的一步奖励

- 获取日期：2026-10-09
- 来源 URL：https://arxiv.org/abs/2610.11519
- 本地原件：—
- 适用范围：preprint，未经同行评议；RLVR 与 on-policy 蒸馏（OPD）的融合；实验为 Qwen3 系 1.7B/4B 学生 + 8B 教师、三套数学基准。
- 证据等级：A
- 可提炼要点：
  1. 范式对比口径：RLVR 每个回答只有单一结果标签、步骤无独立信用；OPD 在学生访问过的前缀上给 token 级指导，但点值信号不反映师生在词表上的分歧模式。
  2. RA 把师生概率残差当作**有界**一步奖励，减去学生策略下的状态价值形成标准优势，在每个回答内居中后再叠加到验证器优势上——指导项在回答内零均值，验证器优势仍是回答的均值标签，教师只在步骤间重新分配信用。
  3. 实验：RA 配合 GRPO 或 REINFORCE++ 在三个数学基准的全部 24 组对比中提升底层算法（宏观 Avg@8 +1.7~3.6，Pass@8 +3.9~6.3），均超过纯教师 OPD；CoRA（同批次上用验证器优势更新教师 LoRA）再加 1.0~1.5 Avg@8。
- 关闭条件：缺更大参数模型与非数学任务验证；需评估教师策略偏离学生路径时的失效边界。
