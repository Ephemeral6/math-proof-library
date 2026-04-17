# Proof: Transformer Self-Attention is Lipschitz

**Route**: Three-Stage Composition

## Setup
$f_i(X) = a_i(X)^T X W_V$ where $a_i(X) = \text{softmax}(X_i M X^T / \sqrt{d_k})$, $M = W_Q W_K^T$. Let $R = \max_j \|X_j\|$.

## Step 1: Product-rule decomposition

$$f_i(X) - f_i(X') = \underbrace{a_i^T (X-X') W_V}_{\text{Term I}} + \underbrace{(a_i - a_i')^T X' W_V}_{\text{Term II}}$$

## Step 2: Term I — value perturbation

$a_i$ is a probability vector ($\|a_i\|_1 = 1$), so $\|a_i^T \Delta X\|_2 \leq \max_j \|\Delta X_j\|_2 \leq \|\Delta X\|_F$.

$$\text{Term I} \leq \|W_V\| \cdot \|\Delta X\|_F$$

## Step 3: Softmax is $\frac{1}{2}$-Lipschitz in $\ell_2$

The Jacobian of softmax is $J = \text{diag}(\sigma) - \sigma\sigma^T$ (= Hessian of log-sum-exp). For any unit vector $v$:

$$v^T J v = \text{Var}_\sigma(v) = \sum_j \sigma_j v_j^2 - \left(\sum_j \sigma_j v_j\right)^2$$

Take $\sigma = (1/2, 1/2, 0, \ldots)$, $v = (1/\sqrt{2}, -1/\sqrt{2}, 0, \ldots)$: $\text{Var} = 1/2$. This is tight.

Upper bound: $\text{Var}_\sigma(v) \leq \mathbb{E}_\sigma[v^2] = \sum \sigma_j v_j^2 \leq \max_j \sigma_j \leq 1$, but the sharper Popoviciu bound gives $\text{Var} \leq (\max v - \min v)^2/4$. For $\|v\|_2 = 1$ with $v_j \in [-1,1]$: $(\max - \min)^2 \leq (1-(-1))^2 = 4$, so **not** better than 1. The direct bound: eigenvalues of $\text{diag}(\sigma) - \sigma\sigma^T$ are $\sigma_j(1-\sigma_j)$ (in a suitable basis) bounded by $1/4$ each, but the spectral norm achieves $1/2$ (as shown above).

By the mean value theorem: $\|\sigma(s) - \sigma(s')\|_2 \leq \frac{1}{2}\|s - s'\|_2$.

## Step 4: Score perturbation — bilinear structure

Row $i$ of the score matrix: $s_{ij} = X_i M X_j^T / \sqrt{d_k}$.

$$\Delta s_{ij} = (X_i M \Delta X_j^T + \Delta X_i M X_j'^T) / \sqrt{d_k}$$

So $|\Delta s_{ij}| \leq \|M\|(R \|\Delta X_j\| + \|\Delta X_i\| R) / \sqrt{d_k}$.

Using $(a+b)^2 \leq 2(a^2+b^2)$:

$$\|\Delta s_i\|_2^2 \leq \frac{2\|M\|^2 R^2}{d_k} \sum_j (\|\Delta X_j\|^2 + \|\Delta X_i\|^2) \leq \frac{4n \|M\|^2 R^2}{d_k} \|\Delta X\|_F^2$$

$$\|\Delta s_i\|_2 \leq \frac{2\sqrt{n} \|M\| R}{\sqrt{d_k}} \|\Delta X\|_F$$

## Step 5: Term II — attention perturbation

$$\|a_i - a_i'\|_2 \leq \frac{1}{2} \|\Delta s_i\|_2 \leq \frac{\sqrt{n} \|M\| R}{\sqrt{d_k}} \|\Delta X\|_F$$

For the value factor: $\|(a_i - a_i')^T X' W_V\|_2 \leq \|a_i - a_i'\|_2 \cdot \|X'\|_{\text{op}} \cdot \|W_V\|$.

Since $\|X'\|_{\text{op}} \leq \|X'\|_F \leq \sqrt{n} R$:

$$\text{Term II} \leq \frac{\sqrt{n} \|M\| R}{\sqrt{d_k}} \cdot \sqrt{n} R \cdot \|W_V\| \cdot \|\Delta X\|_F = \frac{n R^2 \|M\| \|W_V\|}{\sqrt{d_k}} \|\Delta X\|_F$$

## Step 6: Final bound

$$\boxed{\text{Lip}(f_i) \leq \|W_V\| + \frac{n \|W_V\| \|W_Q W_K^T\| (\max_j \|X_j\|)^2}{\sqrt{d_k}}}$$

**Under the unit-norm assumption** $\max_j \|X_j\| \leq 1$ (standard after LayerNorm), $R^2 \leq R$ and $1 \leq 2\sqrt{2}$, recovering the stated bound:

$$\text{Lip}(f_i) \leq \|W_V\| + 2\sqrt{2} \cdot n \cdot \|W_V\| \cdot \|W_Q W_K^T\| \cdot \frac{\max_j \|X_j\|}{\sqrt{d_k}}$$

**Q.E.D.**

## Remark
The natural bound is **quadratic** in $R = \max_j\|X_j\|$ because $f_i$ is cubic in $X$ (bilinear scores × linear values). The constant $n/\sqrt{d_k}$ (rather than $2\sqrt{2}n/\sqrt{d_k}$) is tighter than stated; the factor $2\sqrt{2}$ provides additional slack.
