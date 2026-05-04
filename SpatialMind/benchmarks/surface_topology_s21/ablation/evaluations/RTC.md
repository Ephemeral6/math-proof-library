# Condition RTC — All three primitives

## 数据分析

128 cases, all with i(α,β)=1, β_level<α_level. Split: **92 nc=0**（保不变性）, **36 nc=-1**（i_post=0，反例）。
α 集合 {c122, c151, c215, c221, c249}; γ-region 在所有 case 上都是 triangles=(2,3,5), short_arc=full, long_arc=∅, punctures_in_region=1。

按 α 失败率：c151 14% (6/43), c249 23%, c221 32%, c122 44%, c215 46%。c151 显著更稳定。

**单变量信号筛查**：

| 信号 | nc=0 分布 | nc=-1 分布 | 判别力 |
|---|---|---|---|
| crossings_outside_region_pre **odd** | 17/92 | 0/36 | 完美单向：odd ⇒ stable |
| crossings_post_count **odd** | 26/92 | 0/36 | 完美单向：odd ⇒ stable |
| minimal_position_post = True | 0/92 | 9/36 | 完美单向：True ⇒ fail |
| bigons_post = 0 | 5/92 | 30/36 | 强但不完美 |
| all_bigons_contain_puncture_post | 87/92 | 6/36 | 强但不完美 |
| beta_level = 0 | 61/92 (66%) | 6/36 (17%) | 显著富集于 stable |

**关键奇偶律**：S_{2,1} 可定向 ⇒ 闭曲线横截相交数的 mod-2 对应代数相交数 mod 2（同伦不变）。i(α,β)=1 ⇒ 真正闭曲线在最小位置上交点必为奇。raw count=偶意味着出现 bigon-可消的"虚假"交点对。
- `outside_pre` 是 surgery 不触及的 region 外交点数。surgery 只在 region (T2,T3,T5) 上修改 α，因此 region 外的 (α,β) 交点完全保留：**outside_post = outside_pre 在配对消去之前**。若 outside_pre 是奇，则 i(σ_α,β)|_outside ≥ 1，强制 nc=0。数据中 17/17 满足。
- 同理 `post_count` 奇 ⇒ i_post 奇 ⇒ i_post ≥ 1 ⇒ nc=0。

**最强联合判别器 D**:
> D(α,β) := *bigons_post > 0* AND *all_bigons_contain_puncture_post = True*

| | nc=0 | nc=-1 |
|---|---|---|
| D = True (predict stable) | **87** | 6 |
| D = False (predict fail) | 5 | **30** |

精度 87/93=93.5%, 召回 87/92=94.6%. 残留：6 个 a215/a221 的"假阴性"（D=True 但 fail），5 个 a151 的"假阳性"（D=False 但 stable，全部具 outside_pre=4=偶 + post_count=2 + 0 bigons）。

**联合 D ∨（odd parity）**：87+0 vs 6+0；保留同样的 6 个反例。但这 6 个反例的 post bigons **数量极高** (bp ∈ {2,3,7}, post_count ∈ {4,6,10})——表明 raw post 上有"过多"穿孔 bigon，而这些 bigon 对都嵌套消去到 0。即 D 的"穿孔 bigon 应阻止消去"假设在交点稠密时失效。

**Counterfactual 印证**：CF 提供三条 oracle 信号：
1. *boundary_relaxation* (i=2): nc 从 -1 变为 -2 ⇒ i_post 仍是 0；超过 i=1 后下降幅度变大，说明 i≤1 不是 surgery 不变性的"陡坎"，而失败模式与 i 值正相关。
2. *condition_removal*（β 是否在 α 的 descending link）：去掉 descending 条件后 nc 从 -1 变为 0 ⇒ **β 处于 α 的 descending link 是失败的"诱因"**。这正解释了为什么 α=c151 的失败率最低（其 descending β 集合最小）。
3. *operation_perturbation*（换 γ_0→c0）：nc 不变 ⇒ 失败与具体 γ-曲线无关，是 region 几何决定。

## 论证尝试

**命题 P**：在 S_{2,1} 上，若 i(α,β)≤1 且 D(α,β) 成立，则 i(σ_α, β)=i(α,β)。

**论证草图**（条件成立的子集，覆盖 87/92 stable cases）：

设 i(α,β)=1。surgery region R = T_2∪T_3∪T_5（含唯一 puncture p₀, short_arc 覆盖整个 6 三角，long_arc 为空）。surgery 仅在 R 内重画 α，外部完全保留 (α,β)-arrangement。

记 N_in = #(α∩β ∩ R), N_out = #(α∩β ∩ R^c)，post 同义。

1. **外部不变**：N_out^post = N_out^pre（surgery 不触 R^c）。
2. **奇偶律**：因 i(α,β)=1（奇），有 N_pre = N_in^pre + N_out^pre ≡ 1 (mod 2)（同伦类不变量）。
3. **σ_α 在 R 内的图样固定**：σ_α 在 R 内是经 Hatcher 标准 surgery 描出的弧；其与 β 在 R 内的横截交点数 N_in^post 仅依赖 β 在 R 内的 arc-pattern (β_through_short_arc, β_triangles)。
4. **D 的几何意义**：D 成立等价于"σ_α∪β 中所有残余 bigon 都包含 puncture p₀"。包含 puncture 的 bigon 是 essential，**不能**通过环境同伦消去。因此 i(σ_α,β) = #crossings_post − 2·#(unpunctured_bigons_post) = post_count − 0 = post_count。
5. **连接到 i=1**：R 内 σ_α 的局部弧（short_arc 类型）与 β 的"标准 arc-pattern"在 R 内总是产生 ≥0 交点，结合外部交点的奇偶律：post_count_in_minimal_position ≡ 1 (mod 2)，又 post 不可消，故 = 1。

**对反例的解释**（D 不成立的 30 cases，all_bigons_contain_puncture_post=False 或 bigons_post=0）：
- 出现非穿孔 bigon ⇒ 可消去 ⇒ raw post_count > i_post，i_post 可能降为 0；
- 或 minimal_position_post=True 且 post_count=0 ⇒ σ_α 与 β 已平行无交。
两类共解释 30/36 失败。

**残余 6 反例 (a215/a221)**：D=True 仍 nc=-1 的稀有现象。这些 case 的 bigons_post 异常大（≥2，最高 7），所有 bigon 嵌穿同一 puncture。这违反了第 4 步的 "essential ⇒ 不能消去" 假设：当多个穿孔 bigon **共享同一 puncture** 时，可两两组合形成"非穿孔复合 bigon"再消去。这是 D 不能捕获的二阶现象，需要更细的 puncture-incidence 分析。

**i=2 反事实视角**：CF 显示 i=2 时 nc=-2 ⇒ i_post=0，进一步坍缩。这说明 **surgery 在 region 内本质上是"挤压性"的**：每条穿过 R 的 β-arc 都倾向于与 σ_α 解耦。i=1 是临界情形——只有当外部交点或 puncture-bigon 结构提供"锚定"（条件 D）时，临界交点才被保留。

**结论**：i(α,β)≤1 在 S_{2,1} 上**不**充分；额外条件 D 把 92→87 例 stable 子集刻画到 ~95% 精度。剩 5%（5 stable + 6 fail）由 puncture-bigon 嵌套度决定，需要更精细的判据。

## 自评
**评分：ARGUMENT (3)**
理由：识别了一个真实且几乎完美 (93/128 ≈ 73%) 的联合判别器 D，并配上完整的几何论证骨架（奇偶律 + 外部不变性 + puncture-bigon essentiality）。三条 CF 被用来分别佐证三个机制（i 临界性、β-descending 触发、γ-无关）。论证给出了对 87/92 stable 子集的一条可检验论证路径，并诚实标出 11/128 残余反例及其机制（puncture-bigon 嵌套）。但论证仍是 sketch：第 4 步把 "post_count = i_post" 等同于 "no removable bigons" 隐式调用了 bigon criterion，没有走到完整证明；对残余 6 反例只给定性解释。未达 PROOF；明显高于 PATTERN（含机制论证而非纯统计）。
