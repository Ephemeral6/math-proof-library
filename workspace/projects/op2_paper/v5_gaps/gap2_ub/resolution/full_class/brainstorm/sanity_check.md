# Sanity Check — Li-Liu-Orabona 2022 Lower Bound 是否 Transfer 到 L-smooth？

## 一句话结论

**不 transfer**——他们的反例 `f(x) = max_{i ∈ [T+1]} h_i^T x` 是 piecewise linear (max of linear)，仅 L-Lipschitz、不可微、显式不满足 L-smooth；因此 fixed-β SHB 的 O(σD/√T) last-iterate conjecture 在 L-smooth convex case 下**仍然存活**，smoothness 是必须显式 leverage 的本质要素。

## 证据

- **构造** (Eq. 2, line 282–291)：`f(x) = max_{i ∈ [T+1]} h_i^T x`，h_i ∈ R^T 显式定义。
- **Lipschitz 而非 smooth** (line 296)："Note that f is L-Lipschitz over R^T"。
- **作者自己的分类** (line 152 summary table)：lower bound 归在 "(H2) + Lipschitz" 行，**不**归在 (H1) L-smooth 行。
- **L-smooth 定义** (H1, line 251)："f is continuously differentiable and its gradient is L-Lipschitz"——max 函数在多个超平面交集处显式不可微，违反 H1。
- **Theorem 1** (line 330–339)：lower bound 显式针对 "the function f in (2)"，即 piecewise-linear 反例。

## 含义

1. User 的 conjecture O(σD/√T) for fixed-β SHB on L-smooth convex non-SC **未被排除**。
2. **任何成功的 proof 必须显式用 smoothness**——例如 descent lemma `f(y) ≤ f(x) + ⟨∇f(x), y-x⟩ + (L/2)‖y-x‖²` 或 co-coercivity `⟨∇f(x)-∇f(y), x-y⟩ ≥ (1/L)‖∇f(x)-∇f(y)‖²`。Elementary routes 失败的根因可能是没有把 smoothness "用透"——只用了 convexity + Lipschitz 不等式，而这些在反例中都成立但仍给 log T。
3. **directions_brainstorm.md 的 Top 3 排序无需修订**：
   - #9 VI / monotone (arXiv 2510.02951) 仍最优先——但要确认其是否用 cocoercivity / smoothness。
   - #15 Supermartingale-Lyapunov 仍可行——design V 时必须含 smoothness 项（如 `(1/L)‖∇f‖²`）。
   - #7 iKM 桥接更明确——`‖∇f‖² ≤ 2L(f - f*)` 是 smoothness only 的关键 lever，正是 bridging step 所需。
