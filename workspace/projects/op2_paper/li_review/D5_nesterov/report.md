# D5 — Polyak vs Nesterov Momentum Separation on OP-2's Hard Instance

> **NOTE (2026-04-26):** This is the first-pass report. A careful re-run with WebFetch
> access to GTD23 (arXiv:2307.11291) and a closed-form triangle projection is in
> [`rerun_v2.md`](./rerun_v2.md). The re-run **upgrades the verdict**: it constructs
> an explicit Nesterov-cycling matrix $M^{\mathrm{Nes}}$ producing a Goujaud-style
> NAG counter-example on a non-empty feasibility region $\mathcal F^{\mathrm{Nes}}$,
> generally disjoint from $\mathcal F^{\mathrm{HB}}$. The NAG analogue of OP-2's
> $\Omega(\mu D^2)$ lower bound transfers structurally. Some numerical claims below
> (notably the period-2 norms $\{0.187, 0.919\}$) are refined by the closed-form
> projection to $\{0.184, 0.920\}$; the divergence at $(0.9, 3.5)$ is confirmed genuine.

**Date:** 2026-04-26
**Status:** PARTIAL — qualitative observation only; no clean rate separation on OP-2 instance
**Superseded by:** [`rerun_v2.md`](./rerun_v2.md) — careful re-analysis with NAG-cycling polytope construction

## Verdict

The cycling identity in OP-2 (Lemma 2.6) is **provably Polyak-specific** at the algebraic level. Empirically, Nesterov on OP-2's instance does *not* trace the $K=3$ cycle — it admits its own attractor (period-2 orbit, period-1 fixed point, or divergence). However, **Nesterov also does not converge to $0$** on $f_0$ in any of the tested $\mathcal{F}$ regimes: $\liminf f_0(x_t) > 0$ in two regimes, and divergence in the third. So a clean **Polyak $\Omega(1/T)$ vs Nesterov $O(\rho^T)$ separation does NOT hold on OP-2's instance.**

## Algebraic check (Sub-Q1)

Canonical Nesterov form: $y_t = x_t + \beta(x_t - x_{t-1})$, $x_{t+1} = y_t - \eta \nabla f(y_t)$.

Suppose by induction $(x_{t-1}, x_t) = (\lambda e_{t-1}, \lambda e_t)$ with $\lambda = D/\sqrt 2$. Then
$$y_t = \lambda\bigl[(1+\beta)e_t - \beta e_{t-1}\bigr].$$

**The cycling argument breaks at the gradient evaluation.** OP-2's proof uses the rescaled projection identity $P_{\widetilde C}(\lambda e_t) = \lambda M e_t$, valid only at vertices $\lambda e_t$. The lookahead point $y_t$ is **not** a vertex of $\widetilde P$:
- At $(\beta,\eta L) = (0.5, 3)$, $K=3$: polytope vertices have norm $\approx 0.490$; $\|y_0\| = \lambda\sqrt{1 + 3\beta + 3\beta^2} = 1.275$ — far outside $\mathrm{conv}(\widetilde P)$.
- $d_{\widetilde C}(y_0) = 0.885 \ne 0$, so the Moreau term is active in a different way than at a vertex.

The Polyak identity $\eta\nabla f_0(\lambda e_t) = \lambda[(1+\beta)e_t - e_{t+1} - \beta e_{t-1}]$ is genuinely Polyak-specific.

## Numerical experiment (Sub-Q2)

Setup: rescaled Goujaud $f_0$, $L=D=1$, $K=3$, cycling-init. Projection onto $\mathrm{conv}(\widetilde P)$ via SLSQP. $T = 500$ (confirmed at $T = 2000$).

| $(\beta, \eta L)$ | $\kappa$ | Polyak HB (proven cycle) | Nesterov |
|---|---|---|---|
| $(0.5, 3.0)$ | $0.251$ | $\|x_T\| = 0.7071$, $f_0 = 0.2222$ | **period-2 orbit**, alternating norms $\{0.187, 0.919\}$, $f_0 \in \{0.0175, 0.2523\}$ |
| $(0.7, 2.9)$ | $0.337$ | $\|x_T\| = 0.7071$, $f_0 = 0.2415$ | **fixed point**, $\|x_T\| = 1.091$, $f_0 = 0.3842$ |
| $(0.9, 3.5)$ | $0.398$ | $\|x_T\| = 0.7071$, $f_0 = 0.2354$ | **diverges**, $\|x_{500}\| \sim 6\cdot 10^{16}$, $f_0 \sim 8\cdot 10^{32}$ |

Sanity check: Nesterov on plain quadratic $(\mu/2)\|x\|^2$ converges to 0 at all three pairs in 500–2000 steps. Non-convergence on $f_0$ is caused by the Moreau wall term, not algorithmic instability.

## Why OP-2's cycling argument breaks for Nesterov (Sub-Q3)

Polyak cycle uses two ingredients:
(a) **Vertex projection identity** $P_C(e_t) = M e_t$ (GTD23 KKT), valid *only* at the special points $e_t$.
(b) **Polyak's algebraic identity**: gradient queried at $x_t = $ vertex; (a) applies; clean cancellation produces the cycling formula.

Nesterov's lookahead $y_t = (1+\beta)e_t - \beta e_{t-1}$ (after factoring $\lambda$) is a non-trivial linear combination of two cycle points; lies *outside* $\mathrm{conv}(\widetilde P)$. So $P_{\widetilde C}(y_t)$ is some boundary point chosen by KKT, and the gradient is not a clean linear combination of $e_t, e_{t\pm 1}$. The simple vertex-cycling closure fails.

## Rate consequence on the 3-D OP-2 instance (Sub-Q4)

Decoupling (Claim 2.5) holds for any method running separately on each block. So:

- **Bias term ($x$-block).** Polyak's $\Omega(LD^2/T)$ proof uses Lemma 2.6's $\|x_t\| \equiv D/\sqrt 2$ to lower-bound $f_0(x_T) \ge \mu D^2/4$. For Nesterov, $\|x_T\|$ doesn't equal $D/\sqrt 2$ but is bounded away from 0 in Cases A and B, and diverges in C. **In Cases A/B, $\liminf f_0(x_t) > 0$, so $f_0(x_T) - f_0^\star \ge c'(\beta,\eta) > 0$** — Nesterov also fails to converge on the OP-2 instance, just by a different mechanism (different attractor, not exact $K$-cycle).
- **Variance term.** $y$-block is shared with Polyak; Le Cam argument transfers verbatim (uses only oracle structure). Nesterov retains $\Omega(\sigma D/\sqrt T)$.

## Implication for "publishable separation" (Sub-Q5)

- *Does Nesterov satisfy the same cycle identity?* **NO** — Polyak-specific.
- *Does Nesterov accelerate / converge geometrically on OP-2 instance?* **NO** — own non-zero attractor in Cases A/B, divergence in Case C.
- **The would-be publishable separation does not happen on OP-2's instance.** A genuinely separating Nesterov-side hard instance would need to be built fresh.

## GTD23 cross-check (Sub-Q6)

GTD23 (arXiv:2307.11291) proves the cycling theorem only for fixed-momentum heavy-ball (Polyak form). The cycling theorem is algorithm-specific to HB. Whether GTD23 §4 has a Nesterov-specific cycling region not loaded into the local repo cannot be verified in read-only mode; would need WebFetch.

## Bottom line

- Cycling identity is **provably Polyak-specific** (clean theoretical observation).
- Empirically Nesterov has **different non-zero dynamics** on OP-2 instance (period-2/period-1/divergent).
- **No clean Polyak-vs-Nesterov rate separation** on OP-2 instance: bias is also $\Omega(1)$ asymptotically for Nesterov.
- A separating instance would need fresh construction, possibly along GTD23 §4 lines.

The high-value claim is downgraded: the OP-2 hard instance does not yield a publishable Polyak-vs-Nesterov rate separation. What it does yield is a clean *qualitative* observation worth a remark in the paper.
