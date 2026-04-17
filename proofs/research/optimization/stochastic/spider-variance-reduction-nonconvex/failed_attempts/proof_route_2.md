# Route 2: Lyapunov Function / Potential-based Analysis

## Setup

**有限和问题**: $f(x) = \frac{1}{n}\sum_{i=1}^n f_i(x)$

**假设 (A1)**: 每个 $f_i$ 是 $L$-smooth:
$$\|\nabla f_i(x) - \nabla f_i(y)\| \leq L\|x - y\|, \quad \forall x, y, \forall i \in [n]$$

**假设 (A2)**: $f$ 有下界: $f^* = \inf_x f(x) > -\infty$。

**SPIDER 算法**:

**Outer loop**: $s = 1, 2, ..., S$ epochs
- 设 $x_0^{(s)}$ 为第 $s$ 个 epoch 的起始点（$x_0^{(1)}$ 为初始点，$x_0^{(s+1)} = x_q^{(s)}$）
- 计算全梯度: $v_0^{(s)} = \nabla f(x_0^{(s)})$

**Inner loop**: $t = 0, 1, ..., q-1$
- $x_{t+1} = x_t - \eta v_t$
- $v_{t+1} = \nabla f_{i_{t+1}}(x_{t+1}) - \nabla f_{i_{t+1}}(x_t) + v_t$，$i_{t+1} \sim \text{Uniform}([n])$

## 核心引理

### 引理 1 (方差递推)

记 $e_t = v_t - \nabla f(x_t)$。在一个 epoch 内:

(a) $\mathbb{E}[e_t \mid \mathcal{F}_{t-1}] = e_{t-1}$（鞅性）

(b) $\mathbb{E}[\|e_t\|^2 \mid \mathcal{F}_{t-1}] \leq \|e_{t-1}\|^2 + L^2\|x_t - x_{t-1}\|^2$

(c) $e_0 = 0$

**证明**: 

(c) 显然，因为 $v_0 = \nabla f(x_0)$。

(a) $\mathbb{E}_{i_t}[v_t] = \nabla f(x_t) - \nabla f(x_{t-1}) + v_{t-1}$，所以:
$$\mathbb{E}_{i_t}[e_t] = \mathbb{E}_{i_t}[v_t] - \nabla f(x_t) = -\nabla f(x_{t-1}) + v_{t-1} = e_{t-1}$$

(b) 写 $e_t = e_{t-1} + \delta_t$，其中 $\delta_t = (\nabla f_{i_t}(x_t) - \nabla f_{i_t}(x_{t-1})) - (\nabla f(x_t) - \nabla f(x_{t-1}))$。

$\mathbb{E}[\delta_t \mid \mathcal{F}_{t-1}] = 0$，所以交叉项消失:
$$\mathbb{E}[\|e_t\|^2 \mid \mathcal{F}_{t-1}] = \|e_{t-1}\|^2 + \mathbb{E}[\|\delta_t\|^2 \mid \mathcal{F}_{t-1}]$$

$$\mathbb{E}[\|\delta_t\|^2 \mid \mathcal{F}_{t-1}] \leq \mathbb{E}[\|\nabla f_{i_t}(x_t) - \nabla f_{i_t}(x_{t-1})\|^2 \mid \mathcal{F}_{t-1}] \leq L^2\|x_t - x_{t-1}\|^2$$

最后一步用了 $L$-smoothness 和 $\text{Var}(X) \leq \mathbb{E}[\|X\|^2]$。$\square$

### 引理 2 (单步下降)

$$\mathbb{E}[f(x_{t+1}) \mid \mathcal{F}_t] \leq f(x_t) - \eta\|\nabla f(x_t)\|^2 - \eta\langle \nabla f(x_t), e_t\rangle + \frac{L\eta^2}{2}\|v_t\|^2$$

**证明**: 由 $L$-smoothness:
$$f(x_{t+1}) \leq f(x_t) - \eta\langle \nabla f(x_t), v_t\rangle + \frac{L\eta^2}{2}\|v_t\|^2$$

注意 $x_{t+1} = x_t - \eta v_t$ 是确定性更新（给定 $v_t$），而 $v_t$ 在给定 $\mathcal{F}_t$ 时已确定。所以上式在 $\mathcal{F}_t$ 条件下成立（确定性不等式）。

分解: $\langle \nabla f(x_t), v_t\rangle = \|\nabla f(x_t)\|^2 + \langle \nabla f(x_t), e_t\rangle$。$\square$

## 主定理证明

### Lyapunov 函数构造

定义（在一个 epoch 内）:
$$\Phi_t = f(x_t) + \alpha \|e_t\|^2$$

其中 $\alpha > 0$ 待定。

**单步递减分析**:

$$\mathbb{E}[\Phi_{t+1} \mid \mathcal{F}_t] = \mathbb{E}[f(x_{t+1}) \mid \mathcal{F}_t] + \alpha \mathbb{E}[\|e_{t+1}\|^2 \mid \mathcal{F}_t]$$

**注意**: 这里需要对 $i_{t+1}$ 取期望，但 $f(x_{t+1})$ 已经在 $\mathcal{F}_t$ 确定了（因为 $x_{t+1} = x_t - \eta v_t$ 且 $v_t \in \mathcal{F}_t$）。而 $e_{t+1}$ 依赖于 $i_{t+1}$。

实际上，让我重新定义 filtration 更仔细：$\mathcal{F}_t$ 包含 $i_1, ..., i_t$ 的信息。在给定 $\mathcal{F}_t$ 时，$x_{t+1}, v_t, e_t$ 都已确定，但 $v_{t+1}, e_{t+1}$ 依赖于 $i_{t+1}$。

所以:
$$\mathbb{E}[\Phi_{t+1} \mid \mathcal{F}_t] = f(x_{t+1}) + \alpha \mathbb{E}[\|e_{t+1}\|^2 \mid \mathcal{F}_t]$$

由引理 2（确定性不等式，不是条件期望）:
$$f(x_{t+1}) \leq f(x_t) - \eta\|\nabla f(x_t)\|^2 - \eta\langle \nabla f(x_t), e_t\rangle + \frac{L\eta^2}{2}\|v_t\|^2$$

由引理 1(b)，注意 $e_{t+1}$ 依赖 $i_{t+1}$，而 $\mathcal{F}_t$ 给定后 $x_{t+1}$ 确定:
$$\mathbb{E}[\|e_{t+1}\|^2 \mid \mathcal{F}_t] \leq \|e_t\|^2 + L^2\|x_{t+1} - x_t\|^2 = \|e_t\|^2 + L^2\eta^2\|v_t\|^2$$

因此:
$$\mathbb{E}[\Phi_{t+1} \mid \mathcal{F}_t] \leq f(x_t) + \alpha\|e_t\|^2 - \eta\|\nabla f(x_t)\|^2 - \eta\langle\nabla f(x_t), e_t\rangle + \left(\frac{L\eta^2}{2} + \alpha L^2\eta^2\right)\|v_t\|^2$$

$$= \Phi_t - \eta\|\nabla f(x_t)\|^2 - \eta\langle\nabla f(x_t), e_t\rangle + \left(\frac{L}{2} + \alpha L^2\right)\eta^2\|v_t\|^2$$

处理 $\|v_t\|^2 = \|\nabla f(x_t) + e_t\|^2 \leq 2\|\nabla f(x_t)\|^2 + 2\|e_t\|^2$:

$$\mathbb{E}[\Phi_{t+1} \mid \mathcal{F}_t] \leq \Phi_t - \eta\|\nabla f(x_t)\|^2 - \eta\langle\nabla f(x_t), e_t\rangle + 2\left(\frac{L}{2} + \alpha L^2\right)\eta^2\|\nabla f(x_t)\|^2 + 2\left(\frac{L}{2} + \alpha L^2\right)\eta^2\|e_t\|^2$$

处理交叉项用 Young's inequality: $-\eta\langle\nabla f(x_t), e_t\rangle \leq \frac{\eta}{4}\|\nabla f(x_t)\|^2 + \eta\|e_t\|^2$:

$$\mathbb{E}[\Phi_{t+1} \mid \mathcal{F}_t] \leq \Phi_t - \left(\frac{3\eta}{4} - 2\left(\frac{L}{2} + \alpha L^2\right)\eta^2\right)\|\nabla f(x_t)\|^2 + \left(\eta + 2\left(\frac{L}{2} + \alpha L^2\right)\eta^2\right)\|e_t\|^2$$

为简化，记 $C = \frac{L}{2} + \alpha L^2$。

**选参要求**:
1. $\frac{3\eta}{4} - 2C\eta^2 \geq \frac{\eta}{2}$，即 $2C\eta \leq \frac{1}{4}$，即 $\eta \leq \frac{1}{8C}$
2. $e_t$ 系数: $\eta + 2C\eta^2$

有了要求 1:
$$\mathbb{E}[\Phi_{t+1} \mid \mathcal{F}_t] \leq \Phi_t - \frac{\eta}{2}\|\nabla f(x_t)\|^2 + \left(\eta + 2C\eta^2\right)\|e_t\|^2$$

由 $2C\eta \leq 1/4$: $\eta + 2C\eta^2 \leq \eta + \frac{\eta}{4} = \frac{5\eta}{4}$

**现在关键**: 我们需要 Lyapunov 函数中的 $\alpha\|e_t\|^2$ 项来吸收上面的 $\frac{5\eta}{4}\|e_t\|^2$。

但问题是 $\Phi_t$ 中的 $\alpha\|e_t\|^2$ 已经包含在左边了——变化量中 $e_t$ 部分已经被引理 1(b) 处理了，增长了 $\alpha L^2\eta^2\|v_t\|^2$。

**反思**: 纯 Lyapunov 方法在这里有困难，因为 $\|e_t\|^2$ 的系数始终为正（方差在增长）。Lyapunov 函数本身不能给出 $\Phi_{t+1} \leq \Phi_t - c\|\nabla f\|^2$（因为有正的 $\|e_t\|^2$ 项）。

**修正策略**: 只在一个 epoch 内做 telescope，然后利用 $e_0 = 0$ 和方差随 epoch 内迭代数增长有限的事实。

取无条件期望，对 epoch 内 $t = 0, ..., q-1$ 求和:

$$\mathbb{E}[\Phi_q] \leq \Phi_0 - \frac{\eta}{2}\sum_{t=0}^{q-1}\mathbb{E}[\|\nabla f(x_t)\|^2] + \frac{5\eta}{4}\sum_{t=0}^{q-1}\mathbb{E}[\|e_t\|^2]$$

由于 $\Phi_0 = f(x_0)$（因为 $e_0 = 0$），$\mathbb{E}[\Phi_q] \geq \mathbb{E}[f(x_q)]$（因为 $\alpha\|e_q\|^2 \geq 0$）。

所以:
$$\mathbb{E}[f(x_q)] \leq f(x_0) - \frac{\eta}{2}\sum_{t=0}^{q-1}\mathbb{E}[\|\nabla f(x_t)\|^2] + \frac{5\eta}{4}\sum_{t=0}^{q-1}\mathbb{E}[\|e_t\|^2]$$

现在处理 $\sum_{t=0}^{q-1}\mathbb{E}[\|e_t\|^2]$。由引理 1(b) 递推:
$$\mathbb{E}[\|e_t\|^2] \leq L^2\eta^2\sum_{s=0}^{t-1}\mathbb{E}[\|v_s\|^2]$$

所以:
$$\sum_{t=0}^{q-1}\mathbb{E}[\|e_t\|^2] \leq L^2\eta^2\sum_{t=1}^{q-1}\sum_{s=0}^{t-1}\mathbb{E}[\|v_s\|^2] \leq L^2\eta^2 q\sum_{s=0}^{q-1}\mathbb{E}[\|v_s\|^2]$$

$$\leq 2L^2\eta^2 q\sum_{s=0}^{q-1}\left(\mathbb{E}[\|\nabla f(x_s)\|^2] + \mathbb{E}[\|e_s\|^2]\right)$$

取 $2L^2\eta^2 q \cdot \frac{5\eta}{4} \cdot 2 = 5L^2\eta^3 q$ 足够小以吸收方差项。

设 $V = \sum_{t=0}^{q-1}\mathbb{E}[\|e_t\|^2]$，$G = \sum_{t=0}^{q-1}\mathbb{E}[\|\nabla f(x_t)\|^2]$。

$$V \leq 2L^2\eta^2 q(G + V) \implies V(1 - 2L^2\eta^2 q) \leq 2L^2\eta^2 q \cdot G$$

当 $2L^2\eta^2 q \leq 1/2$ 时: $V \leq 4L^2\eta^2 q \cdot G$。

代回:
$$\mathbb{E}[f(x_q)] \leq f(x_0) - \frac{\eta}{2}G + \frac{5\eta}{4} \cdot 4L^2\eta^2 q \cdot G = f(x_0) - \left(\frac{\eta}{2} - 5L^2\eta^3 q\right) G$$

取 $\eta = \frac{c}{L\sqrt{q}}$，则 $2L^2\eta^2 q = 2c^2 \leq 1/2$ 要求 $c \leq 1/2$。

$$\frac{\eta}{2} - 5L^2\eta^3 q = \frac{c}{2L\sqrt{q}} - \frac{5c^3}{L\sqrt{q}} = \frac{c(1 - 10c^2)}{2L\sqrt{q}}$$

取 $c = 1/4$: $10c^2 = 10/16 = 5/8 < 1$，$2c^2 = 1/8 < 1/2$ ✓

$$\frac{\eta}{2} - 5L^2\eta^3 q = \frac{(1/4)(3/8)}{2L\sqrt{q}} = \frac{3}{64L\sqrt{q}}$$

所以:
$$\mathbb{E}[f(x_q)] \leq f(x_0) - \frac{3}{64L\sqrt{q}} \sum_{t=0}^{q-1}\mathbb{E}[\|\nabla f(x_t)\|^2]$$

## 最终复杂度

对 $S$ 个 epochs telescope:
$$\frac{3}{64L\sqrt{q}}\sum_{\text{all}}\mathbb{E}[\|\nabla f(x_t)\|^2] \leq \Delta_f$$

$$\min_t \mathbb{E}[\|\nabla f(x_t)\|^2] \leq \frac{64L\sqrt{q}\Delta_f}{3T}$$

要求右边 $\leq \epsilon^2$: $T \geq \frac{64L\sqrt{q}\Delta_f}{3\epsilon^2}$

每个 epoch 梯度评估: $n + 2q$。epoch 数: $S = T/q$。

总评估: $S(n + 2q) = \frac{T}{q}(n + 2q) = O\left(\frac{L\sqrt{q}\Delta_f}{\epsilon^2} \cdot \frac{n + 2q}{q}\right) = O\left(\frac{L\Delta_f(n + 2q)}{\sqrt{q}\epsilon^2}\right)$

$$= O\left(\frac{Ln\Delta_f}{\sqrt{q}\epsilon^2} + \frac{L\sqrt{q}\Delta_f}{\epsilon^2}\right)$$

取 $q = n$:
$$= O\left(\frac{L\sqrt{n}\Delta_f}{\epsilon^2}\right)$$

加上第一个 epoch 的 $n$ 次评估: $\boxed{O\left(n + \frac{L\sqrt{n}\Delta_f}{\epsilon^2}\right)}$

（将 $L, \Delta_f$ 视为与 $n, \epsilon$ 无关的常数时，即 $O(n + \sqrt{n}/\epsilon^2)$。）
