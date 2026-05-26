/-
Result R.167 — Quantitative separation of self- vs external impedance
(`Z_self = ∞`, `Z_external < ∞` on the blind-spot family).

Reference: `branches/computation/workspace/summary_R163_R174.md` §R.167 and
`new_results.md` §R.167 (A 无穷比 + B/A 条件多项式比, deps R.86, R.101,
D.3.9 (P3) Ohm relation, L.F).

**Statement (the A-level infinite-ratio core).**  For the enumerable blind-
spot family `{p_{A,k}}` of R.101:

    Z_self(A, p_{A,k}) = ∞      (A guiding itself fails: N(p_{A,k}, A, A) = ∞)
    Z_external(A, p_{A,k}) < ∞  (some external A' succeeds: N(p_{A,k}, A, A') < ∞)

so the impedance ratio `Z_self / Z_external = ∞` for every `k`.  The bridge is
the dual-impedance Ohm relation (D.3.9 P3): in the Ohm regime `N ≈ Φ₀ · Z`
with `Φ₀ ∈ (0, ∞)`, finiteness of `N` is equivalent to finiteness of `Z`, and
`N = ∞ ⟺ Z = ∞` (with the convention that `max ΔΦ* ≤ 0`, i.e. no effective
self-intervention, gives `Z = ∞`).

**Formalization strategy (direct kernel in `ℕ∞`).**  We model the emergence
costs `N_self, N_ext : ℕ∞` and impedances `Z_self, Z_ext : ℕ∞`, and bundle the
Ohm equivalence `N = ∞ ↔ Z = ∞` (the finiteness-transfer half of D.3.9 P3,
valid for `0 < Φ₀ < ∞`) as a hypothesis.  The genuine content is:

* `R_167_Zself_infinite` — `N_self = ∞ ⟹ Z_self = ∞`;
* `R_167_Zext_finite` — `N_ext < ∞ ⟹ Z_ext < ∞`;
* `R_167_separation` — the two together give the strict separation
  `Z_ext < Z_self` (`Z_self = ⊤`, `Z_ext < ⊤`), i.e. the infinite ratio.

We additionally record the source's "max of a non-positive impedance-gain set
forces infinite impedance" mechanism on `EReal` (`R_167_max_nonpos_impedance`).

**This file is `axiom`-free.**  Imports only `Mathlib`; the Ohm finiteness
equivalence and the R.101 blind-spot facts enter as explicit hypotheses.
-/
import Mathlib

namespace MIP

namespace SelfExternalImpedance

open scoped ENNReal

/-- **R.167 — self-impedance is infinite (from `N_self = ∞` via Ohm).**

In the Ohm regime the finiteness of the dual impedance tracks the finiteness of
the emergence cost (`hOhm_self : N_self = ⊤ ↔ Z_self = ⊤`).  Since R.101 gives
`N(p_{A,k}, A, A) = ∞` (`hN_self : N_self = ⊤`), the self-impedance diverges. -/
theorem R_167_Zself_infinite
    (N_self Z_self : ℕ∞)
    (hOhm_self : N_self = ⊤ ↔ Z_self = ⊤)
    (hN_self : N_self = ⊤) :
    Z_self = ⊤ :=
  hOhm_self.mp hN_self

/-- **R.167 — external impedance is finite (from `N_ext < ∞` via Ohm).**

Symmetrically, R.101 supplies an external questioner `A'` with
`N(p_{A,k}, A, A') < ∞` (`hN_ext : N_ext < ⊤`); the Ohm equivalence
`hOhm_ext : N_ext = ⊤ ↔ Z_ext = ⊤` then forces `Z_ext < ⊤`. -/
theorem R_167_Zext_finite
    (N_ext Z_ext : ℕ∞)
    (hOhm_ext : N_ext = ⊤ ↔ Z_ext = ⊤)
    (hN_ext : N_ext < ⊤) :
    Z_ext < ⊤ := by
  rw [lt_top_iff_ne_top] at hN_ext ⊢
  intro hZ
  exact hN_ext (hOhm_ext.mpr hZ)

/-- **R.167 — quantitative separation `Z_external < Z_self` (main theorem).**

Combining the two halves over the same blind-spot problem `p_{A,k}`:
`Z_self = ∞` while `Z_external < ∞`, hence `Z_external < Z_self`.  This is the
strict (in fact infinite-ratio) separation — A's self-metacognition can never
overcome these blind spots, but an external questioner can. -/
theorem R_167_separation
    (N_self N_ext Z_self Z_ext : ℕ∞)
    (hOhm_self : N_self = ⊤ ↔ Z_self = ⊤)
    (hOhm_ext : N_ext = ⊤ ↔ Z_ext = ⊤)
    (hN_self : N_self = ⊤)
    (hN_ext : N_ext < ⊤) :
    Z_ext < Z_self := by
  have hZself : Z_self = ⊤ := R_167_Zself_infinite N_self Z_self hOhm_self hN_self
  have hZext : Z_ext < ⊤ := R_167_Zext_finite N_ext Z_ext hOhm_ext hN_ext
  rw [hZself]; exact hZext

/-- **R.167 — the impedance ratio is infinite.**

Phrased as: `Z_self = ⊤` and `Z_ext ≠ ⊤`.  Any finite multiple of the external
impedance stays below the (infinite) self-impedance — the "ratio `= ∞`"
statement, faithful to "collaboration reduces impedance by an unbounded
factor". -/
theorem R_167_infinite_ratio
    (N_self N_ext Z_self Z_ext : ℕ∞)
    (hOhm_self : N_self = ⊤ ↔ Z_self = ⊤)
    (hOhm_ext : N_ext = ⊤ ↔ Z_ext = ⊤)
    (hN_self : N_self = ⊤)
    (hN_ext : N_ext < ⊤) :
    Z_self = ⊤ ∧ Z_ext ≠ ⊤ := by
  refine ⟨R_167_Zself_infinite N_self Z_self hOhm_self hN_self, ?_⟩
  have := R_167_Zext_finite N_ext Z_ext hOhm_ext hN_ext
  exact ne_of_lt this

/-- **R.167 — L.F mechanism: a non-positive maximal impedance-gain forces
infinite impedance.**

The source's D.3.9 convention: `Z_q = [max_m ΔΦ*(m, s)]⁻¹`, and when every
admissible intervention has `ΔΦ* ≤ 0` (all out-of-frame, by L.F) the maximal
gain `g ≤ 0`, so the impedance is `+∞`.  We record this on `EReal`: if the
maximal effective gain `g` is `≤ 0` then its reciprocal-as-impedance is `⊤`
(modelled by the convention map `impedanceOfGain` with
`impedanceOfGain g = ⊤` whenever `g ≤ 0`). -/
theorem R_167_max_nonpos_impedance
    (impedanceOfGain : EReal → EReal)
    (hconv : ∀ g : EReal, g ≤ 0 → impedanceOfGain g = ⊤)
    (g : EReal) (hg : g ≤ 0) :
    impedanceOfGain g = ⊤ :=
  hconv g hg

end SelfExternalImpedance

end MIP
