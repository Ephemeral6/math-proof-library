# Notes — Coordinate-wise AdaGrad under (L0,L1)-smoothness with affine noise

## Verdict

**PARTIAL.** The original conjectured rate $\widetilde{O}(d^{1/3} T^{-1/3})$ from problem.md was NOT achieved by this pipeline. The proven rate is

$$
\min_{0 \le t \le T-1} \mathbb{E}\bigl[\|\nabla f(x_t)\|_1\bigr] \le \widetilde{O}\!\left( d^{7/8}\, \sigma_0^{1/2}\, (\Delta_0 L_0)^{1/4}\, T^{-1/4} \right).
$$

The user noted that Jiang–Maladkar–Mokhtari (COLT 2025) reportedly achieve $d^{1/3} T^{-1/3}$. We did not read that paper; the structural ingredient that lifts $T^{-1/4}$ to $T^{-1/3}$ remains a future-work bridge identified in the proof's Discussion §D5 as a `[SUB-PROBLEM:...]` candidate.

## Proof technique

**Winning route**: Reduction (Frame 5) — re-instantiated as Option-(b) honest downgrade after the original $d^{1/3} T^{-1/3}$ claim was refuted by Auditor R1.

The integrated proof builds on the Reduction chassis:
- Per-coordinate Taylor descent under coordinate-wise $(L_0, L_1)$-smoothness.
- Predictable surrogate $\sqrt{v_{t-1, i}}$ (technique imported from the AMSGrad chassis).
- Young's inequality on the $L_1\|\nabla f\|$ cross-coupling residual (option-(b) substitute for the failed 3-term AM-GM).
- Honest $\sqrt{d}$ tracking: the conversion from coordinate-wise quantities to $\|\cdot\|_1$ pays an extra $\sqrt d$ that no clean Hölder $(3/2, 3)$ argument absorbs without gradient sparsity.

## Key steps

1. Coordinate-wise descent lemma derived from the $(L_0, L_1)$ assumption (no use of standard global $L$-smoothness).
2. Per-coordinate AdaGrad accumulator telescoping: $\sum_t g_{t,i}^2 / v_{t,i} \le \log(v_{T,i} / \varepsilon^2)$.
3. The genuine **2-term AM-GM** balancing the descent gain $\eta \|\nabla f\|^2$ against the noise term $\eta^2 \sigma_0^2 \log T$. There are only TWO distinct $\eta$-powers; the affine-noise term $\sigma_1^2 (\partial_i f)^2$ produces a constraint $\eta \le \varepsilon / (\sqrt d (L_0 + L_1 G)(1 + \sigma_1^2))$, NOT a third independent $\eta$-power.
4. Conversion to $\ell_1$ via Hölder over coordinates yields the $d^{7/8}$ exponent (rather than $d^{1/3}$) because the $\sigma_1^2$ self-bounding does not lift cleanly from scalar Faw–Tziotis–Caramanis–Mokhtari–Shakkottai–Ward 2022 to the joint coord-wise framing.

## Audit result

- **Round 1**: FAIL_CONTRADICTION. The "3-term AM-GM" in Step 5.5 was unsupported (only 2 distinct $\eta$-powers genuinely available); three independent route calculations confirm $d^{2/3} T^{-1/3}$ on a balanced separable-Gaussian instance, not $d^{1/3} T^{-1/3}$.
- **Round 2**: PASS-WITH-RESERVATIONS. The downgraded rate $\widetilde{O}(d^{7/8} T^{-1/4})$ is genuinely derived; numerical substitutions match within polylog. Net HIGH/STRUCTURAL delta = -3 (FIXER-PROGRESS). One LOW-severity scope SP (SP-6: rate divergence from problem.md headline) is a scope decision, not a proof bug.

## Six-frame outcome summary

| Frame | Verdict | Final rate / contribution |
|---|---|---|
| Construction | FAIL → contributes Lyapunov template | $d^{3/4} T^{-1/4}$ (Lyapunov-recasting wall) |
| Naive | FAIL (predicted) | online-to-batch bridge fails for non-convex |
| Adversarial | PARTIAL | SGD LB $\Omega(d^{1/2}\sqrt{T^{-1}})$; on balanced separable, AdaGrad gives only $d^{2/3} T^{-1/3}$ |
| Orthodox | PARTIAL | $d^{1/2} T^{-1/4}$ (third lever genuinely absent) |
| **Reduction** | **WINNER** | $d^{7/8} T^{-1/4}$ after honest downgrade |
| Compositional | FAIL | same fixed-comparator obstacle as Naive |

## Knowledge Reuse Hooks fired

- Layer 1 (strategy_index): adagrad-norm-nonconvex-convergence, amsgrad-nonconvex-convergence — partial useful (chassis transfers, third lever doesn't).
- Layer 2 (failure_triggers): FT-RATE-UB-LB-MISMATCH (TRIGGER-CONFIRMED), FT-LEGACY-ADAGRAD-LYAPUNOV-RECASTING (TRIGGER-CONFIRMED on Construction frame).
- Layer 3 (fragments): polarization-identity-gradient-error, two-sided-sandwich-on-accumulator, COR-INEQ from adagrad-complexity — all reused.
- Layer 4 (structure_map): D5/D1 cross-cluster links cited.
- Layer 5 (meta_templates): MT1 (Cancellation Pair) attempted; blocker slot = IDENTITY/INEQ for the rate-matching step (third lever missing).

## Related results

- `proofs/research/optimization/adaptive-methods/adagrad-norm-nonconvex-convergence/` — parent chassis; gives $T^{-1/2}\sqrt{\log T}$ in the bounded-noise case.
- `proofs/research/optimization/adaptive-methods/amsgrad-nonconvex-convergence/` — predictable-surrogate trick.
- `proofs/research/optimization/adaptive-methods/adagrad-complexity-improvement-partial-refutation/` — sibling diagnostic; same wall, same conclusion.

## Future-work bridge

The scalar AdaGrad-Norm + affine-noise + $(L_0, L_1)$-smoothness lemma at rate $T^{-1/3}$ (the "Faw 2022 scalar lemma") is NOT in our library; if proven and incorporated, the parent reduction would close at the conjectured $T^{-1/3}$ but with a $d$ exponent likely worse than $1/3$ (the Adversarial route gives $d^{2/3}$ on balanced separable instances). JMM COLT 2025 reportedly closes this; the structural ingredient is unknown to this pipeline.
