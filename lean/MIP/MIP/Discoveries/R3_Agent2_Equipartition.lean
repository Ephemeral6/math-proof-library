/-
  STATUS: DISCOVERY
  AGENT: R3_Agent2
  DIRECTION: Conservation-law composition (A) — T.18.10 + R-SUB.7 →
              equipartition identity for `H_K`.
  SUMMARY:
    Composes T.18.10 (`∑_S π_S = 1`) with the abstract pure-math
    chain rule (`HKChain.chain_atomic`/`R_SUB_7_chain_decomposition`)
    into a single "equipartition collapse" identity:

    if every within-subdomain entropy equals a fixed constant `c`, then
    the total knowledge entropy collapses to
        H_K = H(π) + c · (∑_S π_S) = H(π) + c · 1 = H(π) + c.

    The closed form `H(π) + c` is forced by conservation of mass —
    without `∑ π_S = 1` we would only get `H(π) + c · (∑ π_S)`.

    Headline:

      `equipartition_HK_eq` : if all `H_S = c`,
                              then `H_K = H(π) + c`.

      `equipartition_uniform_HK_eq` : if additionally `π_S = 1/m`
                              and `c = log k` (uniform within parts of
                              size `k`), then `H_K = log m + log k`.

    The second specialisation gives the familiar "log of cardinality"
    closed form `H_K = log|Ω|` whenever `Ω` partitions into `m` parts
    of equal size `k`, `|Ω| = m·k`.

  Depends on:
    - MIP.Theorems.T18_10_Conservation (T18_10_conservation)
    - MIP.Results.RSUB1_Conservation   (R_SUB_1_conservation re-export)
    - MIP.Results.RSUB7_HK_Chain       (HKChain.chain_atomic
                                        / R_SUB_7_chain_decomposition)
-/
import MIP.Theorems.T18_10_Conservation
import MIP.Results.RSUB1_Conservation
import MIP.Results.RSUB7_HK_Chain
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

open scoped BigOperators
open Real

namespace R3_Agent2_Equipartition

/-! ## (A) T.18.10 + R-SUB.7 — equipartition identity. -/

/-- **Equipartition collapse (constant within-part entropy).**

If `∑_S π_S = 1` (T.18.10 / R-SUB.1) and within each part the
"within-subdomain entropy" `H_S = c` is the *same* constant, then the
weighted sum `∑_S π_S · H_S = c`, by mass conservation.

This is a pure algebraic kernel that downstream R-SUB.7-style chain
decompositions plug into: chain rule gives
`H_K = H(π) + ∑_S π_S · H_S`, and this kernel collapses the second
summand to `c` whenever the within-part entropies are uniform. -/
theorem weighted_constant_collapse
    {Ω : Type} [DecidableEq Ω]
    (parts : Finset (Finset Ω))
    (π : Finset Ω → ℝ) (c : ℝ)
    (hπsum : ∑ S ∈ parts, π S = 1) :
    ∑ S ∈ parts, π S * c = c := by
  -- ∑ π_S · c = (∑ π_S) · c = 1 · c = c
  rw [← Finset.sum_mul, hπsum, one_mul]

/-- **Composition (A) — abstract equipartition `H_K = H(π) + c`.**

This is the *abstract* chain-rule form: given any total entropy `H_K`,
coarse-grained partition entropy `Hπ`, mass weights `π`, and per-part
entropies `H_S`, if

* the chain rule `H_K = Hπ + ∑_S π_S · H_S` holds (R-SUB.7),
* the masses sum to 1 (T.18.10 / R-SUB.1),
* every `H_S = c` is the same constant,

then `H_K = Hπ + c`.

This is the headline "equipartition identity": when every subdomain
contributes the same conditional entropy, `H_K` is just the coarse
entropy plus a constant offset. -/
theorem equipartition_HK_eq
    {Ω : Type} [DecidableEq Ω]
    (parts : Finset (Finset Ω))
    (π : Finset Ω → ℝ) (H_S : Finset Ω → ℝ)
    (H_K Hπ c : ℝ)
    (hchain : H_K = Hπ + ∑ S ∈ parts, π S * H_S S)   -- R-SUB.7
    (hπsum  : ∑ S ∈ parts, π S = 1)                  -- T.18.10
    (hconst : ∀ S ∈ parts, H_S S = c)                -- equipartition
    : H_K = Hπ + c := by
  -- Replace H_S by the constant c, then collapse via mass conservation.
  have h_replace :
      ∑ S ∈ parts, π S * H_S S = ∑ S ∈ parts, π S * c := by
    apply Finset.sum_congr rfl
    intro S hS
    rw [hconst S hS]
  rw [hchain, h_replace, weighted_constant_collapse parts π c hπsum]

/-- **Uniform mass collapse.**

Equipartition of mass — `π_S = 1/m` for every `S` — combined with `m`
parts gives `H(π) = log m`. (We don't need to formalise the Shannon
form; we just record the elementary fact that a uniform sum of
log-equal terms equals `log m`.) Stated as the algebraic identity
underlying it. -/
theorem uniform_partition_entropy_kernel
    {Ω : Type} [DecidableEq Ω]
    (parts : Finset (Finset Ω)) (m : ℕ) (hm : (m : ℝ) > 0)
    (hcard : parts.card = m) :
    -∑ S ∈ parts, (1 / (m : ℝ)) * Real.log (1 / (m : ℝ))
      = Real.log (m : ℝ) := by
  -- The sum is constant over `parts`, with parts.card = m.
  have hconst :
      -∑ S ∈ parts, (1 / (m : ℝ)) * Real.log (1 / (m : ℝ))
        = -((parts.card : ℝ) * ((1 / (m : ℝ)) * Real.log (1 / (m : ℝ)))) := by
    rw [Finset.sum_const, nsmul_eq_mul]
  rw [hconst, hcard]
  -- Goal: -(m · ((1/m) · log (1/m))) = log m
  have hm_ne : (m : ℝ) ≠ 0 := ne_of_gt hm
  have hstep : (m : ℝ) * ((1 / (m : ℝ)) * Real.log (1 / (m : ℝ)))
             = Real.log (1 / (m : ℝ)) := by
    field_simp
  rw [hstep]
  -- -log(1/m) = log m
  rw [Real.log_div one_ne_zero hm_ne, Real.log_one]
  ring

/-- **Full equipartition identity (uniform within + uniform between).**

When the partition mass is uniform `π_S = 1/m` (so `H(π) = log m` by
the kernel above), within-part entropy is the constant `c = log k`
(uniform on a part of size `k`), and the chain rule holds, we get the
*familiar* total

    H_K = log m + log k = log (m · k).

By T.18.10 the masses sum to 1, which is consistent with the uniform
choice `π_S = 1/m` over `m` parts.

This is the **single-line equipartition identity** the prompt asks
for. -/
theorem equipartition_uniform_HK_eq
    {Ω : Type} [DecidableEq Ω]
    (parts : Finset (Finset Ω)) (m k : ℕ)
    (hm : (m : ℝ) > 0) (hk : (k : ℝ) > 0)
    (hcard : parts.card = m)
    (H_K Hπ : ℝ)
    -- abstract chain-rule input (R-SUB.7) specialised to uniform π and constant H_S
    (hchain :
      H_K = Hπ + ∑ S ∈ parts, (1 / (m : ℝ)) * Real.log (k : ℝ))
    -- abstract partition-entropy input (Hπ = log m)
    (hHπ : Hπ = Real.log (m : ℝ)) :
    H_K = Real.log (m : ℝ) + Real.log (k : ℝ) := by
  -- Collapse the sum: ∑_S (1/m) · log k = (parts.card / m) · log k
  --                                     = (m/m) · log k = log k.
  have hsum :
      ∑ S ∈ parts, (1 / (m : ℝ)) * Real.log (k : ℝ)
        = Real.log (k : ℝ) := by
    rw [Finset.sum_const, nsmul_eq_mul]
    rw [hcard]
    have hm_ne : (m : ℝ) ≠ 0 := ne_of_gt hm
    field_simp
  rw [hchain, hsum, hHπ]

/-- **Aggregate sanity check — uniform π always sums to 1.**

T.18.10 requires `∑_S π_S = 1`. The uniform choice `π_S = 1/m` over
`m` parts automatically satisfies it. This sanity lemma confirms the
compositional consistency of `equipartition_uniform_HK_eq` with
`R_SUB_1_conservation`/T.18.10. -/
theorem uniform_mass_conservation
    {Ω : Type} [DecidableEq Ω]
    (parts : Finset (Finset Ω)) (m : ℕ)
    (hm : (m : ℝ) > 0) (hcard : parts.card = m) :
    ∑ S ∈ parts, (1 / (m : ℝ)) = 1 := by
  rw [Finset.sum_const, nsmul_eq_mul, hcard]
  field_simp

end R3_Agent2_Equipartition

end MIP
