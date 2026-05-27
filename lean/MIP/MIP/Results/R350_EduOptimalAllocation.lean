/-
Result R.350 — Education optimal-allocation theorem (|K_A| ≫ |K_H| limit).
Reference: branches/sociology/workspace/new_results.md (old sociology R.137).

**Statement.** Consider an AI population `A` with `|K(A)| ≫ |K(H)|` (post
coverage-transition, R.97 stage 2-3).  Under the education budget
constraint `c_K + c_Z + c_H + c_κ = C` (allocation vector
`c = (c_K, c_Z, c_H, c_κ)`), the allocation that minimises the population
expected intervention count `E_P[N(p, A, H)]` satisfies the corner
solution

    c_K* = 0,   c_H* = 0,   c_Z* + c_κ* = C,

and at the interior optimum the (cost-normalised) marginal returns of the
two surviving dimensions are equal — the KKT marginal-balance condition

    ∂E[N]/∂c_Z  =  ∂E[N]/∂c_κ          (abstract balance, A-grade)
    |log κ(H)|·|∂Z/∂c_Z| = (Z(H)/κ(H))·|∂κ/∂c_κ|   (concrete, bridge).

In the |K_A| ≫ |K_H| limit the marginal returns of knowledge expansion
(`c_K`) and knowledge-entropy uniformisation (`c_H`) vanish, so by the
KKT complementary-slackness inequality the optimum lies on the boundary
`c_K = c_H = 0`: education invests *only* in collaboration `Z⁻¹` and
combinatorial `κ`.

**Kernel formalized here.** Pure real-algebra KKT kernel.
(1) `R_350_corner_solution`: if the marginal change of the objective in a
dimension is `≥ 0` (nonincreasing benefit) while the Lagrange multiplier
`λ > 0`, the stationarity-or-boundary KKT condition forces `c* = 0`
for that dimension — the corner solution; applied to both `c_K` and `c_H`.
(2) `R_350_marginal_balance`: at an interior optimum in the surviving
dimensions, `∂N/∂c_i = λ·1` (unit cost) gives the equal-marginal
identity `∂N/∂c_Z = ∂N/∂c_κ` (the R.62 divide-by-cost idiom).
(3) `R_350_budget_residual`: with `c_K = c_H = 0` the budget collapses to
`c_Z + c_κ = C`.
(4) `R_350_concrete_balance`: the concrete |log κ|-weighted balance
identity, derived algebraically from the two unit-cost stationarity
equations.

**Bridge.** `E_P[N]`, the partials `∂E[N]/∂c_i`, and the multiplier `λ`
are MIP/sociology scalars supplied as hypothesis-bundled reals; the
limit `|K_A| ≫ |K_H|` enters only as the hypothesis `∂E[N]/∂c_K ≥ 0`
(marginal knowledge-expansion benefit has decayed to nonpositive),
faithful to the source's `∂E[N]/∂c_K → 0` statement.

Axiom-free.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace R350_EduOptimalAllocation

/-- **R.350 — corner solution (KKT complementary slackness).**

Model the budget-constrained minimisation of the objective `E[N]` by the
Lagrangian `L = E[N] − λ·(Σ cᵢ − C)`.  KKT for an inequality-constrained
variable `c_i ≥ 0` is: either interior stationarity `∂L/∂c_i = 0`, or
boundary `c_i = 0` with `∂L/∂c_i ≥ 0`.

Here `∂L/∂c_i = ∂E[N]/∂c_i − λ`.  In the `|K_A| ≫ |K_H|` limit the
marginal benefit `∂E[N]/∂c_K` has decayed to be nonnegative (the source's
`∂E[N]/∂c_K → 0` ⟹ no further decrease available), while the multiplier
`λ > 0`.  Then `∂L/∂c_K = ∂E[N]/∂c_K − λ`; if the KKT feasibility for an
interior point would require `∂L/∂c_K = 0`, i.e. `∂E[N]/∂c_K = λ`, this
contradicts `∂E[N]/∂c_K ≥ 0` together with `λ` strictly exceeding it.
Hence the dimension cannot be interior and the optimum is the boundary
`c_K* = 0`.

We formalize the contradiction: given a *candidate* interior stationary
value `dEN_dcK = λ` (the only way an interior optimum is admissible) but
`dEN_dcK ≤ 0 < λ`, the interior case is impossible (it would need
`λ = dEN_dcK ≤ 0`, contradicting `λ > 0`), so the KKT verdict
`c_K* = 0 ∨ (interior)` collapses to the boundary `c_K* = 0`. -/
theorem R_350_corner_solution
    (dEN_dcK lam cK_star : ℝ)
    (h_marginal_nonpos : dEN_dcK ≤ 0)
    (h_lam_pos : 0 < lam)
    -- KKT verdict: either the boundary `c_K* = 0`, or interior
    -- stationarity `∂E[N]/∂c_K = λ`.
    (h_kkt : cK_star = 0 ∨ dEN_dcK = lam) :
    cK_star = 0 := by
  rcases h_kkt with h0 | hint
  · exact h0
  · -- interior case: dEN_dcK = lam, but dEN_dcK ≤ 0 < lam — contradiction.
    exfalso; linarith [hint ▸ h_marginal_nonpos]

/-- **R.350 — both knowledge dimensions degenerate (`c_K* = c_H* = 0`).**

The corner argument applies identically to `c_K` (knowledge expansion)
and `c_H` (knowledge-entropy uniformisation): both marginal benefits are
nonpositive in the limit, so both optima are on the boundary. -/
theorem R_350_both_knowledge_corners
    (dEN_dcK dEN_dcH lam cK_star cH_star : ℝ)
    (h_mK : dEN_dcK ≤ 0) (h_mH : dEN_dcH ≤ 0)
    (h_lam_pos : 0 < lam)
    (h_bdK : cK_star = 0 ∨ dEN_dcK = lam)
    (h_bdH : cH_star = 0 ∨ dEN_dcH = lam) :
    cK_star = 0 ∧ cH_star = 0 :=
  ⟨R_350_corner_solution dEN_dcK lam cK_star h_mK h_lam_pos h_bdK,
   R_350_corner_solution dEN_dcH lam cH_star h_mH h_lam_pos h_bdH⟩

/-- **R.350 — budget residual after the corner collapse.**

With `c_K* = 0` and `c_H* = 0`, the budget constraint
`c_K + c_Z + c_H + c_κ = C` collapses to `c_Z + c_κ = C`: the entire
budget flows to collaboration and combinatorial dimensions. -/
theorem R_350_budget_residual
    (cK cZ cH cκ C : ℝ)
    (h_budget : cK + cZ + cH + cκ = C)
    (h_cK0 : cK = 0) (h_cH0 : cH = 0) :
    cZ + cκ = C := by
  rw [h_cK0, h_cH0] at h_budget
  linarith

/-- **R.350 — abstract marginal balance (A-grade core).**

At the interior optimum in the two surviving dimensions, KKT
stationarity gives `∂E[N]/∂c_Z = λ·1` and `∂E[N]/∂c_κ = λ·1` (both with
unit budget cost, since the constraint is `Σcᵢ = C`).  Dividing by the
common unit cost yields the equal-marginal identity

    ∂E[N]/∂c_Z = ∂E[N]/∂c_κ .

This is the R.62 divide-by-(unit-)cost idiom; it is the A-grade rigorous
core of R.137 (independent of any `F`-form ansatz). -/
theorem R_350_marginal_balance
    (dEN_dcZ dEN_dcκ lam : ℝ)
    (h_stat_Z : dEN_dcZ = lam * 1)
    (h_stat_κ : dEN_dcκ = lam * 1) :
    dEN_dcZ = dEN_dcκ := by
  rw [h_stat_Z, h_stat_κ]

/-- **R.350 — concrete |log κ|-weighted balance (bridge form).**

Under the source's "H-side R.61-like asymptotics" bridge assumption, the
marginal of `E[N]` in `c_Z` is proportional to `|log κ(H)|·∂Z/∂c_Z` and
the marginal in `c_κ` is proportional to `(Z(H)/κ(H))·∂κ/∂c_κ` (sign
folded into magnitudes).  Setting the two equal-marginal partials equal
(from `R_350_marginal_balance`) gives the concrete balance identity

    |log κ(H)| · |∂Z/∂c_Z|  =  (Z(H)/κ(H)) · |∂κ/∂c_κ| .

We prove the algebraic step: equal common-factor-scaled marginals imply
the balance, where the common positive factor `c₀·E_P[r]` cancels. -/
theorem R_350_concrete_balance
    (c0Er logκ absZ' Z κ absκ' : ℝ)
    (h_c0Er_ne : c0Er ≠ 0)
    -- the two equal-marginal partials, written in the bridge ansatz:
    (h_mZ : c0Er * (logκ * absZ') = c0Er * ((Z / κ) * absκ')) :
    logκ * absZ' = (Z / κ) * absκ' :=
  mul_left_cancel₀ h_c0Er_ne h_mZ

end R350_EduOptimalAllocation

end MIP
