# Notes: SARAH/SPIDER Non-convex Complexity

## Proof technique
**Winning route**: Route 3 — Epoch-level analysis with clean variance control

核心方法是将 SPIDER 的方差递推与 descent lemma 结合，在 epoch 层面进行 telescoping。关键技巧是 **variance absorption**——将方差累积项用梯度范数的和来控制，然后合并同类项。

选择 Route 3 的原因: 结构最清晰，参数选择一次成功，条件验证完整。Route 1 的参数选择第一次失败（系数恰好为零），Route 2 的 Lyapunov 方法最终退化为 epoch-level 分析。

## Key steps
1. **方差递推 (Lemma 1)**: $e_t = \delta_t + e_{t-1}$，其中 $\delta_t$ 零均值且与 $e_{t-1}$ 条件独立，交叉项消失。Individual smoothness 给出 $\mathbb{E}[\|\delta_t\|^2] \leq L^2\eta^2\|v_{t-1}\|^2$。

2. **下降引理 (Lemma 2)**: 标准 descent + Young's inequality 处理交叉项，$\|a+b\|^2 \leq 2\|a\|^2 + 2\|b\|^2$ 处理二次项。$\eta \leq 1/(4L)$ 确保梯度项系数为正。

3. **方差吸收**: $V \leq 2L^2\eta^2 q(G + V)$，当 $2L^2\eta^2 q$ 足够小时 $V \leq 4L^2\eta^2 q \cdot G$。这一步是整个证明的核心——它表明 epoch 内的累积方差可以被梯度范数控制。

4. **参数平衡**: $\eta = \Theta(1/(L\sqrt{q}))$ 使下降系数为 $\Theta(\eta)$；$q = \sqrt{n}$ 平衡全梯度代价 $n/\sqrt{q}$ 和 epoch 内代价 $\sqrt{q}$。

## Audit result
**PASS** — 所有步骤正确。关键验证点:
- 方差递推中交叉项消失的条件
- $\text{Var}(X) \leq \mathbb{E}[\|X\|^2]$ 的使用
- 参数条件的同时满足性
- Multi-epoch telescoping 中 tower property 的使用

## Related results
- **SVRG** (Johnson & Zhang 2013): 凸情形下的方差缩减，epoch 结构类似但分析不同
- **SARAH** (Nguyen et al. 2017): SPIDER 的前身，递推估计器相同
- **SGD non-convex** (Ghadimi & Lan 2013): $O(1/\epsilon^4)$ 的基准结果
- **STORM** (Cutkosky & Orabona 2019): 无需知道 $n$ 的自适应方差缩减
- **PAGE** (Li et al. 2021): 概率性梯度估计，达到相同最优复杂度
- 本库中的 **SVRG linear convergence** (`proofs/optimization/stochastic/svrg-linear-convergence-abc-framework/`): 凸情形的方差缩减分析
