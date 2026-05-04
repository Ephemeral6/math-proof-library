# Notes: Fixed-momentum SHB last iterate does not accelerate on $\mathcal{F} \subset$ stability region

## Proof technique

**Winning route: Route G + G' hybrid.** Fixer combined:
- Route G's T-independent $\mu = \kappa(\beta,\eta) L$ trick (avoids the $\mu = L/T$ trap that kills the sharp version).
- Route G''s rescaling Lemma R1 (cycle radius matched to $D$-budget by $\lambda = \sqrt 2/D$).

The core identity: on Goujaud's cycling function at fixed $\mu = \kappa L > 0$, deterministic HB with parameters $(\beta, \eta)$ produces a position-pinned cycle at radius $D$, giving $f(x_T) - f^\star \geq \mu D^2 / 2 = \kappa LD^2 / 2$, which dominates $\kappa LD^2/(4T)$ for all $T \geq 1$ trivially.

## Key steps

1. **Define $\mathcal{F}$** as the Goujaud cycling feasibility region: $(\beta - c_K)L\eta \geq (1-c_K)(1+\beta^2-2\beta c_K)$ for some $K \geq 3$.
2. **Construct $f_{\beta,\eta}$** via Goujaud-Taylor-Dieuleveut 2023 polytope-Moreau envelope $\psi_P$ with $\mu = \kappa(\beta,\eta) L > 0$ chosen so the cycle lives on a regular $K$-gon.
3. **Cycle identity**: $P_{\text{conv}(P)}(e_t) = M e_t$ where $M$ is the SHB linear operator. The cycle orbit radius is $\rho(\beta, h) \cdot D$, $\mu$-independent.
4. **Strong-convexity lower bound**: $f(x_T) - f^\star \geq (\mu/2)\|x_T - x^\star\|^2 = \kappa LD^2/2$.
5. **Extend to non-SC via**: $\kappa LD^2/2 \geq (\kappa/4) LD^2/T$ for $T \geq 1$. Function is $\kappa L$-SC with small $\kappa$; problem.md allows $\mu \geq 0$.
6. **Variance term**: 1-D coordinate with zero function + Rademacher noise + Le Cam two-point with bounded quadratic wall; gives $\geq (1/(8\sqrt 2)) \sigma D/\sqrt T$.

## Audit result

**Round 1**: PASS_RESTRICTED with 6 gaps (G1 domain, G2 T-uniformity, G3-G6 minor).

**Round 2**: PASS — all gaps closed. Step 0.5 adversarial simulation confirmed:
- On $\mathcal{F}$: $f(x_T) = 0.4444$ constant at all $T$, cycle drift $\sim 10^{-16}$.
- On $\mathcal{F}^c$: $f(x_{100}) < 10^{-30}$, geometric convergence — confirms theorem is false here on tested instances.

## Related results

- **Goujaud-Taylor-Dieuleveut 2023/2025** (arXiv:2307.11291): strongly-convex non-acceleration. Our theorem extends to non-SC on $\mathcal{F}$.
- **Ghadimi-Feyzmahdavian-Johansson 2015** (arXiv:1412.7457): matching upper bound $O(LD^2/T + \sigma D/\sqrt T)$. Combined, $\Theta(LD^2/T + \sigma D/\sqrt T)$ is TIGHT on $\mathcal{F}$.
- **Lan 2012**: AC-SA achieves $O(LD^2/T^2 + \sigma D/\sqrt T)$. SHB bias is a full factor of $T$ slower.
- **Kidambi et al. 2018**: empirical SHB failure; we give the rigorous lower bound.

## What's left open

$\mathcal{F}^c$ (small-$\beta$ / small-$\eta$ regime) remains OPEN. Empirically, SHB *does* accelerate there on all tested instances — the full ∀-∃ theorem in problem.md may be genuinely FALSE on $\mathcal{F}^c$. Resolution requires either a non-Goujaud hard instance (unknown) or an upper bound proof showing SHB *does* accelerate on $\mathcal{F}^c$.

## Historical context

This is the **first original theorem** produced by the math-proof-agent V3 pipeline. The workflow caught three explorer errors (via Judge + Step 0.5 simulation) and converged to the honest restricted statement. The sharp $\exists f\,\forall(\beta,\eta)$ version was attempted earlier and failed (see `workspace/archive/failed_proof_work_20260417_op2/`); this downgraded ∀-∃ version is the tractable analog, and its restriction to $\mathcal{F}$ is itself a non-trivial finding.
