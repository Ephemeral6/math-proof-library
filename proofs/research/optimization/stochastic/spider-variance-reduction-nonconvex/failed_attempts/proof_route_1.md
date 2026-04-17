# Route 1: Direct Descent Lemma + Variance Recursion

## Setup and Assumptions

**目标函数**: $f(x) = \frac{1}{n}\sum_{i=1}^n f_i(x)$，其中每个 $f_i$ 都是 $L$-smooth:
$$\|\nabla f_i(x) - \nabla f_i(y)\| \leq L\|x - y\|, \quad \forall x, y, \forall i$$

这蕴含 $f$ 本身也是 $L$-smooth。

**SPIDER/SARAH 算法**:
- 将迭代分为 epochs，每个 epoch 长度为 $q$
- 在每个 epoch 的起始，计算全梯度: $v_0 = \nabla f(x_0^{(s)}) = \frac{1}{n}\sum_{i=1}^n \nabla f_i(x_0^{(s)})$
- 在 epoch 内: $v_t = \nabla f_{i_t}(x_t) - \nabla f_{i_t}(x_{t-1}) + v_{t-1}$，其中 $i_t$ 均匀随机从 $\{1,...,n\}$ 中抽取
- 更新: $x_{t+1} = x_t - \eta v_t$

**符号**: 在一个 epoch 内，记 $e_t = v_t - \nabla f(x_t)$ 为方差估计误差。

## Step 1: Unbiasedness of SPIDER Estimator

**引理 1**: 在给定 $x_t, x_{t-1}, v_{t-1}$ 的条件下:
$$\mathbb{E}_{i_t}[v_t] = \nabla f(x_t) - \nabla f(x_{t-1}) + v_{t-1}$$

**证明**: 
$$\mathbb{E}_{i_t}[v_t] = \mathbb{E}_{i_t}[\nabla f_{i_t}(x_t) - \nabla f_{i_t}(x_{t-1})] + v_{t-1} = \nabla f(x_t) - \nabla f(x_{t-1}) + v_{t-1}$$

**注意**: 这说明 $\mathbb{E}_{i_t}[v_t] \neq \nabla f(x_t)$（除非 $v_{t-1} = \nabla f(x_{t-1})$）。SPIDER 估计器 **不是** $\nabla f(x_t)$ 的无偏估计！

但我们有递推关系: $\mathbb{E}_{i_t}[e_t] = e_{t-1}$，即误差序列 $\{e_t\}$ 是一个鞅。

## Step 2: Variance Recursion

**引理 2**: 在一个 epoch 内，对 $t \geq 1$:
$$\mathbb{E}[\|e_t\|^2 \mid \mathcal{F}_{t-1}] \leq \|e_{t-1}\|^2 + L^2\|x_t - x_{t-1}\|^2$$

**证明**: 
$$e_t = v_t - \nabla f(x_t) = [\nabla f_{i_t}(x_t) - \nabla f_{i_t}(x_{t-1})] - [\nabla f(x_t) - \nabla f(x_{t-1})] + e_{t-1}$$

记 $\delta_t = [\nabla f_{i_t}(x_t) - \nabla f_{i_t}(x_{t-1})] - [\nabla f(x_t) - \nabla f(x_{t-1})]$，则 $e_t = \delta_t + e_{t-1}$。

由于 $\mathbb{E}_{i_t}[\delta_t] = 0$，且 $\delta_t$ 与 $e_{t-1}$ 条件独立（给定 $\mathcal{F}_{t-1}$），我们有:
$$\mathbb{E}[\|e_t\|^2 \mid \mathcal{F}_{t-1}] = \mathbb{E}[\|\delta_t\|^2 \mid \mathcal{F}_{t-1}] + \|e_{t-1}\|^2$$

（交叉项因 $\mathbb{E}[\delta_t \mid \mathcal{F}_{t-1}] = 0$ 而消失。）

对于 $\mathbb{E}[\|\delta_t\|^2 \mid \mathcal{F}_{t-1}]$，利用方差不超过二阶矩:
$$\mathbb{E}[\|\delta_t\|^2 \mid \mathcal{F}_{t-1}] \leq \mathbb{E}[\|\nabla f_{i_t}(x_t) - \nabla f_{i_t}(x_{t-1})\|^2 \mid \mathcal{F}_{t-1}]$$

（这里用了 $\text{Var}(X) \leq \mathbb{E}[\|X\|^2]$，注意 $\delta_t = X_t - \mathbb{E}[X_t]$ 其中 $X_t = \nabla f_{i_t}(x_t) - \nabla f_{i_t}(x_{t-1})$。）

由个体函数的 $L$-smoothness:
$$\mathbb{E}[\|\nabla f_{i_t}(x_t) - \nabla f_{i_t}(x_{t-1})\|^2] \leq L^2\|x_t - x_{t-1}\|^2$$

因此:
$$\mathbb{E}[\|e_t\|^2 \mid \mathcal{F}_{t-1}] \leq \|e_{t-1}\|^2 + L^2\|x_t - x_{t-1}\|^2$$

对完全期望取期望:
$$\mathbb{E}[\|e_t\|^2] \leq \mathbb{E}[\|e_{t-1}\|^2] + L^2\mathbb{E}[\|x_t - x_{t-1}\|^2]$$

在 epoch 起始 $e_0 = 0$（因为 $v_0 = \nabla f(x_0)$），递推得:
$$\mathbb{E}[\|e_t\|^2] \leq L^2 \sum_{s=1}^{t} \mathbb{E}[\|x_s - x_{s-1}\|^2] = L^2\eta^2 \sum_{s=0}^{t-1} \mathbb{E}[\|v_s\|^2]$$

## Step 3: Descent Lemma

由 $L$-smoothness:
$$f(x_{t+1}) \leq f(x_t) + \langle \nabla f(x_t), x_{t+1} - x_t \rangle + \frac{L}{2}\|x_{t+1} - x_t\|^2$$

代入 $x_{t+1} - x_t = -\eta v_t$:
$$f(x_{t+1}) \leq f(x_t) - \eta \langle \nabla f(x_t), v_t \rangle + \frac{L\eta^2}{2}\|v_t\|^2$$

取期望并分解 $v_t = \nabla f(x_t) + e_t$:
$$\mathbb{E}[f(x_{t+1})] \leq \mathbb{E}[f(x_t)] - \eta \mathbb{E}[\|\nabla f(x_t)\|^2] - \eta \mathbb{E}[\langle \nabla f(x_t), e_t \rangle] + \frac{L\eta^2}{2}\mathbb{E}[\|v_t\|^2]$$

对于 $\|v_t\|^2$:
$$\|v_t\|^2 = \|\nabla f(x_t) + e_t\|^2 \leq 2\|\nabla f(x_t)\|^2 + 2\|e_t\|^2$$

对于交叉项，由鞅性质 $\mathbb{E}[e_t \mid \mathcal{F}_{t-1}] = e_{t-1}$... 

**这里有一个微妙之处**：$e_t$ 不是零均值的（它是鞅，但不是零均值鞅，除非 $e_0 = 0$ 且我们在 epoch 内）。

在 epoch 内，$e_0 = 0$，所以 $\mathbb{E}[e_t] = 0$。但 $\nabla f(x_t)$ 和 $e_t$ 不独立。

让我换一种处理方式。用 Young's inequality 处理交叉项:
$$-\eta \langle \nabla f(x_t), e_t \rangle \leq \frac{\eta}{2}\|\nabla f(x_t)\|^2 + \frac{\eta}{2}\|e_t\|^2$$

代回:
$$\mathbb{E}[f(x_{t+1})] \leq \mathbb{E}[f(x_t)] - \frac{\eta}{2}\mathbb{E}[\|\nabla f(x_t)\|^2] + \frac{\eta}{2}\mathbb{E}[\|e_t\|^2] + \frac{L\eta^2}{2}\mathbb{E}[\|v_t\|^2]$$

对 $\|v_t\|^2$ 用另一个分解:
$$\mathbb{E}[\|v_t\|^2] = \mathbb{E}[\|\nabla f(x_t)\|^2] + \mathbb{E}[\|e_t\|^2] + 2\mathbb{E}[\langle \nabla f(x_t), e_t \rangle]$$

这还是有交叉项。让我直接用:
$$\frac{L\eta^2}{2}\mathbb{E}[\|v_t\|^2] = \frac{L\eta^2}{2}\mathbb{E}[\|\nabla f(x_t) + e_t\|^2] \leq L\eta^2 \mathbb{E}[\|\nabla f(x_t)\|^2] + L\eta^2 \mathbb{E}[\|e_t\|^2]$$

综合:
$$\mathbb{E}[f(x_{t+1})] \leq \mathbb{E}[f(x_t)] - \left(\frac{\eta}{2} - L\eta^2\right)\mathbb{E}[\|\nabla f(x_t)\|^2] + \left(\frac{\eta}{2} + L\eta^2\right)\mathbb{E}[\|e_t\|^2]$$

当 $\eta \leq \frac{1}{4L}$ 时，$\frac{\eta}{2} - L\eta^2 \geq \frac{\eta}{4}$ 且 $\frac{\eta}{2} + L\eta^2 \leq \eta$。

所以:
$$\mathbb{E}[f(x_{t+1})] \leq \mathbb{E}[f(x_t)] - \frac{\eta}{4}\mathbb{E}[\|\nabla f(x_t)\|^2] + \eta\mathbb{E}[\|e_t\|^2]$$

## Step 4: Epoch-level Telescoping

在一个 epoch 内对 $t = 0, 1, ..., q-1$ 求和:
$$\mathbb{E}[f(x_q)] \leq \mathbb{E}[f(x_0)] - \frac{\eta}{4}\sum_{t=0}^{q-1}\mathbb{E}[\|\nabla f(x_t)\|^2] + \eta\sum_{t=0}^{q-1}\mathbb{E}[\|e_t\|^2]$$

由 Step 2 的递推，$\mathbb{E}[\|e_t\|^2] \leq L^2\eta^2 \sum_{s=0}^{t-1}\mathbb{E}[\|v_s\|^2]$。

对 epoch 内求和:
$$\sum_{t=0}^{q-1}\mathbb{E}[\|e_t\|^2] \leq L^2\eta^2 \sum_{t=0}^{q-1}\sum_{s=0}^{t-1}\mathbb{E}[\|v_s\|^2] \leq L^2\eta^2 q \sum_{s=0}^{q-1}\mathbb{E}[\|v_s\|^2]$$

而 $\mathbb{E}[\|v_s\|^2] \leq 2\mathbb{E}[\|\nabla f(x_s)\|^2] + 2\mathbb{E}[\|e_s\|^2]$，所以:
$$\sum_{t=0}^{q-1}\mathbb{E}[\|e_t\|^2] \leq 2L^2\eta^2 q \sum_{s=0}^{q-1}\mathbb{E}[\|\nabla f(x_s)\|^2] + 2L^2\eta^2 q \sum_{s=0}^{q-1}\mathbb{E}[\|e_s\|^2]$$

当 $2L^2\eta^2 q \leq \frac{1}{2}$ 时（即 $\eta \leq \frac{1}{2L\sqrt{q}}$），可以吸收右边的方差项:
$$\sum_{t=0}^{q-1}\mathbb{E}[\|e_t\|^2] \leq 4L^2\eta^2 q \sum_{s=0}^{q-1}\mathbb{E}[\|\nabla f(x_s)\|^2]$$

代回下降不等式:
$$\mathbb{E}[f(x_q)] \leq \mathbb{E}[f(x_0)] - \frac{\eta}{4}\sum_{t=0}^{q-1}\mathbb{E}[\|\nabla f(x_t)\|^2] + 4L^2\eta^3 q \sum_{t=0}^{q-1}\mathbb{E}[\|\nabla f(x_t)\|^2]$$

$$= \mathbb{E}[f(x_0)] - \left(\frac{\eta}{4} - 4L^2\eta^3 q\right)\sum_{t=0}^{q-1}\mathbb{E}[\|\nabla f(x_t)\|^2]$$

选择 $\eta = \frac{1}{4L\sqrt{q}}$，则:
- $\eta \leq \frac{1}{4L}$（当 $q \geq 1$）✓
- $\eta \leq \frac{1}{2L\sqrt{q}}$（因为 $\frac{1}{4L\sqrt{q}} \leq \frac{1}{2L\sqrt{q}}$）✓
- $4L^2\eta^3 q = 4L^2 \cdot \frac{1}{64L^3 q^{3/2}} \cdot q = \frac{1}{16L\sqrt{q}} = \frac{\eta}{4} \cdot \frac{1}{4} \cdot 4 = \frac{\eta}{16}$

等一下，让我重新算: $4L^2\eta^3 q = 4L^2 \cdot \frac{q}{64L^3 q^{3/2}} = \frac{4}{64L\sqrt{q}} = \frac{1}{16L\sqrt{q}}$。

而 $\frac{\eta}{4} = \frac{1}{16L\sqrt{q}}$。

所以 $\frac{\eta}{4} - 4L^2\eta^3 q = \frac{1}{16L\sqrt{q}} - \frac{1}{16L\sqrt{q}} = 0$。

**问题**: 参数选择恰好使系数为零！需要调整。

选择 $\eta = \frac{c}{L\sqrt{q}}$，其中 $c$ 是足够小的常数。

$\frac{\eta}{4} - 4L^2\eta^3 q = \frac{c}{4L\sqrt{q}} - \frac{4c^3}{L\sqrt{q}} = \frac{c(1 - 16c^2)}{4L\sqrt{q}}$

取 $c = \frac{1}{8}$（使得 $16c^2 = \frac{1}{4} < 1$），则:
- $\eta = \frac{1}{8L\sqrt{q}}$
- $\frac{\eta}{4} - 4L^2\eta^3 q = \frac{3}{128 L\sqrt{q}}$

**检查前面的条件**: $\eta \leq \frac{1}{4L}$ 当 $q \geq 1/4$，即 $q \geq 1$; $2L^2\eta^2 q = 2L^2 \cdot \frac{q}{64L^2 q} = \frac{1}{32} \leq \frac{1}{2}$ ✓

因此:
$$\mathbb{E}[f(x_q^{(s)})] \leq \mathbb{E}[f(x_0^{(s)})] - \frac{3}{128L\sqrt{q}}\sum_{t=0}^{q-1}\mathbb{E}[\|\nabla f(x_t^{(s)})\|^2]$$

## Step 5: Multi-epoch Telescoping and Complexity

假设共 $S$ 个 epochs。记第 $s$ 个 epoch 的起始点为 $x_0^{(s)}$，终止点为 $x_q^{(s)} = x_0^{(s+1)}$。

对所有 epochs 求和:
$$\mathbb{E}[f(x_0^{(S+1)})] \leq f(x_0^{(1)}) - \frac{3}{128L\sqrt{q}}\sum_{s=1}^{S}\sum_{t=0}^{q-1}\mathbb{E}[\|\nabla f(x_t^{(s)})\|^2]$$

总迭代数为 $T = Sq$。记 $\Delta_f = f(x_0^{(1)}) - f^*$。

$$\frac{3}{128L\sqrt{q}} \sum_{\text{all } t}\mathbb{E}[\|\nabla f(x_t)\|^2] \leq \Delta_f$$

$$\frac{1}{T}\sum_{\text{all } t}\mathbb{E}[\|\nabla f(x_t)\|^2] \leq \frac{128L\sqrt{q}\Delta_f}{3T}$$

要使 $\min_t \mathbb{E}[\|\nabla f(x_t)\|^2] \leq \epsilon^2$:
$$\frac{128L\sqrt{q}\Delta_f}{3T} \leq \epsilon^2 \implies T \geq \frac{128L\sqrt{q}\Delta_f}{3\epsilon^2}$$

**梯度评估代价**:
- 每个 epoch 的起始: $n$ 次梯度评估（计算全梯度）
- 每个 epoch 内: $q$ 步，每步计算 $\nabla f_{i_t}(x_t)$ 和 $\nabla f_{i_t}(x_{t-1})$，共 $2q$ 次
- 每个 epoch 总代价: $n + 2q$
- $S$ 个 epochs: $S(n + 2q)$

其中 $S = T/q$，所以总梯度评估数为:
$$S(n+2q) = \frac{T}{q}(n+2q) = \frac{T \cdot n}{q} + 2T$$

取 $T = O\left(\frac{L\sqrt{q}\Delta_f}{\epsilon^2}\right)$:

$$\text{Total} = O\left(\frac{L\sqrt{q}\Delta_f}{\epsilon^2} \cdot \frac{n}{q} + \frac{L\sqrt{q}\Delta_f}{\epsilon^2}\right) = O\left(\frac{Ln\Delta_f}{q^{1/2}\epsilon^2} + \frac{L\sqrt{q}\Delta_f}{\epsilon^2}\right)$$

选择 $q = n^{1/2}$... 不对。让我选 $q$ 来最小化 $\frac{n}{\sqrt{q}} + \sqrt{q}$。

对 $g(q) = \frac{n}{\sqrt{q}} + \sqrt{q}$ 求导: $g'(q) = -\frac{n}{2q^{3/2}} + \frac{1}{2\sqrt{q}} = 0 \implies q = n$。

**但** $q \leq n$（epoch 长度不能超过样本量，这是 SARAH/SPIDER 通常的约束以确保方差控制有意义）。

取 $q = n$:
$$\text{Total} = O\left(\frac{Ln\Delta_f}{\sqrt{n}\epsilon^2} + \frac{L\sqrt{n}\Delta_f}{\epsilon^2}\right) = O\left(\frac{L\sqrt{n}\Delta_f}{\epsilon^2}\right)$$

加上每个 epoch 起始的全梯度计算，epoch 数为 $S = T/q = O\left(\frac{L\sqrt{n}\Delta_f}{n\epsilon^2}\right) = O\left(\frac{L\Delta_f}{\sqrt{n}\epsilon^2}\right)$。

全梯度的总代价: $S \cdot n = O\left(\frac{Ln\Delta_f}{\sqrt{n}\epsilon^2}\right) = O\left(\frac{L\sqrt{n}\Delta_f}{\epsilon^2}\right)$。

这就和 epoch 内的代价一样了。但我们还需要至少一个 epoch，所以总代价:

$$\boxed{O\left(n + \frac{\sqrt{n}}{\epsilon^2}\right)}$$

（其中我们将 $L, \Delta_f$ 视为常数。）

**与 SGD 的比较**: 标准 SGD 在非凸情形下需要 $O(1/\epsilon^4)$ 次梯度评估（因为 $O(\sigma^2/\epsilon^4)$，其中 $\sigma^2$ 是梯度方差）。当 $n$ 为有限但足够大时，$\sqrt{n}/\epsilon^2 \ll 1/\epsilon^4$。

## 证明完成

注意: 上面的分析中对方差递推的处理有一些粗糙的地方（吸收技巧的条件检验），但总体框架是正确的。Route 2 和 3 会提供更严谨的版本。
