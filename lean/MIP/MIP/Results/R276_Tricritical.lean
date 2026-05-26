/-
Result R.276 — Tricritical / first-order criterion for the asymmetric Landau
potential, and the Clausius–Clapeyron coexistence-slope identity.

Reference: `branches/thermodynamics/workspace/new_results.md` R.276
(three-dimensional `(κ, Z⁻¹, |K|)` phase diagram, B, 2026-05-18 thermodynamics
branch).

The release of `|K|` introduces an odd cubic term `c·ψ³` (the (TM)
training-monotonicity constraint explicitly breaks `ψ → −ψ` symmetry), giving
the asymmetric Landau free energy

    F(ψ) = (a/2)·ψ² + (c/3)·ψ³ + (b/4)·ψ⁴ .

**(a) Degenerate double-well (tricritical) criterion.**
A first-order transition occurs when `F` develops a *second* minimum that sits
at the same free-energy level as the trivial minimum `ψ = 0`, i.e. when there is
a NONZERO `ψ` with

    F(ψ) = 0  ∧  F'(ψ) = 0 .

We prove (Theorem `R_276_a_tricritical_iff`) that, for `b ≠ 0`, such a nonzero
`ψ` exists **iff** `2·c² = 9·a·b`, with the witness `ψ = −2c/(3b)`.

  *Note on the source coefficient.*  The source statement writes the criterion
  as `9c² = 32ab`.  An exact algebraic derivation for the potential normalised
  with the standard `(1/2, 1/3, 1/4)` coefficients yields instead `2c² = 9ab`
  (verified by resultant elimination of `ψ` from `F = 0, F' = 0`).  The
  numerical factor `32` does not arise under any standard normalisation of this
  potential; we therefore formalise the mathematically exact criterion
  `2c² = 9ab` (the source grades R.276 as B-level and itself flags the
  discriminant domain as "未数值化", i.e. not worked out).  The qualitative
  content is identical: a single discriminant equality `c² = (const)·a·b`
  separates the first-order region from the second-order region, with the
  tricritical curve at equality.

**(b) Clausius–Clapeyron coexistence slope.**  On the first-order coexistence
surface the two-phase equilibrium gives the MIP analogue of the
Clausius–Clapeyron relation (replacing `T → T_kin`, pressure `P → 1/|K|`):

    ∂T_c/∂(1/|K|) = ΔΦ₀ / Δ(log κ) .

We formalise this as the slope identity `R_276_b_clausius_clapeyron`: given the
coexistence differentials, the slope equals the ratio of the emergent-volume
gap `ΔΦ₀` to the barrier-entropy gap `Δlog κ`.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp

namespace MIP

namespace Tricritical

/-- Asymmetric Landau free energy `F(ψ) = (a/2)ψ² + (c/3)ψ³ + (b/4)ψ⁴`. -/
noncomputable def F (a c b ψ : ℝ) : ℝ :=
  (a / 2) * ψ ^ 2 + (c / 3) * ψ ^ 3 + (b / 4) * ψ ^ 4

/-- Its derivative `F'(ψ) = a·ψ + c·ψ² + b·ψ³`. -/
noncomputable def F' (a c b ψ : ℝ) : ℝ :=
  a * ψ + c * ψ ^ 2 + b * ψ ^ 3

/-- **R.276 (a) — degenerate double-well / tricritical criterion.**

With the cubic term genuinely present (`c ≠ 0`) and a stabilising quartic
(`b ≠ 0`), the asymmetric Landau potential `F` has a *nonzero* critical point at
the zero free-energy level — i.e. there exists `ψ ≠ 0` with
`F(ψ) = 0 ∧ F'(ψ) = 0` — **iff** `2·c² = 9·a·b`.

This is the boundary between the first-order region (a genuine second minimum at
equal depth ⇒ jump transition) and the second-order region (single minimum), so
the equality `2c² = 9ab` is the tricritical curve.

The forward direction eliminates `ψ` from the two polynomial equations
`F'/ψ = a + cψ + bψ² = 0` and `12F/ψ² = 6a + 4cψ + 3bψ² = 0`; their difference
gives `3a + cψ = 0`, whence `bψ² = 2a`, and combining `(cψ)² = 9a²` with
`c²·(bψ²) = 2ac²` yields `a·(9ab − 2c²) = 0`; `a = 0` is excluded by `ψ ≠ 0`,
leaving `2c² = 9ab`.  The reverse direction exhibits the explicit witness
`ψ = −2c/(3b)`. -/
theorem R_276_a_tricritical_iff (a c b : ℝ) (hb : b ≠ 0) (hc : c ≠ 0) :
    (∃ ψ : ℝ, ψ ≠ 0 ∧ F a c b ψ = 0 ∧ F' a c b ψ = 0) ↔ 2 * c ^ 2 = 9 * a * b := by
  constructor
  · rintro ⟨ψ, hψ, hF, hF'⟩
    have hψ2 : ψ ^ 2 ≠ 0 := pow_ne_zero 2 hψ
    -- E1 : 6a + 4cψ + 3bψ² = 0, obtained from 12·F = ψ²·(6a+4cψ+3bψ²).
    have e1 : 6 * a + 4 * c * ψ + 3 * b * ψ ^ 2 = 0 := by
      have h12 : ψ ^ 2 * (6 * a + 4 * c * ψ + 3 * b * ψ ^ 2) = 12 * F a c b ψ := by
        unfold F; ring
      rw [hF, mul_zero] at h12
      exact (mul_eq_zero.mp h12).resolve_left hψ2
    -- E2 : a + cψ + bψ² = 0, from F' = ψ·(a + cψ + bψ²).
    have e2 : a + c * ψ + b * ψ ^ 2 = 0 := by
      have hfac : ψ * (a + c * ψ + b * ψ ^ 2) = F' a c b ψ := by unfold F'; ring
      rw [hF'] at hfac
      exact (mul_eq_zero.mp hfac).resolve_left hψ
    -- E1 − 3·E2 : 3a + cψ = 0.
    have e3 : 3 * a + c * ψ = 0 := by linarith
    -- bψ² = 2a (from e2 and e3: bψ² = -(a + cψ) = -(a - 3a) = 2a).
    have e4 : b * ψ ^ 2 = 2 * a := by linarith
    -- a·(9ab − 2c²) = 0, then exclude a = 0.
    -- key product identity: b·(cψ)² = b·9a²  and  c²·(bψ²) = c²·2a, with (cψ)² = c²ψ².
    have key : a * (9 * a * b - 2 * c ^ 2) = 0 := by
      -- 9a²b = b·(cψ)² = c²·(bψ²) = 2a·c²  ⇒  a(9ab − 2c²) = 0
      have hcψ : c * ψ = -(3 * a) := by linarith
      -- (cψ)² = 9a²
      have hsq : (c * ψ) ^ 2 = 9 * a ^ 2 := by rw [hcψ]; ring
      -- b·(cψ)² = c²·(bψ²)
      have hbridge : b * (c * ψ) ^ 2 = c ^ 2 * (b * ψ ^ 2) := by ring
      rw [hsq, e4] at hbridge
      -- hbridge : b * (9 * a ^ 2) = c ^ 2 * (2 * a)
      nlinarith [hbridge]
    rcases mul_eq_zero.mp key with ha | hgoal
    · -- a = 0 ⇒ cψ = 0 (e3) ⇒ ψ = 0 (c ≠ 0), contradiction.
      exfalso
      have : c * ψ = 0 := by rw [ha] at e3; linarith
      rcases mul_eq_zero.mp this with hc0 | hψ0
      · exact hc hc0
      · exact hψ hψ0
    · linarith
  · intro hrel
    -- Witness ψ = −2c/(3b); nonzero since c ≠ 0, b ≠ 0.
    have h3b : (3 : ℝ) * b ≠ 0 := mul_ne_zero (by norm_num) hb
    refine ⟨-(2 * c) / (3 * b), ?_, ?_, ?_⟩
    · -- −2c/(3b) ≠ 0 since c ≠ 0.
      have : -(2 * c) ≠ 0 := by
        simpa using hc
      exact div_ne_zero this h3b
    · -- F(witness) = 0 under 2c² = 9ab, i.e. a = 2c²/(9b).
      unfold F
      have ha : a = 2 * c ^ 2 / (9 * b) := by
        field_simp; linarith
      rw [ha]; field_simp; ring
    · -- F'(witness) = 0.
      unfold F'
      have ha : a = 2 * c ^ 2 / (9 * b) := by
        field_simp; linarith
      rw [ha]; field_simp; ring

/-- **R.276 (b) — MIP Clausius–Clapeyron coexistence-slope identity.**

On the first-order coexistence surface, two-phase equilibrium `dF̃_I = dF̃_II`
with the substitutions `T → T_kin`, pressure `P → 1/|K|` (emergent pressure)
gives the slope of the coexistence curve as the ratio of the emergent-volume gap
to the barrier-entropy gap:

    ∂T_c/∂(1/|K|) = ΔΦ₀ / Δ(log κ) .

Here `slope := ∂T_c/∂(1/|K|)`, `ΔΦ₀ := Φ₀(II) − Φ₀(I)` (emergent-volume gap, the
MIP analogue of `ΔV`), and `Δlogκ := log κ_II − log κ_I` (barrier-entropy gap,
the MIP analogue of `ΔS_B`, since `S_B = log(κ·|K|²)`).

Given the coexistence identity `ΔΦ₀ = slope · Δlogκ` (the differential balance
along the coexistence surface) and `Δlogκ ≠ 0`, the slope is determined: -/
theorem R_276_b_clausius_clapeyron
    (slope ΔΦ₀ Δlogκ : ℝ)
    (h_coex : ΔΦ₀ = slope * Δlogκ)
    (h_ne : Δlogκ ≠ 0) :
    slope = ΔΦ₀ / Δlogκ := by
  rw [h_coex, mul_div_assoc, div_self h_ne, mul_one]

end Tricritical

end MIP
