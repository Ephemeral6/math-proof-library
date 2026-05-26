/-
Result R.274 — Effective dimension of the barrier DAG: the growth dimension
`d_grow` extracts the power-law exponent from neighborhood-ball growth.

Reference: `branches/thermodynamics/workspace/new_results.md` R.274
(D.4.17 growth dimension / D.4.18 spectral dimension, A for the formalization,
2026-05-18 thermodynamics branch).

**Statement (R.274 lightweight core).**  Model the closed-ball cardinality of
the barrier DAG by a power law `Nr r = C · r ^ d` with constants `C > 0` and
exponent `d ≥ 0`.  The **growth dimension** is defined (D.4.17) by

    d_grow := lim_{r → ∞} log |N_r(b_0)| / log r .

We prove that this limit extracts the exponent exactly:

    Tendsto (fun r => Real.log (Nr r) / Real.log r) atTop (𝓝 d) .

The proof is limit algebra:
`log (C · r^d) / log r = log C / log r + d → 0 + d = d` as `r → ∞`,
since `log r → ∞` and `log C` is a constant.

A corollary specialises to the **chain DAG** (`Nr r = r`, i.e. `C = 1, d = 1`),
giving `d_grow(chain) = 1` — sequential reasoning has effective dimension one.

The companion definition `d_spec` (Alexander–Orbach spectral dimension) and the
amenable-graph equivalence `d_grow = d_spec` are physics-level statements
(requiring Varopoulos-type heat-kernel bounds) and are bundled away; this file
formalises the real-analytic extraction core that both rest on.

**This file is `axiom`-free.**  It imports only Mathlib and proves the limit as
a self-contained statement about a real power law.
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Topology.Algebra.Order.Field

namespace MIP

namespace EffectiveDim

open Filter Topology Real

/-- Power-law neighborhood-growth model: `Nr r = C · r ^ d`. -/
noncomputable def Nr (C d r : ℝ) : ℝ := C * r ^ d

/-- **R.274 — growth dimension extracts the power-law exponent.**

For a power-law ball growth `Nr r = C · r^d` with `C > 0`, the growth-dimension
ratio `log (Nr r) / log r` tends to the exponent `d` as `r → ∞`:

    d_grow := lim_{r→∞} log (C · r^d) / log r = d .

Proof: `log (C · r^d) = log C + d · log r` for `r > 0`, so the ratio equals
`log C / log r + d`.  Since `log r → ∞`, the term `log C / log r → 0`, leaving
the constant `d`. -/
theorem R_274_growth_dim_tendsto (C d : ℝ) (hC : 0 < C) :
    Tendsto (fun r : ℝ => Real.log (Nr C d r) / Real.log r) atTop (𝓝 d) := by
  -- `log r → ∞` as `r → ∞`.
  have hlog : Tendsto (fun r : ℝ => Real.log r) atTop atTop :=
    Real.tendsto_log_atTop
  -- Hence `log C / log r → 0`.
  have hconst : Tendsto (fun r : ℝ => Real.log C / Real.log r) atTop (𝓝 0) := by
    simpa using (hlog.const_div_atTop (Real.log C))
  -- So `log C / log r + d → 0 + d = d`.
  have hsum : Tendsto (fun r : ℝ => Real.log C / Real.log r + d) atTop (𝓝 (0 + d)) :=
    hconst.add_const d
  rw [zero_add] at hsum
  -- The two functions agree eventually (for `r > 1`, where `log r ≠ 0`).
  refine hsum.congr' ?_
  -- Work on the set `r > 1`, which is eventually true at `atTop`.
  filter_upwards [eventually_gt_atTop (1 : ℝ)] with r hr
  have hr0 : 0 < r := lt_trans one_pos hr
  have hlogr_ne : Real.log r ≠ 0 := ne_of_gt (Real.log_pos hr)
  -- `log (C · r^d) = log C + log (r^d) = log C + d · log r`.
  have hpow_pos : 0 < r ^ d := Real.rpow_pos_of_pos hr0 d
  have hexpand : Real.log (Nr C d r) = Real.log C + d * Real.log r := by
    unfold Nr
    rw [Real.log_mul (ne_of_gt hC) (ne_of_gt hpow_pos), Real.log_rpow hr0]
  rw [hexpand]
  field_simp

/-- **R.274.a — chain DAG has effective dimension 1.**

The chain (sequential / chain-of-thought reasoning) has ball growth
`Nr r ~ r`, i.e. `C = 1`, `d = 1`.  Then `d_grow(chain) = 1`. -/
theorem R_274_a_chain_dim_one :
    Tendsto (fun r : ℝ => Real.log (Nr 1 1 r) / Real.log r) atTop (𝓝 1) :=
  R_274_growth_dim_tendsto 1 1 one_pos

/-- **R.274.b — 2D grid (planar attention) has effective dimension 2.**

A planar lattice DAG has `Nr r ~ π r²`, i.e. `C = π`, `d = 2`. -/
theorem R_274_b_grid2D_dim_two :
    Tendsto (fun r : ℝ => Real.log (Nr Real.pi 2 r) / Real.log r) atTop (𝓝 2) :=
  R_274_growth_dim_tendsto Real.pi 2 Real.pi_pos

end EffectiveDim

end MIP
