# FTRL with Negative Entropy (Hedge/Multiplicative Weights) Regret Bound

## Theorem

Let $\Delta_d = \{p \in \mathbb{R}^d_{\geq 0} : \sum_{i=1}^d p_i = 1\}$ be the $d$-simplex. The FTRL algorithm with negative entropy regularizer $R(p) = \sum_{i=1}^d p_i \ln p_i$ and learning rate $\eta > 0$:

$$p_t = \arg\min_{p \in \Delta_d} \left\{ \sum_{s=1}^{t-1} \langle \ell_s, p \rangle + \frac{1}{\eta} \sum_{i=1}^d p_i \ln p_i \right\}$$

yields the closed-form $p_{t,i} \propto \exp(-\eta \sum_{s<t} \ell_{s,i})$, equivalently the multiplicative update:

$$p_{t+1,i} = \frac{p_{t,i}\, \exp(-\eta\, \ell_{t,i})}{\sum_j p_{t,j}\, \exp(-\eta\, \ell_{t,j})}, \qquad p_{1} = \left(\tfrac{1}{d}, \ldots, \tfrac{1}{d}\right).$$

For any adaptive adversary choosing $\ell_1, \ldots, \ell_T \in [0,1]^d$ and any comparator $p^* \in \Delta_d$:

$$R_T = \sum_{t=1}^T \langle \ell_t, p_t \rangle - \sum_{t=1}^T \langle \ell_t, p^* \rangle \leq 2\sqrt{T \ln d}.$$

---

## Proof

### Step 0: Closed-Form Derivation

**Claim.** $p_{t,i} = \frac{\exp(-\eta L_{t-1,i})}{\sum_j \exp(-\eta L_{t-1,j})}$ where $L_t = \sum_{s=1}^t \ell_s$.

**Proof.** The FTRL optimization is $\min_{p \in \Delta_d} \langle L_{t-1}, p\rangle + \frac{1}{\eta}\sum_i p_i \ln p_i$. Writing the Lagrangian with multiplier $\lambda$ for $\sum_i p_i = 1$ (non-negativity constraints are inactive since the exponential is positive):

$$\frac{\partial}{\partial p_i}\left[L_{t-1,i}\, p_i + \frac{1}{\eta} p_i \ln p_i - \lambda p_i\right] = L_{t-1,i} + \frac{1}{\eta}(\ln p_i + 1) - \lambda = 0.$$

Solving: $p_i = \exp(-\eta L_{t-1,i} + \eta\lambda - 1)$. Normalizing via $\sum_i p_i = 1$ gives the claimed formula.

The multiplicative update follows since $L_{t,i} = L_{t-1,i} + \ell_{t,i}$ implies:

$$p_{t+1,i} = \frac{\exp(-\eta L_{t,i})}{\sum_j \exp(-\eta L_{t,j})} = \frac{p_{t,i}\exp(-\eta \ell_{t,i})}{\sum_j p_{t,j}\exp(-\eta \ell_{t,j})}.$$

$\square$

---

### Step 1: Regret Bound via Potential Function

Define unnormalized weights $w_{t,i}$ by $w_{1,i} = 1$ and $w_{t+1,i} = w_{t,i}\exp(-\eta\,\ell_{t,i})$. Then $w_{t,i} = \exp(-\eta L_{t-1,i})$, $p_{t,i} = w_{t,i}/W_t$ where $W_t = \sum_i w_{t,i}$, and $W_1 = d$.

**Upper bound on $\ln(W_{T+1}/W_1)$.** The ratio is:

$$\frac{W_{t+1}}{W_t} = \sum_i \frac{w_{t,i}}{W_t}\exp(-\eta\,\ell_{t,i}) = \sum_i p_{t,i}\exp(-\eta\,\ell_{t,i}).$$

Applying $e^{-x} \leq 1 - x + x^2$ for $x \in [0,1]$ (proved in Step 2) with $x = \eta\,\ell_{t,i} \in [0, \eta]$ (valid when $\eta \leq 1$, which holds for $\eta^* = \sqrt{\ln d/T}$ when $T \geq \ln d$; see Remark below):

$$\frac{W_{t+1}}{W_t} \leq \sum_i p_{t,i}(1 - \eta\,\ell_{t,i} + \eta^2\,\ell_{t,i}^2) = 1 - \eta\langle \ell_t, p_t\rangle + \eta^2 \sum_i p_{t,i}\,\ell_{t,i}^2.$$

Since $\ln(1+x) \leq x$ for all $x > -1$ (proved in Step 2):

$$\ln\frac{W_{t+1}}{W_t} \leq -\eta\langle \ell_t, p_t\rangle + \eta^2 \sum_i p_{t,i}\,\ell_{t,i}^2.$$

Summing $t = 1, \ldots, T$:

$$\ln\frac{W_{T+1}}{W_1} \leq -\eta\sum_{t=1}^T \langle \ell_t, p_t\rangle + \eta^2 \sum_{t=1}^T \sum_i p_{t,i}\,\ell_{t,i}^2. \tag{U}$$

**Lower bound on $\ln(W_{T+1}/W_1)$.** For any $i^* \in [d]$:

$$W_{T+1} \geq w_{T+1,i^*} = \exp\!\left(-\eta\sum_{t=1}^T \ell_{t,i^*}\right), \quad W_1 = d.$$

So:

$$\ln\frac{W_{T+1}}{W_1} \geq -\eta\sum_{t=1}^T \ell_{t,i^*} - \ln d. \tag{L}$$

**Combining (U) and (L).** Rearranging:

$$\sum_{t=1}^T \langle \ell_t, p_t\rangle - \sum_{t=1}^T \ell_{t,i^*} \leq \frac{\ln d}{\eta} + \eta\sum_{t=1}^T \sum_i p_{t,i}\,\ell_{t,i}^2. \tag{1}$$

**Extension to arbitrary $p^* \in \Delta_d$.** Inequality (1) holds for every vertex $e_{i^*}$. For any $p^* = \sum_i p_i^* e_i \in \Delta_d$, note that $\sum_t \langle \ell_t, p^*\rangle = \sum_i p_i^*(\sum_t \ell_{t,i})$. Taking the convex combination of (1) over $i^*$ with weights $p_i^*$:

$$\sum_{t=1}^T \langle \ell_t, p_t\rangle - \sum_{t=1}^T \langle \ell_t, p^*\rangle \leq \frac{\ln d}{\eta} + \eta\sum_{t=1}^T \sum_i p_{t,i}\,\ell_{t,i}^2. \tag{1'}$$

(The left side becomes $\sum_t \langle \ell_t, p_t\rangle - \sum_i p_i^* \sum_t \ell_{t,i}$, and the right side is the same for all $i^*$.) $\square$

---

### Step 2: Auxiliary Inequalities

**Lemma A.** $e^{-x} \leq 1 - x + x^2$ for all $x \in [0, 1]$.

**Proof.** Let $g(x) = 1 - x + x^2 - e^{-x}$. Then $g(0) = 0$, $g'(x) = -1 + 2x + e^{-x}$, $g'(0) = 0$, and $g''(x) = 2 - e^{-x} \geq 2 - 1 = 1 > 0$ for $x \in [0,1]$. So $g'$ is strictly increasing with $g'(0) = 0$, hence $g'(x) \geq 0$ on $[0,1]$. Therefore $g$ is non-decreasing with $g(0) = 0$, giving $g(x) \geq 0$. $\square$

**Lemma B.** $\ln(1 + x) \leq x$ for all $x > -1$.

**Proof.** Let $h(x) = x - \ln(1+x)$. Then $h(0) = 0$ and $h'(x) = 1 - \frac{1}{1+x} = \frac{x}{1+x}$. For $x > 0$: $h'(x) > 0$, so $h$ is increasing, thus $h(x) > h(0) = 0$. For $-1 < x < 0$: $h'(x) < 0$, so $h$ is decreasing, thus $h(x) > h(0) = 0$. Hence $h(x) \geq 0$ for all $x > -1$. $\square$

**Remark on the range of $\eta\,\ell_{t,i}$.** Since $\ell_{t,i} \in [0,1]$, Lemma A requires $\eta\,\ell_{t,i} \in [0,1]$, i.e., $\eta \leq 1$. For the optimal $\eta^* = \sqrt{\ln d/T}$, this holds when $T \geq \ln d$ (i.e., $T \geq 1$ for any $d \leq e^T$). For the edge case $T < \ln d$, the trivial bound $R_T \leq T$ (since losses are in $[0,1]$) already gives $R_T \leq T < \ln d \leq 2\sqrt{T \ln d}$ when $T \leq 4\ln d$. So the theorem holds universally.

---

### Step 3: Bounding the Second-Order Term

Since $\ell_{t,i} \in [0,1]$, we have $\ell_{t,i}^2 \leq \ell_{t,i} \leq 1$. Therefore:

$$\sum_i p_{t,i}\,\ell_{t,i}^2 \leq \sum_i p_{t,i} \cdot 1 = 1.$$

More precisely, $\sum_i p_{t,i}\,\ell_{t,i}^2 \leq \|\ell_t\|_\infty^2 \leq 1$. Substituting into (1'):

$$R_T \leq \frac{\ln d}{\eta} + \eta T. \tag{2}$$

---

### Step 4: Connection to the Entropy Diameter

The $\frac{\ln d}{\eta}$ term corresponds to the diameter of $\Delta_d$ under negative entropy:

$$\max_{p^* \in \Delta_d} \bigl[R(p^*) - R(p_1)\bigr] = \max_{p^*} \sum_i p_i^* \ln p_i^* - \sum_i \tfrac{1}{d}\ln\tfrac{1}{d} = 0 - (-\ln d) = \ln d,$$

where the max of $R(p^*) = \sum_i p_i^* \ln p_i^*$ over $\Delta_d$ is $0$ (attained at any vertex), and $R(p_1) = -\ln d$. $\square$

---

### Step 5: Optimizing the Learning Rate

From (2), $R_T \leq f(\eta) = \frac{\ln d}{\eta} + \eta T$ for $\eta > 0$.

Setting $f'(\eta) = -\frac{\ln d}{\eta^2} + T = 0$:

$$\eta^* = \sqrt{\frac{\ln d}{T}}.$$

Substituting:

$$R_T \leq \frac{\ln d}{\sqrt{\ln d / T}} + \sqrt{\frac{\ln d}{T}} \cdot T = \sqrt{T\ln d} + \sqrt{T\ln d} = 2\sqrt{T\ln d}.$$

This is indeed a minimum since $f''(\eta) = \frac{2\ln d}{\eta^3} > 0$.

$$\boxed{R_T \leq 2\sqrt{T \ln d}.}$$

---

### Step 6: Validity Against Adaptive Adversaries

The proof holds against **adaptive adversaries** where $\ell_t$ may depend on the full history $(p_1, \ell_1, \ldots, p_{t-1}, \ell_{t-1}, p_t)$:

1. **The argument is pointwise.** Inequalities (U) and (L) hold for every realized sequence $\ell_1, \ldots, \ell_T$, regardless of how the sequence is generated.
2. **No independence or distributional assumptions** are used anywhere in the proof.
3. **The comparator $p^*$ is fixed** and chosen after seeing the entire loss sequence (worst-case analysis).

Therefore the bound $R_T \leq 2\sqrt{T \ln d}$ is a **worst-case, deterministic guarantee** that holds against any adaptive adversary.

$\blacksquare$

---

## Summary Table

| Step | Result |
|---|---|
| Potential function | $R_T \leq \frac{\ln d}{\eta} + \eta \sum_t \sum_i p_{t,i}\,\ell_{t,i}^2$ |
| Auxiliary inequality | $e^{-x} \leq 1 - x + x^2$ for $x \in [0,1]$ |
| Second-order bound | $\sum_i p_{t,i}\,\ell_{t,i}^2 \leq 1$ |
| Combined | $R_T \leq \frac{\ln d}{\eta} + \eta T$ |
| Optimal learning rate | $\eta^* = \sqrt{\ln d / T}$ |
| **Final** | $R_T \leq 2\sqrt{T \ln d}$ |
