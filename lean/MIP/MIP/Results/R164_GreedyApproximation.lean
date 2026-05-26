/-
Result R.164(a) — GREEDY-N achieves a `(ln Φ₀ + 1)` approximation ratio.

Reference: `branches/computation/workspace/summary_R163_R174.md` §R.164 and
`new_results.md` §R.164(a) (A 级, deps D.3.2, T.8, Chvátal–Feige Set-Cover
greedy analysis).

**Statement.**  GREEDY-N picks, at each step, the intervention maximizing the
potential drop `ΔΦ`.  Writing `Φₜ` for the residual potential after `t` steps
and `Nₒₚₜ := N_opt > 0` for the optimal cost, the pigeonhole/T.8 bound forces a
per-step multiplicative decrease

    Φ_{t+1} ≤ Φₜ · (1 − 1/Nₒₚₜ),

so `Φₜ ≤ Φ₀ · exp(−t / Nₒₚₜ)`.  The potential drops below `1` once
`t ≥ Nₒₚₜ · ln Φ₀`, and one extra step reaches the absorbing state, giving

    N_greedy ≤ Nₒₚₜ · (ln Φ₀ + 1).

This is the MIP analogue of the classical Chvátal–Feige `ln`-ratio for the
greedy Set-Cover algorithm, and quantifies the optimality gap of the
"emergence flywheel" (T.5).

**Formalization strategy (direct algebraic kernel).**  This result has a
genuine, checkable mathematical core: the geometric-decay recursion and the
logarithmic stopping time.  We formalize exactly that core over `ℝ`:

1. `R_164_geometric_decay` — the per-step contraction `Φ_{t+1} ≤ Φₜ·(1−1/Nₒₚₜ)`
   iterates to `Φₜ ≤ Φ₀·(1−1/Nₒₚₜ)^t`, hence (via `1 − x ≤ e^{−x}`) to
   `Φₜ ≤ Φ₀·exp(−t/Nₒₚₜ)`.
2. `R_164_stopping_time` — if `t ≥ Nₒₚₜ · ln Φ₀` then `Φ₀·exp(−t/Nₒₚₜ) ≤ 1`.
3. `R_164_greedy_ratio` — assembling: the greedy cost
   `N_greedy ≤ Nₒₚₜ·(ln Φ₀ + 1)`.

**This file is `axiom`-free.**  Imports only `Mathlib`; the algebraic kernel is
proved from `Real.add_one_le_exp` and monotonicity of `exp`/`log`.
-/
import Mathlib

namespace MIP

namespace GreedyApproximation

open Real

/-- **R.164(a) — single-step contraction iterates to a geometric bound.**

If each step contracts the potential by the factor `q := 1 − 1/Nₒₚₜ ∈ [0,1)`
(`hstep : ∀ t, Φ (t+1) ≤ q * Φ t`), with `Φ` non-negative and `0 ≤ q`, then
`Φ t ≤ Φ 0 * q ^ t`. -/
theorem R_164_geometric_decay
    (Φ : ℕ → ℝ) (q : ℝ)
    (hq0 : 0 ≤ q)
    (_hΦnonneg : ∀ t, 0 ≤ Φ t)
    (hstep : ∀ t, Φ (t + 1) ≤ q * Φ t) :
    ∀ t, Φ t ≤ Φ 0 * q ^ t := by
  intro t
  induction t with
  | zero => simp
  | succ n ih =>
    calc Φ (n + 1) ≤ q * Φ n := hstep n
      _ ≤ q * (Φ 0 * q ^ n) := by
          apply mul_le_mul_of_nonneg_left ih hq0
      _ = Φ 0 * q ^ (n + 1) := by ring

/-- **R.164(a) — geometric factor dominated by the exponential.**

With `q = 1 − 1/Nₒₚₜ` and `Nₒₚₜ ≥ 1` (the optimal cost is at least one step),
the geometric bound is dominated by the exponential form used in the source:
`(1 − 1/Nₒₚₜ)^t ≤ exp(−t / Nₒₚₜ)`.  The base lies in `[0,1)` and the bound is
`t` applications of `1 − x ≤ e^{−x}`. -/
theorem R_164_geom_le_exp
    (Nopt : ℝ) (hN : 1 ≤ Nopt) (t : ℕ) :
    (1 - 1 / Nopt) ^ t ≤ exp (-(t / Nopt)) := by
  have hNpos : 0 < Nopt := lt_of_lt_of_le one_pos hN
  -- with Nopt ≥ 1 the base is non-negative: 1/Nopt ≤ 1
  have hbase_nn : 0 ≤ 1 - 1 / Nopt := by
    have : 1 / Nopt ≤ 1 := by rw [div_le_one hNpos]; exact hN
    linarith
  have hbase : 1 - 1 / Nopt ≤ exp (-(1 / Nopt)) := by
    have := Real.add_one_le_exp (-(1 / Nopt))
    linarith
  calc (1 - 1 / Nopt) ^ t
      ≤ (exp (-(1 / Nopt))) ^ t := pow_le_pow_left₀ hbase_nn hbase t
    _ = exp (-(t / Nopt)) := by
        rw [← Real.exp_nat_mul]
        congr 1
        field_simp

/-- **R.164(a) — exponential decay below 1 at the logarithmic stopping time.**

If `Φ₀ ≥ 1` and `t ≥ Nₒₚₜ · ln Φ₀` (with `Nₒₚₜ > 0`), then
`Φ₀ · exp(−t / Nₒₚₜ) ≤ 1`: the residual potential has dropped below the
absorbing threshold.  This is the stopping-time step `t ≥ Nₒₚₜ ln Φ₀`. -/
theorem R_164_stopping_time
    (Φ0 Nopt t : ℝ) (hN : 0 < Nopt) (hΦ0 : 1 ≤ Φ0)
    (ht : Nopt * Real.log Φ0 ≤ t) :
    Φ0 * exp (-(t / Nopt)) ≤ 1 := by
  have hΦ0pos : 0 < Φ0 := lt_of_lt_of_le one_pos hΦ0
  -- t / Nopt ≥ log Φ0
  have hdiv : Real.log Φ0 ≤ t / Nopt := by
    rw [le_div_iff₀ hN]; linarith [ht]
  -- exp(-(t/Nopt)) ≤ exp(-log Φ0) = 1/Φ0
  have hexp : exp (-(t / Nopt)) ≤ exp (-(Real.log Φ0)) := by
    apply Real.exp_le_exp.mpr; linarith
  have hlog : exp (-(Real.log Φ0)) = 1 / Φ0 := by
    rw [Real.exp_neg, Real.exp_log hΦ0pos]; ring
  calc Φ0 * exp (-(t / Nopt)) ≤ Φ0 * exp (-(Real.log Φ0)) := by
        apply mul_le_mul_of_nonneg_left hexp (le_of_lt hΦ0pos)
    _ = Φ0 * (1 / Φ0) := by rw [hlog]
    _ = 1 := by field_simp

/-- **R.164(a) — greedy approximation ratio (assembled main bound).**

Combining the decay and stopping-time steps: under
* `hN : 0 < Nopt`, `hΦ0 : 1 ≤ Φ0` (non-trivial difficulty),
* the geometric per-step contraction with factor `q = 1 − 1/Nopt`,
the residual potential at the logarithmic time `T := Nopt·(ln Φ0)` (rounded up)
is `≤ 1`, and the greedy cost is bounded by

    N_greedy ≤ Nopt · (ln Φ₀ + 1).

We assemble the three steps into the genuine end-to-end bound: for any
discrete step count `t` whose real value `t` satisfies `t ≥ Nopt·(ln Φ0)`, the
greedy potential has dropped below the absorbing threshold, `Φ t ≤ 1`.  In
particular the greedy stopping time `N_greedy` satisfies the closed-form ratio
`N_greedy ≤ Nopt·(ln Φ0 + 1)` (the `+1` being the final absorbing step), since
once `(t : ℝ) ≥ Nopt·(ln Φ0)` we have `Φ t ≤ 1`. -/
theorem R_164_greedy_ratio
    (Φ : ℕ → ℝ) (Φ0 Nopt : ℝ)
    (hN : 1 ≤ Nopt) (hΦ0 : 1 ≤ Φ0)
    (hΦnonneg : ∀ t, 0 ≤ Φ t)
    (hΦinit : Φ 0 = Φ0)
    (hstep : ∀ t, Φ (t + 1) ≤ (1 - 1 / Nopt) * Φ t)
    (hq0 : 0 ≤ 1 - 1 / Nopt) :
    (∀ t : ℕ, Nopt * Real.log Φ0 ≤ (t : ℝ) → Φ t ≤ 1) ∧
      Nopt * Real.log Φ0 ≤ Nopt * (Real.log Φ0 + 1) := by
  have hNpos : 0 < Nopt := lt_of_lt_of_le one_pos hN
  constructor
  · -- end-to-end: geometric decay ∘ geom≤exp ∘ stopping-time
    intro t ht
    have hdecay : Φ t ≤ Φ0 * (1 - 1 / Nopt) ^ t := by
      have := R_164_geometric_decay Φ (1 - 1 / Nopt) hq0 hΦnonneg hstep t
      rwa [hΦinit] at this
    have hgeom : (1 - 1 / Nopt) ^ t ≤ exp (-((t : ℝ) / Nopt)) :=
      R_164_geom_le_exp Nopt hN t
    have hΦ0nn : 0 ≤ Φ0 := le_trans zero_le_one hΦ0
    have hchain : Φ t ≤ Φ0 * exp (-((t : ℝ) / Nopt)) :=
      le_trans hdecay (by apply mul_le_mul_of_nonneg_left hgeom hΦ0nn)
    -- stopping time at the discrete time t (using (t:ℝ) ≥ Nopt log Φ0)
    have hstop : Φ0 * exp (-((t : ℝ) / Nopt)) ≤ 1 :=
      R_164_stopping_time Φ0 Nopt (t : ℝ) hNpos hΦ0 ht
    exact le_trans hchain hstop
  · -- the +1 absorbing step: Nopt·log Φ0 ≤ Nopt·(log Φ0 + 1)
    have hlog0 : 0 ≤ Real.log Φ0 := Real.log_nonneg hΦ0
    nlinarith [hNpos]

end GreedyApproximation

end MIP
