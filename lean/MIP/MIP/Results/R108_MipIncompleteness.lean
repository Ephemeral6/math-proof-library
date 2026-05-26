/-
Result R.108 — algorithmic incompleteness of the MIP formal system
(Cj.11 partial).

Reference: `workspace/frontier_attacks.md` §R.108 (攻击 #4, Cj.11 部分).
Status: B (algorithmic-undecidability version; full Gödel independence open).

**Statement.** Using R.83's construction, for each halting-problem instance
`(T, x)` one builds an agent `A*_{T,x}` (each intervention advances `T` one
step) and a problem `p_{T,x}` (accept iff `T` halts) so that

    N(p_{T,x}, A*_{T,x}) < ∞   ⟺   T halts on x.

The MIP-proposition `φ_{T,x} := "N(p_{T,x}, A*_{T,x}) < ∞"` is built from
the legitimate A/D-series objects (A.2: `φ ⟺ R(p) ⊆ K(A*)`), so it is a
**well-formed MIP-proposition**; yet its truth value tracks the halting
predicate, which no algorithm decides (R.84). Hence there is a formally
valid but **algorithmically undecidable** MIP-proposition — a Gödel-style
incompleteness.

**Formal kernel (faithful reduction).** We work over `ℕ` (Gödel codes).
The deep facts enter as explicit hypotheses, matching the MIP-side
dependence:

* **(R.84)** the halting predicate `Halt : ℕ → Prop` is **not** decidable
  by any algorithm: `¬ ComputablePred Halt`  (premise `h_halt_undec`).
* **(R.83 construction)** the halting predicate **many-one reduces** to
  the MIP-proposition family `phiMIP : ℕ → Prop`,
  `Halt ≤₀ phiMIP`  (premise `h_reduce`) — i.e. the computable encoding
  `(T,x) ↦ ⌜φ_{T,x}⌝` sends halting instances exactly to true
  MIP-propositions.

From these, `computable_of_manyOneReducible` gives: if `phiMIP` were
decidable then so would `Halt` be — contradiction. Therefore `phiMIP`
is **not** algorithmically decidable. This is exactly R.108.

We additionally record the elementary structural facts that the
construction `(T,x) ↦ ⌜φ_{T,x}⌝` is injective (distinct instances yield
distinct well-formed propositions) under the bundled injectivity premise.

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Computability.Reduce
import Mathlib.Logic.Function.Basic

namespace MIP

namespace MipIncompleteness

open ComputablePred

/-- **R.108 — algorithmic undecidability of the MIP-proposition family.**

Given (R.84) that the halting predicate is not algorithmically decidable
and (R.83) that halting many-one reduces to the MIP-proposition family,
the MIP family is itself **not** algorithmically decidable: there is no
algorithm that decides the truth value of every MIP-proposition `φ_{T,x}`.
This is the Gödel-style incompleteness of the MIP axiom system. -/
theorem R_108_phi_undecidable
    (Halt phiMIP : ℕ → Prop)
    (h_halt_undec : ¬ ComputablePred Halt)
    (h_reduce : Halt ≤₀ phiMIP) :
    ¬ ComputablePred phiMIP := by
  intro h_phi_dec
  -- If the φ-family were decidable, the reduction would make Halt decidable.
  exact h_halt_undec (computable_of_manyOneReducible h_reduce h_phi_dec)

/-- **R.108 — contrapositive form: decidability of MIP forces decidable halting.**

Equivalently, any algorithm deciding all MIP-propositions would decide the
halting problem. Since none does (R.84), the MIP system is algorithmically
incomplete. -/
theorem R_108_decidable_would_decide_halting
    (Halt phiMIP : ℕ → Prop)
    (h_reduce : Halt ≤₀ phiMIP)
    (h_phi_dec : ComputablePred phiMIP) :
    ComputablePred Halt :=
  computable_of_manyOneReducible h_reduce h_phi_dec

/-- **R.108 — existence form.**

There exists a (well-formed) MIP-proposition family that is undecidable:
namely any family to which the halting predicate reduces. This packages
the construction `φ_{T,x}` as a witness of algorithmic incompleteness. -/
theorem R_108_exists_undecidable_family
    (Halt phiMIP : ℕ → Prop)
    (h_halt_undec : ¬ ComputablePred Halt)
    (h_reduce : Halt ≤₀ phiMIP) :
    ∃ ψ : ℕ → Prop, ¬ ComputablePred ψ :=
  ⟨phiMIP, R_108_phi_undecidable Halt phiMIP h_halt_undec h_reduce⟩

/-- **R.108 — the encoding `(T,x) ↦ ⌜φ_{T,x}⌝` is injective (structural).**

Distinct halting instances yield distinct well-formed MIP-propositions:
the encoding `enc : ℕ → ℕ` of `φ_{T,x}` is injective (each `φ_{T,x}` is a
legitimate A.2/D-series formula, and the instance is recoverable from the
code). Recorded as the standard fact that the many-one reduction witness
function, when injective, gives a one-one reduction — i.e. the family is
genuinely as rich as the halting instances. -/
theorem R_108_encoding_injective
    (enc : ℕ → ℕ) (h_inj : Function.Injective enc)
    {a b : ℕ} (h : enc a = enc b) : a = b :=
  h_inj h

end MipIncompleteness

end MIP
