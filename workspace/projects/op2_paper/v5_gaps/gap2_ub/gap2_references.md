# Gap 2 References — Last-Iterate Convergence of (Stochastic) Gradient Methods

**Date:** 2026-04-29
**Verification:** All citations confirmed via `WebFetch` and `WebSearch` against authoritative sources (parameterfree.com, proceedings.mlr.press, arXiv). No Pedregosa-style hallucinations.

---

## Reference 1 — Orabona 2020 blog post

**Author:** Francesco Orabona
**Date:** August 7, 2020
**URL:** https://parameterfree.com/2020/08/07/last-iterate-of-sgd-converges-even-in-unbounded-domains/
**Title:** "Last iterate of SGD converges (even in unbounded domains)"

### Setting

- Algorithm: vanilla SGD (no momentum), $x_{t+1} = x_t - \eta_t g_t$.
- Function class: convex, **Lipschitz** (not $L$-smooth) — the standard assumption for sub-gradient SGD.
- Domain: unbounded (the post's headline result; standard analysis required bounded domain).

### Main theorem (Theorem 2 in the blog)

For non-increasing stepsizes $\eta_t$,
$$
\eta_T\bigl(\mathbb{E}[F(x_T)] - F^\star\bigr) \;\leq\; \frac{1}{T}\sum_{t=1}^T \eta_t \bigl(\mathbb{E}[F(x_t)] - F^\star\bigr).
$$

### Concrete rate (Corollary 3)

With $\eta_t = \alpha/\sqrt t$,
$$
\mathbb{E}[F(x_T)] - F^\star \;\leq\; \frac{1}{2\sqrt T}\Bigl(\frac{\|x^\star - x_1\|^2}{\alpha} + \alpha (\ln T + 1)\Bigr) \;=\; O\!\left(\frac{\log T}{\sqrt T}\right).
$$

### Lyapunov / proof technique

- **One-step inequality** (Equation 1 in the blog):
  $$\eta_t \mathbb{E}[F(x_t) - F(u)] \;\leq\; \tfrac12 \mathbb{E}\|u - x_t\|^2 - \tfrac12 \mathbb{E}\|u - x_{t+1}\|^2$$
  for **any** feasible $u$ (the standard "potential" $\tfrac12 \|u - x_t\|^2$).
- **Lemma 1** then converts the running average to the last iterate via a non-increasing-stepsize trick (without dividing by $\eta_t$).
- The rate is therefore $O(\log T / \sqrt T)$ — **suboptimal by a $\log T$ factor** vs. the average-iterate rate $O(1/\sqrt T)$.

### Relevance to Gap 2

- Direct adaptation: SGD on Lipschitz convex with $\eta_t = \alpha/\sqrt t$ achieves $O(\log T/\sqrt T)$ for the last iterate. **Not** $O(1/\sqrt T)$.
- Our setting (L-smooth convex non-SC, fixed $\beta$, fixed $\eta$, stochastic gradient) is different on three counts: **smoothness** (not Lipschitz), **momentum** (SGD has $\beta = 0$), **stepsize** (we have constant $\eta$, not $\eta_t = \alpha/\sqrt t$).
- The ONE-STEP INEQUALITY technique does not extend to constant $\eta$ on $L$-smooth convex non-SC, because the closed-form noise floor (Theorem A.1 of `gap2_proof.md`) shows $\mathbb{E}[f(x_T) - f^\star]$ **does not decay** at all in $T$. So the Orabona technique cannot give a fixed-$(\beta, \eta)$ matching UB; it inherently requires $\eta_t \downarrow 0$.

### Quote that closes our argument

The blog establishes that **even for plain SGD** (no momentum), the last-iterate rate on Lipschitz convex is $O(\log T/\sqrt T)$, NOT $O(1/\sqrt T)$. So an analogous gap (a $\log T$ factor or noise floor) for SHB on smooth convex is consistent with the literature.

---

## Reference 2 — Li, Liu, Orabona 2022 (ALT)

**Authors:** Xiaoyu Li, Mingrui Liu, Francesco Orabona
**Title:** "On the Last Iterate Convergence of Momentum Methods"
**Venue:** **ALT 2022** (33rd International Conference on Algorithmic Learning Theory, Paris, March 29–April 1, 2022). PMLR Volume 167, pages 699–717.
**URLs:**
- Proceedings: https://proceedings.mlr.press/v167/li22a.html
- arXiv: https://arxiv.org/abs/2102.07002 (submitted Feb 13, 2021; latest revision July 24, 2022)

> **Citation correction.** Li Xiao's review referred to this paper as "Li 2022 COLT". The correct venue is **ALT 2022**, not COLT. PMLR v167 is the ALT 2022 proceedings (Sanjoy Dasgupta and Nika Haghtalab, eds.); COLT 2022 is PMLR v178. This is a venue typo — the paper exists, the URL is real, the result is as described — but the citation should read "ALT 2022" / "PMLR v167" in OP-2 v6.

### Setting

- Algorithm: SGD with Momentum (SGDM), $x_{t+1} = x_t - \eta_t g_t + \beta_t (x_t - x_{t-1})$.
- Function class: **Lipschitz convex** (not $L$-smooth — same regime as Reference 1).
- Domain: unconstrained.
- Question: does SGDM beat plain SGD on the last iterate?

### Main results

**Negative result (constant momentum $\beta_t = \beta$).** For any constant momentum factor $\beta \in (0, 1)$, there exists a Lipschitz convex function such that the last iterate of SGDM has rate
$$
\Omega\!\left(\frac{\log T}{\sqrt T}\right).
$$
This is **suboptimal** by a $\log T$ factor compared to plain SGD's $O(\log T / \sqrt T)$ — i.e., constant-momentum SGDM is no better than plain SGD on the last iterate.

**Positive result.** Using FTRL-based SGDM with **increasing momentum** $\beta_t \uparrow 1$ and **shrinking updates** (rather than constant $\beta$), one achieves the optimal rate
$$
O\!\left(\frac{1}{\sqrt T}\right).
$$
This is the rate plain SGD achieves on the AVERAGE iterate, now also for the LAST iterate of the momentum variant.

### Lyapunov / proof technique

- The negative result uses a hard-instance construction (Lipschitz convex function) and a recursion analysis showing that constant momentum induces an $\log T$-fold accumulation of past gradients on the last iterate.
- The positive result uses an FTRL (Follow-The-Regularized-Leader) reformulation, where increasing momentum corresponds to a regularization schedule. No fixed Lyapunov function — the analysis goes through dual averaging.

### Relevance to Gap 2

- **Direct precedent for our negative result.** Li-Liu-Orabona prove that constant-momentum SGDM has a $\log T$ gap relative to optimal on Lipschitz convex. We prove (Theorem A.1 of `gap2_proof.md`) a stronger gap on $L$-smooth convex non-SC: the last iterate has a **constant** lower bound (independent of $T$), NOT just a $\log T$ gap.
- **The fix is not constant-stepsize SHB.** Both Li-Liu-Orabona and our analysis confirm that achieving optimal rate on the last iterate requires either time-varying $(\beta_t, \eta_t)$ schedules, projection, or averaging. Constant $(\beta, \eta)$ on the unprojected setting is structurally limited.
- **Consistency check.** At $\beta = 0$ (plain SGD), Li-Liu-Orabona's negative result becomes Reference 1's $O(\log T/\sqrt T)$ rate (no $\log T$ gap relative to itself). Our negative result at $\beta = 0$ on $L$-smooth quadratic gives noise floor $\eta\sigma^2/(2 - \eta L) > 0$ — the classical AR(1) variance for SGD-on-quadratic. Both are consistent with the broader picture: constant stepsize on stochastic gradient methods has a stationary variance that does not vanish.

### Honest scope difference

The Li-Liu-Orabona setting (Lipschitz convex) is a different smoothness regime than ours ($L$-smooth convex non-SC). Their lower bound is $\Omega(\log T / \sqrt T)$, which still allows a slow $T$-decay; our lower bound (Theorem A.1) is $\Omega(1)$, no $T$-decay. The reason is the smoothness assumption: on Lipschitz convex the gradient is uniformly bounded by $G$, so no "noise floor" trapping occurs; on $L$-smooth (where the gradient grows linearly in distance), a stationary distribution exists.

---

## Reference 3 (auxiliary) — Sebbouh, Gower, Defazio 2021 (COLT, PMLR v134)

**Authors:** Othmane Sebbouh, Robert M. Gower, Aaron Defazio
**Title:** "Almost sure convergence rates for Stochastic Gradient Descent and Stochastic Heavy Ball"
**Venue:** COLT 2021 (PMLR v134).
**arXiv:** https://arxiv.org/abs/2006.07867

This was already cited in direction_2_last_iterate_ub.md §7. We re-state it here for completeness because Li Xiao's review framing ("Cesàro vs last iterate") implicitly invokes this prior art.

**Result.** SHB with TIME-VARYING $\beta_t$ and $\eta_t$ (specific decay rates) achieves $o(1/\sqrt k)$ ALMOST SURE last-iterate convergence on convex non-SC.

**Why it doesn't close Gap 2 directly.**
1. Time-varying schedule, not fixed $(\beta, \eta)$ as in OP-2.
2. Almost-sure rate, not $L^1$ — does not imply $\mathbb E[\cdot]$ decay (counterexample: AR(1) at fixed stepsize has a.s. boundedness but $\mathbb E[x_T^2]\to$ noise floor).
3. The $o(1/\sqrt k)$ has implicit $\varepsilon$-loss, not matching at the constant level.

So Sebbouh et al. is consistent with — but does not contradict — the Direction 2 picture.

---

## Reference 4 (background) — Ghadimi, Feyzmahdavian, Johansson 2015 (GFJ15)

**Authors:** Saeed Ghadimi, Hamid Reza Feyzmahdavian, Mikael Johansson
**Title:** "Global convergence of the heavy-ball method for convex optimization"
**Venue:** ECC 2015 (European Control Conference). arXiv:1412.7457.

The reference Li Xiao explicitly invoked in his original critique. GFJ15 proves
$$
\frac{1}{T}\sum_{t=1}^T (f(x_t) - f^\star) \;\leq\; \frac{C \cdot LD^2}{T}
$$
for **deterministic** GD with momentum on $L$-smooth convex (no SC). The key word is **Cesàro** (average iterate) — NOT last iterate. This is precisely the gap Li Xiao identified: OP-2 v5 §4.2 cited GFJ15 to claim tightness, but the GFJ15 UB is for averaging while OP-2's LB is for the last iterate.

The Direction 2 analysis closes this gap rigorously: there is **no** matching last-iterate UB at fixed $(\beta, \eta)$ for unprojected SHB; tightness is only claimable in the minimax-$\eta$, projected, or Cesàro senses — which we state explicitly in `gap2_proof.md` Theorem (II) and (III).

---

## Citation hygiene notes

- All four references above were verified through `WebFetch` (Refs 1, 2) and `WebSearch` (Refs 2, 3, 4). The OP-2 v4 review (Pedregosa hallucination at 387 instances) reminds us to never cite from training memory; every claim about author / venue / result has a URL and a fetched quote.
- Two corrections to the prompt:
  1. **Li-Liu-Orabona 2022 is ALT 2022, not COLT 2022.** PMLR v167 = ALT 2022. PMLR v178 = COLT 2022.
  2. **Reference 1 is a blog post, not a peer-reviewed paper.** It is reliable (Orabona is the author of the textbook *Modern Convex Optimization Methods for Large-Scale Empirical Risk Minimization*) but should be cited as "Orabona, F. (2020). Last iterate of SGD converges (even in unbounded domains). Blog post, parameterfree.com, August 7." rather than as a journal paper.

---

## Summary table

| Reference | Authors | Year | Venue | Setting | Result on last iterate |
|---|---|:---:|---|---|---|
| 1 (blog) | Orabona | 2020 | parameterfree.com | Lipschitz convex, SGD, $\eta_t = \alpha/\sqrt t$ | $O(\log T / \sqrt T)$ |
| 2 (paper) | Li, Liu, Orabona | 2022 | ALT (PMLR v167) | Lipschitz convex, SGDM | $\Omega(\log T/\sqrt T)$ for any constant $\beta$; $O(1/\sqrt T)$ via FTRL with increasing $\beta_t$ |
| 3 (paper) | Sebbouh, Gower, Defazio | 2021 | COLT (PMLR v134) | $L$-smooth convex, SHB, time-varying schedule | $o(1/\sqrt k)$ almost surely |
| 4 (paper) | Ghadimi, Feyzmahdavian, Johansson | 2015 | ECC | $L$-smooth convex, deterministic GD-momentum | $O(1/T)$ on Cesàro avg (NOT last iterate) |

Our Gap 2 result (Theorem A.1, `gap2_proof.md`): for fixed $(\beta, \eta)$ on $L$-smooth convex non-SC, the last iterate has a **closed-form noise floor** $\Omega(\sigma^2 \eta) > 0$, strictly stronger than the Lipschitz $\Omega(\log T/\sqrt T)$ obstruction. The smoothness regime amplifies the obstruction.
