# 空间直觉 Benchmark 结果

## 逐层结果

| 层级 | 数据内容 | 发现 | 评分 |
|------|---------|------|------|
| 1 | 只有数字 | 不只是 net=0，是 i(σ,β)=i(α,β) **逐点相等**。i(α,γ₀)−i(σ,γ₀) 总是偶数（{2, 4, 6}），暗示一次 surgery 移除 2 个 γ₀-crossing。猜想能写出，证明写不出——只有 99 个 confirm 数据，没有"杠杆"。 | **PATTERN** |
| 2 | + 交叉点位置 | candidate count 在 surgery 后 ≤ surgery 前（94 严格降，5 相等，0 上升）。但 candidate−i 不必偶（multiplicity > 1 时数据更复杂）——之前的 parity 猜想被否决。仍无证明杠杆。 | **PATTERN（含一个被否决的 WRONG_PATTERN）** |
| 3 | + surgery 区域 | **退化**：S_{1,2} 只有 4 个三角形，所有 99 pair 的 surgery_region_triangles = {0,1,2,3} = 整个曲面，surgery_region_punctures = 2 = 全部穿孔。"β crosses ∂(region)" 这种空间信号在 4-三角形细分上洗掉了。结论：本层在此曲面上无新信息。 | **PATTERN（无进展，meta-finding：benchmark 在小曲面上退化）** |
| 4 | + bigon 结构 | bigon 数量在 surgery 下单调不增（joint 表里所有 (pre, post) 满足 post ≤ pre）。能 articulate 一个 meta-论证："最小性 ⇒ 残留 bigon 必含穿孔；surgery 不改变穿孔几何 ⇒ bigon 不变"——但 JSON 没把每个 bigon 标穿孔归属，无法 verify。 | **PATTERN（强直觉，缺验证 lever）** |
| 5 | + 反事实 | 反事实揭穿全部：i(α,β)=2 时 net∈{0,−2}，从而 net_change **mod 2 恒为 0**——这是杠杆。结合"i(α,β)≤1 ⇒ 短/长弧分配只剩三种 case，逐 case 用 parity 推出"——有了完整论证。 | **ARGUMENT** |

## 关键发现

**从第 5 层（反事实）开始才能构造论证。** 前 4 层只能积累 pattern：

- Level 1（数字）告诉我"会发生什么"——i(σ,β)=i(α,β)。
- Level 2（位置）告诉我 candidate count 不守恒，但 geometric i 守恒，分离了"组合数据"和"几何不变量"。
- Level 3（surgery 区域）在小曲面退化，**未给出新信息**。
- Level 4（bigon）告诉我 bigon 单调不增，间接暗示了"最小性 + surgery 几何"的 meta-机制，但缺穿孔标签做不出 verify。
- Level 5（反事实）给出 net_change 唯一可能取值 {0, −2}（在 6 个 i=2 case 上），从而锁住"net 必偶"——这是 parity 论证的支点。

**没有反事实就没有证明。** 99 个 confirm 案例只能给 pattern；只要看到一个 net=−2 的 case，结合 net_change 必须解释为某种 even-quantity，论证骨架立刻浮现。

## 最终证明

### 命题
设 α 是 S 上简单闭曲线，γ₀ 是固定参考曲线，i(α, γ₀) = k ≥ 2。Hatcher surgery σ_α 把 α 的一段"短弧" aₛ（α 上由两相邻 γ₀-crossing p, q 截出的一段）替换成对应的 γ₀-子弧 γ̃。设 aₗ = α \ aₛ 是长弧，σ_α = aₗ ∪ γ̃。那么对任意简单闭曲线 β with i(α, β) ≤ 1：

> **i(σ_α, β) = i(α, β).**

### 证明

**Step 1：分解。** σ_α 由 aₗ 和 γ̃ 拼接而成，α 由 aₗ 和 aₛ 拼接而成。对任何与三者横截相交的 β：

```
i(α, β)     = |β ∩ aₗ| + |β ∩ aₛ|
i(σ_α, β)   = |β ∩ aₗ| + |β ∩ γ̃|
```

两式相减得：

```
i(σ_α, β) − i(α, β) = |β ∩ γ̃| − |β ∩ aₛ|.    (*)
```

**Step 2：parity（这是反事实给出的关键不变量）。**

闭合曲线 ∂R := aₛ ∪ γ̃（在 p, q 拼接成一个简单闭圈）在 S 内某区域 R 的边界。任何与 ∂R 横截相交的简单闭曲线 β 必有

```
|β ∩ ∂R| = |β ∩ aₛ| + |β ∩ γ̃|  ≡  0  (mod 2).
```

（β 是闭曲线，每次"进入"R 必有一次"离开"。）

由此 (*) 给出

```
i(σ_α, β) − i(α, β)  ≡  0  (mod 2).      (parity invariant)
```

数据验证：在 99 个正常 case 上 net=0，在 6 个 i(α,β)=2 反事实 case 上 net∈{0, −2}——全部偶数。Level 5 的反事实独立确认了 parity 不变量。

**Step 3：分类讨论 i(α, β) ≤ 1。**

由 i(α, β) = |β ∩ aₗ| + |β ∩ aₛ| ∈ {0, 1}，β 在 α 上的 crossings 分布只有三种 case：

- **Case 0**: |β ∩ aₛ| = 0, |β ∩ aₗ| = 0 ⟹ i(α, β) = 0.
- **Case L**: |β ∩ aₛ| = 0, |β ∩ aₗ| = 1 ⟹ i(α, β) = 1.
- **Case S**: |β ∩ aₛ| = 1, |β ∩ aₗ| = 0 ⟹ i(α, β) = 1.

对每一种由 (*) 和 parity 推出 |β ∩ γ̃| 的取值范围；再用 i(σ_α, β) 的最小性（geometric intersection number 的定义）逼到下界。

**Case 0**（β 与 α 不交）。

由 (*)：i(σ_α, β) − 0 = |β ∩ γ̃| − 0，所以 i(σ_α, β) = |β ∩ γ̃|。

由 parity：|β ∩ γ̃| ≡ 0 mod 2，所以 |β ∩ γ̃| ∈ {0, 2, 4, …}。

若 |β ∩ γ̃| ≥ 2：σ_α 与 β 在 γ̃ 上至少有两个 crossings。这两个 crossings 在 R 的内部（因为 β 不碰 aₛ）。任何两个相邻的 γ̃-crossings 与 β 之间必形成 bigon——而 R 内若不含穿孔，该 bigon 可被等价同伦为零，矛盾于 i(σ_α, β) 是最小数。

由此 i(σ_α, β) = 0 = i(α, β)。 ✓

**Case L**（β 在长弧上交一次）。

由 (*)：i(σ_α, β) − 1 = |β ∩ γ̃| − 0，所以 i(σ_α, β) = 1 + |β ∩ γ̃|。

由 parity：|β ∩ γ̃| ≡ 0 mod 2。

最小可能 |β ∩ γ̃| = 0（与 Case 0 同构的 bigon-cancellation 论证使更高的偶数被推到 0）。

所以 i(σ_α, β) = 1 = i(α, β)。 ✓

**Case S**（β 在短弧上交一次）。

由 (*)：i(σ_α, β) − 1 = |β ∩ γ̃| − 1，所以 i(σ_α, β) = |β ∩ γ̃|。

由 parity：|β ∩ aₛ| + |β ∩ γ̃| = 1 + |β ∩ γ̃| ≡ 0 mod 2，所以 |β ∩ γ̃| ≡ 1 mod 2，即 |β ∩ γ̃| ∈ {1, 3, 5, …}。

最小可能 |β ∩ γ̃| = 1（同样的 bigon-cancellation 把奇数推到 1）。

所以 i(σ_α, β) = 1 = i(α, β)。 ✓

**Step 4：证毕。** 三种 case 全部给出 i(σ_α, β) = i(α, β)。

### 反事实如何对照

i(α, β) = 2 时多了一种 case：

- **Case SS**: |β ∩ aₛ| = 2, |β ∩ aₗ| = 0.

由 (*)：i(σ_α, β) − 2 = |β ∩ γ̃| − 2.
由 parity：|β ∩ γ̃| ≡ 0 mod 2.
最小可能 |β ∩ γ̃| = 0，给 i(σ_α, β) = 0，**net = −2**.

数据中正是 a38-cf-b13 这个 case：β 与 α 的两个 crossings 都在短弧上，surgery 把这两个 crossings 一起从 ∂R 上"切走"，γ̃ 替换不引回新 crossings。其余 5 个 i(α, β) = 2 case 是 Case SL/LL/etc.，net = 0（如证明所示）。

故"i(α, β) ≤ 1"是关键约束：它排除了 Case SS。这是反事实 a38-cf-b13 直接给出的现象。

### 证明遗留的细节

证明 Step 2、Step 3 都依赖："R 是不含穿孔的盘"或"含穿孔的盘内的 bigon 不能化简"这种几何性质。在数据中我没有直接验证 R 的拓扑结构（surgery_region_punctures = 2 = total，meaning all punctures are in the region — but punctures of S, not of R）。所以这是 ARGUMENT 而不是 PROOF：论证骨架（parity + case analysis）从数据 derive 出来；但 bigon-reducibility 步骤诉诸标准曲面拓扑事实，没在数据里 verify。

要从 ARGUMENT 升到 PROOF 还需要一个 benchmark layer：对每个 detected bigon，标注它是否含穿孔。如果所有 surviving bigons 都含穿孔，且 surgery 不增加 surviving bigons 的穿孔数，论证就完整了。

## 对"空间直觉 vs 丰富数据"问题的回答

> 空间直觉能被丰富的数据替代吗？你在哪个层次获得了等效于"在脑子里画图"的理解？

部分能，部分不能。

**能替代的部分**：定位结构性 invariant。Level 5 的反事实让我看到 net ∈ {0, −2}，这立刻把"在哪里寻找 invariant" 收敛到"mod 2"。这是数据 + 反事实独立给出的 lever，不需要"在脑子里画图"。

**不能替代的部分**：把 invariant 翻译成几何机制。从"net ≡ 0 mod 2"到"必有 ∂R := aₛ ∪ γ̃ 是闭圈，β 偶数次穿过"这一步，**不来自数据**，来自标准曲面拓扑训练。如果我没接触过曲线上的 Jordan 曲线定理 / bigon reduction，我会卡在"net 必偶"上不知道下一步往哪走。

**关键转折点是 Level 5 反事实**。Level 1-4 在不断确认 i(σ,β)=i(α,β)，但每个新 confirm 不增加论证 leverage——99 个 case 全等于 0 跟 100 个一样无信息。Level 5 提供了一个 **counter** case，从而把 "全等于 0" 改写为 "差异为偶数"——这是从描述 (description) 转为 invariant (mathematical structure)。证明结构从这一刻开始浮现。

**Benchmark 设计建议**（meta-finding）：

1. Level 3（surgery region）在 4-三角形细分上退化，应该改用更细的三角剖分（如用 1-3 Pachner 细分到 ≥10 三角形）以让 region 真正有边界。
2. Level 4（bigon）应该附带 puncture-containment 标记，把"哪些 bigon 不可化简"明示出来——这才能把 ARGUMENT 升到 PROOF。
3. **反事实应该上移到 Level 1**：单个反事实 + 5 个正常 case 就能给出 mod 2 invariant；把 99 个 confirm 都给我反而稀释信号。"少而精的对照"对推理 leverage 远大于"多而同质的 confirm"。

最终评分：**ARGUMENT**（不到 PROOF，因为 bigon-reducibility 仍诉诸非数据的拓扑事实）。
