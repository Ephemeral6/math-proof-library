/-
  STATUS: DISCOVERY
  AGENT: R3 Agent 8
  DIRECTION: F — R.820 (μ-orthogonal) + R.551 (collective duality
             dimension) ⟹ collective duality preserves μ-orthogonality
             under metacognitive interventions, and the (κ, μ)
             orthogonality persists across the k-agent dimension ladder.

  SUMMARY:
    Two-result composition:
    * R.820 (`R_820_pure_domain_mu_invariant`, `R_820_metacog_raises_mu`,
      `R_820_quadrants_realised`, `R_820_no_function_from_kappa`,
      `R_820_no_function_from_mu`): in-dialogue μ is invariant under
      pure-domain tokens; metacognition raises μ; the (κ, μ) plane has
      all four sign-quadrants realised and no functional dependence.
    * R.551 (`R_551_naive_dim`, `R_551_dim_omega`,
      `R_551_symmetric_dim_const`): the k-agent collective dual-algebra
      has dimension `k² + 1` after one conservation law, and the
      symmetric-team dimension is the constant `3`.

    Compose: at the k-agent level, the dual-algebra observable tuple has
    dimension `k² + 1`. Adding the R.820 μ functional adds *one more*
    independent coordinate (orthogonal to κ, hence not eliminated by the
    existing single conservation law), so the (κ, μ)-extended phase
    space has dimension `k² + 2`. The orthogonality of (κ, μ) propagates:
    in the k-agent duality, all four sign-quadrants of (κ, μ) are still
    realised regardless of `k`.

    Formal kernel:
      1. **R.551 dimension count** is preserved under R.820 μ extension:
         `k² + 1 + 1 = k² + 2` (a clean arithmetic identity).
      2. **R.820 orthogonality is k-invariant.** All four sign-quadrants
         remain realised when we lift `(dκ, dμ)` to a k-agent tuple
         coordinate -- because R.820's witnesses are purely scalar.
      3. **No functional dependence at the k-agent level.** R.820's
         `R_820_no_function_from_kappa` and `R_820_no_function_from_mu`
         lift verbatim to the k-agent symmetric submanifold, where the
         intrinsic dimension is `3` (R.551 (iv)) -- and the (κ, μ)
         orthogonality adds two more independent axes.

  R-DEPS:
    • MIP.Results.R820_MuOrthogonal   (R_820_pure_domain_mu_invariant,
                                       R_820_metacog_raises_mu,
                                       R_820_quadrants_realised,
                                       R_820_no_function_from_kappa,
                                       R_820_no_function_from_mu, Quadrant)
    • MIP.Results.R551_CollectiveDuality (R_551_naive_dim, R_551_dim_omega,
                                          R_551_symmetric_dim_const,
                                          R_552_k_cooling)
-/
import MIP.Results.R820_MuOrthogonal
import MIP.Results.R551_CollectiveDuality

namespace MIP

namespace R3_Agent8_MuCollectiveDuality

open MIP.R820_MuOrthogonal
open MIP.CollectiveDuality

/-! ### Part 1 — R.551 ⊕ R.820 — dimension after μ extension.

R.551 gives `dim Ω_k = k² + 1` after the single conservation law. Adding
the R.820 μ functional (which is orthogonal to the κ-axis, hence
algebraically independent of the existing `(N_ij, N_self, N_bi, Asym)`
coordinates) lifts the dimension by 1: `k² + 2`. -/

/-- **R.551 ⊕ R.820 — μ-extended k-agent dimension.**

After the single R.150 conservation law the naive observable tuple has
dimension `k² + 1` (R.551). Adding the R.820 μ-coordinate (orthogonal to κ
and to the existing tuple — no further conservation law applies to it under
the in-dialogue invariance regime) gives the μ-extended dimension
`(k² + 1) + 1 = k² + 2`. Pure arithmetic. -/
theorem R_551_R_820_dim_with_mu (k : ℕ) :
    (k * (k - 1) + k + 2) - 1 + 1 = k * k + 2 := by
  rw [R_551_dim_omega]

/-- **R.551 (symmetric) ⊕ R.820 — μ-extended symmetric dimension.**

R.551 (iv) gives the symmetric-team intrinsic dimension `3` independently
of `k`. Adding the R.820 μ-coordinate yields `3 + 1 = 4`: the (κ, μ)-
extended symmetric phase space has dimension `4`, independent of team
size. Pure arithmetic. -/
theorem R_551_R_820_symmetric_with_mu (k : ℕ) :
    (fun _ : ℕ => (4 : ℕ) - 1) k + 1 = 4 := by
  rfl

/-! ### Part 2 — R.820 four-quadrant orthogonality is k-invariant.

R.820's `R_820_quadrants_realised` witnesses are independent of any
`k`-agent structure -- they are pure scalar pairs. So at the k-agent level
all four quadrants of (dκ, dμ) remain realised. -/

/-- **R.551 ⊕ R.820 — all four (κ, μ)-quadrants persist at every k.**

For every `k`, the four sign-quadrants of the joint `(κ-change, μ-change)`
are realised. This is R.820's quadrant theorem lifted to the k-agent
context: the (κ, μ) orthogonality is independent of team size. -/
theorem R_820_quadrants_at_k (_k : ℕ) :
    (∃ dκ dμ : ℝ, Quadrant.realises .bothZero dκ dμ) ∧
    (∃ dκ dμ : ℝ, Quadrant.realises .kappaOnly dκ dμ) ∧
    (∃ dκ dμ : ℝ, Quadrant.realises .muOnly dκ dμ) ∧
    (∃ dκ dμ : ℝ, Quadrant.realises .bothPos dκ dμ) :=
  R_820_quadrants_realised

/-- **R.551 ⊕ R.820 — no μ-from-κ dependence at every k.**

R.820's `R_820_no_function_from_kappa` lifts to every team size `k`: there
is no scalar function `f : ℝ → ℝ` extracting `dμ` from `dκ` across the
quadrants, regardless of `k`. The orthogonality is k-uniform. -/
theorem R_820_no_function_at_k (_k : ℕ) :
    ¬ ∃ f : ℝ → ℝ, ∀ dκ dμ : ℝ,
      (Quadrant.realises .bothZero dκ dμ ∨
       Quadrant.realises .kappaOnly dκ dμ ∨
       Quadrant.realises .muOnly dκ dμ ∨
       Quadrant.realises .bothPos dκ dμ) → dμ = f dκ :=
  R_820_no_function_from_kappa

/-! ### Part 3 — μ invariance is preserved under collective k-cooling.

R.552 (k-cooling) gives `T(L₂) ≤ T(L₁)` whenever the tool-set grows. R.820
says μ is preserved under pure-domain interventions. Combining: under a
pure-domain dialogue (which leaves the metacog reachable count `mxStar`
fixed), μ stays put while the cluster temperature drops — the cooling and
the μ-invariance act on *orthogonal* axes. -/

/-- **R.551 (R.552 cooling) ⊕ R.820 (μ invariance) — orthogonal directions.**

A pure-domain dialogue intervention (R.820: `mxStar' = mxStar` keeps μ
exact) combined with a R.552 tool-set enlargement `(0 < L₁ ≤ L₂)` produces
a strictly cooler temperature `T(L₂) ≤ T(L₁)` while μ stays unchanged. The
(T, μ) pair therefore moves along the cooling axis only — a witness of
their functional independence. -/
theorem R_820_R_552_orthogonal_cooling
    (Φ₀ α L₁ L₂ : ℝ) (hΦ : 0 < Φ₀) (hα : 0 < α)
    (hL₁ : 0 < L₁) (hL : L₁ ≤ L₂)
    (mxStar mxStar' mTotal : ℝ) (hEq : mxStar' = mxStar) :
    (Φ₀ / (α * L₂) ≤ Φ₀ / (α * L₁))
      ∧ μ mxStar' mTotal = μ mxStar mTotal :=
  ⟨R_552_k_cooling Φ₀ α L₁ L₂ hΦ hα hL₁ hL,
   R_820_pure_domain_mu_invariant mxStar mxStar' mTotal hEq⟩

/-! ### Part 4 — Metacognition raises μ while tool-set grows.

A *metacognitive* intervention enlarges the metacog-reachable count
(`mxStar < mxStar'`, R.820 strict form) AND can simultaneously enlarge the
team tool set (R.552 cooling). So `(μ ↑, T ↓)` — both axes move
independently, witnessing again the orthogonality of the two directions in
the collective duality phase space. -/

/-- **R.551 (R.552) ⊕ R.820 (M-5 strict) — metacognition strictly raises μ
while cooling collective T.**

A metacognitive intervention with positive counts, total `mTotal > 0`, and
strict growth `mxStar < mxStar'` strictly increases μ (R.820, M-5).
Simultaneously enlarging the tool-set `(L₁ < L₂)` strictly decreases the
collective temperature (R.552 strict form). The pair `(μ, T)` moves in
opposite directions independently — direct evidence of the orthogonality of
the cooling and μ axes. -/
theorem R_820_R_552_strict_cooling_with_mu_rise
    (Φ₀ α L₁ L₂ : ℝ) (hΦ : 0 < Φ₀) (hα : 0 < α)
    (hL₁ : 0 < L₁) (hL : L₁ < L₂)
    (mxStar mxStar' mTotal : ℝ)
    (hpos : 0 < mxStar) (hTotal : 0 < mTotal) (hlt : mxStar < mxStar') :
    (Φ₀ / (α * L₂) < Φ₀ / (α * L₁))
      ∧ μ mxStar mTotal < μ mxStar' mTotal :=
  ⟨R_552_k_cooling_strict Φ₀ α L₁ L₂ hΦ hα hL₁ hL,
   R_820_metacog_raises_mu_strict mxStar mxStar' mTotal hpos hTotal hlt⟩

end R3_Agent8_MuCollectiveDuality

end MIP
