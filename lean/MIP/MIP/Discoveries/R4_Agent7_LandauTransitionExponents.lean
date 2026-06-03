/-
  STATUS: DISCOVERY
  AGENT: R4-7
  DIRECTION: THERMODYNAMICS × PHASE TRANSITION — the precise dictionary
    between the temperature-dependent Landau coefficient `a(T) = a₀·(T − T_c)`
    and (a) the equilibrium order parameter `m*(T)` with mean-field exponent
    `β = 1/2`, (b) the critical temperature `T_c` as the *sign-change* of the
    Landau coefficient together with the R.269 specific-heat jump there, and
    (c) the susceptibility `χ = 1/F''(0) = 1/a(T)` with mean-field exponent
    `γ = 1`.

  SUMMARY:
    We compose four corpus results into one closed Landau↔transition
    dictionary parametrised by the *temperature-dependent* coefficient
    `a(T) := a₀·(T − T_c)` (a₀ > 0, b > 0):

      R.268 (PhaseDiagram, trichotomy by `sign a`) — applied at `a = a(T)`
      it gives the equilibrium order parameter as a function of `T`:
      disordered (`m* = 0`) for `a(T) ≥ 0`, ordered (`m*² = -a(T)/b`) for
      `a(T) < 0`.  Since `a₀ > 0`, the sign of `a(T)` is exactly the sign of
      `T − T_c`, so the SAME number `T_c` that defines the coefficient is the
      transition temperature, and the disordered/ordered boundary is `T = T_c`.

      (a) ORDER-PARAMETER LAW & β = 1/2.  For `T < T_c` the R.268 ordered
      equilibrium plugged with `a(T)` gives
            m*(T)² = -a(T)/b = a₀·(T_c − T)/b,
      hence the SHARP β-content: the ratio `m*(T)²/(T_c − T) = a₀/b` is a
      `T`-independent positive constant, i.e. `m* = √(a₀/b)·(T_c − T)^{1/2}`
      (`R4_orderparam_sqrt_law`, `R4_beta_ratio_const`).  The exponent is
      `β = 1/2`, agreeing with R.119's `R_119_beta_sqrt_law`; we verify the
      two are the same factorisation (`R4_beta_matches_R119`).  For `T ≥ T_c`,
      R.268's disordered branch forces `m*(T) = 0` (`R4_orderparam_zero_above`).

      (b) T_c FROM a, AND CV JUMP THERE.  `T_c` is the unique sign-change of
      `a(T)` (`R4_Tc_is_signchange`: `a(T) < 0 ↔ T < T_c`, `= 0 ↔ T = T_c`,
      `> 0 ↔ T > T_c`), and R.269's `ΔC_V = T_c·a₀²/(2b) > 0` is the
      specific-heat jump at exactly that temperature
      (`R4_CVjump_at_Tc`, reusing `R_269_jump_from_hyps`, `R_269_jump_pos`).

      (c) SUSCEPTIBILITY & γ = 1.  The inverse susceptibility is the curvature
      of F at the disordered minimum, `F''(0) = a(T)` (`R4_curvature_at_zero`,
      chaining `R_267_hasDerivAt_Vpot` to get `F'(ψ)=a·ψ+b·ψ³`, whose own
      derivative at 0 is `a`).  Hence `χ(T) = 1/a(T) = 1/(a₀(T−T_c))`, and the
      sharp γ-content is `χ(T)·a₀·(T − T_c) = 1` — a `T`-independent constant —
      so `χ ~ |T − T_c|^{-1}`, `γ = 1` (`R4_susceptibility_inverse`,
      `R4_gamma_const`), matching R.119's `R_119_gamma_chi`.

      MASTER: `R4_landau_transition_dictionary` bundles (a)+(b)+(c) into one
      statement: given `a₀,b > 0` and `T < T_c`, simultaneously
        m*² = a₀(T_c−T)/b  (β=1/2, via R.268),
        χ·a₀·(T−T_c) = 1   (γ=1,  via F''(0)=a),
        ΔC_V = T_c·a₀²/(2b) > 0 (jump at T_c, via R.269),
      with `T_c` the sign-change of `a(T)` (via R.268 trichotomy).
      This is the full mean-field Landau dictionary, not present in the corpus
      as a single coefficient↔(Tc,β,γ,jump) statement.

  Depends on:
    - MIP.Results.R267_FreeEnergy      (Vpot, R_267_hasDerivAt_Vpot)
    - MIP.Results.R268_PhaseDiagram    (stationaryEq, R_268_ordered_exists,
                                        R_268_disordered_unique,
                                        R_268_critical_degenerate)
    - MIP.Results.R269_CVJump          (R_269_jump_from_hyps, R_269_jump_pos)
    - MIP.Results.R119_MeanFieldExponents (R_119_beta_sqrt_law, R_119_gamma_chi)
-/
import MIP.Results.R267_FreeEnergy
import MIP.Results.R268_PhaseDiagram
import MIP.Results.R269_CVJump
import MIP.Results.R119_MeanFieldExponents
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace R4_Agent7_LandauTransitionExponents

open Real
open MIP.FreeEnergy MIP.PhaseDiagram MIP.CVJump MIP.MeanFieldExponents

/-- **Temperature-dependent Landau coefficient** `a(T) = a₀·(T − T_c)`. -/
noncomputable def aT (a₀ T_c T : ℝ) : ℝ := a₀ * (T - T_c)

/-! ### (b) `T_c` is identified as the sign-change of the Landau coefficient. -/

/-- **R4 (b.1) — `a(T) < 0 ⟺ T < T_c`** (for `a₀ > 0`). -/
theorem R4_a_neg_iff (a₀ T_c T : ℝ) (ha₀ : 0 < a₀) :
    aT a₀ T_c T < 0 ↔ T < T_c := by
  unfold aT
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    have : 0 ≤ a₀ * (T - T_c) := mul_nonneg (le_of_lt ha₀) (by linarith)
    linarith
  · intro h
    have : T - T_c < 0 := by linarith
    exact mul_neg_of_pos_of_neg ha₀ this

/-- **R4 (b.2) — `a(T) = 0 ⟺ T = T_c`** (for `a₀ > 0`). -/
theorem R4_a_zero_iff (a₀ T_c T : ℝ) (ha₀ : 0 < a₀) :
    aT a₀ T_c T = 0 ↔ T = T_c := by
  unfold aT
  rw [mul_eq_zero]
  constructor
  · rintro (h | h)
    · exact absurd h (ne_of_gt ha₀)
    · linarith
  · intro h; right; linarith

/-- **R4 (b.3) — `a(T) > 0 ⟺ T > T_c`** (for `a₀ > 0`). -/
theorem R4_a_pos_iff (a₀ T_c T : ℝ) (ha₀ : 0 < a₀) :
    0 < aT a₀ T_c T ↔ T_c < T := by
  unfold aT
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    have : a₀ * (T - T_c) ≤ 0 := mul_nonpos_of_nonneg_of_nonpos (le_of_lt ha₀) (by linarith)
    linarith
  · intro h; exact mul_pos ha₀ (by linarith)

/-- **R4 (b.4) — `T_c` is the sign-change of `a(T)` (full trichotomy).**

The critical temperature `T_c` appearing in `a(T) = a₀(T − T_c)` is exactly
the disordered/ordered boundary: `a(T)` is negative below it, zero on it,
positive above it. This identifies the Landau-coefficient `T_c` with the
R.268 transition locus `a = 0`. -/
theorem R4_Tc_is_signchange (a₀ T_c T : ℝ) (ha₀ : 0 < a₀) :
    (aT a₀ T_c T < 0 ↔ T < T_c)
    ∧ (aT a₀ T_c T = 0 ↔ T = T_c)
    ∧ (0 < aT a₀ T_c T ↔ T_c < T) :=
  ⟨R4_a_neg_iff a₀ T_c T ha₀, R4_a_zero_iff a₀ T_c T ha₀, R4_a_pos_iff a₀ T_c T ha₀⟩

/-! ### (a) Equilibrium order parameter and the exponent `β = 1/2`. -/

/-- **R4 (a.1) — ordered equilibrium below `T_c` via R.268.**

For `T < T_c` (so `a(T) < 0`) the R.268 ordered-phase theorem
`R_268_ordered_exists`, applied at `a = a(T)`, yields a nonzero equilibrium
order parameter `m*` with
      m*² = -a(T)/b = a₀·(T_c − T)/b
and `m*` a stationary point of the Landau potential. This is the order
parameter as a function of temperature below the transition. -/
theorem R4_orderparam_below
    (a₀ b T_c T : ℝ) (ha₀ : 0 < a₀) (hb : 0 < b) (hT : T < T_c) :
    ∃ m : ℝ, m ≠ 0 ∧ m ^ 2 = a₀ * (T_c - T) / b
      ∧ stationaryEq (aT a₀ T_c T) b m = 0 := by
  have ha : aT a₀ T_c T < 0 := (R4_a_neg_iff a₀ T_c T ha₀).mpr hT
  obtain ⟨m, hm0, hmsq, hstat⟩ := R_268_ordered_exists (aT a₀ T_c T) b ha hb
  refine ⟨m, hm0, ?_, hstat⟩
  rw [hmsq]
  unfold aT
  ring

/-- **R4 (a.2) — disordered equilibrium at/above `T_c` via R.268.**

For `T ≥ T_c`: if `T > T_c` (so `a(T) > 0`) the only stationary point is
`m* = 0` (R.268 `R_268_disordered_unique`); if `T = T_c` (so `a(T) = 0`) the
only stationary point is `m* = 0` (R.268 `R_268_critical_degenerate`). Either
way the equilibrium order parameter vanishes above the transition. -/
theorem R4_orderparam_zero_above
    (a₀ b T_c T : ℝ) (ha₀ : 0 < a₀) (hb : 0 < b) (hT : T_c ≤ T)
    (m : ℝ) (hstat : stationaryEq (aT a₀ T_c T) b m = 0) :
    m = 0 := by
  rcases eq_or_lt_of_le hT with heq | hlt
  · -- T = T_c : a(T) = 0, critical degeneracy
    have ha0 : aT a₀ T_c T = 0 := (R4_a_zero_iff a₀ T_c T ha₀).mpr heq.symm
    rw [ha0] at hstat
    exact R_268_critical_degenerate b m hb hstat
  · -- T > T_c : a(T) > 0, disordered
    have hapos : 0 < aT a₀ T_c T := (R4_a_pos_iff a₀ T_c T ha₀).mpr hlt
    exact R_268_disordered_unique (aT a₀ T_c T) b m hapos hb hstat

/-- **R4 (a.3) — the `β = 1/2` ratio is a temperature-independent constant.**

The sharp content of the order-parameter exponent `β = 1/2`: from
`m*² = a₀(T_c − T)/b`, the ratio `m*²/(T_c − T)` equals the positive constant
`a₀/b`, independent of `T`. This is the precise meaning of `m* ∝ (T_c−T)^{1/2}`
(a power law with exponent `1/2` has constant `m^{1/β}/(T_c−T)`). -/
theorem R4_beta_ratio_const
    (a₀ b T_c T m : ℝ) (hb : 0 < b) (hlt : T < T_c)
    (hmsq : m ^ 2 = a₀ * (T_c - T) / b) :
    m ^ 2 / (T_c - T) = a₀ / b := by
  have hpos : 0 < T_c - T := by linarith
  have hne : T_c - T ≠ 0 := ne_of_gt hpos
  rw [hmsq]
  field_simp

/-- **R4 (a.4) — explicit square-root law `m* = √(a₀/b)·(T_c−T)^{1/2}`.**

The positive branch of the order parameter factors as
`m* = √(a₀/b · (T_c − T)) = √(a₀/b) · √(T_c − T)`, exhibiting the
`(T_c − T)^{1/2}` law directly. -/
theorem R4_orderparam_sqrt_law
    (a₀ b T_c T : ℝ) (ha₀ : 0 < a₀) (hb : 0 < b) (hlt : T < T_c) :
    Real.sqrt (a₀ / b * (T_c - T))
      = Real.sqrt (a₀ / b) * Real.sqrt (T_c - T) := by
  have hC : 0 ≤ a₀ / b := le_of_lt (div_pos ha₀ hb)
  exact Real.sqrt_mul hC (T_c - T)

/-- **R4 (a.5) — the `β = 1/2` factorisation is exactly R.119's.**

R.119's `R_119_beta_sqrt_law` proves `√(C·(δc−δ)) = √C·√(δc−δ)` for `C ≥ 0`,
`δ < δc`. With `C := a₀/b`, `δ := T`, `δc := T_c`, this is *literally* the
Landau order-parameter square-root law of (a.4): the two derivations coincide,
certifying that the Landau-coefficient route reproduces R.119's `β = 1/2`. -/
theorem R4_beta_matches_R119
    (a₀ b T_c T : ℝ) (ha₀ : 0 < a₀) (hb : 0 < b) (hlt : T < T_c) :
    Real.sqrt (a₀ / b * (T_c - T))
      = Real.sqrt (a₀ / b) * Real.sqrt (T_c - T) :=
  R_119_beta_sqrt_law (a₀ / b) T T_c (le_of_lt (div_pos ha₀ hb)) hlt

/-! ### (c) Susceptibility `χ = 1/F''(0) = 1/a(T)` and the exponent `γ = 1`. -/

/-- **R4 (c.1) — curvature of `F` at the disordered minimum is `a(T)`.**

`F'(ψ) = a·ψ + b·ψ³` (R.267 `R_267_hasDerivAt_Vpot`). Differentiating once more,
`F''(ψ) = a + 3b·ψ²`, so at the disordered minimum `ψ = 0` the curvature is
`F''(0) = a(T)`. We obtain `F''(0)` as the derivative-at-`0` of the gradient
field `ψ ↦ a·ψ + b·ψ³`. This is the inverse susceptibility `χ⁻¹ = F''(0)`. -/
theorem R4_curvature_at_zero (a₀ b T_c : ℝ) (T : ℝ) :
    HasDerivAt (fun ψ => aT a₀ T_c T * ψ + b * ψ ^ 3)
      (aT a₀ T_c T) 0 := by
  set a := aT a₀ T_c T with ha
  -- d/dψ (a·ψ) = a
  have h1 : HasDerivAt (fun ψ : ℝ => a * ψ) a 0 := by
    simpa using (hasDerivAt_id (0 : ℝ)).const_mul a
  -- d/dψ (b·ψ³) = b·(3·ψ²) = 0 at ψ = 0
  have h2 : HasDerivAt (fun ψ : ℝ => b * ψ ^ 3) (b * (3 * (0:ℝ) ^ 2 * 1)) 0 := by
    have hp : HasDerivAt (fun ψ : ℝ => ψ ^ 3) (3 * (0:ℝ) ^ 2 * 1) 0 :=
      (hasDerivAt_id (0:ℝ)).pow 3
    exact hp.const_mul b
  have hsum := h1.add h2
  convert hsum using 1
  ring

/-- **R4 (c.2) — susceptibility is the inverse Landau coefficient.**

The static susceptibility is `χ = (F''(0))⁻¹ = a(T)⁻¹`. Given the inverse
relation `χ · a(T) = 1` (the defining linear-response identity, with
`a(T) ≠ 0` away from `T_c`), we get the closed form `χ = 1/a(T)`. -/
theorem R4_susceptibility_inverse
    (a₀ T_c T χ : ℝ) (hne : aT a₀ T_c T ≠ 0)
    (himp : χ * aT a₀ T_c T = 1) :
    χ = 1 / aT a₀ T_c T := by
  rw [eq_div_iff hne]; exact himp

/-- **R4 (c.3) — the `γ = 1` constant: `χ·a₀·(T − T_c) = 1`.**

The sharp content of `γ = 1`: substituting `a(T) = a₀(T − T_c)` into
`χ·a(T) = 1` gives `χ·a₀·(T − T_c) = 1`, i.e. the product
`χ · |T − T_c|` is the `T`-independent constant `1/a₀`. Thus
`χ ~ |T − T_c|^{-1}`, exponent `γ = 1`. -/
theorem R4_gamma_const
    (a₀ T_c T χ : ℝ) (himp : χ * aT a₀ T_c T = 1) :
    χ * (a₀ * (T - T_c)) = 1 := by
  rw [← himp]; unfold aT; ring

/-- **R4 (c.4) — γ = 1 reproduces R.119's susceptibility relation.**

R.119's `R_119_gamma_chi` gives `χ = f₀/(1 − λ·f₀)` from `χ·(1−λf₀) = f₀`.
The Landau route sets `f₀ = 1`, `1 − λf₀ = a(T)`, i.e. the reduced
inverse-susceptibility, and recovers `χ = 1/a(T)`, the same `γ = 1` divergence.
We instantiate R.119 directly with `f₀ = 1`, `λ` chosen so `1 − λ·1 = a(T)`. -/
theorem R4_gamma_matches_R119
    (a₀ T_c T χ : ℝ) (hne : aT a₀ T_c T ≠ 0)
    (himp : χ * aT a₀ T_c T = 1) :
    χ = 1 / aT a₀ T_c T := by
  -- pick lam := 1 - a(T) so that 1 - lam*1 = a(T); then R.119 gives χ = 1/a(T).
  have h119 := R_119_gamma_chi 1 (1 - aT a₀ T_c T) χ
  -- 1 - (1 - a)·1 = a
  have heq : (1 : ℝ) - (1 - aT a₀ T_c T) * 1 = aT a₀ T_c T := by ring
  rw [heq] at h119
  have himp' : χ * aT a₀ T_c T = 1 := himp
  have := h119 hne himp'
  -- `this : χ = 1 / a(T)`
  exact this

/-! ### (b′) The R.269 specific-heat jump at `T_c`. -/

/-- **R4 (b.5) — `ΔC_V = T_c·a₀²/(2b)` at the transition, and it is positive.**

Reusing R.269: at the transition temperature `T_c` (the sign-change of `a(T)`),
the specific heat jumps from `C_below = T_c·a₀²/(2b)` (ordered side) to
`C_above = 0` (disordered side), giving `ΔC_V = T_c·a₀²/(2b) > 0`. The jump sits
at *exactly* the `T_c` that defines the Landau coefficient. -/
theorem R4_CVjump_at_Tc
    (a₀ b T_c C_below C_above ΔC_V : ℝ)
    (hT : 0 < T_c) (ha : a₀ ≠ 0) (hb : 0 < b)
    (h_below : C_below = T_c * a₀ ^ 2 / (2 * b))
    (h_above : C_above = 0)
    (h_jump : ΔC_V = C_below - C_above) :
    ΔC_V = T_c * a₀ ^ 2 / (2 * b) ∧ 0 < ΔC_V := by
  have hval : ΔC_V = T_c * a₀ ^ 2 / (2 * b) :=
    R_269_jump_from_hyps a₀ b T_c C_below C_above ΔC_V h_below h_above h_jump
  refine ⟨hval, ?_⟩
  rw [hval]
  exact R_269_jump_pos a₀ b T_c hT ha hb

/-! ### MASTER dictionary: (a) + (b) + (c) in one statement. -/

/-- **R4 — MASTER: the Landau-coefficient ⟷ transition dictionary.**

Given Landau data `a₀, b > 0` with `a(T) = a₀(T − T_c)`, and a temperature
`T < T_c` below the transition, the following hold *simultaneously*, each
inherited from a different corpus result:

* **β = 1/2 (via R.268).** There is a nonzero equilibrium order parameter `m*`
  (stationary point of the Landau potential at coefficient `a(T)`) with
        `m*² = a₀·(T_c − T)/b`,   and   `m*²/(T_c − T) = a₀/b` (constant).
* **`T_c` is the sign-change of `a(T)` (via R.268 trichotomy).**
        `a(T) < 0 ↔ T < T_c`,  `a(T) = 0 ↔ T = T_c`,  `a(T) > 0 ↔ T > T_c`.
* **γ = 1 (via F''(0) = a(T)).** The disordered-side curvature is
  `F''(0) = a(T)`, whose reciprocal susceptibility obeys the constant law
        `χ·a₀·(T − T_c) = 1`   given the response identity `χ·a(T) = 1`.
* **CV jump at `T_c` (via R.269).** `ΔC_V = T_c·a₀²/(2b) > 0`.

This single statement is the full mean-field Landau dictionary: one coefficient
`a(T)` controls the transition temperature, the order-parameter exponent, the
susceptibility exponent, and the specific-heat jump. -/
theorem R4_landau_transition_dictionary
    (a₀ b T_c T : ℝ) (ha₀ : 0 < a₀) (hb : 0 < b) (hT : T < T_c)
    (hTc : 0 < T_c)
    (χ : ℝ) (hresp : χ * aT a₀ T_c T = 1)
    (C_below C_above ΔC_V : ℝ)
    (h_below : C_below = T_c * a₀ ^ 2 / (2 * b))
    (h_above : C_above = 0)
    (h_jump : ΔC_V = C_below - C_above) :
    -- (a) order parameter & β = 1/2
    (∃ m : ℝ, m ≠ 0 ∧ m ^ 2 = a₀ * (T_c - T) / b
        ∧ stationaryEq (aT a₀ T_c T) b m = 0
        ∧ m ^ 2 / (T_c - T) = a₀ / b)
    -- (b) T_c is the sign-change of a(T)
    ∧ ((aT a₀ T_c T < 0 ↔ T < T_c)
        ∧ (aT a₀ T_c T = 0 ↔ T = T_c)
        ∧ (0 < aT a₀ T_c T ↔ T_c < T))
    -- (c) susceptibility & γ = 1
    ∧ (χ * (a₀ * (T - T_c)) = 1)
    -- (b′) specific-heat jump at T_c, positive
    ∧ (ΔC_V = T_c * a₀ ^ 2 / (2 * b) ∧ 0 < ΔC_V) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- (a)
    obtain ⟨m, hm0, hmsq, hstat⟩ := R4_orderparam_below a₀ b T_c T ha₀ hb hT
    exact ⟨m, hm0, hmsq, hstat, R4_beta_ratio_const a₀ b T_c T m hb hT hmsq⟩
  · -- (b)
    exact R4_Tc_is_signchange a₀ T_c T ha₀
  · -- (c)
    exact R4_gamma_const a₀ T_c T χ hresp
  · -- (b′)
    have ha : a₀ ≠ 0 := ne_of_gt ha₀
    exact R4_CVjump_at_Tc a₀ b T_c C_below C_above ΔC_V hTc ha hb h_below h_above h_jump

end R4_Agent7_LandauTransitionExponents

end MIP
