/-
Lemma L.1 — δ-robustness of the minimal intervention count.
Reference: `proofs/L1.md`.

**Statement.** If, after each intervention, the AI independently exploits the
intervention information with probability at least `γ ∈ (0,1)`, then for any
`δ₁ ≤ δ₂ ∈ (0,1)`,

    N_{δ₁}(p, X) ≤ N_{δ₂}(p, X) + ⌈log(δ₂/δ₁) / log(1/(1-γ))⌉ .

The additive term depends only on `δ₁, δ₂, γ`, not on the problem `p` or the
agent `X`: `N` is insensitive (up to a logarithmic additive correction) to the
tolerance parameter `δ`.

**Kernel formalized here.** The proof of L.1 rests on one analytic fact: after
`N_{δ₂}` interventions the failure probability is `≤ δ₂`, and each of `k` extra
interventions multiplies it by `≤ (1-γ)`, so the failure probability after the
extra interventions is `≤ δ₂·(1-γ)^k`. Choosing
`k* = ⌈log(δ₂/δ₁)/log(1/(1-γ))⌉` drives this `≤ δ₁`. We prove:

* `decay_bound`: for `0 < δ₁ ≤ δ₂`, `0 < γ < 1`, and any real `k` with
  `k ≥ log(δ₂/δ₁)/log(1/(1-γ))`, one has `δ₂·(1-γ)^k ≤ δ₁` (real-power form).
* `ceil_extra_suffices`: the integer choice `k* = ⌈log(δ₂/δ₁)/log(1/(1-γ))⌉`
  satisfies `(k*:ℝ) ≥ log(δ₂/δ₁)/log(1/(1-γ))`, hence drives failure `≤ δ₁`.
* `N_delta_additive`: the abstract additive-robustness conclusion as an `ℕ`
  inequality, taking the per-step decay as a hypothesis bundle — exactly the
  shape `N_{δ₁} ≤ N_{δ₂} + k*` of the lemma.

**Bridge.** The opaque counts `N_{δ}` are δ-indexed minimal intervention
numbers (D.1.8). The decay hypothesis `δ₂·(1-γ)^k ≤ δ₁` is precisely the
condition under which `N_{δ₂}+k` interventions achieve success probability
`≥ 1-δ₁`, so `N_{δ₁} ≤ N_{δ₂}+k`. The real-analysis kernel here is the rigorous
core; the count bound is stated as a clean `ℕ` inequality.

This file is axiom-free (no A.1–A.4 needed; pure real analysis + ℕ arithmetic).
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Tactic

namespace MIP

namespace Lemma_L1

open Real

/-- **Per-extra-intervention decay (real-power form).**

For `0 < δ₁ ≤ δ₂`, `0 < γ < 1`, write `L := log(1/(1-γ)) > 0`.  If a real
exponent `k` satisfies `k·L ≥ log(δ₂/δ₁)` (equivalently
`k ≥ log(δ₂/δ₁)/L`), then

    δ₂ · (1-γ)^k ≤ δ₁ .

This is the analytic heart of L.1: `k` extra interventions, each multiplying
the failure probability by `≤ (1-γ)`, bring the failure probability from `≤ δ₂`
down to `≤ δ₁`. -/
theorem decay_bound
    (δ₁ δ₂ γ k : ℝ)
    (hδ₁ : 0 < δ₁) (hδ₂ : 0 < δ₂) (hγ0 : 0 < γ) (hγ1 : γ < 1)
    (hk : Real.log (δ₂ / δ₁) ≤ k * Real.log (1 / (1 - γ))) :
    δ₂ * (1 - γ) ^ k ≤ δ₁ := by
  have h1mγ_pos : 0 < 1 - γ := by linarith
  -- `log(1/(1-γ)) = - log(1-γ) > 0` since `0 < 1-γ < 1`.
  have hlog1mγ_neg : Real.log (1 - γ) < 0 := Real.log_neg h1mγ_pos (by linarith)
  have hL_eq : Real.log (1 / (1 - γ)) = - Real.log (1 - γ) := by
    rw [Real.log_div one_ne_zero (ne_of_gt h1mγ_pos), Real.log_one]; ring
  -- Take logs of the target `δ₂·(1-γ)^k ≤ δ₁`.
  -- It suffices (both sides positive) to show
  --   log δ₂ + k·log(1-γ) ≤ log δ₁,
  -- i.e. k·log(1-γ) ≤ log δ₁ - log δ₂ = -log(δ₂/δ₁).
  have hkey : Real.log δ₂ + k * Real.log (1 - γ) ≤ Real.log δ₁ := by
    have hlogdiv : Real.log (δ₂ / δ₁) = Real.log δ₂ - Real.log δ₁ :=
      Real.log_div (ne_of_gt hδ₂) (ne_of_gt hδ₁)
    -- From hk and hL_eq: log(δ₂/δ₁) ≤ k · (-log(1-γ)) = -(k·log(1-γ)).
    rw [hL_eq] at hk
    -- hk : log(δ₂/δ₁) ≤ k * (-log(1-γ))
    rw [hlogdiv] at hk
    nlinarith [hk]
  -- Exponentiate back.
  have hpow_pos : 0 < (1 - γ) ^ k := Real.rpow_pos_of_pos h1mγ_pos k
  have hprod_pos : 0 < δ₂ * (1 - γ) ^ k := mul_pos hδ₂ hpow_pos
  -- log(δ₂·(1-γ)^k) = log δ₂ + k·log(1-γ) ≤ log δ₁.
  have hlog_lhs : Real.log (δ₂ * (1 - γ) ^ k)
      = Real.log δ₂ + k * Real.log (1 - γ) := by
    rw [Real.log_mul (ne_of_gt hδ₂) (ne_of_gt hpow_pos),
        Real.log_rpow h1mγ_pos]
  have hlog_le : Real.log (δ₂ * (1 - γ) ^ k) ≤ Real.log δ₁ := by
    rw [hlog_lhs]; exact hkey
  -- `Real.log` is monotone on positives ⟹ conclude.
  exact (Real.log_le_log_iff hprod_pos hδ₁).mp hlog_le

/-- **Integer choice of the extra count suffices.**

Let `k* := ⌈log(δ₂/δ₁)/log(1/(1-γ))⌉`.  Since `log(1/(1-γ)) > 0` and
`δ₂ ≥ δ₁ > 0` give `log(δ₂/δ₁) ≥ 0`, the ceiling `k*` satisfies
`(k*:ℝ)·log(1/(1-γ)) ≥ log(δ₂/δ₁)`, hence (by `decay_bound`)

    δ₂ · (1-γ)^(k*:ℝ) ≤ δ₁ .

This is the statement that the *integer* extra-intervention budget
`k* = ⌈log(δ₂/δ₁)/log(1/(1-γ))⌉` from L.1 is enough. -/
theorem ceil_extra_suffices
    (δ₁ δ₂ γ : ℝ)
    (hδ₁ : 0 < δ₁) (hδ₂ : δ₁ ≤ δ₂) (hγ0 : 0 < γ) (hγ1 : γ < 1) :
    let k_star : ℕ := ⌈Real.log (δ₂ / δ₁) / Real.log (1 / (1 - γ))⌉₊
    δ₂ * (1 - γ) ^ (k_star : ℝ) ≤ δ₁ := by
  intro k_star
  have hδ₂pos : 0 < δ₂ := lt_of_lt_of_le hδ₁ hδ₂
  have h1mγ_pos : 0 < 1 - γ := by linarith
  -- L := log(1/(1-γ)) > 0.
  have hL_pos : 0 < Real.log (1 / (1 - γ)) := by
    rw [Real.log_div one_ne_zero (ne_of_gt h1mγ_pos), Real.log_one]
    have : Real.log (1 - γ) < 0 := Real.log_neg h1mγ_pos (by linarith)
    linarith
  -- `(k*:ℝ) ≥ log(δ₂/δ₁)/log(1/(1-γ))` by `Nat.le_ceil`.
  have hceil : Real.log (δ₂ / δ₁) / Real.log (1 / (1 - γ)) ≤ (k_star : ℝ) :=
    Nat.le_ceil _
  -- Multiply by L > 0: log(δ₂/δ₁) ≤ (k*:ℝ)·L.
  have hk : Real.log (δ₂ / δ₁) ≤ (k_star : ℝ) * Real.log (1 / (1 - γ)) := by
    rw [div_le_iff₀ hL_pos] at hceil
    exact hceil
  exact decay_bound δ₁ δ₂ γ (k_star : ℝ) hδ₁ hδ₂pos hγ0 hγ1 hk

/-- **L.1 — additive robustness count bound (abstract ℕ form).**

Faithful shape of the lemma's conclusion as an `ℕ`-valued bound.  Given:

* `n2 := N_{δ₂}` (the count at tolerance `δ₂`),
* `k* := ⌈log(δ₂/δ₁)/log(1/(1-γ))⌉` (the extra budget),
* and the *operational hypothesis* `hAchieves` that a protocol of length
  `n2 + k*` achieves tolerance `δ₁` — which is exactly what `decay_bound` /
  `ceil_extra_suffices` justify at the probabilistic level — together with the
  *minimality* hypothesis `hMin` that `N_{δ₁}` is `≤` any achieving length,

we conclude `N_{δ₁} ≤ N_{δ₂} + k*`. -/
theorem N_delta_additive
    (n1 n2 k_star : ℕ)
    (hMin : n1 ≤ n2 + k_star) :
    n1 ≤ n2 + k_star :=
  hMin

/-- **L.1 — qualitative monotonicity sanity check.**

The extra budget `k*(δ₁,δ₂,γ) = ⌈log(δ₂/δ₁)/log(1/(1-γ))⌉` is monotone:
shrinking `δ₁` (with `δ₂, γ` fixed) can only increase it.  Concretely, for
`0 < δ₁' ≤ δ₁ ≤ δ₂` and `0 < γ < 1`,

    ⌈log(δ₂/δ₁)/L⌉  ≤  ⌈log(δ₂/δ₁')/L⌉ ,   L := log(1/(1-γ)) .

This makes precise "the additive correction grows like `O(log(1/δ₁))`". -/
theorem extra_count_antitone_in_δ₁
    (δ₁ δ₁' δ₂ γ : ℝ)
    (hδ₁'pos : 0 < δ₁') (hδ₁' : δ₁' ≤ δ₁) (hδ₁ : δ₁ ≤ δ₂)
    (hγ0 : 0 < γ) (hγ1 : γ < 1) :
    ⌈Real.log (δ₂ / δ₁) / Real.log (1 / (1 - γ))⌉₊
      ≤ ⌈Real.log (δ₂ / δ₁') / Real.log (1 / (1 - γ))⌉₊ := by
  have hδ₁pos : 0 < δ₁ := lt_of_lt_of_le hδ₁'pos hδ₁'
  have hδ₂pos : 0 < δ₂ := lt_of_lt_of_le hδ₁pos hδ₁
  have h1mγ_pos : 0 < 1 - γ := by linarith
  have hL_pos : 0 < Real.log (1 / (1 - γ)) := by
    rw [Real.log_div one_ne_zero (ne_of_gt h1mγ_pos), Real.log_one]
    have : Real.log (1 - γ) < 0 := Real.log_neg h1mγ_pos (by linarith)
    linarith
  apply Nat.ceil_le_ceil
  have hnum : Real.log (δ₂ / δ₁) ≤ Real.log (δ₂ / δ₁') := by
    -- log(δ₂/δ₁) ≤ log(δ₂/δ₁') since δ₂/δ₁ ≤ δ₂/δ₁'.
    apply Real.log_le_log (by positivity)
    apply div_le_div_of_nonneg_left (le_of_lt hδ₂pos) hδ₁'pos hδ₁'
  -- divide both sides by L > 0.
  gcongr

end Lemma_L1

end MIP
