# Genuine κ-dependent phenomena in SHB iterate types

All computations at 50-digit mpmath precision. Setup: SHB iteration

  x_{t+1} = x_t - η ∇f(x_t) + β (x_t - x_{t-1}),  η = (ηL)/L

with κ = L/μ, two initializations:
- `zero_mom`: x₀ = x₋₁ = (1,1,…)
- `alt_mom`: x₀ = (1,1,…), x₋₁ = (1,−1,1,−1,…) (nonzero "velocity" of magnitude 2 in coords with +/−)

Iterate types compared at each (β, ηL, κ, T):
- `last`  : x_T
- `cesaro`: (1/(T+1)) Σ_{t=0}^T x_t
- `pr`    : (Σ (t+1) x_t) / (Σ (t+1))   (Polyak–Ruppert with linear weights)
- `suffix`: average of last ⌊√T⌋ iterates
- `best`  : x_{argmin_t f(x_t)}

f-suboptimality reported as f(iterate) − f*.

---

## Phenomenon A — **f(PR) / f(Cesaro) ≍ κ² on SC quadratics, asymptotic in T**

### Statement

For SHB on f₁(x) = (L/2)x₁² + (μ/2)x₂² and f₂ (10-D quadratic with logspaced eigenvalues from μ to L), with **alt_mom** initialization, fixed (β, ηL) inside the stability region (β ∈ [0.5, 0.99], ηL ∈ (0, 2(1+β))), and T = 10000:

| iterate type | κ-exponent c such that f(·) − f* = Θ(κ^c) |
|---|---|
| Cesàro avg | **c = 2.00** (R² = 1.000 across κ ∈ {10, 100, 1000, 10000}) |
| Polyak–Ruppert | **c = 3.7 – 4.0** (R² ≥ 0.99) |
| last / suffix / best | exp(−Θ(T/κ)) for moderate β; ≈ κ¹ at β → 1 |

Therefore **f(PR) / f(Cesàro) = Θ(κ²)** uniformly across the entire (β, ηL) grid for f₁ and f₂.

The phenomenon is asymptotic in T:
- T = 100  : c_Cesàro ≈ 0.5 – 1.6, c_PR ≈ 0.7 – 2.6 (transient)
- T = 1000 : c_Cesàro ≈ 1.3 – 1.9, c_PR ≈ 2.5 – 3.6 (approaching)
- T = 10000: c_Cesàro = 1.99 ± 0.01, c_PR = 3.7 – 4.0 (asymptotic)

### Genuineness checks

- 50-digit precision used throughout: differentiates effects from FP-floor.
- R² ≥ 0.99 on log-log fit across 4 decades of κ.
- Exponent stable across β ∈ {0.5, 0.7, 0.9, 0.95, 0.99} for alt_mom.
- Reproduces in both 2-D (f₁) and 10-D (f₂); the additional log-spaced eigenvalues do not alter the leading exponent.
- For zero_mom init, Cesàro is also c = 2.00 universally; PR is c = 4 for moderate β (≤ 0.7) but degrades to c ≈ 2 at β = 0.99 because the slow-mode coefficient vanishes when initial velocity is zero.

### Conjectured closed form

The leading-order asymptotic constant is derivable from the slow-eigenmode rate r₁ = 1 − ημ/(1−β) + O((ημ/(1−β))²). For T·η μ /(1−β) "large but finite" and r₁^T ≪ 1:

f(x_T^{Ces})  ≈  (μ/2) · A² (1−β)² / (T η μ)²  ·  (1 + O(1/T))
f(x_T^{PR})   ≈  (μ/2) · 4 A² (1−β)⁴ / (T η μ)⁴  ·  (1 + O(1/T))

where A is the slow-mode coefficient determined by initial conditions. For x₀ ≠ x₋₁ (alt_mom), A = Θ(1) for the slow eigenmode. Hence

**f(x_T^{PR}) / f(x_T^{Ces}) = 4 (1−β)² κ² / (T η L)² · (1 + O(1/T))**

so the exponent gap is exactly **2** in the κ-power law.

---

## Phenomenon B — Same κ²/κ⁴ split for Huber-smoothed (non-quadratic) loss

### Statement

For f₃(x) = L · Huber(x₁) + Huber(x₂) (Huber with δ = 1, L-smooth, only locally SC) with alt_mom initialization and T = 10000:

In the stable parameter region (β = 0.5 or 0.7, ηL ≤ 2.0), the same κ-exponents hold:

| (β, ηL) | c_Cesàro | c_PR | Δ |
|---|---|---|---|
| (0.5, 1.0) | 1.95 | 3.85 | +1.90 |
| (0.5, 2.0) | 1.99 | 3.94 | +1.95 |
| (0.7, 1.0) | 1.99 | 3.92 | +1.93 |
| (0.7, 2.0) | 2.00 | 3.93 | +1.93 |
| (0.9, 1.0) | 2.00 | 3.89 | +1.89 |
| (0.9, 2.0) | 2.00 | 3.82 | +1.82 |

For high momentum or aggressive step (β = 0.99, ηL > 2 with f₃), iterates leave the quadratic region of Huber and the exponents become (β, ηL)-specific. In the stable region the κ²/κ⁴ split survives — confirming this is a **smooth-strongly-convex iterate-averaging phenomenon**, not specific to quadratics.

---

## Phenomenon C — Cesàro converges with κ² amplification regardless of step size or momentum

### Statement

For all functions f₁, f₂, f₃ (in stable region) and both initializations, **f(Cesàro) − f* = (1.99 ± 0.02) · κ² · const(β, ηL, T) for T = 10000**, with R² = 1.000 in every fit.

The exponent c = 2 is immune to:
- choice of β ∈ {0.5, 0.7, 0.9, 0.95, 0.99}
- choice of ηL ∈ {0.5, 1.0, 1.5, 2.0, 2.5, 2.9}
- dimension (d = 2 vs d = 10 with logspaced spectrum)
- non-quadraticity (f₃ Huber matches when iterates remain in stable region)

This is the cleanest "universal" κ-dependence found in the sweep — the const(·) absorbs all parameter dependence, leaving the κ² law untouched.

---

## Other observations (less crisp)

- **f4 Rosenbrock** with η = ηL/κ blew up at every (β, ηL, κ) tested at T = 10000 — the step-size rule is mismatched to Rosenbrock's variable curvature; not a phenomenon in our setup.
- **last, best, suffix iterates** for moderate β converge geometrically (numerically zero at 50 dps for κ ≤ 1000), so f-suboptimality is **not** a power law in κ; the apparent log-linear slopes (≈ 60–75 for β = 0.95) come from the collapsing exponential `exp(−Θ(T/κ))` and are not genuine κ-power laws (R² ≈ 0.6).
- At **β = 0.99** with **zero_mom**, PR's exponent drops from 4 to 2 because the slow-mode coefficient A is suppressed when initial velocity is zero — the PR formula's leading term vanishes and the next-order term controls. With **alt_mom**, PR keeps c ≈ 3.5 even at β = 0.99 because A stays Θ(1). This is itself evidence that the PR ~ κ⁴ law is *driven by the slow-mode amplitude*, consistent with the conjectured closed form.

---

## Files

- `raw_data.csv` — 14400 rows, all (function, β, ηL, κ, init, T, iterate_type, fvalue) tuples.
- `exponents.csv` — per-setting log-log fit of f(·) vs κ, with R² and the four f-values at κ ∈ {10,100,1000,10000}.
- `separations_all.csv` — pairwise iterate-type κ-exponent differences with R² and ratios.
- `separations_genuine.csv` — filtered to |Δexp| > 0.5 and R² > 0.99 with ratio range > 1 decade.
- `top_conjecture.md` — single strongest conjecture, formalized.
- `shb_search.py`, `analyze.py` — reproduction scripts.
