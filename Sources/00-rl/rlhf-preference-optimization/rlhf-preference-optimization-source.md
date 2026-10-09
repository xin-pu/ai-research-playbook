# rlhf-preference-optimization · RLHF 与偏好优化

> 归属域：`Sources/00-rl`。提炼去向：未提炼（候选：`knowledge-base/solutions/01-强化学习方法`）。
> 本箱收录 RLHF/NLHF/多目标偏好优化的方法与评测；策略优化算法细节见 [policy-optimization-source.md](../policy-optimization/policy-optimization-source.md)。

## 证据索引

| 编号 | 主题 | 等级 | 获取日期 | 原件 | 状态 |
|---|---|---|---|---|---|
| E1 | GLHF：分组条件策略的失真（distortion）保证 | A | 2026-10-09 | `originals/arxiv-2610.05450-groupwise-preference-guarantees.pdf` | 未提炼 |
| E2 | MAESTRO：对抗偏好分布上的端到端多目标对齐 | A | 2026-10-09 | — | 未提炼 |
| E3 | RLHF 用于人机协作的范围综述（PRISMA，20 篇） | A | 2026-10-09 | — | 未提炼 |

## E1 · Groupwise Distortion Guarantees（GLHF）：比较数据能否支撑社会福利最大化

- 获取日期：2026-10-09
- 来源 URL：https://arxiv.org/abs/2610.05450
- 本地原件：`originals/arxiv-2610.05450-groupwise-preference-guarantees.pdf`（723,951 B，已校验 `%PDF-`）
- 适用范围：preprint，未经同行评议；理论为主（individual Bradley–Terry 比较假设），实验为人类咖啡评分与合成 LLM 评分；不覆盖非比较型反馈（评分、RLVR）。
- 证据等级：A
- 可提炼要点：
  1. 核心口径：仅靠成对比较本身不必能识别「最大化社会 welfare（平均基数效用）」；用 GHY 的 distortion 指标（最优固定彩票与学习到的彩票的福利最坏比）衡量这一缺口，NLHF 在人人同一彩票时最优。
  2. 账户级 LLM 可以对不同用户给不同彩票：GLHF 用每用户一次比较学一个分组条件策略，在预设（可重叠）各组上同时渐近达到 GHY 最优总体失真界，样本复杂度随组数对数增长、随最小组质量反比增长。
  3. 实验：GLHF 在每个评测组都降低失真，相对 NLHF 与组无关基线大幅降低最坏组失真。
- 关闭条件：需读正文确认实现依赖（分组元数据从何而来）与规模上限；有同行评议版本后可关。

## E2 · MAESTRO：对抗偏好分布上的多目标对齐

- 获取日期：2026-10-09
- 来源 URL：https://arxiv.org/abs/2610.04845
- 本地原件：—
- 适用范围：preprint，未经同行评议；至多三目标的多目标对齐（MOA），基准为 HH-RLHF、BeaverTails 与摘要任务。
- 证据等级：A
- 可提炼要点：
  1. 问题口径：helpfulness/harmlessness/humor 相互权衡且用户偏好各异；现有 MOA 方法（每偏好一模型、事后插值若干专家、单条件模型固定训练分布）会漏训偏好单纯形的困难区域。
  2. MAESTRO 把 MOA 形式化为偏好分布上的 minimax 问题：单个 prompt 条件策略端到端 RL 训练，对抗的 Dirichlet 偏好分布用 online mirror descent 朝「当前策略服务最差的偏好」更新。
  3. 单次训练跑出多数任务上最优 Pareto 前沿、且在对比方法中训练成本最低；最大优势恰好出现在固定分布漏训的困难区域。
- 关闭条件：缺 >3 目标的扩展性证据与在线部署反馈；有后续实验后可关。

## E3 · RLHF 用于人机协作的范围综述与反馈时机实验

- 获取日期：2026-10-09
- 来源 URL：https://arxiv.org/abs/2610.09891
- 本地原件：—
- 适用范围：preprint（综述部分按 PRISMA 筛 199 条、纳入 20 篇 2020–2025 同行评议文献）；场景限定人机协作（HRC），实验为 VR 环境的机器人近距行为导航任务。
- 证据等级：A
- 可提炼要点：
  1. 首个聚焦 RLHF 双向闭环设计的综述：反馈形态多样（多模态），数据可注入训练不同阶段形成多步开发流程；三大未解问题为开发期安全、反馈质量、人机双向适应。
  2. 对照实验结论：**用户发起**的反馈比系统发起的反馈更能捕捉感知安全（psychological safety），说明反馈时机直接影响反馈质量——这对 RLHF 数据采集设计是可操作结论。
  3. 方法学提示：HRC 的 RLHF 研究应优先做真实闭环实验，并同时报告人侧与机器人侧指标（如 inverse time-to-collision）。
- 关闭条件：结论限定在 HRC/VR 场景，迁移到 LLM 对齐需另证；缺其它实验室的重复研究。
