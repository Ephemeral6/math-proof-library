# Notes — A2 / fixed-momentum SHB stationary-point LB

## Proof technique

**Orthogonal non-convexity** (the central insight of Phase 3).

The Goujaud cycling skeleton from OP-2 v5 lives on a $\R^2$ subspace and gives
a constant-in-T LB on the gradient norm at the cycle vertex. To lift this to a
**non-convex** function-class member, we add a third coordinate $z$ with a
non-convex bump $h(z) = (L/2)z^2 e^{-z^2/D^2}$ that:

- has $h'(0) = 0$ and no $z$-noise (so the SHB iterate is dynamically pinned at $z = 0$),
- is non-convex globally because $h''(D) = -2L/e < 0$.

Hence the function $f^{(s)}$ is in the L-smooth non-convex class, but the
SHB iterate's trajectory is contained in the $z = 0$ hyperplane where $f^{(s)}$
restricts to a convex subfunction. The non-convex saddles of $f^{(s)}$ at
$(0, \mp s D/\sqrt 2, \pm D)$ are at distance $\geq D\sqrt{3/2}$ from the cycle;
the iterate never approaches them. This sidesteps Sun et al. IJCAI 2019's
strict-saddle escape result entirely.

The cycling identity itself is **verbatim from OP-2 v5 / GTD23 Lemma 1.3(iv)**.
The new ingredient is the algebraic μ-cancellation in §5.2 of the proof:
$$\mu\,e_t + (L-\mu)\,M e_t \;=\; \frac{(1+\beta)\,e_t - e_{t+1} - \beta\,e_{t-1}}{\eta},$$
which makes the LB constant μ-independent (the convex bias LB in OP-2 v5 was
$\mu D^2/4$, scaling with $\mu$; the non-convex gradient LB is $3D^2(1+\beta+\beta^2)/(2\eta^2)$,
NOT scaling with $\mu$).

## Key steps

1. **Cycling identity** (OP-2 v5 Lemma 1.3(iv) verbatim): SHB on $f_0$ with non-zero-velocity init $x_0 - x_{-1} = (D/\sqrt 2)(e_0 - e_{K-1})$ produces $x_t = (D/\sqrt 2) e_{t \bmod K}$.

2. **z-invariance** (induction on $t$): $z_0 = z_{-1} = 0$ and $h'(0) = 0$ imply $z_t = 0$ path-wise for every realization of $\xi_t$. This is what makes the LB hold path-wise (not just in expectation).

3. **μ-cancellation**: the algebraic identity in §5.2 of the proof shows the gradient norm at the cycle vertex is exactly $D^2/(2\eta^2) \cdot \|(1+\beta)e_t - e_{t+1} - \beta e_{t-1}\|^2$, with no μ dependence.

4. **K=3 norm computation**: $\|(1+\beta)e_0 - e_1 - \beta e_2\|^2 = 9(1+\beta)^2/4 + 3(1-\beta)^2/4 = 3(1+\beta+\beta^2)$.

5. **Combine**: $B_{\mathrm{NC}}(\beta, \eta) = 3D^2(1+\beta+\beta^2)/(2\eta^2)$.

6. **Variance term** (Frame 2): a separate Le Cam two-point argument adapted to the gradient norm metric (sidestepping the L-smooth-gap-direction issue via direct sign-vs-gradient algebra) gives $\E_s[\|\nabla_y f^{(s)}\|^2] \geq \sigma^2/(27T)$.

7. **Two-regime LB**: $\max\{\sigma^2/(27T), B_{\mathrm{NC}}\}$ — the cycling constant dominates after $T_0 = 2\sigma^2 \eta^2 / [81 D^2 (1+\beta+\beta^2)]$.

## Audit result

- All 8 numerical sanity checks PASS to machine precision (Hessian eigenvalue table, ‖h''‖_∞ = L, μ-cancellation symbolic, wall-gradient ≥ α on misidentification event, etc.).
- All 4 constants in the LB (3, $D^2$, $1+\beta+\beta^2$, $1/(2\eta^2)$) traced to specific lines.
- All 5 failure-pattern warnings from `workspace/failure_patterns.md` respected (non-quadratic, ∇²f(x*)≠L locally, ∀-∃, last-iterate, non-zero-velocity init).
- All 7 citations web-search verified (no Pedregosa-style hallucination); 3 LOW/MEDIUM citation hygiene defects fixed by Phase 5c Fixer.
- Phase 6 numerical gate: 19/19 PASS (4 (β,η) pairs, 5 μ values at 100 dps, 4 SGD-escape tests, 3 σ Monte Carlo, 3 L-smoothness checks).

## Related results

- **OP-2 v5** (`workspace/op2_proof_v5.tex`): convex bias-term LB on $\E[f(x_T) - f^*]$. A2 is the non-convex stationary-point analog.
- **GTD23** (arXiv:2307.11291): the cycling skeleton (deterministic convex strongly-convex).
- **Arjevani et al. 2019/2023** (arXiv:1912.02365): minimax LB $\Omega(\Delta L \sigma^2/\varepsilon^4)$. A2 is **orthogonal** (algorithm-specific, not minimax).
- **Sun et al. IJCAI 2019** (arXiv:1907.09697): deterministic HB a.s. avoids strict saddles. **Sidestepped** by orthogonal-non-convexity.
- **Okamura et al. 2024** (arXiv:2406.06100): HB-ODE attains $\varepsilon^{-7/4}$ under Lipschitz Hessian. **Sidestepped** because $f_0$ is $C^{1,1}$ but not $C^2$.
- **Yan et al. 2018** (arXiv:1808.10396): SHB UB $O(L\Delta/T + L\sigma^2/\sqrt T)$ matching SGD. **Compatible** with A2 (UB is algorithm-class statement; A2 says the worst-case constant is bounded below by $B_{\mathrm{NC}}$).
- **Polyak-Ruppert SHB κ-blow-up** (`shb-pr-average-kappa-blowup`): companion result on SC quadratics. Together with A2, paints a coherent picture: fixed-momentum SHB has multiple algorithm-specific suboptimalities across function classes and iterate types.
- **SHB cycling critical momentum** (`shb-cycling-critical-momentum`): proves $\beta^\star = (\sqrt{13}-3)/2$ is sharp; A2 inherits this threshold (below $\beta^\star$, ℱ_{K=3} is empty and A2 vacuous).

## Floquet stability of the cycle (from Frame 6)

The 3-step Floquet multipliers of the SHB iterate map at $(\beta, L\eta, \mu/L) = (0.5, 2.8, 0.01)$ are $\lambda_+^3 = 0.831$, $\lambda_-^3 = 0.150$ — both $< 1$, so the cycle is **asymptotically stable** in the (x, x_{-1}) phase space. As μ → 0, $\lambda_+^K \to 1$ (neutral in the rotation direction), explaining the init-sensitivity observed in OP-2 v5 §5.4 and FP-OP2-CYCLING-INIT-BASIN-DEPENDENCE.

## Categorical formulation: not natural

Frame 6 attempted to formulate the cycling-induced LB as a functor in a category of optimization algorithms × function classes. The honest answer is: **no natural functorial structure exists**. The LB is inherently algorithm-specific (transports falsely under Alg morphisms) and class-specific (not contravariant under class inclusion). The closest existing literature is Rebjock–Boumal 2024's metric-KL framework (metric-space-theoretic, not categorical).

## Numerical certification (Phase 6 gate)

| Gate | Sub-checks | Status |
|---|---|---|
| G1 | B_NC closed-form on 4 (β, η) pairs | 4/4 PASS, rel_err ≤ 4e-16 |
| G2 | μ-independence at 100 dps (5 μ values) | 5/5 PASS, abs err ≤ 10⁻¹⁰¹ |
| G3 | SGD escape on 4 instances | 4/4 PASS, ‖∇f‖² ~ 10⁻⁸ |
| G4 | Monte Carlo (3 σ values, T sweep) | 3/3 PASS, flat in T |
| G5 | L-smoothness (h, w, f₀ blocks) | 3/3 PASS |

Total: 19/19 PASS, no Stop-4 trigger.
