/-
Theorem T.32 — Cognitive Boundary Lower Bound (IBΦ).

Reference: `proofs/derived/A4_grade.md` R.800 ＝ T.32 (A 无条件).

**Statement.** Given an agent `X` and a family of `k` problems `p_1, …, p_k`
whose initial queries have identical `K(X)`-projections and whose correct-
solution regions are pairwise disjoint, the initial emergence potentials
satisfy

    Σᵢ exp(-Φ₀(X, p_i))  ≤  1

and hence (an AM-min consequence) at least one `Φ₀(X, p_i) ≥ log k`.

Dependencies: A.4 (cognitive boundary, projection invariance), D.3.1
(Φ₀ = -log Pr[正解]), Boole inequality.

**Strategy.**  The MIP-specific content (A.4 projection collapse +
Pr[正解] = exp(-Φ₀)) is encapsulated by an opaque "Boltzmann mass"
function `bm X p := exp(-Φ₀(X, p))`. The pure-math kernel — "if
`Σ bᵢ ≤ 1` over `k` terms, then `max -log bᵢ ≥ log k`" — is fully
proved without `sorry` as `T32_AMmin_kernel`. The full IBΦ theorem
combines the kernel with the MIP hypothesis `Σ bm X p_i ≤ 1`,
which is itself the conclusion of the (sorry-ed) A.4 + Boole step.
-/
import MIP.Axioms
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

open scoped BigOperators
open Real

namespace IBPhi

/-! ## Pure-math kernel: the AM-min lemma underlying T.32. -/

/-- **AM-min kernel.** If `k` non-negative reals sum to at most `1`, then
the largest of them is at most `1/k`; equivalently, the maximum of the
"negative log masses" is at least `log k`.

This is the bare combinatorial/analytic content of T.32 step 3, fully
proved here without `sorry`. -/
theorem T32_AMmin_kernel {k : ℕ} (hk : 0 < k) (Φ : Fin k → ℝ)
    (h : ∑ i, Real.exp (-Φ i) ≤ 1) :
    ∃ i : Fin k, Real.log k ≤ Φ i := by
  -- Step 1: some `exp (-Φ i) ≤ 1 / k`.
  -- (Otherwise all > 1/k, so Σ > k·(1/k) = 1, contradiction.)
  have hk_pos : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hcard : (Finset.univ : Finset (Fin k)).card = k := Finset.card_univ.trans (by simp)
  by_contra hcon
  push Not at hcon
  -- hcon : ∀ i, Φ i < Real.log k
  -- ⟹ -Φ i > -log k ⟹ exp(-Φ i) > exp(-log k) = 1/k
  have hinv : ∀ i : Fin k, (1 / (k : ℝ)) < Real.exp (-Φ i) := by
    intro i
    have hΦ : Φ i < Real.log k := hcon i
    have hneg : -(Real.log k) < -Φ i := by linarith
    have hexp : Real.exp (-(Real.log k)) < Real.exp (-Φ i) := Real.exp_lt_exp.mpr hneg
    rw [Real.exp_neg, Real.exp_log hk_pos] at hexp
    -- hexp : (↑k)⁻¹ < rexp (-Φ i)
    have hinv_eq : (1 : ℝ) / (k : ℝ) = ((k : ℝ))⁻¹ := one_div _
    rw [hinv_eq]; exact hexp
  -- Sum over all i: Σ exp(-Φ i) > Σ 1/k = k · (1/k) = 1.
  have hsum_lt : (1 : ℝ) < ∑ i : Fin k, Real.exp (-Φ i) := by
    have hstep : ∑ i : Fin k, (1 / (k : ℝ)) < ∑ i : Fin k, Real.exp (-Φ i) :=
      Finset.sum_lt_sum_of_nonempty
        (Finset.univ_nonempty_iff.mpr ⟨⟨0, hk⟩⟩) (fun i _ => hinv i)
    have hone : ∑ _i : Fin k, (1 / (k : ℝ)) = 1 := by
      rw [Finset.sum_const, hcard, nsmul_eq_mul]; field_simp
    linarith [hstep.trans_le (le_refl _), hone]
  linarith

/-! ## MIP-level statement (Σ Boltzmann mass ≤ 1 form).

The MIP-specific content — A.4 projection invariance + Boole for
pairwise-disjoint correctness regions ⟹ `Σ exp(-Φ₀(X, pᵢ)) ≤ 1` — is
modelled as an opaque hypothesis here; the conclusion `max Φ₀ ≥ log k`
follows from the kernel above. -/

variable {α : Type}

/-- "Boltzmann mass" of a problem under an agent: `exp(-Φ₀(X, p))`.

We pin down the formal definition via `ENNReal.toReal` so that the
opaque `Phi0` (an `ENNReal`) can interact with `Real.exp`. -/
noncomputable def boltzmannMass (X : Agent α) (p : Problem α) : ℝ :=
  Real.exp (-(Phi0 X p).toReal)

/-- **The Boole / disjoint-correctness hypothesis** packaged abstractly.
Inputs `q₀` (problem-indexed initial queries) and `correctSets` (the
correctness sets `Eᵢ ⊆ Σ*`) are kept implicit in the abstract form: the
hypothesis is simply "the `k` Boltzmann masses sum to ≤ 1", which is the
exact output of A.4 projection collapse + Boole inequality applied to
pairwise-disjoint correctness regions.

Justification (NL): under (IBΦ-i) `Restr_{K(X)}(q₀^{(i)}) = q̄`, A.4
iteration gives `𝓛(X(q₀^{(i)})) = 𝓛(X(q̄))` for all `i`. Then
`Σᵢ exp(-Φ₀(X,pᵢ)) = Σᵢ Pr_{X(q̄)}[Eᵢ] = Pr[⋃ᵢ Eᵢ] ≤ 1` (Boole +
disjointness). -/
def DisjointCoverageHyp {k : ℕ} (X : Agent α) (p : Fin k → Problem α) : Prop :=
  ∑ i, boltzmannMass X (p i) ≤ 1

/-- **T.32 (IBΦ).** Under the disjoint-coverage hypothesis (encapsulating
A.4 projection invariance + Boole inequality), at least one of the `k`
emergence potentials is `≥ log k`.

To recover the exact NL statement `min Φ₀ ≥ log k` (a slip in the
source: AM-min gives `max ≥ log k`, not `min`), one would need every
`Φ₀(X, pᵢ)` to be `≥ log k`, which the partition-mass argument does not
imply. The Lean formalisation states the AM-min-true form: **some** `pᵢ`
has `Φ₀ ≥ log k`.

This theorem follows from the AM-min kernel applied to
`Φᵢ := (Phi0 X (p i)).toReal`. -/
theorem T32_IBPhi {k : ℕ} (hk : 0 < k)
    (X : Agent α) (p : Fin k → Problem α)
    (hsum : DisjointCoverageHyp X p) :
    ∃ i : Fin k, Real.log k ≤ (Phi0 X (p i)).toReal := by
  have := T32_AMmin_kernel hk (fun i => (Phi0 X (p i)).toReal) ?_
  · exact this
  · simpa [DisjointCoverageHyp, boltzmannMass] using hsum

end IBPhi

end MIP
