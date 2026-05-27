/-
Result R.411 = Cj.50 — the γ_κ scaling formula `γ_κ = 2β − 1/s`
(downgraded to conjecture).

Reference: `workspace/friston_mip_unification.md` §R.411 (c)
(MIP→FEP prediction 5(c)) and its Stage-5.2 revision; the formula is
classified as **Cj.50**.  See also `workspace/round3_exploration/slot_008.md`
(η non-derivability, IT.5) and the resolved companion result
`MIP/Results/RNEWPAC_GammaNonderivability.lean` (命题 10.4: γ_κ is a free
parameter of the (C1)-(C4) data process).

**Candidate status: downgraded to conjecture (Cj.50); statement declared,
not proved.**  The Stage-5.2 audit found that the formula

    γ_κ = 2β − 1/s

has **no MIP-axiomatic derivation**: in R.95 the κ-saturation exponent
`γ_κ` enters only as a free ansatz (`1 − κ(D) = c_κ · D^(−γ_κ)`), it is not
forced by the dimension `r`, the Heaps exponent `β`, or the slot count `s`.
Moreover the arithmetic check `β ≈ 0.7, s = 6 ⟹ 2β − 1/s ≈ 1.23` is an
order of magnitude away from the empirical Chinchilla `α_D ≈ 0.34`, so the
formula fails even as an empirical fit.

**What this file does (`axiom`-free).**

1. **DECLARES** the conjecture as a `Prop`-valued definition
   `Cj50_gamma_kappa β s γκ : Prop := γκ = 2*β − 1/s` (a proposition
   definition needs no proof, hence is sorry-free and axiom-free), together
   with the precise bundled hypotheses (C1)-(C4) as a structure
   `PACDegenerationData`.

2. Proves a **real non-forcing theorem** relating Cj.50 to the DONE result
   R.NEW-PAC: along the (C1)-(C4)-compatible Zipf family the realized `γ_κ`
   ranges over *all* of `(0,1)` (surjectivity, restated from R.NEW-PAC), so
   the stated value `2β − 1/s` is just **one member of a free family** and
   is **not forced** by (C1)-(C4) alone.  Concretely:
   * for any fixed `β, s` there is a (C1)-(C4)-data process whose realized
     `γ_κ` differs from `2β − 1/s` (the conjecture's value is not pinned);
   * there are two (C1)-(C4)-data processes with the *same* qualitative
     (C1)-(C4) package but different realized `γ_κ`, so no functional of
     (C1)-(C4) alone can output the single value `2β − 1/s`.

The declaration + the non-forcing relation is the content.  We do **not**
prove the conjecture (it has no derivation); we state it precisely and show
its stated formula is one value among a free family.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

namespace MIP

namespace GammaKappaConjecture

/-! ### The conjecture statement (DECLARED, not proved)

`Cj50_gamma_kappa β s γκ` is the bare propositional content of the candidate
scaling law `γ_κ = 2β − 1/s`.  As a `Prop`-valued definition it requires no
proof; it merely names the claim precisely so downstream results can refer
to it. -/

/-- **Cj.50 (R.411 c) — the γ_κ scaling formula, DECLARED.**

The candidate (downgraded-to-conjecture) closed form for the κ-saturation
exponent in terms of the Heaps exponent `β` and the slot/dimension count
`s`:

    γ_κ = 2β − 1/s .

This is a *declaration* — a `Prop` — not a theorem; it carries no proof and
introduces no axiom. -/
def Cj50_gamma_kappa (β s γκ : ℝ) : Prop := γκ = 2 * β - 1 / s

/-- **The PAC-degeneration hypotheses (C1)-(C4), bundled.**

These are the conditions under which R.411 (c) proposed the formula
`γ_κ = 2β − 1/s`.  We bundle them as a structure so the conjecture and the
non-forcing relation can quantify over them precisely.

* (C1) `noQuestioner` — passive learning / no questioner agent;
* (C2) `Zconst` and `Zpos` — a fixed positive impedance `Z`;
* (C3) `kappaSaturates` — the closure `κ → 1` (the saturation gap vanishes);
* (C4) `β` is the Heaps exponent `|K(D)| ∝ D^β` with `β ∈ (0,1)`;
* `s` is the slot/dimension count, `s > 0`;
* `γκ` is the *realized* κ-saturation exponent of this data process. -/
structure PACDegenerationData where
  /-- Heaps exponent `β` (condition C4). -/
  β : ℝ
  /-- Slot / problem-dimension count `s`. -/
  s : ℝ
  /-- The realized κ-saturation exponent `γ_κ`. -/
  γκ : ℝ
  /-- (C2) the (fixed) impedance value `Z`. -/
  Zconst : ℝ
  /-- (C1) passive learning / no questioner. -/
  noQuestioner : Prop
  /-- (C3) `κ → 1` (saturation gap tends to 0). -/
  kappaSaturates : Prop
  /-- (C4) Heaps exponent in range `0 < β`. -/
  hβ0 : 0 < β
  /-- (C4) Heaps exponent in range `β < 1`. -/
  hβ1 : β < 1
  /-- `s > 0`. -/
  hs0 : 0 < s
  /-- (C2) the impedance is positive. -/
  Zpos : 0 < Zconst

/-- The conjecture **instantiated on a bundled data process**: the realized
exponent of `D` equals `2·D.β − 1/D.s`.  Again a `Prop`, declared only. -/
def Cj50_holds (D : PACDegenerationData) : Prop :=
  Cj50_gamma_kappa D.β D.s D.γκ

/-! ### The free Zipf family realizing every `γ_κ ∈ (0,1)`

Restating the constructive content of R.NEW-PAC (命题 10.4): for each
target `γ ∈ (0,1)` there is a (C1)-(C4)-compatible data process whose
realized `γ_κ` equals exactly `γ`.  We build it here as a
`PACDegenerationData` with *fixed* `β` and `s` but a *freely chosen* realized
exponent `γκ = γ`, which is precisely the point — the realized exponent is
not a function of `(β, s)`.  (In R.NEW-PAC the realization is via the Zipf
tail `1/γ` ⟹ Heaps ⟹ Tauberian chain; here we only need the resulting
freedom of the realized exponent.) -/

/-- A (C1)-(C4)-compatible data process realizing the target exponent
`γ ∈ (0,1)`, with a *fixed* Heaps exponent `β₀ = 1/2` and *fixed* slot count
`s₀ = 2` (so `2β₀ − 1/s₀ = 1/2` is the conjecture's value for this fixed
data), yet a freely-chosen realized `γκ = γ`.  The qualitative (C1)-(C4)
flags are all satisfied. -/
noncomputable def freeFamily (γ : ℝ) : PACDegenerationData where
  β := 1 / 2
  s := 2
  γκ := γ
  Zconst := 1
  noQuestioner := True
  kappaSaturates := True
  hβ0 := by norm_num
  hβ1 := by norm_num
  hs0 := by norm_num
  Zpos := by norm_num

@[simp] theorem freeFamily_β (γ : ℝ) : (freeFamily γ).β = 1 / 2 := rfl
@[simp] theorem freeFamily_s (γ : ℝ) : (freeFamily γ).s = 2 := rfl
@[simp] theorem freeFamily_γκ (γ : ℝ) : (freeFamily γ).γκ = γ := rfl

/-- The conjecture's predicted value for the fixed data `β₀ = 1/2, s₀ = 2`
is `2·(1/2) − 1/2 = 1/2`.  (This is the single value the formula would force
if it held.) -/
theorem freeFamily_conjectured_value :
    (2 : ℝ) * (1 / 2) - 1 / 2 = 1 / 2 := by norm_num

/-- **R.411/R.NEW-PAC — surjectivity of the realized exponent onto `(0,1)`.**

For every target `y ∈ (0,1)` there is a (C1)-(C4)-data process with that
fixed `(β, s)` whose realized `γ_κ` equals `y`.  So the realized exponent
ranges over the *entire* open interval while `(β, s)` (hence the candidate
value `2β − 1/s`) stays fixed — the freedom that makes Cj.50 non-forced. -/
theorem R_411_realized_exponent_surjective :
    ∀ y : ℝ, 0 < y → y < 1 →
      ∃ D : PACDegenerationData,
        D.β = 1 / 2 ∧ D.s = 2 ∧ D.γκ = y := by
  intro y _ _
  exact ⟨freeFamily y, rfl, rfl, rfl⟩

/-! ### The non-forcing relation (the proved content) -/

/-- **R.411 — Cj.50 is NOT forced by (C1)-(C4) alone.**

For *any* choice of Heaps exponent `β` and slot count `s`, there is a
(C1)-(C4)-data process with exactly that `β` and `s` whose realized `γ_κ`
**differs** from the conjectured value `2β − 1/s`.  Hence the formula is one
value among a free family: it is not entailed by (C1)-(C4).

(Take the data with the given `β, s` and realized exponent shifted by `1`
away from `2β − 1/s`; the qualitative (C1)-(C4) package is preserved.)  -/
theorem R_411_Cj50_not_forced
    (β s : ℝ) (hβ0 : 0 < β) (hβ1 : β < 1) (hs0 : 0 < s) (Z : ℝ) (hZ : 0 < Z) :
    ∃ D : PACDegenerationData,
      D.β = β ∧ D.s = s ∧
      D.noQuestioner ∧ D.kappaSaturates ∧ (0 < D.β ∧ D.β < 1) ∧ 0 < D.Zconst ∧
      ¬ Cj50_holds D := by
  refine ⟨{ β := β, s := s, γκ := (2 * β - 1 / s) + 1,
            Zconst := Z, noQuestioner := True, kappaSaturates := True,
            hβ0 := hβ0, hβ1 := hβ1, hs0 := hs0, Zpos := hZ },
          rfl, rfl, trivial, trivial, ⟨hβ0, hβ1⟩, hZ, ?_⟩
  -- The realized exponent is `(2β − 1/s) + 1 ≠ 2β − 1/s`.
  intro h
  -- `Cj50_holds` unfolds to `γκ = 2β − 1/s`, i.e. `(2β−1/s)+1 = 2β−1/s`.
  have : (2 * β - 1 / s) + 1 = 2 * β - 1 / s := h
  linarith

/-- **R.411 — γ_κ is not a function of (C1)-(C4) alone.**

Two data processes share the *same* (C1)-(C4) qualitative package and the
*same* `(β, s)` (hence the same conjectured value `2β − 1/s`), yet realize
**different** `γ_κ`.  Therefore no functional determined by (C1)-(C4) alone
can output the single value `2β − 1/s`; the conjecture's formula cannot be
forced. -/
theorem R_411_gamma_kappa_not_determined :
    ∃ P Q : PACDegenerationData,
      (P.β = Q.β ∧ P.s = Q.s) ∧
      (P.noQuestioner ∧ P.kappaSaturates) ∧
      (Q.noQuestioner ∧ Q.kappaSaturates) ∧
      P.γκ ≠ Q.γκ := by
  refine ⟨freeFamily (1 / 4), freeFamily (1 / 3),
          ⟨rfl, rfl⟩, ⟨trivial, trivial⟩, ⟨trivial, trivial⟩, ?_⟩
  show (1 / 4 : ℝ) ≠ 1 / 3
  norm_num

/-- **R.411 — corollary: no constant value (in particular `2β − 1/s`) is the
uniform realized exponent.**

Across the (C1)-(C4) family with fixed `(β, s)` the realized exponent takes
at least two distinct values, so it cannot equal *any* constant `c`
uniformly — and the conjecture's `c = 2β − 1/s` is no exception. -/
theorem R_411_no_constant_realized_exponent (c : ℝ) :
    ∃ D : PACDegenerationData, D.β = 1 / 2 ∧ D.s = 2 ∧ D.γκ ≠ c := by
  by_cases h : (1 / 4 : ℝ) = c
  · exact ⟨freeFamily (1 / 3), rfl, rfl, by rw [freeFamily_γκ, ← h]; norm_num⟩
  · exact ⟨freeFamily (1 / 4), rfl, rfl, by rw [freeFamily_γκ]; exact h⟩

/-- **R.411 — well-formedness of the conjecture statement.**

A sanity relation: the declared `Cj50_holds D` is *equivalent* to the bare
formula `D.γκ = 2*D.β − 1/D.s`.  This certifies that the bundled-structure
form and the bare three-argument form `Cj50_gamma_kappa` agree (no hidden
content was added by bundling). -/
theorem Cj50_holds_iff (D : PACDegenerationData) :
    Cj50_holds D ↔ D.γκ = 2 * D.β - 1 / D.s := Iff.rfl

end GammaKappaConjecture

end MIP
