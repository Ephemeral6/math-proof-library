# Retry Queue — Prioritized

**Date**: 2026-04-27
**Method**: scored each non-PASS by **expected value = P(success on retry) × research impact**, then sorted.
**Filter**: only problems where retry is meaningful (not already superseded, not provably-false-as-stated, not abandoned by mathematical impossibility).

---

## Scoring summary

| ID | Problem | P(success) | Impact | EV | Action |
|---|---|---|---|---|---|
| **R1** | A2 — BLLT 2020 Benign Overfitting (bias half) | 0.75 | 0.95 | 0.71 | RETRY with library aug |
| **R2** | E1 — AdaGrad-Norm last-iterate (LB only, no UB) | 0.85 | 0.55 | 0.47 | RETRY with weaker claim |
| **R3** | A4 — OP-2 / I4 (suffix-average LB, almost-every-T form) | 0.80 | 0.50 | 0.40 | RETRY with weaker claim |
| **R4** | C4 — SSL InfoNCE LB (close log gap) | 0.50 | 0.65 | 0.33 | RETRY with library aug |
| **R5** | D1 — Variance-only OP-2 extension to Adam | 0.55 | 0.55 | 0.30 | RETRY with restricted claim |
| **R6** | D-OP2-Init — Zero-momentum init on $\mathcal F_{\text{usable}}$ | 0.55 | 0.45 | 0.25 | RETRY with weaker claim |
| **R7** | A3 — OP-2 sharp ($\exists f\,\forall(\beta,\eta_t)$) | 0.10 | 0.95 | 0.10 | LOW-PRIORITY long-shot |
| **R8** | D4 — High-dim variance under $\ell_\infty$ oracle | 0.35 | 0.30 | 0.11 | RETRY with stronger oracle |
| **R9** | C9 — SSL phase transition first-order in $d\to\infty$ limit | 0.30 | 0.30 | 0.09 | LOW-PRIORITY |

**Top 5 retry prompts follow.** Each is a self-contained problem statement ready to paste into the five-phase pipeline.

---

## R1 — BLLT 2020 Bias Bound (Gordon Comparison)

```markdown
# Benign Overfitting Bias Bound (BLLT 2020 Lemma 11)

## Source
- Bartlett, Long, Lugosi, Tsigler 2020 PNAS, Theorem 1.
- This is a sub-problem extracted from a previous failed run on the full
  BLLT theorem (workspace/archive/failed_proof_work_20260417_203157/).
  The variance half is already proven and archived (Route 2 Step 5 in that
  working dir, ~30 KB of clean derivations).
- Pre-requisite: Gordon-Slepian Gaussian comparison theorem
  (PLEASE first ensure this is in proofs/library/ as a B-class lemma; if not,
  add it before launching the Explorer).

## Statement (target)

Setting: Gaussian features x_i ~ N(0, Σ), Σ = diag(λ_1 ≥ λ_2 ≥ ...) ≥ 0,
β* ∈ R^p with ‖β*‖_Σ := √(β*^T Σ β*) ≤ B. Sample matrix X ∈ R^{n×p} with
n ≤ p. Define P := X^T (XX^T)^{-1} X (orthogonal projection onto rowspan(X))
and r_0(Σ) := tr(Σ)/λ_1.

Prove: there exist universal constants C_1, C_2 > 0 such that

  β*^T (I - P) Σ (I - P) β*  ≤  C_1 ‖β*‖_Σ^2 ·
       max{ √(r_0(Σ)/n), r_0(Σ)/n, √(log n / n) }

with probability at least 1 - e^{-n/C_2} over the sample matrix X.

## Difficulty
research

## What is already proven (do NOT redo)

The variance bound
  σ^2 · tr[X(XX^T)^{-1}Σ(XX^T)^{-1}X^T]  ≤  C ·σ^2 · (k*/n + n/R_{k*}(Σ))
is FULLY PROVED in the prior workspace (Route 2 Steps 5a–5h: Woodbury identity
+ Hanson-Wright on tail Gram H + Hanson-Wright on top block W). Import it as
given.

## Strategy hint

Use Gordon's Gaussian min-max theorem applied to
  min_{‖v‖_Σ ≤ 1} ‖(I-P)v‖_Σ
       ≡ min_{‖v‖_Σ ≤ 1} dist( Σ^{1/2} v, Σ^{1/2} rowspan(X) ).
After whitening X = G·Λ^{1/2} (G ∈ R^{n×p} standard Gaussian), the problem
becomes a Gaussian-width estimate on the unit Σ-ball. The √(r_0/n) factor
arises as the Gaussian width of the tail eigenspace divided by √n.

Reference proof to mimic: BLLT 2020 Lemma 11 + Lemma 10 + Theorem 4 chain.

## Pitfall to avoid

Do NOT attempt operator-norm bounds on (I-P), (I-P)Σ(I-P), or
Σ^{1/2}(I-P)Σ^{-1/2}: 4 prior routes verified that all such bounds give
either trivial (≥ 1) or wrong-direction estimates. The Gordon route is the
only known path.

## Success criterion

A clean proof of the boxed inequality, with explicit C_1 and C_2 (no
unspecified universal constants), and a numerical sanity check on a small
isotropic case (Σ = I, n = 50, p = 200, β* = e_1) showing the empirical
ratio is consistent with the predicted scaling.
```

---

## R2 — AdaGrad-Norm Last-Iterate Lower Bound (LB only)

```markdown
# AdaGrad-Norm Last-Iterate Ω(1/N^{1/4}) Lower Bound

## Source
- Ward, Wu, Bottou 2019 (ICML/JMLR) — AdaGrad-Norm convergence analysis.
- Re-statement of the failed blind test from 2026-04-17 (FP-18); the original
  problem.md asked for both UB O(1/N^{1/4}) AND LB Ω(1/N^{1/4}) with
  tightness, but the UB and LB are mutually inconsistent at the
  asymptotic level (a stronger UB O(log N / √N) was correctly proved).

## Statement (target)

Let f : R^d → R be L-smooth, possibly non-convex, with bounded gradient noise
(unbiased, variance ≤ σ^2). AdaGrad-Norm:
  x_{k+1} = x_k - η g_k / b_k,
  b_k^2 = b_{k-1}^2 + ‖g_k‖^2,
  b_0^2 = b₀² > 0.

Prove: there exist L, σ, b₀ and an instance f such that the LAST iterate
satisfies, for all N ≥ 2,
  E[ ‖∇f(x_N)‖^2 ]  ≥  c · N^{-1/2}    (NOT 1/N^{1/4})

(Note: the correct asymptotic for last-iterate AdaGrad-Norm is Ω(1/√N) up to
log factors, NOT Ω(1/N^{1/4}). The original blind-test problem confused
last-iterate with average-iterate rates.)

If you can sharpen to Ω(log N / √N) matching the proven UB, do so.
This would close the picture: UB = Ω(LB) up to constants.

## Difficulty
research

## Strategy hint

Construct a one-dimensional non-convex hard instance (e.g., scaled Hermite
polynomial or a wall function similar to OP-2) on which AdaGrad-Norm's
adaptive step-size η/b_k decays just-fast-enough that the last iterate
cannot exit a Θ(N^{-1/2}) neighborhood of the suboptimal stationary point.
The variance term σ^2 should dominate the bias for large N.

## Pitfall to avoid

Do NOT confuse last-iterate with averaged-iterate: Shamir-Zhang
suffix-averaging gives O(log N / √N) for the AVERAGE, not the last iterate.
Cf. the FP-18 failure: Route 3 in 2026-04-17 made exactly this error.

## Success criterion

Explicit hard instance with explicit constants. Numerical verification on
N ∈ {10², 10³, 10⁴, 10⁵} showing the last-iterate gradient norm scales as
predicted within 30% of the theoretical constant.
```

---

## R3 — OP-2 Suffix-Average LB on Off-Resonance T

```markdown
# OP-2 Suffix Average LB — Off-Resonance Version

## Source
- Direct retry of Problem I4 (DISPROVED in 2026-04-26 archive
  workspace/archive/failed_proof_work_op2_I4_20260426_120000/).
- The literal problem ("for every T ≥ K, suffix avg has gap ≥ c LD²/T") is
  provably false on Goujaud's K-gon hard instance because of resonance at
  T = (jK)² where the suffix annihilates exactly. This restated version
  excludes the resonance subsequence.

## Statement (target)

Let F be the Goujaud feasibility region for SHB. For each (β, η) ∈ F let
K = K(β, η) be the corresponding cycle period (1 ≤ K ≤ K_max(β, η) < ∞).
Define the resonance set
  R(β, η) := { T : ⌈√T⌉ ∈ K · ℕ }.

For the suffix average ŷ_{T, ⌈√T⌉} = (1/⌈√T⌉) Σ_{t=T-⌈√T⌉+1}^T x_t,
prove: for every (β, η) ∈ F there exists L-smooth convex f_{β,η} : R² → R
with optimum f* such that, for all T ≥ K with T ∉ R(β, η),

  f_{β,η}( ŷ_{T, ⌈√T⌉} ) - f*  ≥  c · L D² / T,

with explicit c = c(β, η) > 0 depending only on (β, η).

(Equivalently, for a positive-density set of T — density at least 1 - 1/K
asymptotically — the suffix-average LB matches the last-iterate LB up to
constants.)

## Difficulty
research

## What we know

- LB FAILS on R(β, η): at T = (jK)², the K-gon partial sum vanishes by
  rotational symmetry of K-th roots of unity (verified to machine
  precision in the 2026-04-26 disproof).
- OFF-resonance, numerics show f₀(ŷ)/(LD²/T) ≈ 1/2 uniformly across the
  tested grid. So a constant c(β, η) ≈ 1/2 should be achievable.

## Strategy

Direct algebraic computation: when ⌈√T⌉ = mK + r with 0 < r < K, the
suffix sum is (D'/⌈√T⌉) · Σ_{j=a}^{a+r-1} e_{j mod K} with a = T mod K.
The norm of this partial polygon sum is ≥ c_K · sin(πr/K) · D' (lower
bounded by the chord opposite to the missing vertices). Combining with
the SC floor f₀(x) ≥ μ‖x‖²/2 = κL‖x‖²/2 gives the bound.

## Success criterion

Explicit c(β, η) ≥ κ(β, η)·L·D²·sin²(π/K)/(8K²) (or sharper). Numerical
verification on (β, η, K) ∈ {(0.5, 3/L, 4), (0.7, 2.9/L, 6), (0.9, 3/L, 3)}
across non-resonant T = 5, 7, 11, 13, 17, 19, 23, 29 (skipping T such that
⌈√T⌉ ∈ KN).
```

---

## R4 — SSL InfoNCE Minimax LB (Close Log Gap via Assouad)

```markdown
# SSL InfoNCE Minimax Downstream LB — Sharp $d^2/(n·I)$ Without Logs

## Source
- Direct retry of Problem 7.3 from Yang Yuan Batch 3.
- The current archived proof at
  proofs/research/learning-theory/generalization/ssl-infonce-minimax-lower-bound/
  shows C·d²/(n·I) UP TO LOG FACTORS via Yang-Barron packing on SO(d).
  Closing the log gap requires Assouad's hypercube method, not attempted
  in the original run.
- Pre-requisite: Assouad's hypercube method (Tsybakov 2009 §2.3); ensure it
  is in proofs/library/ as a B-class lemma before launching.

## Statement (target)

Setting (inherited from Problem 7.3): SSL with InfoNCE loss on n positive
pairs from data-generating model with mutual information I(X; X' | A).
Downstream task: linear probe with weight w* ∈ R^d, ‖w*‖² ≤ d. Risk =
expected squared loss on a held-out task drawn from the conditional
distribution.

Prove: there exist constants c_1, c_2 > 0 (universal) such that

  inf_θ̂  sup_{(f*, w*)}  E[ Risk(θ̂) - Risk* ]  ≥  c_1 · d² / (n · I(X;X'|A))

WITHOUT log factors, where the inf is over all SSL estimators θ̂ that
process the n pairs and the sup is over the joint adversary (f*, w*).

## Difficulty
research

## What we know (do NOT redo)

The d² / (n·I) rate up to log factors is fully proven in the prior archive,
including:
- σ-link to squared-loss reduction (constant 1/16);
- Schur-complement linear-probe gap;
- DPI + chain rule MI bound: I(V; samples^n) ≤ n · I(X; X' | A);
- Yang-Barron metric-entropy packing on SO(d) giving log M ∝ d² log(1/δ);
- Fano + packing-separation amplification.

## What needs to be added

Assouad's hypercube embedding to remove the log factor:
- Construct a {±1}^{d²} hypercube of orthogonal-rotation parameters at
  Hamming-separation Θ(δ²);
- Use Assouad's lemma to lower-bound the minimax risk by Σ_i (1 - TV_i),
  not max_i;
- TV bound via Pinsker + chain rule on the n-fold product gives the
  d²-dimensional rate without the union-bound log factor.

## Pitfall to avoid

The "joint sup" subtlety from the original run: the d² rate requires sup over
(f*, w*) jointly, not sup over w* alone with fixed f* (which gives only
d/(n·I)). Make sure the Assouad construction respects the joint adversary.

## Success criterion

Removed log factor in the bound. Numerical verification across d ∈
{4, 8, 16, 32, 64} matching theory within 20%.
```

---

## R5 — OP-2 Variance-Only Extension to Adam

```markdown
# Variance-Only Lower Bound for Adam on a Decoupled-Coordinate Hard Instance

## Source
- Direct retry of Problem D1 (failed 2026-04-26, recorded in
  failure_patterns.md as FP-OP2-ADAM-COORDWISE-SCALING-BREAKS-CYCLING).
- The bias term Ω(LD²/T) does NOT extend to Adam (genuinely false: Adam
  reaches optimum on the OP-2 hard instance). But the variance term
  Ω(σD/√T) likely does, via a separate Le Cam construction on a decoupled
  y-coordinate that Adam's per-coord scaling cannot exploit.

## Statement (target)

Let L, σ, D > 0 be fixed. Consider Adam with hyperparameters
(β_1, β_2, ε, η) in the standard convergence regime
(0 ≤ β_1 < √β_2 < 1, η ≤ √ε / L). Prove:

There exists a 1-D L-smooth convex function g(y) with arg min g = 0,
‖y_0‖ ≤ D, and an unbiased σ²-bounded oracle, such that for every fixed
(β_1, β_2, ε, η) and every T ≥ 1,

  E[ g(y_T^{Adam}) - g(0) ]  ≥  c(β_1, β_2, ε, η) · σ D / √T

with explicit c > 0 (allowed to depend on hyperparameters; e.g.,
c ~ 1 / (η · √(1/(1-β_2)))).

## Difficulty
research

## Strategy

Use the OP-2 variance construction: g(y) = α_s · y + w(y) where w is a
flat-bottom wall function with two stable optima at ±D/2, and the linear
slope α_s ∈ {±α} is hidden by a Bernoulli ε-sign noise. Le Cam two-point
test on s ∈ {±1} from T noisy gradient observations.

The key claim: Adam's per-coord scaling does NOT help on a 1-D problem
because there is only one coordinate. The Le Cam information bound
applies to ANY first-order algorithm (including Adam) and gives
σD/√T-rate Ω-bound on E[gap].

## Pitfall to avoid

Do NOT try to extend the bias term — D1 disproof shows it fails. Variance
is decoupled from cycling and should transfer.

## Success criterion

Clean proof using Le Cam two-point lower bound. Numerical verification
that empirical Adam regret on the constructed instance scales as σD/√T.
```

---

## Lower-priority retries (R6-R9, sketches only)

### R6 — OP-2 Zero-Momentum Init on $\mathcal F_{\text{usable}}$
**One-line**: characterize the subset $\mathcal F_{\text{usable}}\subset\mathcal F$ where the cycling orbit is attractive under standard $x_0=x_{-1}$ init, via spectral linearization analysis at the origin. Prove OP-2 LB holds on $\mathcal F_{\text{usable}}$ even with standard init.

### R7 — OP-2 Sharp ($\exists f\,\forall(\beta,\eta_t)$)
**One-line**: requires a fundamentally new hard-instance idea (not in cycling family). Long shot. Might benefit from a search for non-quadratic functions with $\nabla^2 f(x^\star)=0$ globally that are also resistant to plain GD.

### R8 — D4 High-Dim Variance under $\ell_\infty$-Bounded Oracle
**One-line**: re-state with $\|\xi_t\|_\infty\le\sigma$ (instead of $\|\xi_t\|_2\le\sigma$); naive product extension gives $\sqrt d$ scaling cleanly. Easier than the original.

### R9 — SSL Phase Transition in $d\to\infty$ Limit
**One-line**: prove the gap $g(\sigma_{\text{aug}})$ becomes first-order discontinuous in the proportional-asymptotic limit $d\to\infty$ with $\Delta_{\min}/\sqrt d \to $ const. Random matrix theory (BBP transition) is the standard tool.

---

## Triage — recommended action per problem

| Problem | Action | Reason |
|---|---|---|
| A1 (heavy-tail) | ARCHIVE (superseded) | already PASSED on 2026-04-05 |
| A2 (BLLT) | RETRY R1 — high priority | variance done, only bias missing, library aug straightforward |
| A3 (OP-2 sharp) | LONG-SHOT R7 | genuine open problem since 2015 |
| A4 (I4) | RETRY R3 — moderate priority | weaker form (off-resonance) is provably true |
| B1 (Mei) | ARCHIVE (superseded) | sublinear restatement already PASSED |
| C1 (3.1 SVRG) | ARCHIVE | DISPROVED + matched UB/LB is the right answer |
| C2 (7.1 OT) | ARCHIVE | refined version PROVED |
| C3 (7.2 categorical) | ARCHIVE | near-retraction is the right answer |
| C4 (7.3 InfoNCE) | RETRY R4 — moderate priority | log-gap closure via Assouad |
| C5 (7.4 nonstat) | ARCHIVE | corrections accepted |
| C6 (7.5 Rényi) | ARCHIVE | conditional theorem accepted |
| C7 (7.6 heavy-tail traj) | ARCHIVE | caveat accepted |
| C8 (7.7 compositional) | ARCHIVE | corrected form accepted |
| C9 (7.8 phase transition) | LONG-SHOT R9 | first-order in $d\to\infty$ limit |
| C10 (7.9 depth) | ARCHIVE | corrections accepted |
| C11 (7.10 adv tradeoff) | ARCHIVE | honest scope accepted |
| C12 (I3 best-iterate) | ARCHIVE | bias proven + variance disproof is the right answer |
| C13 (I5 PR-defeats-cycling) | ARCHIVE | DISPROVED + matching UB is the right answer |
| C14 (S4 interp regime) | ARCHIVE | bias survives + variance impossibility is the right answer |
| D-OP2-Cesaro | ABANDON | rotational symmetry kills any cycling-based approach |
| D-OP2-Init | RETRY R6 — moderate priority | $\mathcal F_{\text{usable}}$ characterization |
| D-OP2-PEP | ABANDON | reverse-engineering is a separate research project |
| D1 (Adam) | RETRY R5 — variance-only | bias provably false, variance still likely |
| D4 (high-dim var) | RETRY R8 — moderate priority | weaker oracle assumption makes it tractable |
| D5 (Polyak vs Nesterov) | ARCHIVE-AS-REMARK | qualitative observation only |
| E1 (AdaGrad-Norm) | RETRY R2 — moderate priority | drop the inconsistent UB, prove only LB |
| E2 (ADMM feasibility) | ARCHIVE | resolved |
| E3 (Q-learn bonus) | ARCHIVE | resolved |

**Active retry queue (high-EV)**: R1 (BLLT bias), R2 (AdaGrad LB-only), R3 (I4 off-resonance), R4 (InfoNCE log gap), R5 (Adam variance-only).
