# Notes: NPG Softmax Tabular Convergence

## Proof technique
Route 1 (Canonical Mirror Descent + PDL) won among 5 parallel explorations. The proof uses the following chain:

1. Performance Difference Lemma to express value gap as weighted advantage
2. NPG update = KL-regularized policy improvement (mirror descent)
3. Three-point decomposition (exact identity) for KL divergence
4. Donsker-Varadhan variational formula + Hoeffding's lemma on centered advantage
5. **Key cancellation**: The KL(π_{k+1}‖π_k) terms from the three-point identity and from the Donsker-Varadhan bound cancel exactly, leaving only the telescoping KL(π*‖π_k) - KL(π*‖π_{k+1}) terms plus a constant error η²/(8(1-γ)²) per step.

## Key steps
1. **The splitting trick**: Writing π* - π_k = (π* - π_{k+1}) + (π_{k+1} - π_k) and using the EXACT three-point identity (not the inequality) for the first part, combined with an UPPER bound on the second part, enables a cancellation that wouldn't occur if both parts used inequalities.

2. **Advantage centering**: Using A^π (mean zero under π) instead of Q^π in the Hoeffding application gives a tighter constant (1/8 vs 1/2), because the range width is 1/(1-γ) for advantages vs 2/(1-γ) for Q-values.

3. **Monotone improvement**: The mirror descent optimality condition directly implies G_k(s) ≥ 0, which gives V^{π_{k+1}} ≥ V^{π_k} via the PDL. This converts average-iterate to last-iterate convergence.

4. **Distribution mismatch resolution**: The PDL with π' = π* uses the FIXED distribution d^{π*}_ρ (independent of k), so the telescoping of KL terms across iterations is valid. This avoids the distribution mismatch problem that plagues other approaches.

## Audit result
- Round 1: PASS WITH REVISIONS (sign error in three-point identity statement, circular Lemma 8, Part (c) algebra error for small γ — all fixed)
- Round 2: PASS (all corrections verified)

## Related results
- The bound has an additive bias η/(8(1-γ)³) that is inherent to the Hoeffding-based analysis. Eliminating it entirely (for a pure O(1/K) bound without burn-in) would require either: (a) a K-dependent step size (giving O(1/√K) instead), or (b) a more refined analysis beyond the generic mirror descent framework (e.g., the Cen-Cheng-Chen-Wei-Chi approach using exact log-partition analysis).
- Routes 2-5 all encountered the same fundamental obstacle: the Hoeffding penalty η²/(8(1-γ)²) per round creates an irreducible bias for fixed η.
- The O(1/K) rate here is sublinear (not linear in the sense of geometric convergence). True linear (geometric) convergence for NPG requires additional assumptions like sufficient exploration or log-linear parameterization with regularization.
- The mirror descent perspective connects NPG to online convex optimization: the per-state update is exactly exponential weights / multiplicative weights, and the FTRL regret bound (Lemma 6) provides an alternative path to the same result.
