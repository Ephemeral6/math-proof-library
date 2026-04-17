# EXP3 Regret Bound for Adversarial Multi-Armed Bandits

## Proof

**Route**: Direct Potential + Importance Weighting

---

### Setup and Notation

We have $K$ arms and $T$ rounds. An oblivious adversary fixes loss vectors $\ell_t \in [0,1]^K$ before the game begins. At each round $t$:

- **Normalized weights**: $\tilde{p}_t(i) = w_t(i) / W_t$ where $W_t = \sum_{j=1}^K w_t(j)$, initialized $w_1(i) = 1$.
- **Sampling distribution**: $p_t(i) = (1-\gamma)\tilde{p}_t(i) + \gamma/K$.
- **Action**: Draw $I_t \sim p_t$, observe only $\ell_t(I_t)$.
- **Importance-weighted estimate**: $\hat{\ell}_t(i) = \frac{\ell_t(i) \cdot \mathbf{1}[I_t = i]}{p_t(i)}$.
- **Weight update**: $w_{t+1}(i) = w_t(i) \cdot \exp\!\big(-\eta\,\hat{\ell}_t(i)\big)$.

Parameters: learning rate $\eta > 0$, exploration rate $\gamma \in (0, 1]$.

**Goal**: Show $\displaystyle\mathbb{E}[\mathrm{Regret}] = \sum_{t=1}^T \mathbb{E}[\ell_t(I_t)] - \min_{i \in [K]} \sum_{t=1}^T \ell_t(i) \leq \frac{\ln K}{\eta} + \eta K T + \gamma T.$

---

### Step 1: Unbiasedness of Importance-Weighted Estimates

**Claim.** $\;\mathbb{E}[\hat{\ell}_t(i) \mid \mathcal{F}_{t-1}] = \ell_t(i)$ for all $i \in [K]$, where $\mathcal{F}_{t-1} = \sigma(I_1, \ldots, I_{t-1})$.

**Proof.** Conditional on $\mathcal{F}_{t-1}$, the distribution $p_t$ is determined and $\ell_t$ is fixed (oblivious adversary):

$$\mathbb{E}[\hat{\ell}_t(i) \mid \mathcal{F}_{t-1}] = \frac{\ell_t(i)}{p_t(i)} \cdot \Pr[I_t = i \mid \mathcal{F}_{t-1}] = \frac{\ell_t(i)}{p_t(i)} \cdot p_t(i) = \ell_t(i). \qquad \square$$

**Corollary.** For any $\mathcal{F}_{t-1}$-measurable vector $q_t \in \mathbb{R}^K$:

$$\mathbb{E}[\langle q_t, \hat{\ell}_t \rangle \mid \mathcal{F}_{t-1}] = \langle q_t, \ell_t \rangle.$$

---

### Step 2: Exponential Weights Potential Argument

Define the log-potential $\Phi_t = \ln W_t$. We have $\Phi_1 = \ln K$.

**Upper bound (per round).** Using the fundamental inequality $e^{-x} \leq 1 - x + x^2/2$ for all $x \geq 0$ (proved below):

$$\frac{W_{t+1}}{W_t} = \sum_{i=1}^K \tilde{p}_t(i)\, e^{-\eta \hat{\ell}_t(i)} \leq \sum_i \tilde{p}_t(i)\!\left(1 - \eta\hat{\ell}_t(i) + \frac{\eta^2}{2}\hat{\ell}_t(i)^2\right) = 1 - \eta\langle \tilde{p}_t, \hat{\ell}_t\rangle + \frac{\eta^2}{2}\langle \tilde{p}_t, \hat{\ell}_t^2\rangle.$$

*Verification of $e^{-x} \leq 1 - x + x^2/2$ for $x \geq 0$*: Let $f(x) = 1 - x + x^2/2 - e^{-x}$. Then $f(0) = 0$, $f'(x) = -1 + x + e^{-x}$, $f'(0) = 0$, and $f''(x) = 1 - e^{-x} \geq 0$ for $x \geq 0$. So $f'$ is nondecreasing with $f'(0) = 0$, hence $f'(x) \geq 0$ for $x \geq 0$, giving $f(x) \geq 0$. $\checkmark$

Applying $\ln(1 + u) \leq u$ (valid for $u > -1$; the argument is positive since $W_{t+1}/W_t > 0$):

$$\Phi_{t+1} - \Phi_t = \ln\frac{W_{t+1}}{W_t} \leq -\eta\langle \tilde{p}_t, \hat{\ell}_t\rangle + \frac{\eta^2}{2}\langle \tilde{p}_t, \hat{\ell}_t^2\rangle.$$

**Telescoping** from $t = 1$ to $T$:

$$\Phi_{T+1} - \ln K \leq -\eta \sum_{t=1}^T \langle \tilde{p}_t, \hat{\ell}_t\rangle + \frac{\eta^2}{2} \sum_{t=1}^T \langle \tilde{p}_t, \hat{\ell}_t^2\rangle. \tag{1}$$

**Lower bound.** For any fixed arm $i^* \in [K]$:

$$\Phi_{T+1} = \ln W_{T+1} \geq \ln w_{T+1}(i^*) = -\eta \sum_{t=1}^T \hat{\ell}_t(i^*). \tag{2}$$

**Combining** (1) and (2), dividing by $\eta > 0$:

$$\sum_{t=1}^T \langle \tilde{p}_t, \hat{\ell}_t\rangle - \sum_{t=1}^T \hat{\ell}_t(i^*) \leq \frac{\ln K}{\eta} + \frac{\eta}{2} \sum_{t=1}^T \langle \tilde{p}_t, \hat{\ell}_t^2\rangle. \tag{3}$$

This is a deterministic inequality holding pathwise for every realization of $(I_1, \ldots, I_T)$.

---

### Step 3: Variance Control

**Claim.** $\displaystyle\mathbb{E}\!\left[\sum_{i=1}^K \tilde{p}_t(i)\,\hat{\ell}_t(i)^2 \;\middle|\; \mathcal{F}_{t-1}\right] \leq \frac{K}{1-\gamma}.$

**Proof.** Since only the $I_t$-th component of $\hat{\ell}_t$ is nonzero:

$$\mathbb{E}\!\left[\tilde{p}_t(i)\,\hat{\ell}_t(i)^2 \mid \mathcal{F}_{t-1}\right] = \tilde{p}_t(i) \cdot \frac{\ell_t(i)^2}{p_t(i)^2} \cdot p_t(i) = \frac{\tilde{p}_t(i)}{p_t(i)} \cdot \ell_t(i)^2.$$

Now use the structural relationship: $p_t(i) = (1-\gamma)\tilde{p}_t(i) + \gamma/K \geq (1-\gamma)\tilde{p}_t(i)$, so:

$$\frac{\tilde{p}_t(i)}{p_t(i)} \leq \frac{1}{1-\gamma}.$$

Combining with $\ell_t(i)^2 \leq \ell_t(i) \leq 1$:

$$\mathbb{E}\!\left[\sum_i \tilde{p}_t(i)\,\hat{\ell}_t(i)^2 \;\middle|\; \mathcal{F}_{t-1}\right] \leq \frac{1}{1-\gamma}\sum_i \ell_t(i)^2 \leq \frac{K}{1-\gamma}. \tag{4}$$

For $\gamma \leq 1/2$, this gives $\leq 2K$. We use the bound $\frac{K}{1-\gamma}$ in general. $\square$

---

### Step 4: Mixing Cost (Relating $p_t$ to $\tilde{p}_t$)

**Claim.** For every round $t$ and every arm $i$:

$$\langle p_t, \ell_t \rangle - \ell_t(i) \leq \langle \tilde{p}_t, \ell_t \rangle - \ell_t(i) + \gamma.$$

**Proof.** Write $\mathbf{u} = (1/K, \ldots, 1/K)$. Then:

$$\langle p_t, \ell_t \rangle - \ell_t(i) = (1-\gamma)\big(\langle \tilde{p}_t, \ell_t \rangle - \ell_t(i)\big) + \gamma\big(\langle \mathbf{u}, \ell_t \rangle - \ell_t(i)\big).$$

We need to show this is $\leq \langle \tilde{p}_t, \ell_t \rangle - \ell_t(i) + \gamma$, i.e.:

$$-\gamma\big(\langle \tilde{p}_t, \ell_t \rangle - \ell_t(i)\big) + \gamma\big(\langle \mathbf{u}, \ell_t \rangle - \ell_t(i)\big) \leq \gamma,$$

$$\Longleftrightarrow \quad \langle \mathbf{u}, \ell_t \rangle - \langle \tilde{p}_t, \ell_t \rangle \leq 1.$$

This holds since both $\langle \mathbf{u}, \ell_t \rangle \leq 1$ and $\langle \tilde{p}_t, \ell_t \rangle \geq 0$. $\square$

**Corollary.** Summing over $t$, using $\mathbb{E}[\ell_t(I_t) \mid \mathcal{F}_{t-1}] = \langle p_t, \ell_t \rangle$ and the unbiasedness from Step 1:

$$\sum_{t=1}^T \mathbb{E}[\ell_t(I_t)] - \sum_{t=1}^T \ell_t(i) \leq \sum_{t=1}^T \mathbb{E}[\langle \tilde{p}_t, \hat{\ell}_t \rangle] - \sum_{t=1}^T \ell_t(i) + \gamma T. \tag{5}$$

---

### Step 5: Assembling the Three-Term Bound

Take expectations in the deterministic inequality (3):

$$\sum_{t=1}^T \mathbb{E}[\langle \tilde{p}_t, \hat{\ell}_t \rangle] - \sum_{t=1}^T \ell_t(i) \leq \frac{\ln K}{\eta} + \frac{\eta}{2} \sum_{t=1}^T \mathbb{E}\!\left[\langle \tilde{p}_t, \hat{\ell}_t^2 \rangle\right],$$

where we used $\mathbb{E}[\hat{\ell}_t(i)] = \ell_t(i)$ on the left side.

Substituting the variance bound (4):

$$\sum_{t=1}^T \mathbb{E}[\langle \tilde{p}_t, \hat{\ell}_t \rangle] - \sum_{t=1}^T \ell_t(i) \leq \frac{\ln K}{\eta} + \frac{\eta KT}{2(1-\gamma)}. \tag{6}$$

Combining (5) and (6):

$$\mathbb{E}[\mathrm{Regret}] = \sum_{t=1}^T \mathbb{E}[\ell_t(I_t)] - \min_{i} \sum_{t=1}^T \ell_t(i) \leq \frac{\ln K}{\eta} + \frac{\eta KT}{2(1-\gamma)} + \gamma T.$$

For $\gamma \leq 1/2$, we have $\frac{1}{2(1-\gamma)} \leq 1$, so:

$$\boxed{\mathbb{E}[\mathrm{Regret}] \leq \frac{\ln K}{\eta} + \eta K T + \gamma T.} \tag{7}$$

(More precisely, $\frac{\eta KT}{2(1-\gamma)} \leq \eta KT$ when $\gamma \leq 1/2$, since $\frac{1}{2(1-\gamma)} \leq 1 \iff 1 \leq 2(1-\gamma) \iff \gamma \leq 1/2$.)

---

### Step 6: Parameter Optimization

Set $\gamma = K\eta$. Then (7) becomes:

$$\mathbb{E}[\mathrm{Regret}] \leq \frac{\ln K}{\eta} + \eta K T + K\eta T = \frac{\ln K}{\eta} + 2K\eta T.$$

Minimize over $\eta$. Let $f(\eta) = \frac{\ln K}{\eta} + 2K\eta T$.

$$f'(\eta) = -\frac{\ln K}{\eta^2} + 2KT = 0 \implies \eta^* = \sqrt{\frac{\ln K}{2KT}}.$$

Substituting:

$$f(\eta^*) = \frac{\ln K}{\sqrt{\ln K/(2KT)}} + 2K\sqrt{\frac{\ln K}{2KT}} \cdot T = \sqrt{2KT\ln K} + \sqrt{2KT\ln K} = 2\sqrt{2KT\ln K}.$$

This gives $\mathbb{E}[\mathrm{Regret}] \leq 2\sqrt{2KT\ln K} \approx 2.83\sqrt{KT\ln K}$, which is already $O(\sqrt{KT\ln K})$.

**For the exact $3\sqrt{KT\ln K}$ bound**: Use the slightly simpler parameter choice $\eta = \sqrt{\ln K/(KT)}$ and $\gamma = K\eta = \sqrt{K\ln K/T}$. Then each of the three terms in (7) equals $\sqrt{KT\ln K}$:

- $\frac{\ln K}{\eta} = \frac{\ln K}{\sqrt{\ln K/(KT)}} = \sqrt{KT \ln K}$.
- $\eta KT = \sqrt{\frac{\ln K}{KT}} \cdot KT = K\sqrt{T\ln K} \cdot \frac{\sqrt{T}}{\sqrt{1}} = \sqrt{KT\ln K} \cdot \sqrt{K}$... 

Let me compute carefully:
$$\eta KT = \sqrt{\frac{\ln K}{KT}} \cdot KT = KT \cdot \frac{\sqrt{\ln K}}{\sqrt{KT}} = \sqrt{K} \cdot \sqrt{T} \cdot \sqrt{\ln K} = \sqrt{KT\ln K}.$$

$$\gamma T = K\eta \cdot T = K \cdot \sqrt{\frac{\ln K}{KT}} \cdot T = \sqrt{K} \cdot \sqrt{\frac{\ln K}{T}} \cdot T = \sqrt{K} \cdot \sqrt{T\ln K} = \sqrt{KT\ln K}.$$

Therefore:

$$\mathbb{E}[\mathrm{Regret}] \leq \sqrt{KT\ln K} + \sqrt{KT\ln K} + \sqrt{KT\ln K} = 3\sqrt{KT\ln K}.$$

**Validity check**: We need $\gamma = \sqrt{K\ln K/T} \leq 1/2$, which holds when $T \geq 4K\ln K$. For smaller $T$, the regret is at most $T$ anyway (since per-round loss difference is at most 1), and $3\sqrt{KT\ln K} \geq 3\sqrt{K \cdot 4K\ln K \cdot \ln K} = 6K\ln K \geq 4K\ln K \geq T$, so the bound is vacuously true.

---

### Summary of the Five Key Ingredients

| Step | Content | Bound |
|------|---------|-------|
| 1 | Unbiasedness of $\hat{\ell}_t$ | $\mathbb{E}[\hat{\ell}_t(i) \mid \mathcal{F}_{t-1}] = \ell_t(i)$ |
| 2 | Exp-weights potential | $\sum_t \langle \tilde{p}_t, \hat{\ell}_t\rangle - \sum_t \hat{\ell}_t(i) \leq \frac{\ln K}{\eta} + \frac{\eta}{2}\sum_t \langle \tilde{p}_t, \hat{\ell}_t^2\rangle$ |
| 3 | Variance control | $\mathbb{E}[\langle \tilde{p}_t, \hat{\ell}_t^2\rangle] \leq K/(1-\gamma) \leq 2K$ |
| 4 | Mixing cost | Switching $p_t \to \tilde{p}_t$ costs $\gamma$ per round |
| 5 | Parameter tuning | $\eta = \sqrt{\ln K/(KT)}$, $\gamma = K\eta$ gives $3\sqrt{KT\ln K}$ |

$$\boxed{\mathbb{E}[\mathrm{Regret}] \leq 3\sqrt{KT \ln K}}$$

$$\tag*{Q.E.D.}$$
