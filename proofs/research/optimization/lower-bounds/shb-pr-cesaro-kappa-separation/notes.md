# Notes — Polyak–Ruppert κ²-Amplification over Cesàro for SHB on SC quadratics

## Proof technique

**Winning route**: Route F — Modulus / algebraic identity tracking via Vieta + change of variable $w = 1 - r$.

The route reparametrizes the slow-mode characteristic polynomial $r^2 - (1+\beta-\eta\mu)r + \beta = 0$ via $w = 1-r$ to get $w^2 - (s+u)w + u = 0$ with $s = 1-\beta$, $u = \eta\mu$. Vieta on this transformed polynomial gives $w_1 w_2 = u$ and $w_1 + w_2 = s + u$, from which the slow root expansion $w_1 = u/s \cdot (1 + O(u/s^2))$ falls out cleanly when $u \ll s^2$ (the over-damped slow-mode condition).

This change-of-variable trick is more elegant than the alternative approaches (closed-form quadratic formula expansion, matrix companion-form computation, Z-transform). It directly produces both leading order and explicit error terms.

## Key steps

1. **Spectral decomposition** + Vieta → central identity $(1-r_1)(1-r_2) = \eta\lambda$ (regime-independent).
2. **Over-damped slow-root expansion**: $1 - r_{1,\mu} = \eta\mu/(1-\beta) + O((\eta\mu)^2/(1-\beta)^3)$.
3. **Cesàro and PR slow-mode asymptotics**: $\bar x_T^{(\mu)} \sim A_\mu(1-\beta)/(T\eta\mu)$ and $\tilde x_T^{(\mu)} \sim 2A_\mu(1-\beta)^2/(T^2(\eta\mu)^2)$.
4. **Slow-mode dominance** (μ-mode dominates L-mode by $\Theta(\kappa)$ in Cesàro and $\Theta(\kappa^3)$ in PR).
5. **Final ratio** with explicit constant: $4(1-\beta)^2\kappa^2/(T^2(\eta L)^2)$.

## Audit result

PASS in Round 1. All 8 numbered steps VALID, 0 INVALID. Zero HIGH/MEDIUM issues. One LOW-severity refinement noted (the proof's Step 7 attribution of κ=10 deviation to "$1+o(1)$" is more honestly understood as a regime mismatch, since at $\beta=0.7$ the over-damped slow-mode condition $\eta\mu < (1-\sqrt\beta)^2 = 0.0267$ requires $\kappa > 38$ for $\eta L = 1$, hence $\kappa = 10$ is outside the theorem's scope).

The auditor's 50-digit mpmath verification of the central identities (Vieta's $(1-r_1)(1-r_2) = \eta\lambda$ to $10^{-50}$ accuracy; slow-root expansion with predicted $O(1/\kappa)$ relative error) provided strong corroboration of the proof's algebraic moves.

## Related results

- **Numerical proposer**: `workspace/proposer/kappa_blowup_search/top_conjecture.md` — the heuristic discovery that motivated this proof. The numerical sweep at 50-digit precision across 14400 (β, ηL, κ, T) settings established the κ²/κ⁴ scaling with R² = 1.000.
- **Closest cousin**: `proofs/research/optimization/convergence/polyak-ruppert-shb-defeats-cycling/` — proves PR averaging beats last-iterate on the Goujaud cycling instance (different regime: $|r| = 1$ unit-modulus). Our setting has $|r| = \sqrt\beta < 1$ geometric decay.
- **Companion result**: `proofs/research/optimization/convergence/shb-pr-average-kappa-blowup/` (related κ-blowup phenomenon).

## Why this matters

This is an **iterate-type lower bound for Polyak–Ruppert averaging**. The folklore expectation is that PR averaging — emphasizing later iterates — performs at least as well as Cesàro on smooth strongly convex problems. The opposite is true asymptotically for SHB: PR's quadratic weighting amplifies the slow-mode bias by an extra factor of $\kappa^2$.

Practical implication: for SHB-type momentum methods on ill-conditioned problems, **Cesàro averaging strictly dominates Polyak–Ruppert averaging** in the asymptotic constant. (Without averaging, the last iterate decays geometrically and is even better; both averages pay a κ-amplification penalty that the last iterate avoids.)

## Open directions

- **Stochastic SHB.** Adding gradient noise: PR has lower variance ($\sigma^2/T$ scale) but worse bias ($\kappa^2$ amplification). The bias-variance tradeoff determines an optimal averaging rule per κ-regime.
- **Drop the quadratic / exact-Hessian assumption.** For C²-smooth μ-strongly-convex objectives, the slow-mode dominance argument should generalize via local quadratic approximation; the κ² ratio should hold modulo lower-order terms.
- **Suffix averaging.** Empirically tracks the last iterate (no κ-amplification once last has converged) — consistent with discarding the early bad iterates that drive Cesàro/PR amplification.
