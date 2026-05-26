/-
Result R.700-R.704 — EPI-K entropy-power family (slot 007, EKI).

Reference: `workspace/round3_exploration/slot_007.md` and
`workspace/round3_exploration/work_slot_007.md` (Entropy-Knowledge
Inequality Family).  Source results R.700 (EPI-K), R.701 (self-sub-kernel
entropy ceiling), R.702 (κ ≥ 1/|K|, the first universal κ lower bound).

**Candidate status: Round-3 autonomous exploration, not yet
human-audited.**

This file formalises the *crisp algebraic kernels* of the family.  The
deep entropy facts (Shannon concavity, conditional-≤-marginal entropy)
are bundled as hypotheses; what is proved here is the exact passage from
those facts to the stated entropy-power / cardinality inequalities.

* **R.700 (EPI-K).**  Writing `N_K(W) := exp(H_K(W))` for the knowledge
  entropy power, Shannon concavity of `H_K` under the cooperative-merge
  mixing `H_K(X ⊞_λ Y) ≥ c·H_K(X) + (1-c)·H_K(Y)` becomes the
  entropy-power inequality
      `N_K(X ⊞_λ Y) ≥ N_K(X)^c · N_K(Y)^{1-c}`
  by exponentiating (the geometric-mean form, with `Real.rpow` weights).

* **R.701 (self-sub-kernel ceiling).**  Conditional ≤ marginal entropy
  `H_K(A_Y^{self}) ≤ H_K(Y)` exponentiates to `N_K(self) ≤ N_K(Y)`.

* **R.702 (κ universal lower bound).**  The repaired proof (REPAIRS.md
  §1.1): reflexivity gives the diagonal `{(ω,ω) : ω ∈ K} ⊆ R_∘`, hence
  `|K| ≤ |R_∘|`, hence `κ := |R_∘| / |K|² ≥ 1 / |K|`.  This is a pure
  cardinality / probability inequality.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace EntropyPower

open Real

/-! ### Knowledge entropy power

`N_K(W) := exp(H_K(W))` is the "effective alphabet size" of the
normalised activation distribution `p_W`.  We work directly with the
entropy values `H_K` and define the power by `Real.exp`. -/

/-- Knowledge entropy power `N_K(H) := exp H`. -/
noncomputable def Npow (H : ℝ) : ℝ := Real.exp H

@[simp] lemma Npow_pos (H : ℝ) : 0 < Npow H := Real.exp_pos H

/-- **Geometric-mean identity for the entropy power.**

`N_K(X)^c · N_K(Y)^{1-c} = exp(c·H_X + (1-c)·H_Y)`.  This is the bridge
between the additive (entropy) world and the multiplicative
(entropy-power) world, using `Real.rpow` for the real exponents. -/
theorem Npow_geom (Hx Hy c : ℝ) :
    (Npow Hx) ^ c * (Npow Hy) ^ (1 - c) = Real.exp (c * Hx + (1 - c) * Hy) := by
  unfold Npow
  rw [Real.exp_add, Real.rpow_def_of_pos (Real.exp_pos Hx), Real.log_exp,
      Real.rpow_def_of_pos (Real.exp_pos Hy), Real.log_exp,
      mul_comm c Hx, mul_comm (1 - c) Hy]

/-- **R.700 (EPI-K, entropy-power form).**

Cooperative-merge concavity of the knowledge entropy,
`c·H_X + (1-c)·H_Y ≤ H_merge`, exponentiates to the
Entropy-Knowledge Power Inequality

    N_K(X)^c · N_K(Y)^{1-c}  ≤  N_K(X ⊞_λ Y).

The hypothesis `h_concave` packages Shannon concavity of `H_K` together
with the marginal-activation mixing formula `p_merge = c·p_X + (1-c)·p_Y`
(work_slot_007.md §2.2-2.3); the weight `c = λ Z_X / (λ Z_X + (1-λ) Z_Y)`
is left abstract. -/
theorem R_700_EPI_K
    (Hx Hy Hmerge c : ℝ)
    (h_concave : c * Hx + (1 - c) * Hy ≤ Hmerge) :
    (Npow Hx) ^ c * (Npow Hy) ^ (1 - c) ≤ Npow Hmerge := by
  rw [Npow_geom]
  exact Real.exp_le_exp.mpr h_concave

/-- **R.700 specialisation (`c = 1/2`).**

Equal-weight merge (`λ = 1/2`, `Z_X = Z_Y`) gives the symmetric
geometric-mean lower bound

    √(N_K(X) · N_K(Y))  ≤  N_K(X ⊞_{1/2} Y).

Here `(Npow Hx)^(1/2) · (Npow Hy)^(1/2)` is exactly that square root. -/
theorem R_700_EPI_K_half
    (Hx Hy Hmerge : ℝ)
    (h_concave : (1/2 : ℝ) * Hx + (1 - 1/2) * Hy ≤ Hmerge) :
    (Npow Hx) ^ (1/2 : ℝ) * (Npow Hy) ^ (1 - 1/2 : ℝ) ≤ Npow Hmerge :=
  R_700_EPI_K Hx Hy Hmerge (1/2) h_concave

/-- **R.701 (self-sub-kernel entropy ceiling, entropy-power form).**

Conditional ≤ marginal entropy `H_K(A_Y^{self}) ≤ H_K(Y)` (Shannon, under
the semantic-preservation hypothesis bundled as `h_le`) exponentiates to

    N_K(A_Y^{self})  ≤  N_K(Y) :

the self-reflective sub-kernel is never *richer* than the parent. -/
theorem R_701_self_subkernel_ceiling
    (Hself Hy : ℝ) (h_le : Hself ≤ Hy) :
    Npow Hself ≤ Npow Hy :=
  Real.exp_le_exp.mpr h_le

/-! ### R.702 — universal κ lower bound

The combinatorial closure degree is `κ(X) := |R_∘| / |K(X)|²`, where
`R_∘ ⊆ K(X) × K(X)` is the co-occurrence relation.  Reflexivity of the
`∘`-product (D.3.7: `ω ∘ ω ∈ K(X)` always) forces the diagonal to lie in
`R_∘`. -/

/-- **Diagonal cardinality bound.**

If the diagonal `{(ω,ω) : ω ∈ K}` is contained in the co-occurrence
relation `R`, then `|K| ≤ |R|`.  (The diagonal map `ω ↦ (ω,ω)` is
injective, so its image has cardinality `|K|`.) -/
theorem diag_card_le
    {ι : Type} [DecidableEq ι] (K : Finset ι) (R : Finset (ι × ι))
    (h_diag : ∀ ω ∈ K, (ω, ω) ∈ R) :
    K.card ≤ R.card := by
  have h_sub : (K.image (fun ω => (ω, ω))) ⊆ R := by
    intro x hx
    simp only [Finset.mem_image] at hx
    obtain ⟨ω, hω, rfl⟩ := hx
    exact h_diag ω hω
  calc K.card
      = (K.image (fun ω => (ω, ω))).card := by
        rw [Finset.card_image_of_injective]
        intro a b hab; simpa using hab
    _ ≤ R.card := Finset.card_le_card h_sub

/-- **R.702 (κ universal lower bound, real / cardinality form).**

Given `κ = |R| / |K|²` with `0 < |K| ≤ |R|` (the diagonal bound), the
combinatorial closure degree satisfies

    1 / |K|  ≤  κ .

This is the first non-trivial universal lower bound on κ — before this,
only the trivial range `0 ≤ κ ≤ 1` was known.  Proof: `|R|/|K|² ≥
|K|/|K|² = 1/|K|`. -/
theorem R_702_kappa_lower_bound
    (Kc Rc κ : ℝ) (hK : 0 < Kc) (h_diag : Kc ≤ Rc)
    (hκ : κ = Rc / Kc ^ 2) :
    1 / Kc ≤ κ := by
  rw [hκ, div_le_div_iff₀ hK (by positivity)]
  have hsq : Kc ^ 2 = Kc * Kc := by ring
  rw [hsq, one_mul]
  exact mul_le_mul_of_nonneg_right h_diag hK.le

/-- **R.702 (integrated form).**

Packaging `diag_card_le` with the arithmetic bound: from the diagonal
hypothesis on the finite co-occurrence relation `R ⊆ K × K`, with
`κ = |R| / |K|²` and `K` nonempty, conclude `1/|K| ≤ κ`. -/
theorem R_702_kappa_lower_bound_finset
    {ι : Type} [DecidableEq ι] (K : Finset ι) (R : Finset (ι × ι))
    (h_diag : ∀ ω ∈ K, (ω, ω) ∈ R) (h_ne : K.Nonempty)
    (κ : ℝ) (hκ : κ = (R.card : ℝ) / (K.card : ℝ) ^ 2) :
    1 / (K.card : ℝ) ≤ κ := by
  have hK_pos : (0 : ℝ) < (K.card : ℝ) := by
    exact_mod_cast Finset.card_pos.mpr h_ne
  have h_le : (K.card : ℝ) ≤ (R.card : ℝ) := by
    exact_mod_cast diag_card_le K R h_diag
  exact R_702_kappa_lower_bound (K.card : ℝ) (R.card : ℝ) κ hK_pos h_le hκ

end EntropyPower

end MIP
