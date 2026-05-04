# C1 — SHB no-acceleration on F (OP-2 downgraded)

**Path**: `proofs/research/optimization/lower-bounds/shb-no-acceleration-restricted/`
**Verdict**: **NOVEL (extension)**

## Our statement
For every $(\beta,\eta) \in \mathcal{F}$ (Goujaud cycling feasibility region), there exists an $L$-smooth, $\kappa(\beta,\eta)L$-strongly-convex function $f_{\beta,\eta} : \mathbb{R}^3 \to \mathbb{R}$, an unbiased oracle of variance $\le \sigma^2$, and an initial state with $\|x_0-x^\star\|\le D$, such that for **all $T \ge 1$**:
$$
\mathbb{E}[f(x_T)-f^\star] \ge \frac{\kappa(\beta,\eta)}{4}\cdot\frac{LD^2}{T} + \frac{1}{8\sqrt 2}\cdot\frac{\sigma D}{\sqrt T}.
$$
$\mathcal{F}$ is non-empty for $\beta > \beta^\star = (\sqrt{13}-3)/2$. Construction: 2-D Goujaud polytope-Moreau function rescaled by $1/D$ + 1-D Le Cam variance coordinate with quadratic wall, in $\mathbb{R}^3$.

## Literature

### GPT 2023 (arXiv:2307.11291) — Goujaud–Taylor–Dieuleveut
- Setting: **strongly convex μ > 0** quadratics (and convex extensions). The abstract states "either the worst-case rate is not accelerated (slower than 1−O(κ)), or there exists an L-smooth μ-strongly convex function such that HB does not converge" — this is the **non-acceleration / cycling dichotomy** for the strongly convex regime.
- Their cycling inequality (GTD-cyc) involves $\kappa = \mu/L$ as a fixed positive parameter; the cycling region $\mathcal{F}$ is parameterized by $(\beta,\eta,\kappa,K)$.
- They prove cycling for HB on **strongly convex** functions, not non-SC.

### Ghadimi 2015 (arXiv:1412.7457) — Ghadimi-Feyzmahdavian-Johansson
- Setting: **deterministic heavy ball** on smooth convex functions.
- Result: Cesaro average converges at $O(1/k)$ (function gap), linear under strong convexity.
- Does NOT cover stochastic SHB nor lower bounds.

### Lan 2012 — accelerated stochastic approximation (AC-SA)
- Upper bound $O(LD^2/T^2 + \sigma D/\sqrt T)$ for accelerated stochastic methods on smooth convex functions.

### Nemirovski-Yudin 1983
- Universal lower bound $\Omega(\sigma D/\sqrt T)$ for any first-order stochastic algorithm on convex Lipschitz problems. Constant $1/(8\sqrt 2)$ is folklore.

## Comparison

| Aspect | GPT 2023 | Ghadimi 2015 | Lan 2012 | OUR C1 |
|---|---|---|---|---|
| Setting | Det. HB, μ>0 SC | Det. HB, convex | AC-SA, stoch convex | Stoch SHB, μ→0 limit |
| Type | Non-accel dichotomy | Upper $O(1/k)$ | Upper $O(1/T^2 + 1/\sqrt T)$ | LB $\Omega(LD^2/T + \sigma D/\sqrt T)$ |
| Scope | All $(\beta,\eta)$ | Cesaro avg | All algorithms | $(\beta,\eta) \in \mathcal{F}$ only |
| T-uniform LB | N/A | N/A | N/A | YES, all $T \ge 1$ |
| Construction dim | abstract | abstract | abstract | $\mathbb{R}^3$ explicit |

## Novelty assessment

**This is a genuinely novel extension** of GPT 2023 to:
1. The **stochastic** setting (GPT is deterministic);
2. The **μ→0 limit** treated honestly: μ = κL > 0 is held fixed but $\mathcal{F}$ characterization captures the small-κ behavior;
3. **3-D wall construction** combining Goujaud cycling (bias) + 1-D Le Cam (variance) — not in any prior work;
4. **T-uniform lower bound with explicit constants** $c(\beta,\eta) = \kappa/4$, $c_{NY} = 1/(8\sqrt 2)$.

Result is **honestly downgraded** — quantification is over $\mathcal{F} \subsetneq \mathcal{S}$ (not all of stability region), and the $\mathcal{S}\setminus\mathcal{F}$ case (where deterministic SHB achieves geometric convergence on Goujaud instances) is flagged OPEN. The proof's §9 explicitly discusses what's NOT covered.

## Verdict

**NOVEL extension of GPT 2023 / matching the Ghadimi 2015 upper bound from below**. The honest restriction to $\mathcal{F}$ is exemplary scientific practice — the original problem's claim over all of $\mathcal{S}$ may be false (Section 9 candidly admits this).

The lower bound $\Omega(LD^2/T)$ on $\mathcal{F}$ + Lan 2012's $O(LD^2/T^2)$ upper bound for AC-SA rigorously establishes "SHB does NOT accelerate on $\mathcal{F}$" — this is the first such tight lower bound in the literature for non-quadratic SHB.
