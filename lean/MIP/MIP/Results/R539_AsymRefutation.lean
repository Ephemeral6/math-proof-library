/-
Result R.539 — Cj.55 (Asym ≥ W₁) Asym-series refutation supplement
(duality D.4.15 Asym  vs  optimal_transport R.141-R.146 Wasserstein).

Reference: `workspace/round3_exploration/slot_028.md` (slot 028, "Cj.55
否证 + Asym ↔ W₁ 桥梁修正"),  `workspace/round3_exploration/work_slot_028.md`
§3 (R.NEW-1: universal Cj.55 refuted by `A₁ = δ_{x₁}, A₂ = δ_{x₂}`, giving
`Asym = 0 < W₁ = 1`) and §7 (R.148.b strict counterexample `(p₃, A₇, A₈)`:
`Z_{A₇}(b) = Z_{A₈}(b)` so `Asym = 0`, while the natural output measures are
supported on disjoint solution sets so `W₁^{Hamming} = 2/3 > 0`).

**Candidate status: Round-3 autonomous exploration, not yet
human-audited.**

**The conjecture being refuted.**  Cj.55 claims a *universal* bound

    Asym(p, A, H)  ≥  W₁^d(μ_A, μ_H)    for every  p, A, H  and metric d.

Here `Asym(p,A,H) = Σ_{b∈B(p)} Φ(b)·|Z_A(b) − Z_H(b)|` is the D.4.15 weighted
L¹ cost-asymmetry, while `W₁^d(μ_A, μ_H)` is the 1-Wasserstein distance of the
zero-intervention output distributions.

**The refutation kernel (formalized).**  We exhibit a concrete configuration
in which the left side is `0` but the right side is strictly positive, so the
universal inequality is false.

* **(R.539-Asym0)** `Asym = 0` whenever the two agents share their per-barrier
  impedance, `Z_A(b) = Z_H(b)` for all `b ∈ B(p)` — every summand
  `Φ(b)·|Z_A(b) − Z_H(b)|` vanishes.  (This covers both the §3 degenerate
  case `B(p) = ∅` and the §7 Type-S case `Z_{A₇} = Z_{A₈}`.)
* **(R.539-W1pos)** For two Dirac output measures `δ_{x₁}, δ_{x₂}` the
  1-Wasserstein cost under a ground metric `d` is the ground distance
  `W₁ = d(x₁, x₂)`; when `x₁ ≠ x₂` and `d` is a genuine metric this is
  strictly positive.
* **(R.539-refute)** Combining the two with a witnessing configuration gives
  `Asym = 0 < W₁`, contradicting `Asym ≥ W₁`.  Hence Cj.55 is **false**
  (A-unconditional: the construction uses only the definitions of `Asym`,
  `W₁` of Dirac masses, and a metric's positivity on distinct points).

**Bundled OT fact (entered as an explicit hypothesis, NOT built here).**  Per
the project HYPOTHESIS-BUNDLE convention, the optimal-transport value of the
two-point coupling enters as a hypothesis `hW1 : W1 = d x₁ x₂` (the unique
coupling of two Dirac masses is the product, with transport cost `d(x₁,x₂)`).

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.Ring.Abs
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

open scoped BigOperators

namespace AsymRefutation

variable {ι α : Type*}

/-- The D.4.15 cognitive asymmetry as a weighted L¹ functional over the finite
barrier set `s`:  `Asym := Σ_{b∈s} Φ(b)·|Z_A(b) − Z_H(b)|`.  (Same form as
`AsymWassersteinBridge.Asym`; restated locally for self-containment.) -/
noncomputable def Asym (s : Finset ι) (Φ ZA ZH : ι → ℝ) : ℝ :=
  ∑ b ∈ s, Φ b * |ZA b - ZH b|

/-- **R.539-Asym0 — equal impedances force `Asym = 0`.**

If the two agents have the same per-barrier impedance `Z_A(b) = Z_H(b)` on
every barrier `b ∈ s`, then each summand `Φ(b)·|Z_A(b) − Z_H(b)| = Φ(b)·0`
vanishes, so `Asym = 0`.  This is the §3/§7 "Type-S, `Asym = 0`" half of the
counterexample, valid for any weights `Φ`. -/
theorem R_539_Asym_eq_zero
    (s : Finset ι) (Φ ZA ZH : ι → ℝ)
    (hZ : ∀ b ∈ s, ZA b = ZH b) :
    Asym s Φ ZA ZH = 0 := by
  unfold Asym
  apply Finset.sum_eq_zero
  intro b hb
  rw [hZ b hb]
  simp

/-- **R.539-Asym0 (empty-barrier corollary).**

The §3 degenerate witness `A₁ = δ_{x₁}, A₂ = δ_{x₂}` has empty independent
barrier set `B(p) = ∅`; the empty sum is `0`. -/
theorem R_539_Asym_empty (Φ ZA ZH : ι → ℝ) :
    Asym (∅ : Finset ι) Φ ZA ZH = 0 := by
  simp [Asym]

/-- **R.539-W1pos — the 1-Wasserstein cost of two Dirac masses is the ground
distance, hence positive for distinct points.**

The only coupling of `δ_{x₁}` and `δ_{x₂}` is the product `δ_{(x₁,x₂)}`, with
transport cost `d(x₁, x₂)` (bundled as `hW1`).  For a genuine metric `d`
(positive off the diagonal, `hpos`) and distinct points `x₁ ≠ x₂`, this cost
is strictly positive. -/
theorem R_539_W1_pos
    (d : α → α → ℝ) (x₁ x₂ : α) (W1 : ℝ)
    (hW1 : W1 = d x₁ x₂)
    (hpos : ∀ a b : α, a ≠ b → 0 < d a b)
    (hne : x₁ ≠ x₂) :
    0 < W1 := by
  rw [hW1]; exact hpos x₁ x₂ hne

/-- **R.539-refute — Cj.55 (`Asym ≥ W₁`) is FALSE (A-unconditional).**

Witnessing configuration: equal per-barrier impedances (`hZ`, so `Asym = 0`)
together with distinct Dirac output points under a genuine metric (`hW1`,
`hpos`, `hne`, so `W₁ > 0`).  Then `Asym = 0 < W₁`, which **contradicts** the
conjectured universal bound `Asym ≥ W₁`.  We package the refutation as: the
universal hypothesis `hCj : Asym ≥ W₁` is impossible under the witness.

This is the slot's refutation kernel: a concrete instance where the conjectured
Asym lower bound on `W₁` fails. -/
theorem R_539_refute_Cj55
    (s : Finset ι) (Φ ZA ZH : ι → ℝ)
    (d : α → α → ℝ) (x₁ x₂ : α) (W1 : ℝ)
    (hZ : ∀ b ∈ s, ZA b = ZH b)
    (hW1 : W1 = d x₁ x₂)
    (hpos : ∀ a b : α, a ≠ b → 0 < d a b)
    (hne : x₁ ≠ x₂)
    (hCj : W1 ≤ Asym s Φ ZA ZH) :  -- the conjectured Cj.55 bound
    False := by
  have hA : Asym s Φ ZA ZH = 0 := R_539_Asym_eq_zero s Φ ZA ZH hZ
  have hW : 0 < W1 := R_539_W1_pos d x₁ x₂ W1 hW1 hpos hne
  rw [hA] at hCj
  linarith

/-- **R.539-refute (positive form) — there is a witness with `Asym < W₁`.**

The strict separation `Asym(p,A,H) < W₁^d(μ_A, μ_H)` holds at the witness, so
no universal `Asym ≥ W₁` can be true.  This is the contrapositive-free
statement of the refutation, matching the boxed
`Asym = 0 < W₁` of work_slot_028 §3.5 / §7.4. -/
theorem R_539_strict_separation
    (s : Finset ι) (Φ ZA ZH : ι → ℝ)
    (d : α → α → ℝ) (x₁ x₂ : α) (W1 : ℝ)
    (hZ : ∀ b ∈ s, ZA b = ZH b)
    (hW1 : W1 = d x₁ x₂)
    (hpos : ∀ a b : α, a ≠ b → 0 < d a b)
    (hne : x₁ ≠ x₂) :
    Asym s Φ ZA ZH < W1 := by
  have hA : Asym s Φ ZA ZH = 0 := R_539_Asym_eq_zero s Φ ZA ZH hZ
  have hW : 0 < W1 := R_539_W1_pos d x₁ x₂ W1 hW1 hpos hne
  rw [hA]; exact hW

/-! ### Concrete numeric witness — R.148.b §7.4 `(p₃, A₇, A₈)` -/

/-- The Hamming ground metric on the symbol space `Fin 5` (encoding
`{"a","b","c","d","0"}` of §7.4): `d(x,y) = 0` if `x = y`, else `1`. -/
noncomputable def hamming : Fin 5 → Fin 5 → ℝ :=
  fun x y => if x = y then 0 else 1

/-- The Hamming metric is positive off the diagonal. -/
theorem hamming_pos (a b : Fin 5) (h : a ≠ b) : 0 < hamming a b := by
  unfold hamming; rw [if_neg h]; norm_num

/-- **R.539 (concrete §7.4 witness) — `Asym = 0 < W₁` for `(p₃, A₇, A₈)`.**

The §7.4 construction has a single shared barrier `b₊` with equal impedances
`Z_{A₇}(b₊) = Z_{A₈}(b₊) = 1/log(3/2)`, so `Asym = 0`; the natural output
measures put their mass on disjoint solutions (`A₇` on `"a","b"`, `A₈` on
`"c","d"`), so under the Hamming metric the two single-point witnesses
`x₁ = "a" (= 0)`, `x₂ = "c" (= 2)` are distinct and `W₁ ≥ d("a","c") = 1 > 0`.
We instantiate `R_539_strict_separation` at this concrete data, with the
single-barrier set `{b₊}` (modelled as `({0} : Finset (Fin 1))`) and shared
impedance value `z`. -/
theorem R_539_witness_7_4 (Φ : Fin 1 → ℝ) (z : ℝ) :
    Asym ({0} : Finset (Fin 1)) Φ (fun _ => z) (fun _ => z)
      < (1 : ℝ) := by
  have hsep := R_539_strict_separation
    ({0} : Finset (Fin 1)) Φ (fun _ => z) (fun _ => z)
    hamming (0 : Fin 5) (2 : Fin 5) (hamming 0 2)
    (by intro b _; rfl)              -- equal impedances ⇒ Asym = 0
    rfl                              -- W₁ = d(x₁, x₂)
    hamming_pos                      -- metric positive off diagonal
    (by intro h; exact absurd (Fin.val_eq_of_eq h) (by norm_num)) -- 0 ≠ 2
  -- d("a","c") = hamming 0 2 = 1
  have hne02 : (0 : Fin 5) ≠ 2 := by
    intro h; exact absurd (Fin.val_eq_of_eq h) (by norm_num)
  have : hamming (0 : Fin 5) 2 = 1 := by unfold hamming; rw [if_neg hne02]
  rwa [this] at hsep

end AsymRefutation

end MIP
