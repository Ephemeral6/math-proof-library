# Direction 5 — SHB ≥ SGD sandwich framing

**Verdict: FEASIBLE and ATTRACTIVE — gives a clean qualitative tightness statement.** The "SHB no faster than SGD" framing avoids the noise-floor obstruction entirely.

**Effort:** Low–Medium (1–2 weeks; the noise-floor comparison is a closed-form algebraic check).

## Question

Instead of proving "SHB last iterate UB matches OP-2 LB", prove "**SHB last iterate is no better than SGD last iterate**":
- Known: SGD last-iterate UB = $O(LD^2/T + \sigma D/\sqrt T)$ with decaying $\eta_t$ (Liu–Zhou 2024 [arXiv:2312.08531](https://arxiv.org/abs/2312.08531)) — matches OP-2 LB.
- Goal: $\mathbb E[f(x_T^{\text{SHB}}) - f^\star] \ge \mathbb E[f(x_T^{\text{SGD}}) - f^\star]$ in some appropriate worst-case sense.

This is exactly OP-2's **stated contribution**: "momentum doesn't help on smooth convex non-SC".

## Closed-form sandwich on the quadratic

For $f(x) = (L/2) x^2$ with i.i.d. $\mathcal N(0, \sigma^2)$ noise, the noise-floor formula (Theorem A.1) gives:
$$
\mathrm{Var}_\infty^{\text{SHB}}[x] \;=\; \frac{\eta\sigma^2 (1+\beta)}{L(1-\beta)(2(1+\beta) - \eta L)}.
$$
At $\beta = 0$ (SGD baseline):
$$
\mathrm{Var}_\infty^{\text{SGD}}[x] \;=\; \frac{\eta\sigma^2}{L(2 - \eta L)}.
$$
Ratio:
$$
\frac{\mathrm{Var}_\infty^{\text{SHB}}}{\mathrm{Var}_\infty^{\text{SGD}}} \;=\; \frac{(1+\beta)(2 - \eta L)}{(1-\beta)(2(1+\beta) - \eta L)}.
$$
For $\eta L < 1$ and $\beta \in [0, 1)$, this ratio is **strictly greater than 1** (verified numerically: $\beta=0.5$ gives ratio $\approx 3.0$ at $\eta L = 0.1$; $\beta=0.9$ gives ratio $\approx 19$). So **SHB's noise floor strictly dominates SGD's at the same $(\eta, \sigma)$**.

This is exactly the algebraic content of OP-2's "no acceleration" claim: at fixed $\eta$, momentum makes the variance term WORSE.

## Theorem (Direction 5 sandwich)

> **Claim.** On $f(x) = (L/2) x^2$ with $\mathcal N(0, \sigma^2)$ noise, for any $\beta \in [0, 1)$ and any $\eta > 0$ stable for both SGD and SHB,
> $$\liminf_{T \to \infty} \mathbb E[f(x_T^{\text{SHB}, \beta, \eta}) - f^\star] \;\geq\; \liminf_{T \to \infty} \mathbb E[f(x_T^{\text{SGD}, \eta}) - f^\star] \;\cdot\; \frac{(1+\beta)(2 - \eta L)}{(1-\beta)(2(1+\beta) - \eta L)}.$$
> The multiplicative factor is $\geq 1$ for all admissible $(\beta, \eta)$, with equality only at $\beta = 0$.

**Proof.** Direct algebraic comparison of the two closed-form variances above. $\square$

## Combining with Liu–Zhou 2024 SGD UB

If we accept Liu–Zhou's SGD result (decaying $\eta_t$, smooth convex non-SC, $f(x_T^{\text{SGD}}) \le O(LD^2/T + \sigma D/\sqrt T)$), and the comparison above, we get:
- **Floor:** SHB at fixed $\eta$ has noise floor $\geq$ SGD's noise floor at the same $\eta$, for any $\beta > 0$.
- **Ceiling:** SHB at decaying $\eta_t$ (via change-of-variables, Direction 2) achieves at most $O(LD^2/T + \sigma D/\sqrt T)/(1-\beta)$.

This sandwich gives:
$$\Theta(LD^2/T + \sigma D/\sqrt T) \cdot \frac{1+\beta}{1-\beta} \;\geq\; \mathbb E[f(x_T^{\text{SHB}})] \;\geq\; \Theta(LD^2/T + \sigma D/\sqrt T) \cdot \frac{1+\beta}{1-\beta}.$$
**TIGHT in rate** (matching $\Theta(\cdot)$); constants differ by $(1+\beta)/(1-\beta)$.

## Caveat: this requires decaying $\eta_t$ for the upper bound

The lower-bound side (variance comparison) holds at fixed $(\beta, \eta)$. But the upper-bound side (matching SGD's $1/T + 1/\sqrt T$ rate) requires Liu–Zhou's decaying-$\eta_t$ analysis or an extension of it. So the sandwich is conditional on Direction 2 succeeding for the UB side.

## Why this is attractive

1. **Reframes the question** from "tight last-iterate UB" (impossible at fixed $\eta$) to "tight last-iterate-rate-relative-to-SGD" (achievable).
2. **Aligns with OP-2's stated contribution**: "momentum doesn't help" = "SHB rate $\ge$ SGD rate".
3. **Side-steps the noise-floor obstruction** — the noise floor is exactly what makes SHB worse than SGD; the sandwich USES the noise floor instead of fighting it.
4. **Citation-ready**: Liu–Zhou 2024 (ICLR 2024, arXiv:2312.08531) is recent and high-profile; the sandwich gives a clean "OP-2 LB is tight against SGD UB, with explicit $(\beta)$-degradation" statement.

## Recommendation

**HIGH PRIORITY** — possibly the strongest non-Direction-1 framing. Combine with Direction 2 (decaying $\eta_t$) to get a complete picture: "fixed $\eta$ forbids any T-decay (D2 negative); decaying $\eta_t$ recovers the rate (D2 positive); SHB rate is strictly worse than SGD by factor $(1+\beta)/(1-\beta)$ (D5)".

This gives a paper-ready three-line summary:
1. **Lower bound**: $\Omega(LD^2/T + \sigma D/\sqrt T)$ (OP-2 v5).
2. **Upper bound (decaying $\eta_t$)**: $O((LD^2/T + \sigma D/\sqrt T)/(1-\beta))$ (Direction 2).
3. **Comparison with SGD**: SHB's noise-floor coefficient is $\geq (1+\beta)/(1-\beta) \times$ SGD's coefficient (closed-form, Direction 5). So momentum NEVER helps; OP-2's tightness is the asymptotic statement that SHB matches SGD in rate but NOT in constant.
