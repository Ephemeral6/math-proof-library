# Direction 1 — Bias-only tightness (σ = 0)

**Verdict: FEASIBLE — but the result REFRAMES OP-2's claim rather than confirming the original $\Omega(LD^2/T)$ tightness.**

**Effort:** Low (4–6 hours; the numerical experiment + Floquet argument is already in `gap1_proof.md`).

## Question

In deterministic SHB ($\sigma = 0$) on the Goujaud K=3 polytope-Moreau function $f_0$, what is the rate at which $f_0(x_T) - f_0^\star$ decays, separately in cycling vs non-cycling parameter regimes?

## Numerical evidence (`d1_d6_bias_only.py`, mpmath dps=50, σ=0)

| Regime | $(\beta, \eta L, \kappa)$ | $f_0(x_{10000}) - f_0^\star$ | Comparison to $\kappa LD^2/(23 T)$ at $T=10^4$ |
|---|---|---|---|
| Cycling, OP-2 init | (0.8, 3.247, 0.387) | **0.2373** | $1.4 \times 10^5 \times$ LB (LB massively loose) |
| Cycling, zero-mom init | (0.8, 3.247, 0.387) | **0.2373** | same — cycling regardless of init |
| Period-6, zero-mom init | (0.9, 3.78, 0.05) | **0.9157** | $> 10^5 \times$ LB |
| Non-cycling, low β | (0.3, 1.5, 0.2) | $\sim 0$ (numerical zero by $T=10^3$) | exponential decay, much faster than $1/T$ |
| Non-cycling, mid β | (0.6, 2.5, 0.25) | $\sim 0$ (numerical zero by $T=3000$) | exponential decay |

## Core insight

The deterministic SHB last iterate has **two regimes**, neither of which has rate $\Theta(LD^2/T)$:

1. **Cycling regime** ($\mathcal F^{\text{cycle}}_{K=3}$ established in Gap 1): the orbit reaches a period-3 attractor with $\|x_t\| = \lambda$ and $f_0(x_T) = $ constant $\approx 0.24 \cdot LD^2$ for all $T \ge T_0$. This is **STRICTLY WORSE** than the OP-2 LB of $\Omega(LD^2/T)$. The actual rate is $\Theta(1)$.

2. **Non-cycling regime**: orbit converges exponentially to $x^\star = 0$ with linearized rate $\beta^{3/2} < 1$. So $f_0(x_T) = O(\beta^{3T})$. This is **STRICTLY FASTER** than the OP-2 LB.

## Implications for tightness

- **OP-2's Ω(LD²/T) lower bound is correct** (a true LB at every $T$), but **NOT TIGHT in either regime**. The cycling regime has rate $\Theta(1)$ (LB is loose by factor $T$); the non-cycling regime has rate $\Theta(\exp(-cT))$ (LB is loose exponentially).

- **Bias-only "tightness" against the trivial UB $f(x_0) - f^\star \le LD^2/2$**: in cycling regime, both LB and UB are $\Theta(LD^2)$ constants — **TIGHT in rate**.

## Strongest tight statement (for OP-2 v6 §4.2)

> **Theorem (bias-only, deterministic).** On a positive-measure subset $\mathcal F^{\text{cycle}}_{K=3} \subset \mathcal F_{K=3}$, deterministic SHB ($\sigma = 0$) on the Goujaud K=3 polytope-Moreau function with **either** OP-2 init **or** zero-momentum init satisfies
> $$\liminf_{T \to \infty} (f_0(x_T) - f_0^\star) \;\ge\; c_F^{\text{bias}} \cdot LD^2 \;>\; 0,$$
> where $c_F^{\text{bias}} = \kappa^2/4$ at the cycle floor (anchor: $c_F^{\text{bias}} \approx 0.24$). This **constant** lower bound is the tight rate; it matches the trivial upper bound $f(x_0) - f^\star \le LD^2/2$ up to a factor depending only on $\kappa$.

## What it does not solve

- The variance term LB $\Omega(\sigma D/\sqrt T)$ is unaffected — this direction is bias-only.
- It changes the LB from $\Omega(LD^2/T)$ to $\Omega(LD^2)$, which is a **stronger statement** but **not the form Li Xiao asked about**. He asked for matching UB to the $1/T$ rate; we now show the $1/T$ rate isn't even the right *order* — the actual rate is constant.

## Risk / caveat

This direction *upgrades* OP-2's claim from "$\Omega(1/T)$ lower bound" to "$\Omega(1)$ lower bound on a positive-measure subset". This is a **better paper claim** but requires Li Xiao and other reviewers to accept the reframing. If the OP-2 community is anchored on the $1/T$ rate as a benchmark (because GFJ15 and Cesàro upper bounds are $1/T$), this stronger statement might be perceived as "moving the goalposts".

## Recommendation

**HIGH PRIORITY.** The numerical evidence is overwhelming (140000× LB-vs-actual gap). This direction transforms OP-2's contribution from "LB matching Cesàro UB" (which Li Xiao correctly identified as gap-y) into "the cycling regime gives a constant-floor LB strictly worse than the Cesàro UB". The "strict gap" framing is cleaner and more interpretable.
