/-
Result R.272 — Ginzburg criterion: upper critical dimension d_c = 4.

Reference: `branches/thermodynamics/workspace/new_results.md` R.272
(Ginzburg criterion, mean-field failure at d_c = 4; thermodynamics
branch, 2026-05-18).

**Statement.** Mean-field theory is self-consistent iff fluctuations in
the correlation volume `ξ^{d_eff}` are small compared with `⟨ψ⟩²`:

    (1/ξ^{d_eff}) · ∫_{|x|<ξ} G(x) d^{d_eff}x  <<  ⟨ψ⟩² .             (#1)

Substituting the mean-field exponents (R.119/R.270/R.271)

    β = 1/2,   γ = 1,   ν = 1/2,

the left side scales as `|ε|^{ν·d_eff − γ}` and the right side as
`|ε|^{2β}`. For `|ε| → 0`, the criterion `LHS << RHS` is equivalent to the
exponent inequality

    ν·d_eff − γ > 2·β        (larger exponent ⟹ smaller as |ε|→0)      (♣)

Substituting `ν=1/2, γ=1, β=1/2` reduces this to `d_eff/2 − 1 > 1`,
i.e. **`d_eff > 4`**. Hence the upper critical dimension is `d_c = 4`:
mean-field is rigorous for `d_eff > 4`, and fails (Wilson-Fisher regime)
for `d_eff < 4`.

**This file is `axiom`-free.** It bundles the mean-field exponent values
and proves the equivalence `(ν·d_eff − γ > 2·β) ↔ (d_eff > 4)` by
substitution and `linarith`, together with the directional consequences
(d_eff > 4 ⟹ mean-field; d_eff < 4 ⟹ failure).
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace Ginzburg

/-- **R.272 (♣) — Ginzburg criterion ⟺ d_c = 4 (exponent equivalence).**

With the mean-field critical exponents `β = 1/2`, `γ = 1`, `ν = 1/2`, the
Ginzburg self-consistency condition `ν·d_eff − γ > 2·β` is equivalent to
the dimension condition `d_eff > 4`. -/
theorem R_272_ginzburg_iff
    (d_eff β γ ν : ℝ)
    (hβ : β = 1 / 2) (hγ : γ = 1) (hν : ν = 1 / 2) :
    (ν * d_eff - γ > 2 * β) ↔ (d_eff > 4) := by
  subst hβ hγ hν
  constructor
  · intro h; linarith
  · intro h; linarith

/-- **R.272 — mean-field validity (forward direction).**

If the effective DAG dimension exceeds the upper critical dimension
(`d_eff > 4`), then the Ginzburg condition `ν·d_eff − γ > 2·β` holds with
mean-field exponents, so mean-field theory is rigorous. -/
theorem R_272_meanfield_valid
    (d_eff β γ ν : ℝ)
    (hβ : β = 1 / 2) (hγ : γ = 1) (hν : ν = 1 / 2)
    (h_dim : d_eff > 4) :
    ν * d_eff - γ > 2 * β :=
  (R_272_ginzburg_iff d_eff β γ ν hβ hγ hν).mpr h_dim

/-- **R.272 — mean-field failure (Wilson-Fisher regime).**

If the Ginzburg condition fails — concretely, if `ν·d_eff − γ ≤ 2·β` with
mean-field exponents — then `d_eff ≤ 4`: fluctuations dominate and the
system flows to the Wilson-Fisher fixed point rather than the Gaussian
(mean-field) one. -/
theorem R_272_meanfield_fails
    (d_eff β γ ν : ℝ)
    (hβ : β = 1 / 2) (hγ : γ = 1) (hν : ν = 1 / 2)
    (h_fail : ν * d_eff - γ ≤ 2 * β) :
    d_eff ≤ 4 := by
  subst hβ hγ hν
  linarith

/-- **R.272 — the reduced form `d_eff/2 − 1 > 1`.**

Intermediate algebraic content of (♣): with mean-field exponents the
Ginzburg condition is exactly `d_eff/2 − 1 > 1`. -/
theorem R_272_reduced_form
    (d_eff β γ ν : ℝ)
    (hβ : β = 1 / 2) (hγ : γ = 1) (hν : ν = 1 / 2) :
    (ν * d_eff - γ > 2 * β) ↔ (d_eff / 2 - 1 > 1) := by
  subst hβ hγ hν
  constructor
  · intro h; linarith
  · intro h; linarith

end Ginzburg

end MIP
