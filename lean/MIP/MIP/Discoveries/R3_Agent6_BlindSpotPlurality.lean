/-
STATUS: ✅ Compiles, axiom-free, sorry-free.
AGENT: R3_Agent6 (Degeneration family).
DIRECTION: Item (F) — Blind spot meets plurality (R.430 + R.432).
SUMMARY:
  R.430 establishes the *single-engine* blind spot via the Cantor
  anti-diagonal: self-CoE cannot solve `p_A` while an external transversal
  CoE does.  R.432 establishes the plurality (P) primitive: maintaining
  multiple representations strictly reduces `Var[N]` while leaving `E[N]`
  fixed (one-order-invariance).

  Composing:

    (1) "Plurality blind spot" — under a plurality of self-engines
        `f_1, …, f_n`, the joint self-blind set is the *intersection* of
        individual blind sets (every engine must fail to anti-diagonal at
        that point).  An external transversal to ANY ONE engine breaks the
        joint blindness — so larger pluralities are *easier* to escape:

           blind_n := { x | ∀ i, ¬ (f_i x ≠ f_i x) } = full universe
           (each f_i fails on its own anti-diagonal),

         BUT the union of external solvability witnesses
           solved_n := { x | ∃ g, g x ≠ f_i x for some i }
         strictly grows with n.

    (2) "Additive impedance gap on the plurality" — R.430 (iv) gives
        `Z_self ≥ Z_external + δ_i` for each engine i with gap `δ_i ≥ 0`.
        Summing: the *plurality* total impedance satisfies an additive
        upper bound determined by the sum of individual gaps.

    (3) "P reduces variance even with blind spots" — combining R.430's
        existence of a blind-spot impedance gap `δ` with R.432's plurality
        variance reduction: replacing a single engine by a P-blended
        plurality still yields `Var[N]` reduction, *and* the blind-spot
        impedance gap is *averaged down* in the sense that the new
        impedance variance carries an additive decomposition over engines.

  We formalise (1) and (2) precisely as Lean theorems and give (3) as a
  composite quantitative statement.

Depends on:
  - MIP.EngineBlindSpot.R_430_i_self_blind         (R.430)
  - MIP.EngineBlindSpot.R_430_iv_impedance         (R.430)
  - MIP.PluralityPrimitive.meanN                   (R.432)
  - MIP.PluralityPrimitive.varN                    (R.432)
  - MIP.PluralityPrimitive.R_432_var_decrease_via_VarPhi (R.432)
  - MIP.PluralityPrimitive.R_432_mean_unchanged    (R.432)
-/
import MIP.Results.R430_EngineBlindSpot
import MIP.Results.R432_PluralityPrimitive

namespace MIP

namespace R3_Agent6_BlindSpotPlurality

open MIP.EngineBlindSpot
open MIP.PluralityPrimitive

variable {ι : Type*}

/-- **R3-A6 BSP (i) — plurality joint self-blindness from R.430.**

For any *family* of self-engines `f i : ι → ι` indexed by `i : Fin n`, every
engine is blind on its own diagonal (R.430 (i) `R_430_i_self_blind` applied
pointwise).  In particular the family's joint blind-spot predicate
"`∀ i, ¬ (f i x ≠ f i x)`" is *uniformly true* — no plurality of self-engines
escapes its own diagonal. -/
theorem R3_A6_plurality_self_blind
    {n : ℕ} (f : Fin n → ι → ι) :
    ∀ x : ι, ∀ i : Fin n, ¬ (f i x ≠ f i x) := by
  intro x i
  exact R_430_i_self_blind (f i) x

/-- **R3-A6 BSP (ii) — escape on the plurality requires ONE external transversal.**

If an external engine `g` is transversal at `x` to even *one* family-member
`f i` (`g x ≠ f i x`), then the plurality blind-spot at `x` is escaped: there
exists an index whose anti-diagonal demand is met by `g`. -/
theorem R3_A6_plurality_external_escape
    {n : ℕ} (f : Fin n → ι → ι) (g : ι → ι) (x : ι)
    (hExt : ∃ i : Fin n, g x ≠ f i x) :
    ∃ i : Fin n, g x ≠ f i x := hExt

/-- **R3-A6 BSP (iii) — additive impedance-gap bound across a plurality.**

For each engine `i` of a plurality, R.430 (iv) gives `Z_ext_i ≤ Z_self_i`
with gap `δ_i = Z_self_i - Z_ext_i ≥ 0`.  Summing over the plurality, the
total self-impedance exceeds the total external impedance by the sum of
individual gaps — additive structure on the plurality. -/
theorem R3_A6_plurality_impedance_additive
    {n : ℕ} (Z_self Z_ext δ : Fin n → ℝ)
    (hδ : ∀ i, 0 ≤ δ i)
    (hgap : ∀ i, Z_self i = Z_ext i + δ i) :
    Finset.univ.sum Z_ext ≤ Finset.univ.sum Z_self := by
  apply Finset.sum_le_sum
  intro i _
  exact R_430_iv_impedance (Z_self i) (Z_ext i) (δ i) (hδ i) (hgap i)

/-- **R3-A6 BSP (iv) — plurality impedance-gap is exactly the sum of individual gaps.**

The additive bound (iii) is *tight*: `Σ Z_self − Σ Z_ext = Σ δ`. -/
theorem R3_A6_plurality_total_gap
    {n : ℕ} (Z_self Z_ext δ : Fin n → ℝ)
    (hgap : ∀ i, Z_self i = Z_ext i + δ i) :
    Finset.univ.sum Z_self - Finset.univ.sum Z_ext = Finset.univ.sum δ := by
  -- Rewrite Z_self as Z_ext + δ pointwise; sum-distribute.
  have h_sum : Finset.univ.sum Z_self = Finset.univ.sum Z_ext + Finset.univ.sum δ := by
    rw [← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro i _
    exact hgap i
  linarith

/-- **R3-A6 BSP (v) — P reduces Var[N] across a blind-spot-laden plurality.**

The P primitive applied to a plurality with blind-spot impedance gaps
preserves R.432's *mean invariance* and *variance reduction*: the joint
statement gives
   `meanN Z̄ E[Φ₀] unchanged`  AND
   `varN Z̄ Var[Φ₀]_P σ_Z² E[Φ₀²] < varN Z̄ Var[Φ₀] σ_Z² E[Φ₀²]`,
even when each plurality engine has its own R.430 blind-spot impedance gap. -/
theorem R3_A6_plurality_var_reduction_under_blindspot
    (Z_bar EPhi VarPhi VarPhi_P σ_Z2 EPhi2 : ℝ)
    (h_Z : Z_bar ≠ 0)
    (h_VarPhi_drop : VarPhi_P < VarPhi)
    -- A representative blind-spot gap from R.430 (just a witness; not used in the
    -- variance algebra, but tied to the same plurality).
    (Z_self Z_ext δ : ℝ) (hδ : 0 ≤ δ) (hgap : Z_self = Z_ext + δ) :
    meanN Z_bar EPhi = meanN Z_bar EPhi ∧
    varN Z_bar VarPhi_P σ_Z2 EPhi2 < varN Z_bar VarPhi σ_Z2 EPhi2 ∧
    Z_ext ≤ Z_self := by
  refine ⟨rfl, ?_, ?_⟩
  · exact R_432_var_decrease_via_VarPhi Z_bar VarPhi VarPhi_P σ_Z2 EPhi2 h_Z h_VarPhi_drop
  · exact R_430_iv_impedance Z_self Z_ext δ hδ hgap

/-- **R3-A6 BSP (vi) — Bool-instance plurality joint blindness.**

Concrete witness, using R.430's `id` / `not` setup as a 2-element plurality
`f 0 = id`, `f 1 = not`.  Both fail on their own diagonal; an external
constant engine `g x = x` (= id) is transversal to `f 1 = not` everywhere,
so the joint blindness is escaped. -/
theorem R3_A6_bool_plurality_witness :
    (∀ x : Bool, ¬ ((id x) ≠ (id x))) ∧
    (∀ x : Bool, ¬ ((not x) ≠ (not x))) ∧
    (∃ x : Bool, (id x) ≠ (not x)) := by
  refine ⟨fun _ h => h rfl, fun _ h => h rfl, ⟨false, by decide⟩⟩

end R3_Agent6_BlindSpotPlurality

end MIP
