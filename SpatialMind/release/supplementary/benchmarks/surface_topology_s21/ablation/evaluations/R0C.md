# Condition R0C — Relation + Contrastive

## 数据分析

128 cases: 92 net=0 (valid), 36 net=-1 (反例). 全部 case 都满足 i_alpha_beta=1（边界）。

**按 net_change 分层 R-features**（剔除 trivial 的 bigon_with_puncture：两组 bigons_without_puncture_pre 全为 0，即所有 pre-bigon 都是 puncture bigon，无信息量）：

| Feature | NET=0 (92) | NET=-1 (36) |
|---|---|---|
| crossings_outside_region_pre = 0 | 0 | 6 |
| crossings_outside_region_pre ≥ 1 | 92 | 30 |
| bigons_post = 0 (全部 bigon 被消) | 5 | 30 |
| bigons_post ≥ 1 (有残留 bigon) | 87 | 6 |
| minimal_position_post = True | 0 | 9 |
| minimal_position_post = False | 92 | 27 |

最干净的二分：
- **bigons_post**：NET=0 几乎总有残留 bigon (87/92=94.6%)；NET=-1 几乎总把 bigon 全消 (30/36=83.3%)。
- **minimal_position_post**：NET=0 永远=False；NET=-1 有 9 个=True。完美单向蕴含：minimal_position_post=True ⇒ net=-1。
- 典型 NET=0 模式：(in_region: 12→0, outside: 6→4) — region 内 crossing 全清，但 region 外保留对偶，刚好抵消。
- 典型 NET=-1 模式：(in: x→0, outside: 2→2) 或 (in: x→0, outside: 6→0) — bigon 被彻底清空。

**CF (i=2 反事实)**：boundary_relaxation 把 i(α,β)=1 抬到 i(α,β)=2，net 从 -1 变 -2 (delta=-1)。说明：i=2 时即便保留 R-条件，仍然 reflux，且更严重；boundary 不"卡"在 i=1，i=1 已经在反例区。condition_removal（去掉 descending link）把 net 从 -1 翻到 0：descending_link 是 *fail* 方向的关键，去掉就能稳。operation_perturbation（换 surgery curve）net 不变。

## 论证尝试

**Claim**：在 S_{2,1} 上，i(α,β)≤1 不足以保 surgery 不变性；额外需要的限制是 *post-surgery 的 puncture bigon 至少保留一个*（等价：surgery 后非 minimal_position）。

**机制**（从数据推）：S_{2,1} 上 surgery region 仅占 3/6 三角形，β 与 region 关系可分。
- 若 β 完全落在 region 内（outside=0，6 个 case）：surgery 把所有 crossing 一并消，region 内 bigon 全部撤销，没有 region 外的对偶 crossing 来补，→ net=-1 必发生。
- 若 β 同时穿过 region 内外（outside≥1，绝大多数）：region 外 crossing 不动，**当且仅当**这些"外部 crossing"参与某个 puncture bigon（bigons_post≥1），surgery 才在 i 上给出 0 净变；否则 puncture bigon 都被消（bigons_post=0），post 进入 minimal_position，i 净降 1。

**限制约束（limiting R-feature）**：在 i(α,β)≤1 之上，区分 valid 与 reflux 的最紧约束是 **bigons_post ≥ 1**（同义：post 不进入 minimal_position）。这本质上是"surgery 之后仍存在 puncture bigon 提供的额外环绕量"，对应 Hatcher surgery 在 punctured-genus-2 上保 i 的真正条件——*β 关于 puncture 的环绕在 surgery 后必须有保留*。

**与 CF 的吻合**：i=2 反事实 net=-2，即每条额外 crossing 都对 i 贡献一份 reflux；说明该机制是 *crossing-by-crossing* 的，不是某个全局拓扑奇点。bigons_post 这个量化 R-feature 正好抓住了"哪些 crossing 在 surgery 后还被 puncture bigon 锁住"。

## 自评

**评分：PATTERN+ (2)**

理由：
- 找到了清晰的二分 R-feature（bigons_post / minimal_position_post），96% accuracy 区分两类 case；这远超 NO_SIGNAL 或 WRONG_PATTERN。
- 把 CF 的 boundary_relaxation 与 R-feature 串起来给出了一致解释（crossing-wise reflux）。
- 但这只是 *相关性级别*的刻画：我没有给出"为什么 surgery 必然消所有非外部 puncture bigon"的几何证明，也没从 surgery region 占 3/6、descending link 等数据外的结构推出 bigons_post≥1 的充分条件。i.e. 我描述了"valid 的 case 长什么样"，没构造"满足 X 蕴含 valid"的论证。
- 与 S_{1,2} 上 PATTERN+ 持平：那里也是抓到 bigon-相关 invariant 但未达 ARGUMENT 的可证级别。这里没有 Transform primitive，所以无法谈 surgery 局部轨迹，进一步限制了升到 ARGUMENT 的可能。
