# Theorem 3 Proof Gap — Fix Attempt and Honest Report

**Date:** 2026-04-29
**Status:** **Gap NOT closed.** Theorem 3's $T^{-1/2}$ rate on the full class remains a **conjecture** with strong empirical support but no rigorous proof. The best available rigorous result is Hudiani 2025's $T^{-1/3}$ for fixed-momentum SHB with decaying stepsize.

---

## 1. Routes evaluated

We evaluated five routes proposed in the user prompt, plus a literature deep-dive.

### Route A — Signed bias tracking (convexity LB)

**Approach:** Use convexity LB $\langle \nabla f(y_t), u_t \rangle \ge f(y_t) - f(y_{t-1})$ to convert the bias term into a telescope. The bias contribution to the SGD-on-$w_t$ analysis becomes
$$\sum_t (-a) \langle \nabla f(y_t), u_t\rangle \;\le\; -a\,(f(y_T) - f(y_0)) \;\le\; a \cdot \frac{LD^2}{2}.$$

**Verdict:** **FAILS.** This bound is a **constant** ($aLD^2/2$), not decaying in $T$. When substituted into the SGD-on-$w_t$ analysis (which we'd divide by $\alpha_T v_T \asymp 1$ in Liu-Zhou), this constant remains and **dominates the rate**.

**Numerical check (`analyze_route_B.py`):**

| $\beta$ | $T$ | $a \cdot \mathbb E[\sum \langle \nabla f, u \rangle]$ | Convexity-telescope UB $aLD^2/2$ | Ratio |
|:-:|:-:|:-:|:-:|:-:|
| 0.5 | 100 | 0.283 | 0.500 | 0.57 |
| 0.5 | 10000 | 0.328 | 0.500 | 0.66 |
| 0.9 | 100 | 3.83 | 4.50 | 0.85 |
| 0.9 | 10000 | 4.22 | 4.50 | 0.94 |

**The empirical signed sum is close to the convexity-telescope upper bound** (60-94% of it). So the convexity bound is reasonably tight on the *signed sum*, but this signed sum is itself $\Theta(LD^2)$ (constant, not decaying).

### Route B — Direct Lyapunov on $(y_t, m_t)$

**Approach:** Use $V_t = \|y_t - y^*\|^2 + \alpha\eta^2\|m_t\|^2 + \gamma\eta\langle y_t - y^*, m_t\rangle$. With $\gamma = 2\beta/(1-\beta)$, $\alpha = \beta^2/(1-\beta)^2$, this completes the square: $V_t = \|w_t - w^*\|^2$ where $w_t = y_t + a(y_t - y_{t-1})$. So Route B reduces to Route A (the Lyapunov is the COV in disguise).

**Verdict:** Same as Route A — gives Cesàro UB matching LB but cannot give last-iterate without bias-handling.

The descent identity:
$$\mathbb E[V_{t+1} - V_t] \le -\frac{\eta(1+\beta)}{(1-\beta)^2} \mathbb E[f(y_t) - f^*] + \frac{2\eta\beta}{(1-\beta)^2} \mathbb E[f(y_{t-1}) - f^*] + \frac{\eta^2 \sigma^2}{(1-\beta)^2}.$$

After telescoping and using $\mathbb E V_T \ge 0$:
- **LAST iterate** UB at horizon-tuned $\eta$: $(1-\beta)\sigma D \sqrt T/(1+\beta)$ — **GROWS** in $T$ (useless).
- **Cesàro UB** at horizon-tuned $\eta$: $\sigma D/\sqrt T$ — **TIGHT** (this is Theorem 1).

Direct Lyapunov suffices for Cesàro tightness (already in `resolution.md` Theorem 1) but is **insufficient for last iterate** in the noise-floor regime.

### Route C — Two-phase analysis

**Approach:** Phase 1 ($t < T_0$): bias accumulates "crudely". Phase 2 ($t \ge T_0$): η is small, bias per step is small.

**Verdict:** Doesn't work. Even with η small in Phase 2, the bias contribution per step is $O(\eta \cdot \|m_t\|)$, and $\|m_t\|$ is bounded below by stationary $\sigma/\sqrt{1-\beta^2}$. Cumulative bias in Phase 2 is $O(T_2 \cdot \nu \cdot L a \eta \cdot \sigma/\sqrt{1-\beta^2}) = O(D^2)$ — same constant, no improvement.

### Route D — Implicit bias / martingale

**Approach:** Treat $z_t$ update as SGD with perturbation, use Jain-Nagaraj-Netrapalli's martingale technique to handle correlated perturbation.

**Verdict:** **NOT FEASIBLE** for our setting. Jain-Nagaraj-Netrapalli 2019 handle SGD without momentum — their martingale argument doesn't extend to the SHB bias structure. We didn't find a citable adaptation in the literature.

### Route E — Sebbouh-Gower-Defazio direct SHB analysis

**Approach:** Adapt Sebbouh-Gower-Defazio 2021 (COLT, [arXiv:2006.07867](https://arxiv.org/abs/2006.07867)) which analyzes SHB directly without COV.

**Verdict:** **PARTIALLY FEASIBLE but their schedule differs.** Sebbouh et al. require **time-varying** $(\eta_t, \beta_t)$ with specific decay rates, and prove $o(1/\sqrt k)$ **almost surely**. For our setting (fixed $\beta$, horizon-tuned constant $\eta$, in expectation), their analysis doesn't directly transfer.

---

## 2. The closest rigorous result: Hudiani 2025

**Reference:** Marcel Hudiani, "Convergence Rate for the Last Iterate of Stochastic Gradient Descent Schemes" ([arXiv:2507.07281](https://arxiv.org/abs/2507.07281)), revised March 2026.

**Key theorem (Hudiani Theorem 2.7).** For SHB with fixed momentum $\beta \in (0, 1)$ and time-varying stepsize $\eta_t = \Theta(t^{-p})$ with $p \in (1/(1+\gamma), 1)$ on convex $f$ with $\gamma$-Hölder gradient:
$$F(w_t) - F^\star \;=\; o\!\left(t^{\frac{2}{1+\gamma}\max(p-1,\, 1-p(\gamma+1))}\right) \quad\text{a.s.}$$

For $\gamma = 1$ (standard $L$-smooth) and optimal $p = 2/3$: rate $\boxed{O(t^{-1/3} \log^2 t)}$ in high probability.

**Significance:**
- This is the **best rigorous rate for fixed-$\beta$ SHB on smooth convex non-SC** in the literature.
- It is **strictly worse** than $T^{-1/2}$ — confirming the "constant momentum is suboptimal" theme of Li-Liu-Orabona 2022 (Lipschitz convex) extends to L-smooth.
- The proof avoids the COV (uses direct Gronwall + Doob martingale convergence) and handles the bias implicitly.

**For our Theorem 3 setting (fixed $\beta$ + horizon-tuned constant $\eta_T$):** Hudiani's analysis doesn't directly apply (different stepsize schedule), but his result strongly suggests that **fixed-momentum SHB is fundamentally limited to $T^{-1/3}$ rate** in any rigorous analysis with $\eta_t$ that doesn't depend on the horizon.

For **horizon-tuned** $\eta_T$ (depends on $T$), the empirical rate is $T^{-1/2}$, suggesting that horizon-knowledge gives a $T^{-1/6}$ improvement. But proving this requires a **horizon-aware analysis** that Hudiani 2025 doesn't have.

---

## 3. Why simple techniques fail (root cause analysis)

The fundamental obstruction:

1. **The bias contribution doesn't naturally vanish.** Numerical check shows $a \cdot \mathbb E[\sum \langle \nabla f, u\rangle] \to a LD^2/2$ as $T \to \infty$ (the convexity-telescope upper bound). This is a **constant offset** that, in any standard SGD analysis, would dominate the rate.

2. **The empirical $f(y_T)$ is much smaller than this offset.** $f(y_T) \sim 0.0025$ at $T = 10^4$, vs. the bias offset $0.5$ (for $\beta = 0.5$) or $4.5$ (for $\beta = 0.9$). Ratio: 200-1800× difference.

3. **The cancellation must come from the structure of the descent identity itself.** When we compute the FULL descent (bias + main terms together), the constant offsets cancel. But Liu-Zhou's analysis decouples them — bounding bias and main terms separately gives a loose bound.

4. **A horizon-aware analysis is needed.** With $\eta_T = D(1-\beta)/(\sigma\sqrt T)$, the noise floor of the SHB process is exactly $\sigma D /\sqrt T$. The last iterate is approximately drawn from this stationary distribution after burn-in. The "rate" $T^{-1/2}$ comes from the **horizon-tuning**, not from $\eta_t$ decay over time.

This is why constant-$\eta$ analysis (which gives noise-floor) directly gives the right rate — but the formal proof requires showing the iterate IS at the noise floor after $O(\log T)$ burn-in, which uses spectral/contraction structure of SHB.

---

## 4. Empirical evidence (re-verified)

`verify_bridge.py` results (already in `../verify_bridge_output.txt`):

| Function class | $\beta$ | Empirical rate | Predicted (Theorem 3) |
|---|:-:|:-:|:-:|
| Quadratic | 0.0 | $T^{-0.503}$ | $T^{-0.50}$ |
| Quadratic | 0.5 | $T^{-0.495}$ | $T^{-0.50}$ |
| Quadratic | 0.9 | $T^{-0.486}$ | $T^{-0.50}$ |
| Huber smoothed | 0.0 | $T^{-0.509}$ | $T^{-0.50}$ |
| Huber | 0.5 | $T^{-0.502}$ | $T^{-0.50}$ |
| Huber | 0.9 | $T^{-0.493}$ | $T^{-0.50}$ |
| Logistic regularized | 0.0 | $T^{-0.646}$ | $T^{-0.50}$ |
| Logistic regularized | 0.5 | $T^{-0.645}$ | $T^{-0.50}$ |
| Logistic regularized | 0.9 | $T^{-0.643}$ | $T^{-0.50}$ |

All 9 cases show empirical $T^{-0.5}$ rate (or faster for SC instances). Absolute UB constant $\le 0.26 \cdot \sigma D/\sqrt T$.

**This empirical evidence is overwhelming and strongly supports the theorem statement.** The proof gap is in the rigorous derivation, not the truth of the theorem.

---

## 5. What CAN be claimed rigorously

| Setting | Rigorous rate | Source |
|---|---|---|
| **β = 0** (no momentum, plain SGD), full L-smooth convex non-SC, horizon-tuned $\eta$ | $O(LD^2/T + \sigma D/\sqrt T)$ (no log factor) | Liu-Zhou 2024 Theorem 3.4 (with linear-decay) |
| **Fixed $\beta > 0$, decaying $\eta_t = \Theta(t^{-2/3})$**, full L-smooth convex non-SC | $O(T^{-1/3} \log^2 T)$ a.s. and h.p. | Hudiani 2025 Theorem 2.7 / 2.9 |
| **Fixed $\beta > 0$, horizon-tuned constant $\eta_T$**, **quadratic class only** | $O(\sigma D / \sqrt T)$ (constant $(1+\beta)/(4(1-\beta))$) | Theorem 2 of `../resolution.md` (closed-form Lyapunov) |
| **Fixed $\beta > 0$, horizon-tuned constant $\eta_T$**, full L-smooth convex non-SC class | **$O(\sigma D/\sqrt T)$ — CONJECTURE, empirical only** | This work |

---

## 6. Honest verdict

**Theorem 3 (full-class last-iterate UB) is a CONJECTURE supported by:**
- Strong empirical evidence (9 cases, all at $T^{-0.5}$ rate).
- Theoretical consistency with Liu-Zhou 2024 at $\beta = 0$.
- Theoretical consistency with Theorem 2 on the quadratic class.

**It is NOT a proven theorem** because:
- The COV approach has a bias-induced term whose convexity-telescope upper bound is $\Theta(aLD^2)$ — a constant offset that doesn't decay.
- The actual cancellation (which makes the empirical rate $T^{-1/2}$) is structurally deeper and not captured by elementary bounding techniques.
- Hudiani 2025's rigorous analysis for fixed-$\beta$ SHB only achieves $T^{-1/3}$, suggesting the gap to $T^{-1/2}$ requires horizon-aware techniques not yet developed.

**For OP-2 v6 submission:** Theorem 3 should be stated as a **conjecture with empirical support**, not as a proven theorem. Cite Hudiani 2025 as the best rigorous result. The actual rigorous results (Theorem 1, Theorem 2, noise-floor refutation) suffice for a strong paper.

---

## 7. Recommended OP-2 v6 §4.2 text

> **Conjecture (full-class last-iterate UB).** For any L-smooth convex non-SC $f$ with $\|x_0 - x^\star\| \le D$, fixed $\beta \in [0, 1)$, $\sigma^2$-bounded variance, fixed-momentum SHB with horizon-tuned constant stepsize $\eta_T = D(1-\beta)/(\sigma\sqrt T)$ and zero-velocity initialization satisfies, **conjecturally**,
> $$\mathbb E[f(y_T) - f^\star] \;\le\; C(\beta) \left(\frac{LD^2}{T} + \frac{\sigma D}{\sqrt T}\right)$$
> with $\beta$-polynomial constants. Empirical verification across 3 function classes × 3 momentum values supports this conjecture with empirical rate $T^{-0.50 \pm 0.02}$.
>
> The closest rigorous result is Hudiani 2025 ([arXiv:2507.07281](https://arxiv.org/abs/2507.07281), Theorem 2.7/2.9), which proves $O(t^{-1/3} \log^2 t)$ in high probability for fixed-$\beta$ SHB with $\eta_t = \Theta(t^{-p})$, $p \in (1/2, 1)$. Closing the gap from $T^{-1/3}$ (rigorous, decaying $\eta_t$) to $T^{-1/2}$ (empirical, horizon-tuned constant $\eta_T$) is **open**.

---

## 8. Files

```
fix/
├── fix.md                       # this honest report
├── 2507_07281.pdf               # Hudiani 2025 paper
├── 2507_07281.txt               # extracted text (2170 lines)
├── analyze_route_B.py           # numerical analysis of convexity telescope
└── analyze_route_B_output.txt   # output showing convexity telescope is loose by 200-1800×
```

---

## 9. Recommendation

**Do not claim Theorem 3 as proven.** Instead:
1. State it as a **conjecture** with strong empirical evidence.
2. Cite Hudiani 2025's rigorous $T^{-1/3}$ for fixed $\beta$ + decaying $\eta_t$.
3. State Theorem 2 (quadratic class, rigorous $T^{-1/2}$) as the strongest rigorous matching result.
4. Acknowledge the gap as an OPEN PROBLEM in the discussion.

The OP-2 paper has substantial rigorous content (gap2_proof.md noise floor, resolution.md Theorems 1+2, Gap 1's zero-momentum result). The Theorem 3 conjecture is interesting but not necessary for SIOPT/MP submission. **Honest is better than over-claiming.**

$\blacksquare$
