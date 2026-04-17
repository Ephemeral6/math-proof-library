# Proof: SPIDER/SARAH Non-convex Complexity

## Setup

**问题**: $f(x) = \frac{1}{n}\sum_{i=1}^n f_i(x)$，每个 $f_i$ 是 $L$-smooth，$f^* > -\infty$。

**算法**: SPIDER/SARAH，epoch 长度 $q$，步长 $\eta$，epoch 数 $S$。每个 epoch 起始计算全梯度 $v_0 = \nabla f(x_0)$，epoch 内递推 $v_{t+1} = \nabla f_{i_{t+1}}(x_{t+1}) - \nabla f_{i_{t+1}}(x_t) + v_t$，更新 $x_{t+1} = x_t - \eta v_t$。

## Lemma 1 (Variance recursion)

记 $e_t = v_t - \nabla f(x_t)$。在一个 epoch 内:

(i) $e_0 = 0$

(ii) $\mathbb{E}[\|e_t\|^2] \leq L^2\eta^2\sum_{j=0}^{t-1}\mathbb{E}[\|v_j\|^2]$

**Proof**: 写 $e_t = \delta_t + e_{t-1}$，其中 $\delta_t = [\nabla f_{i_t}(x_t) - \nabla f_{i_t}(x_{t-1})] - [\nabla f(x_t) - \nabla f(x_{t-1})]$。

由 $\mathbb{E}[\delta_t \mid \mathcal{F}_{t-1}] = 0$ 且 $e_{t-1} \in \mathcal{F}_{t-1}$，交叉项消失:
$$\mathbb{E}[\|e_t\|^2 \mid \mathcal{F}_{t-1}] = \|e_{t-1}\|^2 + \mathbb{E}[\|\delta_t\|^2 \mid \mathcal{F}_{t-1}]$$

由 $\text{Var}(X) \leq \mathbb{E}[\|X\|^2]$ 和 individual $L$-smoothness:
$$\mathbb{E}[\|\delta_t\|^2 \mid \mathcal{F}_{t-1}] \leq L^2\|x_t - x_{t-1}\|^2 = L^2\eta^2\|v_{t-1}\|^2$$

从 $e_0 = 0$ 递推得 (ii)。$\square$

## Lemma 2 (Per-step descent)

由 $L$-smoothness，分解 $v_t = \nabla f(x_t) + e_t$，用 Young's inequality 和 $\|a+b\|^2 \leq 2\|a\|^2 + 2\|b\|^2$:

当 $\eta \leq \frac{1}{4L}$:
$$\mathbb{E}[f(x_{t+1})] \leq \mathbb{E}[f(x_t)] - \frac{\eta}{4}\mathbb{E}[\|\nabla f(x_t)\|^2] + \frac{3\eta}{4}\mathbb{E}[\|e_t\|^2]$$

**推导**: $f(x_{t+1}) \leq f(x_t) - \eta\|\nabla f(x_t)\|^2 - \eta\langle\nabla f(x_t), e_t\rangle + \frac{L\eta^2}{2}\|\nabla f(x_t) + e_t\|^2$。

$-\langle a, b\rangle \leq \frac{1}{2}\|a\|^2 + \frac{1}{2}\|b\|^2$ 给出 $-\eta\langle\nabla f, e\rangle \leq \frac{\eta}{2}\|\nabla f\|^2 + \frac{\eta}{2}\|e\|^2$。

$\frac{L\eta^2}{2}\|a+b\|^2 \leq L\eta^2\|a\|^2 + L\eta^2\|b\|^2$。

合并: 系数 $-\eta + \frac{\eta}{2} + L\eta^2 = -\frac{\eta}{2} + L\eta^2$ 对 $\|\nabla f\|^2$；$\frac{\eta}{2} + L\eta^2$ 对 $\|e\|^2$。

$\eta \leq 1/(4L)$ 时: $\eta/2 - L\eta^2 \geq \eta/4$, $\eta/2 + L\eta^2 \leq 3\eta/4$。$\square$

## Main Proof

### Epoch-level descent

对 Lemma 2 在一个 epoch 内 $t = 0, ..., q-1$ 求和，记 $G = \sum_t\mathbb{E}[\|\nabla f(x_t)\|^2]$, $V = \sum_t\mathbb{E}[\|e_t\|^2]$:

$$\mathbb{E}[f(x_q)] \leq f(x_0) - \frac{\eta}{4}G + \frac{3\eta}{4}V$$

### Variance absorption

由 Lemma 1，交换求和，用 $\|v_j\|^2 \leq 2\|\nabla f(x_j)\|^2 + 2\|e_j\|^2$:
$$V \leq 2L^2\eta^2 q(G + V)$$

当 $2L^2\eta^2 q \leq 1/2$: $V \leq 4L^2\eta^2 q \cdot G$。

代入: $\mathbb{E}[f(x_q)] \leq f(x_0) - (\frac{\eta}{4} - 3L^2\eta^3 q) G$

### Parameter choice

取 $\eta = \frac{1}{10L\sqrt{q}}$, $q = \lfloor\sqrt{n}\rfloor$:

- $\eta \leq 1/(4L)$ ✓, $2L^2\eta^2 q = 1/50 \leq 1/2$ ✓
- 下降系数: $\frac{\eta}{4} - 3L^2\eta^3 q = \frac{22}{1000L\sqrt{q}} > 0$

### Multi-epoch telescoping

$S$ 个 epochs，tower property 保证:
$$\frac{22}{1000L\sqrt{q}}\sum_{\text{all}}\mathbb{E}[\|\nabla f(x_t)\|^2] \leq \Delta_f$$

输出均匀随机选取: $\mathbb{E}[\|\nabla f(\hat{x})\|^2] \leq \frac{1000L\sqrt{q}\Delta_f}{22T}$

$T = O(L\sqrt{q}\Delta_f / \epsilon^2)$ 即可。

### Complexity

每 epoch: $n + 2q$ 次梯度评估。$S = T/q$ 个 epoch。

$$\text{Total} = S(n+2q) = O\left(\frac{L\Delta_f(n+2q)}{\sqrt{q}\epsilon^2}\right)$$

取 $q = n$: $= O\left(\frac{L\sqrt{n}\Delta_f}{\epsilon^2}\right)$。

$$\boxed{O\left(n + \frac{\sqrt{n}}{\epsilon^2}\right)}$$

（$L, \Delta_f$ 视为常数。）

### Comparison with SGD

SGD 非凸: $O(\sigma^2/\epsilon^4) = O(1/\epsilon^4)$。SPIDER 通过方差递推将有效方差从 $\sigma^2$ 降为 $O(1/q)$，代价是每 $q$ 步一次全梯度，$q = \sqrt{n}$ 时达到最优 trade-off。$\blacksquare$
