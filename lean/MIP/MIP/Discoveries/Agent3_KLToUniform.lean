/-
  STATUS: DISCOVERY
  AGENT: 3
  DIRECTION: Tier C — KL divergence of the partition-mass profile to uniform.
  SUMMARY:
    Define
      KL_to_uniform(d, P) := log m  -  H_π(d, P)         (m := P.parts.card)
    where H_π is the Shannon entropy of the subdomain masses and the
    "log m" term is the entropy of the uniform profile. Then:
      Tier C.11   KL_to_uniform ≥ 0                       (Gibbs)
      Tier C.11b  KL_to_uniform = 0 ⟺ H_π = log m         (saturation = uniform attention)

    This is the partition-level Gibbs inequality, framed as "divergence of
    the current attention profile from the generalist (uniform) profile".
    Equivalent to B.8 (Hpi ≤ log m), but the framing makes it useful in
    free-energy / phase-transition contexts where the gap log m - H_π is a
    natural "specialisation index".

    Note: the standard KL form `∑ π_i log (π_i / (1/m)) = ∑ π_i log π_i + log m`
    is what we want here. Since ∑ π_i = 1 by conservation, the +log m term
    is multiplied by 1, giving the identity `KL = log m - H_π`.
-/
import MIP.Theorems.T18_10_Conservation
import MIP.Discoveries.Agent3_PiEntropyBounds

namespace MIP

namespace Agent3_KLToUniform

open scoped BigOperators
open Real
open MIP.Agent3_PiEntropyBounds (Hpi Hpi_nonneg Hpi_le_log_card)

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-- **KL divergence of the partition-mass profile to the uniform profile.**

`KL_to_uniform(d, P) := log m - H_π(d, P)`, with `m := P.parts.card`.

This is the standard Gibbs-form KL divergence
`∑ π_S log (π_S / (1/m))` rewritten using `∑ π_S = 1` (R-SUB.1):
`∑ π_S log π_S - ∑ π_S log (1/m) = -H_π + log m · ∑ π_S = log m - H_π`. -/
noncomputable def KL_to_uniform
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) : ℝ :=
  Real.log (P.parts.card : ℝ) - Hpi d P

/-- **C.11 (Gibbs) — KL to uniform is nonnegative.**

For any normalised distribution and any nonempty `SubdomainPartition`,
`KL_to_uniform(d, P) ≥ 0`.  Immediate from `Hpi ≤ log m`. -/
theorem KL_to_uniform_nonneg
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    0 ≤ KL_to_uniform d P := by
  unfold KL_to_uniform
  linarith [Hpi_le_log_card d P hP]

/-- **C.11b — KL to uniform = 0 ⟺ H_π attains log m.**

Saturation of the Gibbs inequality is equivalent to entropy saturation,
which (by the standard concavity equality case) means uniform attention.
We state the algebraic equivalence; the "iff uniform" reading is then
the content of CjNEW13's uniform-attainer side. -/
theorem KL_to_uniform_eq_zero_iff
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    KL_to_uniform d P = 0 ↔ Hpi d P = Real.log (P.parts.card : ℝ) := by
  unfold KL_to_uniform
  constructor
  · intro h; linarith
  · intro h; linarith

/-- **C.11c — KL bounds:** `0 ≤ KL_to_uniform ≤ log m`.

The upper bound is `log m - 0 = log m` since `H_π ≥ 0`. -/
theorem KL_to_uniform_bracket
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (hP : P.parts.Nonempty) :
    0 ≤ KL_to_uniform d P ∧ KL_to_uniform d P ≤ Real.log (P.parts.card : ℝ) := by
  refine ⟨KL_to_uniform_nonneg d P hP, ?_⟩
  unfold KL_to_uniform
  linarith [Hpi_nonneg d P]

/-- **C.11d — KL upper bound saturated at a vertex.**

When `H_π = 0` (point-mass partition / vertex), `KL_to_uniform = log m`,
the maximum possible value. So:

* `H_π = 0`  ⟺ point-mass partition (vertex)  (B.10).
* In that case, `KL_to_uniform = log m`. -/
theorem KL_to_uniform_max_at_vertex
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (h_vertex : Hpi d P = 0) :
    KL_to_uniform d P = Real.log (P.parts.card : ℝ) := by
  unfold KL_to_uniform
  rw [h_vertex]; ring

/-- **Sanity: KL of uniform-vs-uniform = 0.**

When `H_π = log m` (uniform / generalist), the KL gap is zero. -/
theorem KL_to_uniform_zero_at_uniform
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    (h_uniform : Hpi d P = Real.log (P.parts.card : ℝ)) :
    KL_to_uniform d P = 0 := by
  unfold KL_to_uniform
  rw [h_uniform]; ring

end Agent3_KLToUniform

end MIP
