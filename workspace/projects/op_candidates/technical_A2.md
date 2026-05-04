# Technical Assessment: Direction A2
# SHB Non-Convex Stochastic Lower Bound for ε-Stationary Point
# Generated: 2026-04-28

---

## 1. Which technique?

### Primary candidate: Oracle-restriction (Arjevani 2019 style) + SHB-specific layer

The Arjevani et al. 2019/2023 LB uses a **hard function family** for all SFO algorithms. The construction encodes a "needle in a haystack" problem: f has a flat region where the gradient is ε-small everywhere except near the optimum, which requires Ω(ε⁻⁴) queries to locate. This construction naturally defeats any algorithm in the SFO model, including SHB.

The A2 contribution would require going beyond minimax to show something SHB-specific. Three sub-routes:

**Route I (Restriction + Bias Analysis):**
- Take the Arjevani hard instance. Show that SHB with fixed β > 0, due to its momentum term, cannot escape the flat region faster than SGD — in fact, the momentum accumulates a systematic bias that makes the effective gradient step smaller (the "inertia in flat region" phenomenon).
- Result: SHB requires ≥ Ω_β(ε⁻⁴) with a constant that is explicitly β-dependent and ≥ the SGD constant; i.e., fixed β does not help and may hurt.
- Difficulty: The Arjevani construction is for the randomized oracle model; translating the bias argument requires care about the random oracle response distribution and how SHB's momentum state interacts with it.

**Route II (Cycling in non-convex landscape):**
- Extend GTD cycling to non-convex f. In the convex/SC setting, the cycling construction gives a function on which SHB fails to converge to the minimizer. In the non-convex setting, the target is ε-stationarity, so "cycling" means: SHB's trajectory visits a loop of points with ‖∇f‖ ≥ ε forever (or at least for Ω(ε⁻⁴) steps).
- This requires constructing a smooth non-convex f with a periodic orbit for SHB where ‖∇f‖ ≥ ε on the entire orbit.
- **Key obstacle**: In the non-convex setting, gradient norms can be large at non-minimizers. Constructing such a cycle requires that the function does not have a stationary point "inside" the cycle, i.e., the cycle must avoid all critical points. This is topologically constrained (by Brouwer's theorem, any continuous map on a disk has a fixed point — so cycles must be on non-simply-connected sets, i.e., the dynamics must be on a manifold without boundary).
- This is technically harder than the convex cycling because the function must be specifically non-convex and smooth, with no spurious critical points on the cycle.

**Route III (Direct construction via stochastic bias):**
- Construct an explicit 1-D stochastic LB function where the momentum accumulation under SHB creates a systematic drift toward a non-stationary point. Use Le Cam two-point method with a function that has gradient ≥ ε everywhere reachable by SHB with fixed β, but SGD escapes.
- This yields a β-dependent constant improvement over the Arjevani minimax LB.
- This route produces the cleanest result but requires the most originality.

### Recommended primary route: Route I + Route II hybrid

Start with Route I (restriction) to get a clean ε⁻⁴ LB with β-explicit constant, then attempt Route II as the "structural" insight showing *why* SHB fails — the cycling mechanism adapted to non-convex.

---

## 2. Reusable from pipeline

### Directly reusable

- **`shb-no-acceleration-restricted` (OP-2 core)**: The Goujaud cycling construction at μ→0. The key lemma (cycle amplitude ≥ ρ(β,η)·D, μ-independent) is exactly what one would use to anchor a cycling-based LB in the non-convex regime. The ∀β ∃f structure is already proved.
  
- **`shb-cycling-critical-momentum`**: Identifies β* = (√13−3)/2 as the sharp cycling threshold. In the non-convex setting, cycling can occur for any β ∈ (0,1) provided step-size is large enough — this threshold result gives intuition about which regime is "hardest" for constructing non-convex cycling.

- **`shb-cycling-lyapunov-nogo` / `shb-energy-tight-ub-nogo`**: The nogo results on Lyapunov functions and energy bounds directly constrain which proof routes are viable for non-convex too — any attempt to prove SHB converges faster using a Lyapunov argument will fail, confirming the gap is genuine.

- **`lp-lq-oracle-complexity`**: The oracle complexity framework (Arjevani 2019 style) is already formalized in the library. This gives the mathematical infrastructure for the "restriction" argument.

- **`spider-nonconvex-gradient-complexity` + `page-optimal-gradient-complexity`**: These give the upper bound landscape for non-convex stochastic optimization (ε⁻³ and ε⁻⁴ rates). Useful for calibrating what "matching the LB" means and what SHB would need to beat.

### Partially reusable (need adaptation)

- **`shb-interpolation-regime-lb`**: The interpolation noise model analysis. Non-convex + interpolation is a relevant regime (over-parameterized neural nets); the techniques partially transfer.

- **`momentum-sgd-interpolation-*` (3 proofs in stochastic/)**: The interpolation regime convergence theory for momentum SGD. Background for understanding when SHB does converge in non-convex settings.

- **`shb-coefficient-suboptimality` / `shb-cooling-momentum-lb`**: The β-explicit suboptimality results. These give quantitative bounds on how badly SHB underperforms; adapting to non-convex requires re-establishing the gap in terms of ‖∇f‖ rather than f−f*.

---

## 3. What's new: SHB cycling in non-convex world

The critical new ingredient is **extending GTD cycling to non-convex functions with gradient-norm targets**.

Existing cycling is entirely in the convex/SC world:
- GTD 2023: SHB cycles on an L-smooth μ-SC Moreau function. The cycling is around x*, the global minimizer. The cycle amplitude gives f(x_t) − f* ≥ c.
- OP-2: Takes μ→0 limit. Still convex.
- All SHB cycling proofs in the library: convex or SC.

The non-convex version requires:
1. **New hard function**: f must be smooth non-convex, with ‖∇f(x)‖ ≥ ε at all cycle points but ‖∇f‖ < ε somewhere (otherwise the LB is trivial). The cycle must be an "ε-stationary avoidance" cycle.
2. **Non-convex SHB dynamics**: The standard GTD cycling analysis uses strong convexity to bound eigenvalues of the iteration matrix. In the non-convex case, one must analyze a non-linear system — linearization around the cycle orbit.
3. **Stochastic coupling**: The stochastic oracle must be defined to preserve the cycling behavior in expectation while adding bounded-variance noise. This coupling argument is new even for OP-2 (it was needed there too, but for convex functions).

The conceptually cleanest new construction: take a smooth periodic function f on ℝ (e.g., f(x) = −cos(ωx) + εx) such that:
- ‖∇f(x)‖ ≥ ε/2 everywhere on a reachable set for SHB with fixed β,
- SHB with fixed (β,η) generates an orbit that stays within this "ε-gradient" region for Ω(ε⁻⁴) steps,
- The stochastic oracle respects the bounded-variance model.

This is philosophically analogous to the GTD cycling but technically distinct because the "cycling" is gradient-norm avoidance rather than distance-to-minimizer amplification.

---

## 4. Numerical verification feasibility

**HIGH feasibility**. The key numerical checks are:

1. Run SHB (fixed β ∈ {0.5, 0.9}) on the Arjevani hard function (or a periodic non-convex analogue) and measure:
   - Number of steps T(ε) until E‖∇f(x_t)‖ ≤ ε
   - Compare to SGD (β=0) on same function
   - Verify T(ε) ∼ C(β)·ε⁻⁴ empirically
   
2. Construct a 1-D periodic hard function, plot SHB trajectories for β ∈ {0, 0.3, 0.6, 0.9}, verify that:
   - All β values require Ω(ε⁻⁴) steps,
   - The constant C(β) is non-decreasing in β (if the A2 claim is that momentum does not help).
   - Or: for certain β, the trajectory actually cycles with ‖∇f‖ persistently ≥ ε.

3. The existing `spider-nonconvex-gradient-complexity` proof provides matching UB (ε⁻³ with variance reduction). Numerically confirming SHB cannot achieve ε⁻³ (even with large mini-batches) would strengthen the A2 contribution.

All numerical experiments are 1-D or 2-D, use only standard scipy/numpy, and can be completed in < 1 hour. This is the same infrastructure used in the OP-2 verification (`workspace/active/proof_work_op2_I3_*/`).
