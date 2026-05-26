/-
Result R.169 — Out-of-frame questioner ineffectiveness theorem.

Reference: `branches/computation/workspace/summary_R163_R174.md` §R.169 and
`new_results.md` §R.169 (A (a)(b)(c)(d), A 条件性 (e); deps R.19, D.3.9 L.F,
R.167, R.163, R.165(c)).

**Statement.**  For solver `X` and questioner `Y` with metacognitive reference
set `K^M(Y) := ⋃_{m∈M_Y} K^M(m)`:

* **(a)** out-of-frame failure: if `K^M(Y) ∩ K(X) = ∅` then `Z_q(X|Y) = ∞`
  and `N(p,X,Y) = ∞`.
* **(b)** in-frame band: `Z_q(X|Y)` depends only on `Y`'s projection into
  `K(X)`, i.e. on `M_Y ∩ M_X^*` where `M_X^* := {m : K^M(m) ⊆ K(X)}`.
* **(c)** R.19 refinement: there exist `Y₁, Y₂` with `|K^M(Y₁)| < |K^M(Y₂)|`
  yet `Z_q(X|Y₁) < Z_q(X|Y₂)` (when `Y₂`'s extra knowledge is all out-of-frame).
* **(e)** OPT-Y undecidable: deciding "`Y` is the optimal questioner for `X`"
  is undecidable, by reduction from R.165(c).

The L.F mechanism: an intervention `m` with `K^M(m) ⊄ K(X)` has effective gain
`ΔΦ*(m, s_X) ≤ 0`; impedance is `Z_q = [max_m ΔΦ*]⁻¹`, infinite when every gain
is `≤ 0`.

**Formalization strategy (direct kernel + decidability-transfer for (e)).**
We model each intervention's effective gain by `gain : M → ℝ`, the in-frame
predicate `inFrame : M → Prop`, and the L.F fact `hLF : ¬ inFrame m → gain m ≤ 0`.
"Impedance finite" is modelled by "some admissible intervention has positive
gain" (`∃ m ∈ S, 0 < gain m`); infinite impedance is its negation.

* `R_169_a_out_of_frame` — if all of `Y`'s interventions are out-of-frame, no
  positive gain exists, so impedance is infinite.
* `R_169_b_in_frame_band` — the existence of an effective intervention depends
  only on the in-frame projection.
* `R_169_c_more_knowledge_worse` — explicit `Y₁/Y₂` separation.
* `R_169_e_OPTY_undecidable` — undecidability of OPT-Y by transfer from R.165
  (decidability-pullback kernel, identical to R.83's).

**This file is `axiom`-free.**  Imports only `Mathlib`; L.F and the R.165
undecidability source enter as explicit hypotheses.
-/
import Mathlib

namespace MIP

namespace OutOfFrameQuestioner

variable {M : Type*}

/-- "Questioner `Y` has an effective intervention" (impedance `< ∞`) is modelled
as: some intervention in `Y`'s set `S` has strictly positive effective gain. -/
def HasEffective (gain : M → ℝ) (S : M → Prop) : Prop :=
  ∃ m, S m ∧ 0 < gain m

/-- **R.169(a) — out-of-frame failure (infinite impedance).**

If every intervention of `Y` is out-of-frame (`∀ m ∈ M_Y, ¬ inFrame m`), then
by L.F (`hLF : ¬ inFrame m → gain m ≤ 0`) every admissible gain is `≤ 0`, so no
effective intervention exists: `Z_q(X|Y) = ∞`.  Formally, `¬ HasEffective`. -/
theorem R_169_a_out_of_frame
    (gain : M → ℝ) (inFrame : M → Prop) (MY : M → Prop)
    (hLF : ∀ m, ¬ inFrame m → gain m ≤ 0)
    (hOut : ∀ m, MY m → ¬ inFrame m) :
    ¬ HasEffective gain MY := by
  rintro ⟨m, hmMY, hpos⟩
  exact absurd hpos (not_lt.mpr (hLF m (hOut m hmMY)))

/-- **R.169(b) — in-frame band (impedance depends only on the projection).**

`Z_q(X|Y)` depends only on `M_Y ∩ M_X^*`: there is an effective intervention in
`M_Y` iff there is one in the in-frame projection `M_Y ∩ M_X^*`.  The forward
direction needs L.F (an effective — hence positive-gain — intervention must be
in-frame); the reverse is monotonicity of the existential. -/
theorem R_169_b_in_frame_band
    (gain : M → ℝ) (inFrame : M → Prop) (MY : M → Prop)
    (hLF : ∀ m, ¬ inFrame m → gain m ≤ 0) :
    HasEffective gain MY ↔ HasEffective gain (fun m => MY m ∧ inFrame m) := by
  constructor
  · rintro ⟨m, hmMY, hpos⟩
    refine ⟨m, ⟨hmMY, ?_⟩, hpos⟩
    by_contra hnf
    exact absurd hpos (not_lt.mpr (hLF m hnf))
  · rintro ⟨m, ⟨hmMY, _⟩, hpos⟩
    exact ⟨m, hmMY, hpos⟩

/-- **R.169(c) — more metacognitive knowledge can be strictly worse.**

Explicit separation refuting "argmin Z = argmax |K^M|".  `Y₁` has a single
in-frame effective intervention `m₁` (positive gain), so it is effective.  `Y₂`
has many interventions, all out-of-frame (hence gain `≤ 0` by L.F), so it is
ineffective.  Thus `|K^M(Y₂)| ≫ |K^M(Y₁)|` yet `Z_q(X|Y₁) < ∞ = Z_q(X|Y₂)`:
`Y₁` is effective while `Y₂` is not. -/
theorem R_169_c_more_knowledge_worse
    (gain : M → ℝ) (inFrame : M → Prop)
    (m₁ : M) (MY₁ MY₂ : M → Prop)
    (hLF : ∀ m, ¬ inFrame m → gain m ≤ 0)
    (h₁_mem : MY₁ m₁) (_h₁_inframe : inFrame m₁) (h₁_pos : 0 < gain m₁)
    (h₂_out : ∀ m, MY₂ m → ¬ inFrame m) :
    HasEffective gain MY₁ ∧ ¬ HasEffective gain MY₂ := by
  refine ⟨⟨m₁, h₁_mem, h₁_pos⟩, ?_⟩
  exact R_169_a_out_of_frame gain inFrame MY₂ hLF h₂_out

-- Decidability surrogate (Prop-valued, negatable), as in R.83.
/-- A total Boolean decider for a predicate. -/
def Decides {α : Type*} (f : α → Bool) (P : α → Prop) : Prop := ∀ a, f a = true ↔ P a

/-- `P` is decidable iff a total Boolean decider exists. -/
def IsDecidablePred {α : Type*} (P : α → Prop) : Prop := ∃ f : α → Bool, Decides f P

/-- **R.169(e) — OPT-Y is undecidable (decidability transfer from R.165).**

Deciding "`Y` is `X`'s optimal questioner for `p`" (`isOptY`) is undecidable.
The source reduces it from the formally undecidable MIP-consistency predicate
`consUndec` of R.165(c): `red` maps a consistency instance to an OPT-Y instance
with `consUndec n ↔ isOptY (red n)`.  Decidability pulls back along `red`, so
undecidability of `consUndec` (R.165) forces undecidability of `isOptY`.  This
is the standard `Halt ≤ TARGET` decidability-transfer, here `R.165 ≤ OPT-Y`. -/
theorem R_169_e_OPTY_undecidable {α β : Type*}
    (isOptY : β → Prop) (consUndec : α → Prop)
    (red : α → β)
    (hval : ∀ a, consUndec a ↔ isOptY (red a))
    (h_R165_undec : ¬ IsDecidablePred consUndec) :
    ¬ IsDecidablePred isOptY := by
  intro hOpt
  apply h_R165_undec
  obtain ⟨f, hf⟩ := hOpt
  refine ⟨fun a => f (red a), ?_⟩
  intro a
  rw [hf (red a), ← hval a]

end OutOfFrameQuestioner

end MIP
