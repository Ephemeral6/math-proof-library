/-
Result R.147 — Multi-step cumulative mutual information (information-theoretic
bound on the teaching process).

Reference: `branches/duality/workspace/new_results.md` R.147 (terminal-3
local R.074, A 条件性, 2026-05-16 duality branch).

**Statement interpretation used.**  R.147 models the teaching trajectory by
the residual-potential sequence `Φ : ℕ → ℝ` with `Φ(k+1) = Φ(k) − ψ(k)`
(each step `k` removes `ψ_k := max ΔΦ*` of the residual emergence
potential).  The `n`-step cumulative mutual information is

    I_cum^(n) := Σ_{k<n} log( Φ(k) / Φ(k+1) ) .

The arithmetic / structural cores formalized here:

* **(iii) telescoping identity**
  `I_cum^(n) = log( Φ(0) / Φ(n) )`  (positive sequence).
* **residual identity** `Φ(n) = Φ(0) − Σ_{k<n} ψ(k)`.
* **(i)+(ii) closed form** `I_cum^(n) = log( Φ₀ / (Φ₀ − Σψ) )`, hence at
  `n = N*` (where `Σψ = Φ₀ − Φ_res`) `I_cum = log(Φ₀ / Φ_res)`.
* **(ii) autonomy-singularity divergence**: as `Φ_res → 0⁺`,
  `I_cum = log(Φ₀/Φ_res) → ∞` (infinite information transfer at the
  autonomy singularity).
* **(iii) dual identity** `N* · Ī_single = I_cum`  with
  `Ī_single := I_cum / N*`.
* **(iv) N\* information-theoretic lower bound**: from `Φ₀·ρ^n ≤ Φ_res`
  (fastest decay `ρ := 1 − ψ_max/Φ₀`), `log(Φ₀/Φ_res) ≤ n · log(1/ρ)`,
  i.e. `n ≥ log(Φ₀/Φ_res) / log(1/ρ)` — the minimum number of
  interventions to teach `H` down to residual `Φ_res`.

All MIP dependencies enter as explicit bundle hypotheses.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.BigOperators.Intervals
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace CumulativeMutualInfo

open Real Filter Topology Finset

/-- **R.147 (iii) — telescoping identity for cumulative mutual information.**

For a positive residual-potential sequence `Φ`,

    Σ_{k<n} log( Φ(k) / Φ(k+1) )  =  log( Φ(0) / Φ(n) ) .

Pure telescoping (`log` turns the per-step ratio into a difference). -/
theorem R_147_iii_telescoping
    (Φ : ℕ → ℝ) (n : ℕ) (hpos : ∀ k, 0 < Φ k) :
    ∑ k ∈ Finset.range n, Real.log (Φ k / Φ (k + 1))
      = Real.log (Φ 0 / Φ n) := by
  have h1 : ∀ k ∈ Finset.range n,
      Real.log (Φ k / Φ (k + 1)) = Real.log (Φ k) - Real.log (Φ (k + 1)) := by
    intro k _; exact Real.log_div (ne_of_gt (hpos k)) (ne_of_gt (hpos (k + 1)))
  rw [Finset.sum_congr rfl h1, Finset.sum_range_sub' (fun k => Real.log (Φ k)) n,
      ← Real.log_div (ne_of_gt (hpos 0)) (ne_of_gt (hpos n))]

/-- **R.147 — residual-potential identity.**

If each step removes `ψ(k)` of the residual potential
(`Φ(k+1) = Φ(k) − ψ(k)`), then after `n` steps

    Φ(n) = Φ(0) − Σ_{k<n} ψ(k) .

Hence the total removed potential is `Σψ = Φ(0) − Φ(n)`. -/
theorem R_147_residual_identity
    (Φ ψ : ℕ → ℝ) (n : ℕ) (hrec : ∀ k, Φ (k + 1) = Φ k - ψ k) :
    Φ n = Φ 0 - ∑ k ∈ Finset.range n, ψ k := by
  induction n with
  | zero => simp
  | succ m ih => rw [hrec m, ih, Finset.sum_range_succ]; ring

/-- **R.147 (i)+(ii) — closed form `I_cum = log(Φ₀ / (Φ₀ − Σψ))`.**

Combining the telescoping identity with the residual identity:

    I_cum^(n) = log( Φ₀ / (Φ₀ − Σ_{k<n} ψ_k) ) .

In particular, at `n = N*` (full resolution, `Σψ = Φ₀ − Φ_res`) this is
`log(Φ₀ / Φ_res)`. -/
theorem R_147_i_closed_form
    (Φ ψ : ℕ → ℝ) (n : ℕ) (hpos : ∀ k, 0 < Φ k)
    (hrec : ∀ k, Φ (k + 1) = Φ k - ψ k) :
    ∑ k ∈ Finset.range n, Real.log (Φ k / Φ (k + 1))
      = Real.log (Φ 0 / (Φ 0 - ∑ k ∈ Finset.range n, ψ k)) := by
  rw [R_147_iii_telescoping Φ n hpos, ← R_147_residual_identity Φ ψ n hrec]

/-- **R.147 (ii) — autonomy-singularity divergence.**

As the residual potential `Φ_res → 0⁺`, the cumulative mutual information
`I_cum = log(Φ₀ / Φ_res)` diverges to `+∞`: the autonomy singularity is
the limit of infinite information transfer. -/
theorem R_147_ii_diverges (Φ0 : ℝ) (hΦ0 : 0 < Φ0) :
    Tendsto (fun Φ_res => Real.log (Φ0 / Φ_res)) (𝓝[>] 0) atTop := by
  have hdiv : Tendsto (fun r : ℝ => Φ0 / r) (𝓝[>] 0) atTop := by
    have hinv : Tendsto (fun r : ℝ => r⁻¹) (𝓝[>] (0 : ℝ)) atTop :=
      tendsto_inv_nhdsGT_zero
    have := hinv.const_mul_atTop hΦ0
    simpa [div_eq_mul_inv] using this
  exact Real.tendsto_log_atTop.comp hdiv

/-- **R.147 (iii) — dual identity `N* · Ī_single = I_cum`.**

With the average single-step mutual information `Ī := I_cum / N*`
(`N* ≠ 0`), the cumulative information satisfies `N* · Ī = I_cum`. -/
theorem R_147_iii_dual_identity
    (N_star I_cum : ℝ) (h : N_star ≠ 0) :
    N_star * (I_cum / N_star) = I_cum := by
  rw [mul_div_cancel₀ I_cum h]

/-- **R.147 (iv) — N\* information-theoretic lower bound.**

With the fastest-decay envelope `Φ₀·ρ^n ≤ Φ_res` (`ρ := 1 − ψ_max/Φ₀ ∈
(0,1)` the per-step survival factor), the number of steps obeys

    log(Φ₀ / Φ_res)  ≤  n · log(1 / ρ) ,

i.e. `n ≥ log(Φ₀/Φ_res) / log(1/ρ)` — the minimal intervention count to
teach `H` down to residual `Φ_res`. -/
theorem R_147_iv_lower_bound
    (Φ0 Φ_res ρ : ℝ) (n : ℕ)
    (hΦ0 : 0 < Φ0) (hres : 0 < Φ_res) (hρ : 0 < ρ)
    (hbound : Φ0 * ρ ^ n ≤ Φ_res) :
    Real.log (Φ0 / Φ_res) ≤ n * Real.log (1 / ρ) := by
  have hlog : Real.log (Φ0 * ρ ^ n) ≤ Real.log Φ_res :=
    Real.log_le_log (by positivity) hbound
  rw [Real.log_mul (ne_of_gt hΦ0) (by positivity), Real.log_pow] at hlog
  rw [Real.log_div (ne_of_gt hΦ0) (ne_of_gt hres), one_div, Real.log_inv]
  nlinarith [hlog]

end CumulativeMutualInfo

end MIP
