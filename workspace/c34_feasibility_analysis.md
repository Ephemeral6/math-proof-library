# C3.4 — Feasibility Analysis (pre-proof)

**Conjecture**: Non-negative coarse Ricci curvature of the per-step SGD Markov kernel implies HRS-style uniform stability $\beta_T \le 2L \sum_t \alpha_t / n$, hence generalization gap $\le \beta_T$.

This document answers 5 feasibility questions. **No proof is attempted.**

---

## Q1. Minimum noise injection for non-degenerate coarse Ricci curvature

Define, for a Markov kernel $P$ on $\mathbb{R}^d$,
$$\kappa(x,y) = 1 - \frac{W_1\!\big(P(\cdot \mid x), P(\cdot \mid y)\big)}{\|x - y\|}, \qquad \kappa = \inf_{x \ne y} \kappa(x,y).$$

We examine three SGD variants.

### (a) Pure SGD (no noise)
Per-index kernel $P^i_\alpha(\cdot \mid x) = \delta_{x - \alpha \nabla f_i(x)}$ is **deterministic**, so
$$W_1(P^i(\cdot|x), P^i(\cdot|y)) = \|x - \alpha \nabla f_i(x) - y + \alpha \nabla f_i(y)\|.$$
Coarse Ricci $\kappa^i \ge 0$ ⟺ the per-index map is non-expansive ⟺ (when $f_i$ smooth) $\alpha \le 2/\beta$ AND $f_i$ convex (co-coercivity). **In the non-convex smooth case, $\kappa^i = -\alpha\beta < 0$**: pure SGD is curvature-degenerate.

The aggregated kernel $P_\alpha(\cdot|x) = \frac{1}{n}\sum_i P^i_\alpha(\cdot|x)$ is supported on $n$ atoms; under synchronous coupling $\kappa$ inherits the per-index sign.

**Conclusion (a)**: pure SGD has $\kappa \ge 0$ **iff HRS hypotheses hold**. C3.4 does not exceed HRS in this regime.

### (b) SGD + isotropic Gaussian (vanishing-noise SGLD)
Kernel $P_\alpha(\cdot|x) = \mathcal{N}\!\big(x - \alpha \nabla f(x), \, 2\alpha\tau I\big)$ with temperature $\tau \ge 0$.

Synchronous coupling of the two Gaussians cancels the noise:
$$W_1(P_\alpha(\cdot|x), P_\alpha(\cdot|y)) \le \|x - \alpha\nabla f(x) - y + \alpha\nabla f(y)\|.$$
Identical to deterministic case ⇒ **synchronous coupling is insensitive to additive noise**, so naive Gaussian injection does not help.

**Reflection coupling** is the right tool: under dissipativity $\langle\nabla f(x) - \nabla f(y), x-y\rangle \ge m\|x-y\|^2 - K$ outside a compact, reflection coupling gives $W_1$ contraction at rate $\sim m$ for sufficiently large $\tau$. This is Eberle's framework (and its discrete-time analog studied by Durmus–Moulines, Cheng–Bartlett 2018).

**Conclusion (b)**: vanishing-noise SGLD with reflection coupling gives $\kappa > 0$ under **dissipativity + temperature large enough**. This is the minimal non-trivial regime where C3.4 extends HRS.

### (c) Full SGLD (noise = $\sqrt{2\alpha\tau}\xi$, fixed $\tau > 0$)
Same kernel as (b), but $\tau$ not vanishing. Coarse Ricci is governed by the smoothed potential $f_\tau = -\tau \log(P_\alpha \cdot e^{-f/\tau})$. Bakry–Émery / log-Sobolev under positive curvature of $f_\tau$ gives $\kappa > 0$. This is the regime where existing literature (Vempala–Wibisono, Erdogdu–Mackey, [2305.12056](https://arxiv.org/abs/2305.12056)) operates.

### Verdict
- Min noise for non-degenerate $\kappa \ge 0$ **without** assuming convexity = SGLD-style Gaussian injection paired with **reflection** (not synchronous) coupling under dissipativity.
- For purely synchronous-coupling analysis (what HRS does), additive Gaussian buys nothing — convexity of each $f_i$ remains necessary.

---

## Q2. HRS coupling metric and the W₁-bridge

### What HRS actually uses
- **Metric**: $\delta_t = \mathbb{E}_{\{i_t\}}[\|w_t - w_t'\|]$ — expectation over shared random-index sequence; **pointwise on parameters**.
- **Coupling**: synchronous on $\{i_t\}$; **deterministic** (non-coupling) on the parameter level — both copies update with the *same* gradient when $i_t \ne j$.
- **Step contraction**: pointwise $\|w_{t+1} - w_{t+1}'\| \le \|w_t - w_t'\|$ (a.s., not just in expectation), via co-coercivity.

This is **stronger than $W_1$ contraction**, because $W_1$ gives only an *infimum* over couplings:
$$W_1(P\delta_x, P\delta_y) \le \|w_{t+1} - w_{t+1}'\|_{\text{synchronous}}.$$
Going from $W_1$ contraction back to a pointwise statement is **not free**.

### What's needed to bridge $W_1$ contraction → HRS-style sup stability

| Need | Source / cost |
|---|---|
| (i) Lipschitz loss $\ell(\cdot, z)$ | Already in HRS. Gives $|\mathbb{E}\ell(w_T^S, z) - \mathbb{E}\ell(w_T^{S'}, z)| \le L \cdot W_1(\text{law}(w_T^S), \text{law}(w_T^{S'}))$ via Kantorovich–Rubinstein. |
| (ii) Conversion $W_1$-stability ⇒ uniform stability | Use *expected* uniform stability (Bousquet–Elisseeff is fine with $\mathbb{E}|\ell - \ell'|$). HRS's "sup over $z$" is automatic from Lipschitz. |
| (iii) Inhomogeneity bound: $W_1\!\big(P^S_\alpha(\cdot|w), P^{S'}_\alpha(\cdot|w)\big) \le 2\alpha L / n$ | From triangle on synchronous coupling: with prob $1/n$ the index hits $j$ and the gradient differs by $\le 2L$; with prob $1-1/n$ the kernels coincide exactly. Holds **without** any curvature hypothesis. |
| (iv) Iterate the recursion $W_1(\mu_{t+1}, \nu_{t+1}) \le (1 - \kappa)W_1(\mu_t, \nu_t) + 2\alpha L/n$ | From (iii) + $\kappa \ge 0$. |

So the **bridge needs no new hypothesis** beyond (a) Lipschitz loss (already there) and (b) "$\kappa \ge 0$ for the per-step kernel against the *same* dataset." Crucially, the inhomogeneity step (iii) is a routine triangle-inequality observation that does **not** require curvature.

**One subtlety**: HRS's bound is *almost-sure* in the random-index sequence, so it gives a stronger generalization bound (with high-probability tails). The $W_1$-route gives only **in-expectation** stability. For Bousquet–Elisseeff-style generalization this is sufficient; for high-probability generalization (Feldman–Vondrák) the $W_1$ route loses information.

### Verdict on Q2
HRS's metric is stronger than $W_1$, but for the **expected** stability bound that drives Bousquet–Elisseeff generalization, the $W_1$-contraction route reproduces the same $2L\sum\alpha_t/n$ rate without extra assumptions. **No genuine cost** in the bridge — except that a high-probability bound is downgraded to in-expectation.

---

## Q3. When does "uniform $\kappa \ge 0$" hold?

### (a) Quadratic loss $f_i(w) = \tfrac12 (a_i^\top w - b_i)^2$
Per-index map $w \mapsto w - \alpha (a_i^\top w - b_i) a_i = (I - \alpha a_i a_i^\top) w + \alpha b_i a_i$. Linear with operator norm $\max(|1 - \alpha\|a_i\|^2|, 1) = 1$ when $\alpha \le 2/\|a_i\|^2$. **$\kappa = 0$ uniformly**, attained along $a_i$-orthogonal directions.

For the *mixture* kernel $\frac{1}{n}\sum_i$: synchronous coupling still gives $\kappa = 0$. ✓

**Holds** iff $\alpha \le 2 / \max_i \|a_i\|^2$.

### (b) Strongly convex $\mu$, $\beta$-smooth
Co-coercivity sharpens to: per-index step contracts by $(1 - \alpha\mu)$ (when $\alpha \le 2/(\mu + \beta)$, in the optimal range). So **$\kappa \ge \alpha\mu > 0$ uniformly**. Strict positivity gives exponential stability $\beta_T = O(1/(\mu n))$ independent of $T$, **better than HRS's $T/n$**. ✓

**Holds robustly.**

### (c) General non-convex smooth
Per-index map: $\|w - \alpha\nabla f_i(w) - w' + \alpha\nabla f_i(w')\| \in [(1-\alpha\beta)\|w-w'\|, (1+\alpha\beta)\|w-w'\|]$. Lower bound on $W_1$ comes from the worst (expanding) direction — at saddles or near maxima, $\nabla^2 f_i \prec 0$ gives expansion. **$\kappa = -\alpha\beta < 0$ generically.**

To restore $\kappa \ge 0$ in non-convex case:
- **Add Gaussian noise** + use **reflection** coupling: under dissipativity $\langle \nabla f, x \rangle \ge m\|x\|^2 - K$ outside ball $B$, get $\kappa > 0$ at rate $\sim m \cdot \alpha$ on the *aggregated* SGD+noise kernel. But this is **distance-dependent**: $\kappa(x,y) > 0$ only for $\|x-y\|$ large enough (Eberle's regime). True **uniform** $\kappa \ge 0$ over all pairs requires globally dissipative + sufficient noise.
- **PL-condition + smoothness**: not enough on its own; PL only controls function value, not parameter-distance contraction.
- **Manifold / non-Euclidean SGD**: positive sectional curvature of the parameter manifold can give $\kappa \ge 0$ even for non-convex objective, but this is exotic.

### Verdict on Q3
| Regime | $\kappa \ge 0$? | Notes |
|---|---|---|
| Quadratic, $\alpha \le 2/\|a_i\|^2$ | YES (=0) | Exactly HRS convex case. |
| Strongly convex smooth | YES (>0) | Strictly positive — beats HRS. |
| General non-convex smooth (no noise) | NO | $\kappa < 0$ generically. |
| Non-convex + Gaussian noise + dissipativity | Distance-dependent | Reflection coupling gives positive curvature only outside a coupling ball; "uniform $\kappa \ge 0$" fails. |
| Non-convex on positively-curved manifold | Sometimes | Exotic — depends on geometry. |

**The "uniform $\kappa \ge 0$ for non-convex" hypothesis is fragile**: it does not hold under any standard regularity condition on $f$ alone.

---

## Q4. Minimal-strength assumption list

For the target theorem
> *"Uniform $\kappa \ge 0$ ⇒ uniform stability $\beta_T \le 2L \sum_t \alpha_t / n$, hence generalization gap $\le \beta_T$"*:

| # | Assumption | Provenance |
|---|---|---|
| A1 | Loss $\ell(\cdot, z)$ is $L$-Lipschitz, uniformly in $z$. | **Identical to HRS.** |
| A2 | Bounded step sizes $\alpha_t > 0$. | **Identical to HRS.** |
| A3 | Per-step Markov kernel $P_\alpha(\cdot \mid x; z)$ has uniform coarse Ricci $\kappa(x, y) \ge 0$ for all $x, y$, all data $z$, all $\alpha \le \alpha_0$. | **NEW geometric assumption.** *Sufficient* via "convex + $\alpha\le 2/\beta$" (recovers HRS). *Necessary* nowhere. |
| A4 | Inhomogeneity bound: $\sup_x W_1\!\big(P^S_\alpha(\cdot|x), P^{S'}_\alpha(\cdot|x)\big) \le 2\alpha L / n$ for neighboring $S, S'$. | **Implied by A1 + the $1/n$-coupling structure of leave-one-out.** Not a real new assumption. |

### Strength comparison

- A1, A2: same as HRS.
- A3: **strictly weaker than HRS's "convex $\beta$-smooth + $\alpha \le 2/\beta$"** in the sense that A3 ⇐ HRS hypothesis but not the converse. The strict-weakness bites in:
  - Noise-injected non-convex kernels with $\kappa \ge 0$ (the Eberle / log-Sobolev regime).
  - Non-Euclidean parameter spaces (manifolds, graphs) where "convex" is undefined but coarse Ricci is.
  - Non-smooth Lipschitz losses where co-coercivity fails but kernel curvature can still hold post-noise-injection.
- A4: weaker than HRS's pointwise $2\alpha L$ drift bound (which is implied by A1).

### Where the contribution lives

- **In the convex smooth case**: A3 ≡ HRS. **No new theorem.**
- **In the SGLD non-convex case** (Eberle / dissipative): A3 holds in a *distance-dependent* way (only outside a coupling ball). Forcing uniform A3 means restricting to globally log-concave or globally dissipative — for which $W_1$-stability is already in [2305.12056](https://arxiv.org/abs/2305.12056), via Lyapunov rather than curvature.
- **In non-Euclidean / discrete settings**: A3 is the natural condition (Ollivier's home turf). HRS doesn't apply at all here. **This is the genuine gap** — and the genuine value of C3.4.

---

## Q5. Blocker assessment and revised theorem statement

### Risk roll-up

| Risk | Severity | Resolvable? |
|---|---|---|
| (R1) Pure SGD's coarse Ricci is degenerate ⇒ A3 ≡ HRS in convex case ⇒ no new content there. | **High but expected.** | Yes — by restricting the contribution claim to non-convex/non-Euclidean. |
| (R2) Uniform A3 in non-convex Euclidean setting requires globally log-concave smoothing ⇒ overlap with [2305.12056](https://arxiv.org/abs/2305.12056). | **Medium.** | Distinguish via *technique* (curvature vs. Lyapunov) and via *generality* (works on manifolds/discrete spaces). |
| (R3) Reflection coupling for noisy non-convex SGD gives only distance-dependent $\kappa \ge 0$, not uniform. Theorem hypothesis can fail in the very regime where it would matter most. | **High.** | **Genuine blocker** for "non-convex Euclidean" scope. Resolvable only by relaxing A3 to "$\kappa(x,y) \ge -L_0/d(x,y)$" or restricting to coupled-down ball — both significantly complicate the statement. |

### Verdict

**R3 is a blocker** for the Euclidean non-convex extension under the cleanest hypothesis. R1 is expected (the convex case reduces to HRS, that's a feature). R2 is overlap, not blocker.

The clean version of C3.4 is therefore **not** a stronger HRS for SGD on $\mathbb{R}^d$. It is a clean reformulation that pays off when one **leaves Euclidean space** or **adds enough regularity that A3 holds globally**.

### Revised theorem statement

**Theorem (C3.4-revised).** Let $(\mathcal{W}, d)$ be a Polish metric space and $P_\alpha^z : \mathcal{W} \to \mathcal{P}(\mathcal{W})$ a family of Markov kernels indexed by data $z$ and step $\alpha \in (0, \alpha_0]$. Suppose:

1. **(Lipschitz loss)** $\ell(\cdot, z)$ is $L$-Lipschitz in $d$, uniformly in $z$.
2. **(Bounded leave-one-out sensitivity)** For every $w$ and neighboring $S, S'$: $W_1\!\big(\bar P^S_\alpha(\cdot | w), \bar P^{S'}_\alpha(\cdot | w)\big) \le 2\alpha L / n$ where $\bar P^S = \frac{1}{n}\sum_{z \in S} P^z$.
3. **(Non-negative coarse Ricci)** $\bar P^S_\alpha$ has $\kappa \ge 0$ uniformly over $S$ and $\alpha \le \alpha_0$.

Then the SGD-style algorithm $w_{t+1} \sim \bar P^S_{\alpha_t}(\cdot | w_t)$ has uniform stability $\beta_T \le \frac{2L}{n}\sum_t \alpha_t$ in expectation, and Bousquet–Elisseeff generalization gap $\le \beta_T$.

**Corollaries**:
- (Recovers HRS) On $\mathbb{R}^d$ with each $\ell(\cdot, z)$ convex $\beta$-smooth and $\alpha \le 2/\beta$: hypothesis 3 holds via co-coercivity.
- (Strongly convex) $\kappa \ge \alpha\mu$ ⇒ stability $O(1/(\mu n))$ independent of $T$.
- (Graph SGD / GNN training) On graph-structured parameter spaces with non-negative graph Ricci.
- (Manifold SGD) On positively-curved Riemannian manifolds via Bakry–Émery.

This statement **explicitly does not claim** to extend HRS in non-convex Euclidean SGD. The contribution is geometric reformulation + reach into non-Euclidean domains.

### Recommendation

**Proceed with C3.4** but **scope it down to the revised statement above.** Specifically:
- Don't claim a new non-convex Euclidean result; the regime where uniform $\kappa \ge 0$ holds non-trivially is already covered by [2305.12056](https://arxiv.org/abs/2305.12056) under different hypotheses.
- Lead with the manifold / graph / discrete-space corollaries as the genuine novelty.
- Spend effort on at least one concrete non-Euclidean example (e.g., SGD on Stiefel manifold for orthogonality-constrained NN training, or SGD on graph-structured probabilistic model) where the curvature condition is verifiable and HRS literally does not apply.

**Do not abandon for C1.4** unless the manifold/graph corollary cannot be made concrete. C1.4 (STORM-MCMC) is also a strong candidate but would be a **second** project — pursuing C3.4 first is preferable because (a) the proof template is essentially HRS verbatim once A3 is assumed, (b) the geometric reframing is genuinely useful pedagogically, (c) concrete non-Euclidean examples expose new applications the optimization-theory community has not connected to HRS.

**Fallback condition**: if no concrete non-Euclidean example admits a verifiable non-negative coarse Ricci hypothesis after a focused literature pass on graph-Ricci-based SGD, then C3.4 collapses to "rephrasing HRS." In that case **switch to C1.4**.
