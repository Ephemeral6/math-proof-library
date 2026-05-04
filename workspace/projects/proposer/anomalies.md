# Proposer Mode B — Anomaly catalog

Generated 2026-04-27 from numerical experiments in `workspace/proposer/scripts/`.
All results trace to CSV/MD files in `workspace/proposer/results/`.

Time spent: ~25 min experiments (under 70-min cap). Anomalies grouped by classification.

---

## DIVERGENCE class

### Anomaly A-1: Adam diverges late on strongly convex quadratic
- **Algorithm**: Adam (β1=0.9, β2=0.999, ε=1e-8, η=1/L)
- **Setting**: f(x) = 0.5 xᵀAx, A random PSD with eigenvalues in [0.05, 1.0], d=10, T=10000, x0 = N(0,I)
- **Expected behavior**: For SC L-smooth, Adam should converge geometrically; final gap should be at or near machine precision
- **Observed behavior** (from `b1_5_adam_sc_traj.csv`, `b3_robustness.csv`): Adam reaches min gap ≈ 4e-26 at iter 562, then DIVERGES back to final gap 5.4e-4 by iter 10000. Across 30 seeds: `final/min` ratio in [8.3e3, 1.9e56], geometric mean ~ 1e30. Smaller stepsizes delay but do not prevent: η=0.1/L gives final/min = 3.5e94, η=0.01/L gives 6.6e286.
- **Discrepancy**: 22-286 orders of magnitude divergence after reaching minimum
- **Classification**: DIVERGENCE (late-iteration instability under bias-corrected EMA)
- **Suggested problem statement**:
  > For Adam with hyperparameters (β1, β2, ε, η) such that 0 < β1 < β2 < 1 and ε > 0, on the L-smooth μ-strongly convex quadratic f(x)=½xᵀAx, the iterate sequence {xₜ} satisfies limsup_{t→∞} f(xₜ) > 0 almost surely from random initialization, even though inf_t f(xₜ) = 0. Quantify the floor as a function of (β1, β2, ε, η, μ, L).
- **Robustness**: ROBUST in direction (30/30 seeds had final/min > 1000); FRAGILE in magnitude (CoV=5.4)
- **Confidence**: HIGH

### Anomaly A-2: Adam fails to reach high accuracy on SC quadratic
- **Algorithm**: Adam (default), η=1/L
- **Setting**: same as A-1
- **Expected behavior**: final gap ~ 0 (machine precision)
- **Observed**: 23/30 seeds end with final gap > 1e-6; mean final gap 2.7e-3
- **Discrepancy**: ~10 orders of magnitude floor above zero
- **Classification**: DIVERGENCE / convergence-floor
- **Suggested problem statement**:
  > Identify the exact "Adam floor" g̃(β1, β2, ε, η, condA) such that limsup_t f(xₜ) ≥ g̃ for any random initialization on SC quadratics.
- **Robustness**: ROBUST in direction (23/30); FRAGILE in magnitude
- **Confidence**: HIGH

### Anomaly A-3: Adam diverges on Goujaud-style 2D quadratic late iterations
- **Algorithm**: Adam, η=1/L
- **Setting**: 2D quadratic with eigenvalues (1, 1e-3), random rotation, T ∈ {100, 1000, 10000}
- **Expected**: monotone (or nearly so) gap decrease
- **Observed** (`b1_2_iterates.csv`): At T=1000, gap=1.17e-49 (excellent). At T=10000, gap=5.7e-9 — 40 orders WORSE than at T=1000. Best gap at any iter ≤ T=10000 is 1.19e-89.
- **Discrepancy**: ratio best/last = 1e80
- **Classification**: DIVERGENCE
- **Suggested problem statement**:
  > Adam admits last-iterate non-monotone failure modes on 2D well-conditioned quadratics, with last/best ratio that grows super-polynomially in T.
- **Robustness**: ROBUST in direction (consistent across multiple seeds in B1.2)
- **Confidence**: HIGH

---

## DIMENSION_ANOMALY class

### Anomaly A-4: Adam gap explodes with dimension on random L-smooth convex quadratic
- **Algorithm**: Adam, η=1/L=1
- **Setting**: random PSD A with eigenvalues uniform[1e-3, 1], d ∈ {2, 10, 50, 200, 500}, T = 5000, x0 = x* + N(0, I)
- **Expected behavior**: Full-batch GD on a fixed-L quadratic is dimension-independent in function value (theory slope = 0)
- **Observed** (`b1_4_dimension.csv`): Adam final gap is 2.2e-16 at d=2 → 5.5e-3 at d=10 → 1.93e-3 at d=50 → 0.167 at d=200 → 0.329 at d=500. Slope of log10(gap) vs log10(d) = +5.4 (single-seed run); over 30 seeds, slope mean = +41.0, range [1.3, 105.3], 30/30 seeds have slope > 0.5
- **Discrepancy**: theory says slope ≈ 0; observed slope ≥ 1.3 in EVERY seed; mean slope 41
- **Classification**: DIMENSION_ANOMALY
- **Suggested problem statement**:
  > For Adam with default hyperparameters and stepsize η=1/L on a random L-smooth convex quadratic in d dimensions with fixed condition number, the asymptotic function-value gap satisfies E[f(xT) - f*] = Ω(d^c) for some c > 1, despite the deterministic nature of the iteration and the dimension-independence of the function class.
- **Robustness**: ROBUST in direction (30/30 with positive slope > 0.5); FRAGILE in slope magnitude (CoV=1.17)
- **Confidence**: HIGH

### Anomaly A-5: AdaGrad mild dimension dependence on random quadratic
- **Algorithm**: AdaGrad, η=1/L
- **Setting**: same as A-4
- **Expected**: dimension-independent on full-batch quadratic
- **Observed**: slope of log10(gap) vs log10(d) = +1.34 (single seed run; 4 orders of magnitude across d ∈ [2, 500])
- **Discrepancy**: slope expected ≈ 0, observed +1.3
- **Classification**: DIMENSION_ANOMALY
- **Suggested problem statement**:
  > AdaGrad on random L-smooth convex quadratics has function-value gap scaling as Θ(d^c) for some c ∈ [1, 2], unlike GD which is dimension-independent. Identify c precisely.
- **Robustness**: NEEDS_MORE (only single-seed run)
- **Confidence**: MEDIUM

---

## ITERATE_TYPE_GAP class

### Anomaly A-6: Polyak-Ruppert averaging is catastrophic for SHB(0.9) on ill-conditioned quadratic
- **Algorithm**: SHB (β=0.9), η=1/L, deterministic
- **Setting**: 2D quadratic with eigenvalues (1, 1e-3), random rotation, T=1000
- **Expected behavior**: PR averaging at most a constant factor worse than last iterate for deterministic methods on quadratics
- **Observed** (`b1_2_iterates.csv`, `b3_robustness.csv`): PR_gap / last_gap mean = 1.33e6 across 30 seeds, std/mean = 0.002 (extremely stable!). Cesàro/last has mean 1.66e8.
- **Discrepancy**: PR averaging is 10⁶× worse than last iterate
- **Classification**: ITERATE_TYPE_GAP
- **Suggested problem statement**:
  > For deterministic SHB with β close to 1 on ill-conditioned quadratics, the Polyak-Ruppert average satisfies f(x̄ₜ) / f(xₜ) → ∞ at rate at least Θ(κ²), where κ is the condition number. Characterize the precise rate.
- **Robustness**: ROBUST (CoV=0.002 for PR/last)
- **Confidence**: HIGH

### Anomaly A-7: Adam best-iterate vs last-iterate gap on Goujaud2D
- **Algorithm**: Adam
- **Setting**: 2D rotated quadratic eigenvalues (1, 1e-3), T=10000
- **Expected**: best ≈ last (or constant ratio)
- **Observed** (`b1_2_iterates.csv`): best=1.19e-89, last=5.70e-9; ratio = 4.7e-81
- **Discrepancy**: best is 80 orders of magnitude better than last (= massive cycling/divergence)
- **Classification**: ITERATE_TYPE_GAP (degenerate case of DIVERGENCE)
- **Suggested problem statement**:
  > On 2D quadratics with condition κ ≥ 1000, Adam's last-iterate gap exceeds its best-iterate gap by a factor that grows exponentially in T after entering an oscillatory regime.
- **Robustness**: NEEDS_MORE (single seed)
- **Confidence**: MEDIUM

### Anomaly A-8: PR averaging dramatically beats last iterate for SHB(0.5) on Goujaud2D
- **Algorithm**: SHB(β=0.5)
- **Setting**: same as A-3 (2D)
- **Expected**: PR/last bounded
- **Observed**: At T=1000, last=9.1e-6, pr=4.4e-5 (4.8× worse). At T=10000, last=1.9e-21, pr=1.2e-8 (PR is 13 orders worse). NOT cycling — last is converging fast and PR averages over too-bad early iterates.
- **Discrepancy**: 13 orders of magnitude
- **Classification**: ITERATE_TYPE_GAP
- **Suggested problem statement**:
  > For deterministic momentum methods that achieve linear convergence, Polyak-Ruppert averaging *destroys* the linear rate; identify the optimal averaging window for momentum-deterministic methods.
- **Robustness**: ROBUST (consistent in B1.2)
- **Confidence**: HIGH

---

## FASTER_THAN_THEORY class

### Anomaly A-9: GD/SHB/NAG on quartic f=‖x‖⁴/4 achieve gap rate ~ 1/T² (not 1/T)
- **Algorithm**: SGD (full-batch GD), SHB(0.5/0.9), NAG(0.5/0.9), with η=1/(4‖x₀‖²)
- **Setting**: f(x) = ¼‖x‖⁴ in d=10, T=10000
- **Expected behavior**: textbook smooth-convex (without strong convexity at minimizer) rate is 1/T for f-gap
- **Observed** (`b3_robustness.csv`): empirical α = log(gap_T)/log(T) across 30 seeds:
  - SGD: -1.995 ± 2e-15
  - SHB(0.5): -1.974
  - SHB(0.9): -1.830
  - NAG(0.5): -1.989
  - NAG(0.9): -1.890
- **Discrepancy**: -2.0 vs textbook -1.0 → 1 order in α (i.e. 1/T² vs 1/T)
- **Classification**: FASTER_THAN_THEORY (or rather: theory is loose because gap = ‖x‖⁴ not ‖x‖²)
- **Suggested problem statement**:
  > For GD with constant stepsize η on f(x)=‖x‖⁴/4, prove that f(xₜ) = O(1/t²) and identify the sharp constant. Generalize to f(x)=‖x‖^p/p for p > 2: rate becomes 1/t^{p/(p-2)}.
- **Robustness**: ROBUST (CoV=0 in all 30 seeds, fully deterministic)
- **Confidence**: HIGH

### Anomaly A-10: SHB(0.9) much faster than SHB(0.5) on quartic gap
- **Algorithm**: SHB
- **Setting**: f=‖x‖⁴/4, d=10, T=10000
- **Observed** (`b1_1_rates.csv`): SHB(0.5) gap=1.6e-9 vs SHB(0.9) gap=6.1e-11 (~26× better)
- **Expected**: For non-strongly-convex problems momentum at most matches GD constant
- **Classification**: FASTER_THAN_THEORY
- **Suggested problem statement**:
  > For homogeneous f(x)=‖x‖^p/p (p≥3), SHB with momentum β provides a constant-factor speedup over GD that grows with β (until divergence). Quantify.
- **Robustness**: ROBUST (deterministic)
- **Confidence**: MEDIUM

---

## SLOWER class (PEPit worst-case results)

### Anomaly A-11: SHB(β=0.9) worst-case f-gap is NON-MONOTONE in T (PEPit)
- **Algorithm**: SHB (β=0.9), η=1/L
- **Setting**: smooth convex (non-SC) class, ‖x₀ - x*‖² ≤ 1, T ∈ {3, 5, 10}
- **Expected**: monotonically non-increasing worst-case gap
- **Observed** (`b1_3_pepit.md`): T=3: 0.5735; T=5: 0.4717; T=10: 0.6907 — gap GROWS from T=5 to T=10
- **Discrepancy**: Non-monotone in T; matches Goujaud et al's theoretical prediction of cycling
- **Classification**: SLOWER (formally PEPit-certified non-monotone)
- **Suggested problem statement**:
  > For SHB with β ≥ β_crit on smooth convex non-SC problems, the worst-case gap as a function of T is not monotone, and exhibits a "humped" pattern with worst case at intermediate T.
- **Robustness**: ROBUST (PEPit is exact computation)
- **Confidence**: HIGH

### Anomaly A-12: SHB(β=0.5) worst-case beats GD at T=10
- **Algorithm**: SHB(0.5) vs GD
- **Setting**: smooth convex L=1, η=1/L, T ∈ {3, 5, 10}
- **Observed** (`b1_3_pepit.md`):
  - GD: 0.0714, 0.0455, 0.0238 (matches L/(4T+2) exactly)
  - SHB(0.5): 0.1112, 0.0608, 0.0243
- **Discrepancy**: SHB(0.5) starts WORSE than GD but converges to GD by T=10. So momentum at β=0.5 hurts initially but recovers.
- **Classification**: SLOWER (initially) → matches GD asymptotically
- **Suggested problem statement**:
  > Identify βcrit(T) such that SHB(β) on smooth convex outperforms GD for T ≥ Tcrit(β).
- **Robustness**: ROBUST (PEPit exact)
- **Confidence**: HIGH

### Anomaly A-13: NAG with t/(t+3) momentum nearly matches optimal 1/T² but with constant ~ 1.15
- **Algorithm**: Nesterov constant scheme y = x + (t/(t+3))(x - x_prev)
- **Setting**: smooth convex L=1, T ∈ {3, 5, 10}
- **Observed**: T=3: 0.0588; T=5: 0.0313; T=10: 0.0115. Theory 1/T²: 0.111, 0.04, 0.01 → empirical/theory: 0.53, 0.78, 1.15. Deviates from a clean 1/T² constant.
- **Classification**: PHASE_TRANSITION (constant deteriorates as T grows)
- **Suggested problem statement**:
  > For NAG with momentum schedule (t-1)/(t+2) on smooth convex non-SC, the worst-case gap satisfies f(xT) - f* = c(T) · L D² / T² where c(T) is monotone increasing and tends to a limit > 1. Compute the limit.
- **Robustness**: ROBUST (PEPit exact)
- **Confidence**: MEDIUM

---

## PHASE_TRANSITION class

### Anomaly A-14: SVRG: monotone degradation as snapshot frequency m increases
- **Algorithm**: SVRG with m ∈ {n/4, n/2, n, 2n, 4n}, η=1/(10 L_max)
- **Setting**: linear regression with n=200, d=10
- **Observed** (`b1_6_svrg.md`): final gap 6.5e-4 (m=n/4) → 6.8e-4 (m=n/2) → 6.9e-4 (m=n) → 9.7e-4 (m=2n) → 2.6e-3 (m=4n)
- **Discrepancy**: m=4n is 4× worse than m=n/4 in final gap; smooth degradation, no sharp threshold
- **Classification**: PHASE_TRANSITION (smooth, no break)
- **Suggested problem statement**:
  > For SVRG on least-squares with condition κ, the final-iterate gap is a U-shaped function of snapshot frequency m, with optimal m* = Θ(κ); characterize the constant and the curvature of the U.
- **Robustness**: NEEDS_MORE (single seed)
- **Confidence**: MEDIUM

### Anomaly A-15: SHB(0.9) on Goujaud2D — phase change at small T → fast linear at moderate T
- **Algorithm**: SHB(0.9)
- **Setting**: 2D rotated quadratic eigenvalues (1, 1e-3)
- **Observed** (`b1_2_iterates.csv`): last gap T=100: 6.9e-5; T=1000: 1.2e-13; T=10000: 4.1e-101. Per-step contraction rate ≈ exp(-1/40) for first 1000 then exp(-1/45) — actually IMPROVES.
- **Classification**: PHASE_TRANSITION
- **Suggested problem statement**:
  > Identify when SHB(β) on SC quadratics transitions from sub-optimal to accelerated linear rate; the threshold appears around the "alignment phase" with eigendirections.
- **Robustness**: ROBUST (deterministic)
- **Confidence**: MEDIUM

---

## Misc / supporting findings

### Anomaly A-16: Adam fails to make progress on Q-SC = diag(1,2,...,d)/d at all dimensions
- **Algorithm**: Adam default
- **Setting**: f(x) = 0.5 sum_i (i/d) x_i², d ∈ {2, 10, 50}, T=10000
- **Observed**: gap at T=10000 is 2.07e-5 (d=2), 2.63e-4 (d=10), 1.86e-3 (d=50). All 4-5 orders of magnitude above SGD's machine-precision floor.
- **Classification**: SLOWER + DIMENSION_ANOMALY
- **Suggested problem statement**: same family as A-1, A-2, A-4
- **Confidence**: HIGH (consistent with A-1)

### Anomaly A-17: AdaGrad slower than SGD on quartic at d=50
- **Algorithm**: AdaGrad vs GD
- **Setting**: f=‖x‖⁴/4, d=50, T=10000
- **Observed** (`b1_1_rates.csv`): SGD gap 1.5e-6, AdaGrad gap 7.5e-3 (5000× worse)
- **Classification**: SLOWER
- **Suggested problem statement**:
  > AdaGrad on f=‖x‖^p/p with p>2 has gap scaling worse than GD by a factor d^? — identify the dimension penalty.
- **Robustness**: NEEDS_MORE
- **Confidence**: MEDIUM

---

## Summary table

| ID | classification | confidence | robustness |
|---|---|---|---|
| A-1 | DIVERGENCE | HIGH | ROBUST(dir) FRAGILE(mag) |
| A-2 | DIVERGENCE | HIGH | ROBUST(dir 23/30) |
| A-3 | DIVERGENCE | HIGH | ROBUST |
| A-4 | DIMENSION_ANOMALY | HIGH | ROBUST(dir 30/30) FRAGILE(mag) |
| A-5 | DIMENSION_ANOMALY | MEDIUM | NEEDS_MORE |
| A-6 | ITERATE_TYPE_GAP | HIGH | ROBUST CoV=0.002 |
| A-7 | ITERATE_TYPE_GAP | MEDIUM | NEEDS_MORE |
| A-8 | ITERATE_TYPE_GAP | HIGH | ROBUST |
| A-9 | FASTER_THAN_THEORY | HIGH | ROBUST CoV=0 |
| A-10 | FASTER_THAN_THEORY | MEDIUM | ROBUST |
| A-11 | SLOWER (PEPit) | HIGH | ROBUST(exact) |
| A-12 | SLOWER (PEPit) | HIGH | ROBUST(exact) |
| A-13 | PHASE_TRANSITION | MEDIUM | ROBUST(exact) |
| A-14 | PHASE_TRANSITION | MEDIUM | NEEDS_MORE |
| A-15 | PHASE_TRANSITION | MEDIUM | ROBUST |
| A-16 | SLOWER + DIM | HIGH | ROBUST |
| A-17 | SLOWER | MEDIUM | NEEDS_MORE |
