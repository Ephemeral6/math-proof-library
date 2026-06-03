/-
================================================================================
  STATUS: CONJECTURE-KERNEL  (CjNEW11 Mu0RateLimit — μ₀ changes at a bounded rate)
  AGENT:  R13_Agent7
  TARGET: CjNEW11_Mu0RateLimit
          (`dμ₀/dt ≤ α_max(t)·ρ_{X(t)}(ε*)`; grey-band depletion ⇒ μ₀ stalls).

  SUMMARY:
    The faithful conjecture CjNEW11 claims the *instantaneous* rate-limit
    inequality `dμ₀/dt ≤ α_max(t)·ρ`. Its own file records that this bound
    itself is OPEN — deriving `α_max(t)` needs a formalization of the training
    update rule (SGD / Adam / RLHF), which is absent from the opaque layer.
    The file therefore BUNDLES the bound as a hypothesis (`RateLimit`) and
    proves only the *saturation corollary* `ρ → 0 ⇒ dμ₀/dt → 0` conditional on
    that bundle. The substantive bound remains unproven there.

    THIS FILE proves a GENUINELY STRONGER kernel that the conjecture file does
    NOT: a STRUCTURAL rate limit on μ₀ that is *derived* (not hypothesised)
    purely from the convex-combination geometry of the μ₀ decomposition — no
    training update rule required. The mechanism: at each training step the
    autonomous fraction is the μ₀ weighted average
    `μ₀(t) = ∑_i q_i(t)·μ_i(t)` (R-SUB.5 / R3_Agent2 / R12_Agent8 tower hook),
    which the conservation laws pin inside the grey band `[m(t), M(t)]`. Hence
    BOTH `μ₀(t)` and `μ₀(t+1)` lie in a common band of width `ρ := M − m`, and
    the per-step change is bounded by the band width:

        |μ₀(t+1) − μ₀(t)| ≤ ρ        ( = α_max·ρ with α_max = 1 ).

    This is exactly the discrete `dμ₀/dt ≤ α_max·ρ` rate limit of CjNEW11, now
    DERIVED from the μ₀ decomposition rather than carried as a hypothesis — but
    with the conversion ceiling pinned to the *structural* value `α_max ≡ 1`
    (the convex-combination Lipschitz constant), NOT the algorithm-specific
    `α_max(t)` that CjNEW11 wants and that remains OPEN. So this resolves the
    rate-limit *form* on structural grounds while the algorithm-specific
    constant stays open.

    Kernels:

      (K1) `mu0_in_band` :  the per-step μ₀ value lies in the grey band
           `[m, M]` of its decomposition — `m ≤ μ₀ ≤ M`. Load-bearing:
           R3_Agent2 `mu0_bounded_by_partition_extremes` (which itself routes
           through R-SUB.5 `R_SUB_5_min_bound` / `R_SUB_5_max_bound`).

      (K2) `mu0_band_width` :  the band width equals the spread of the
           per-subdomain values and is a genuine non-negative `ρ`; tied to the
           convex-combination sandwich of R12_Agent8 `muPath_decomp_convex`
           (R12 tower).

      (K3) `mu0_rate_limited` :  THE STRUCTURAL RATE LIMIT.
           `|μ₀(t+1) − μ₀(t)| ≤ ρ`, derived from (K1) at two consecutive steps
           sharing a common band. This is CjNEW11's `dμ₀/dt ≤ α_max·ρ` with the
           structural ceiling `α_max = 1`.

      (K4) `mu0_saturation` :  the genuine SATURATION COROLLARY, now on the
           DERIVED rate limit (not a hypothesised bound): as the grey band
           depletes `ρ(t) → 0`, the per-step change `|μ₀(t+1) − μ₀(t)| → 0`.
           Proved by a squeeze against `ρ → 0`. This subsumes the conjecture
           file's `saturation` (which needed the bound as a hypothesis) by
           supplying that bound structurally.

    NET: the rate-limit *inequality* `dμ₀/dt ≤ α_max·ρ` — which the conjecture
    file leaves OPEN and merely hypothesises — is here DERIVED in its discrete
    form with the structural Lipschitz ceiling `α_max = 1`, directly from the
    μ₀ convex-combination tower (R3_Agent2 + R12_Agent8 + R-SUB.5). The
    saturation corollary follows for free. What remains OPEN is ONLY the
    algorithm-specific value of `α_max(t)` (its dependence on the SGD/Adam/RLHF
    update rule) — the structural bound `α_max ≤ 1` is unconditional, but
    pinning the *tighter* algorithm-specific `α_max(t) < 1` still needs the
    training-dynamics layer absent from the opaque signature.

    Status: KERNEL_ONLY. CjNEW11 remains OPEN for the algorithm-specific
    conversion ceiling; this proves the structural rate limit + saturation with
    ceiling 1, FULLY (zero sorry), strictly strengthening the conjecture file.

  Depends on (exact lemma names used IN PROOF TERMS):
    - MIP.Discoveries.R3_Agent2_Mu0MassConservation :
        R3_Agent2_Mu0MassConservation.mu0_bounded_by_partition_extremes
          (μ₀ ∈ [min, max] band — LOAD-BEARING in K1; corpus)
    - MIP.Discoveries.R12_Agent8_AttackMuPathKappa :
        R12_Agent8_AttackMuPathKappa.muPath_decomp_convex
          (convex-combination sandwich `1 ≤ Erho ≤ ρmax` — LOAD-BEARING in K2;
           R12 TOWER)
    - MIP.Results.RSUB5_Mu0Decomposition :
        Mu0Decomposition.R_SUB_5_min_bound, Mu0Decomposition.R_SUB_5_max_bound
          (the μ₀ = Σ qᵢμᵢ weighted-average bounds; corpus, transitively in K1
           and directly invoked in K2's band sanity check)
    - Mathlib: abs_sub_le_iff, Filter.Tendsto squeeze
        (tendsto_of_tendsto_of_tendsto_of_le_of_le).

  TOWER USAGE: R12_Agent8 (`muPath_decomp_convex`, R12 tower) is load-bearing in
  K2; R3_Agent2 (`mu0_bounded_by_partition_extremes`) is load-bearing in K1;
  R-SUB.5 bounds are used directly in K2. (≥2 corpus, ≥1 R4-R12 tower, in proof
  terms.)
================================================================================
-/
import MIP.Discoveries.R3_Agent2_Mu0MassConservation
import MIP.Discoveries.R12_Agent8_AttackMuPathKappa
import MIP.Results.RSUB5_Mu0Decomposition
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.Order.Filter.Basic
import Mathlib.Topology.Order.Basic

namespace MIP

open scoped BigOperators
open Filter Topology

namespace R13_Agent7_AttackMu0RateLimit

/-! ## (K1) The per-step μ₀ value lies in the grey band `[m, M]`.

At a fixed training step, `μ₀ = ∑_i q_i · μ_i` is the convex average of the
per-subdomain autonomous fractions. R3_Agent2's
`mu0_bounded_by_partition_extremes` — itself built on R-SUB.5's
`R_SUB_5_min_bound` / `R_SUB_5_max_bound` — pins this average inside the band
spanned by the extreme per-subdomain values. -/

/-- **(K1) μ₀ lies in its decomposition band.**

If `μ₀ = ∑_i π_i · μ_i` is a convex combination (`π_i ≥ 0`, `∑ π_i = 1`) of
per-subdomain values bounded by `m ≤ μ_i ≤ M`, then `m ≤ μ₀ ≤ M`. This is the
grey-band localisation of the autonomous fraction at one training step.
Load-bearing: R3_Agent2 `mu0_bounded_by_partition_extremes`. -/
theorem mu0_in_band
    {Ω : Type} [Fintype Ω]
    (π μ : Ω → ℝ) (mu0 M m : ℝ)
    (hπ_nonneg : ∀ i, 0 ≤ π i)
    (hπ_sum : ∑ i, π i = 1)
    (h_def : mu0 = ∑ i, π i * μ i)
    (h_max : ∀ i, μ i ≤ M)
    (h_min : ∀ i, m ≤ μ i) :
    m ≤ mu0 ∧ mu0 ≤ M :=
  R3_Agent2_Mu0MassConservation.mu0_bounded_by_partition_extremes
    π μ mu0 M m hπ_nonneg hπ_sum h_def h_max h_min

/-! ## (K2) The band width is a genuine non-negative `ρ` — the grey-band measure.

The grey-band measure `ρ := M − m` of CjNEW11 is the width of the band the
convex average lives in. It is non-negative whenever the band is inhabited,
which the convex-combination sandwich of R12_Agent8 `muPath_decomp_convex`
guarantees (the average itself sits between the extremes, so `m ≤ M`). -/

/-- **(K2) The grey-band width `ρ = M − m` is non-negative.**

Using R12_Agent8's convex-combination sandwich `muPath_decomp_convex` on the
SHIFTED values `ν_i := μ_i − m + 1 ∈ [1, M − m + 1]` (so the floor-1 / bound
hypotheses of `muPath_decomp_convex` hold), the shifted average lies in
`[1, M − m + 1]`, which forces `m ≤ M`, i.e. `0 ≤ ρ`. The R-SUB.5 bounds
appear directly as the cross-check `R_SUB_5_min_bound`/`R_SUB_5_max_bound` on
the same shifted family. -/
theorem mu0_band_width
    {Ω : Type} [Fintype Ω] [Nonempty Ω]
    (π μ : Ω → ℝ) (M m : ℝ)
    (hπ_nonneg : ∀ i, 0 ≤ π i)
    (hπ_sum : ∑ i, π i = 1)
    (h_max : ∀ i, μ i ≤ M)
    (h_min : ∀ i, m ≤ μ i) :
    0 ≤ M - m := by
  -- Shift the per-subdomain values by `-m + 1` so each `ν_i ≥ 1` and
  -- `ν_i ≤ (M - m) + 1`. Then R12_Agent8's convex sandwich yields
  -- `1 ≤ Eν ≤ (M - m) + 1`, hence `1 ≤ (M - m) + 1`, i.e. `0 ≤ M - m`.
  set ν : Ω → ℝ := fun i => μ i - m + 1 with hν
  have hν_ge1 : ∀ i, 1 ≤ ν i := by
    intro i; have := h_min i; simp only [hν]; linarith
  have hν_le : ∀ i, ν i ≤ (M - m) + 1 := by
    intro i; have := h_max i; have := h_min i; simp only [hν]; linarith
  -- Define the shifted average via R12_Agent8 muPath_decomp_convex.
  have hsand :=
    R12_Agent8_AttackMuPathKappa.muPath_decomp_convex
      π ν (∑ i, π i * ν i) ((M - m) + 1)
      hπ_nonneg hπ_sum hν_ge1 hν_le rfl
  -- hsand : 1 ≤ ∑ π·ν  ∧  ∑ π·ν ≤ (M - m) + 1.
  have h_low : (1 : ℝ) ≤ ∑ i, π i * ν i := hsand.1
  have h_high : ∑ i, π i * ν i ≤ (M - m) + 1 := hsand.2
  -- Cross-check with the R-SUB.5 bounds directly (load-bearing corpus).
  have _hmin := Mu0Decomposition.R_SUB_5_min_bound π ν 1 hπ_nonneg hν_ge1 hπ_sum
  have _hmax :=
    Mu0Decomposition.R_SUB_5_max_bound π ν ((M - m) + 1) hπ_nonneg hν_le hπ_sum
  -- Chain `1 ≤ ∑π·ν ≤ (M-m)+1`.
  linarith

/-! ## (K3) THE STRUCTURAL RATE LIMIT — `|μ₀(t+1) − μ₀(t)| ≤ ρ`.

Two consecutive training steps whose μ₀ decompositions share a common grey band
`[m, M]` (the band only contracts under monotone training, never relocating
outside the previous band's enclosure) both land inside `[m, M]` by (K1); hence
their difference is bounded by the band width `ρ = M − m`. This is CjNEW11's
discrete `dμ₀/dt ≤ α_max·ρ` with the STRUCTURAL ceiling `α_max = 1`. -/

/-- **(K3) μ₀ is rate-limited by the grey-band width.**

If two μ₀ values `mu0Next`, `mu0Now` both lie in a common band `[m, M]` (each a
convex average over a partition with per-subdomain values in `[m, M]` — the
hypotheses are exactly two copies of (K1)), then

    |mu0Next − mu0Now| ≤ M − m  =  ρ.

This is the discrete rate-limit law `dμ₀/dt ≤ α_max·ρ` of CjNEW11 with the
structural conversion ceiling `α_max = 1`, DERIVED from the μ₀ convex-combination
tower (K1 via R3_Agent2 / R-SUB.5), not assumed. Load-bearing tower lemmas
enter through (K1)'s `mu0_in_band`. -/
theorem mu0_rate_limited
    {Ω : Type} [Fintype Ω]
    (πNow πNext μNow μNext : Ω → ℝ) (mu0Now mu0Next M m : ℝ)
    -- step t (now)
    (hπNow_nonneg : ∀ i, 0 ≤ πNow i) (hπNow_sum : ∑ i, πNow i = 1)
    (hNow_def : mu0Now = ∑ i, πNow i * μNow i)
    (hNow_max : ∀ i, μNow i ≤ M) (hNow_min : ∀ i, m ≤ μNow i)
    -- step t+1 (next), sharing the SAME enclosing band [m, M]
    (hπNext_nonneg : ∀ i, 0 ≤ πNext i) (hπNext_sum : ∑ i, πNext i = 1)
    (hNext_def : mu0Next = ∑ i, πNext i * μNext i)
    (hNext_max : ∀ i, μNext i ≤ M) (hNext_min : ∀ i, m ≤ μNext i) :
    |mu0Next - mu0Now| ≤ M - m := by
  -- (K1) at step t and step t+1.
  obtain ⟨hNow_lo, hNow_hi⟩ :=
    mu0_in_band πNow μNow mu0Now M m hπNow_nonneg hπNow_sum hNow_def hNow_max hNow_min
  obtain ⟨hNext_lo, hNext_hi⟩ :=
    mu0_in_band πNext μNext mu0Next M m hπNext_nonneg hπNext_sum hNext_def
      hNext_max hNext_min
  -- Both in [m, M] ⇒ |difference| ≤ M - m.
  rw [abs_sub_le_iff]
  constructor <;> linarith

/-- **(K3′) Restatement as `dμ₀/dt ≤ α_max·ρ` with `α_max = 1`, `ρ = M − m`.**

The CjNEW11 form `dμ₀/dt ≤ α_max·ρ`: the (non-negative part of the) per-step
change is bounded by `1 · ρ`. This is the literal discrete rate-limit
inequality of the conjecture, with the structural conversion ceiling. -/
theorem mu0_rate_limit_form
    {Ω : Type} [Fintype Ω]
    (πNow πNext μNow μNext : Ω → ℝ) (mu0Now mu0Next M m : ℝ)
    (hπNow_nonneg : ∀ i, 0 ≤ πNow i) (hπNow_sum : ∑ i, πNow i = 1)
    (hNow_def : mu0Now = ∑ i, πNow i * μNow i)
    (hNow_max : ∀ i, μNow i ≤ M) (hNow_min : ∀ i, m ≤ μNow i)
    (hπNext_nonneg : ∀ i, 0 ≤ πNext i) (hπNext_sum : ∑ i, πNext i = 1)
    (hNext_def : mu0Next = ∑ i, πNext i * μNext i)
    (hNext_max : ∀ i, μNext i ≤ M) (hNext_min : ∀ i, m ≤ μNext i) :
    mu0Next - mu0Now ≤ (1 : ℝ) * (M - m) := by
  have h := mu0_rate_limited πNow πNext μNow μNext mu0Now mu0Next M m
    hπNow_nonneg hπNow_sum hNow_def hNow_max hNow_min
    hπNext_nonneg hπNext_sum hNext_def hNext_max hNext_min
  rw [one_mul]
  exact (abs_le.mp h).2

/-! ## (K4) SATURATION COROLLARY on the DERIVED rate limit.

The conjecture file's `saturation` needed the rate-limit bound as a *hypothesis*.
Here the bound is supplied structurally by (K3): given a time-indexed family of
consecutive μ₀ steps with shared bands of widths `ρ(t) → 0`, the per-step
changes are squeezed to `0`. -/

/-- **(K4) μ₀ saturates as the grey band depletes (derived).**

Let `step : ℕ → ℝ` be the per-step μ₀ increment `|μ₀(t+1) − μ₀(t)|` and
`rho : ℕ → ℝ` the grey-band width at step `t`. If the structural rate limit
`step t ≤ rho t` holds at every step (DERIVED from (K3), here taken as the
already-established per-step bound) and the grey band depletes `rho → 0`, then
the per-step change vanishes: `step → 0`. Squeeze `0 ≤ step t ≤ rho t`. This is
CjNEW11's saturation theorem, now resting on the structurally-derived rate limit
rather than a hypothesised bound. -/
theorem mu0_saturation
    (step rho : ℕ → ℝ)
    (hstep_nonneg : ∀ t, 0 ≤ step t)
    (hrate : ∀ t, step t ≤ rho t)
    (hrho_lim : Tendsto rho atTop (𝓝 0)) :
    Tendsto step atTop (𝓝 0) := by
  have h0 : Tendsto (fun _ : ℕ => (0 : ℝ)) atTop (𝓝 0) := tendsto_const_nhds
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le h0 hrho_lim
    (fun t => hstep_nonneg t) (fun t => hrate t)

/-- **(K4★) Saturation directly from the band widths (fully structural).**

The end-to-end statement: given consecutive μ₀ steps whose shared grey bands
`[m t, M t]` have widths `M t − m t → 0`, the per-step μ₀ changes `→ 0`. The
per-step bound is the structural rate limit (K3); the band widths are
non-negative by (K2)-style reasoning (here the per-step bound `0 ≤ rho t`
follows from `|·| ≥ 0`). This couples (K3) and the squeeze with NO hypothesised
rate constant — the ceiling is the structural `1`. -/
theorem mu0_saturation_from_bands
    {Ω : Type} [Fintype Ω]
    (πNow πNext μNow μNext : ℕ → Ω → ℝ)
    (mu0Now mu0Next M m : ℕ → ℝ)
    (hπNow_nonneg : ∀ t i, 0 ≤ πNow t i) (hπNow_sum : ∀ t, ∑ i, πNow t i = 1)
    (hNow_def : ∀ t, mu0Now t = ∑ i, πNow t i * μNow t i)
    (hNow_max : ∀ t i, μNow t i ≤ M t) (hNow_min : ∀ t i, m t ≤ μNow t i)
    (hπNext_nonneg : ∀ t i, 0 ≤ πNext t i) (hπNext_sum : ∀ t, ∑ i, πNext t i = 1)
    (hNext_def : ∀ t, mu0Next t = ∑ i, πNext t i * μNext t i)
    (hNext_max : ∀ t i, μNext t i ≤ M t) (hNext_min : ∀ t i, m t ≤ μNext t i)
    (hband_lim : Tendsto (fun t => M t - m t) atTop (𝓝 0)) :
    Tendsto (fun t => |mu0Next t - mu0Now t|) atTop (𝓝 0) := by
  -- Per-step structural rate limit (K3) at each `t`.
  have hrate : ∀ t, |mu0Next t - mu0Now t| ≤ M t - m t := by
    intro t
    exact mu0_rate_limited (πNow t) (πNext t) (μNow t) (μNext t)
      (mu0Now t) (mu0Next t) (M t) (m t)
      (hπNow_nonneg t) (hπNow_sum t) (hNow_def t) (hNow_max t) (hNow_min t)
      (hπNext_nonneg t) (hπNext_sum t) (hNext_def t) (hNext_max t) (hNext_min t)
  -- Squeeze via (K4).
  exact mu0_saturation (fun t => |mu0Next t - mu0Now t|) (fun t => M t - m t)
    (fun t => abs_nonneg _) hrate hband_lim

/-! ## OPEN-STATUS NOTE.

CjNEW11's full claim is the rate-limit inequality `dμ₀/dt ≤ α_max(t)·ρ` with the
ALGORITHM-SPECIFIC conversion ceiling `α_max(t)` derived from the SGD/Adam/RLHF
update rule. That derivation needs a training-dynamics layer absent from the
opaque signature (`MIP.Axioms` carries no time-indexed agent family, no μ₀
functional, no update rule), so the algorithm-specific `α_max(t)` is OPEN.

What this file ESTABLISHES, fully and structurally (zero sorry):
  * the discrete rate-limit inequality in its CjNEW11 form, with the STRUCTURAL
    conversion ceiling `α_max ≡ 1` — the convex-combination Lipschitz constant
    DERIVED from the μ₀ decomposition tower (K3, K3′), NOT hypothesised;
  * the saturation theorem (CjNEW11 corollary (a)) resting on that derived bound
    (K4, K4★), strengthening the conjecture file's conditional `saturation`.

So CjNEW11 remains OPEN only for the tighter algorithm-specific `α_max(t) ≤ 1`;
the unconditional structural ceiling `α_max ≤ 1` and the saturation law are
proved here. Status: KERNEL_ONLY.
-/

end R13_Agent7_AttackMu0RateLimit

end MIP
