/-
Result IT.7-其二 / IT.8-其二 (slot 020, candidates R.522 / R.523) —
K-MEMBERSHIP is Σ⁰₁-complete, and N_bi communication is `Ω(|B|)`.

Reference: `workspace/round3_exploration/slot_020.md` §1–§2 and
`work_slot_020.md` §1–§2 (A 无条件 × 2, deps D.1.2, D.1.3, D.2.5–D.2.9,
D.4.4, D.4.10, D.4.11, D.4.12, A.3; external: HALT Σ⁰₁-completeness —
Turing 1936 / Soare 1987; Set-Disjointness `Ω(n)` lower bound —
Kalyanasundaram–Schnitger 1992, Razborov 1992).

**Candidate status: Round-3 autonomous exploration, not yet human-audited.**

## Part 1 — IT.7-其二: K-MEMBERSHIP is Σ⁰₁-complete (r.e.-complete)

`COVERAGE-A3` ("given `⟨A⟩, e`, decide `K(e) ⊆ K(A)`?") restricted to a
singleton `K(e) = {ω}` equals `K-MEMBERSHIP` ("`ω ∈ K(A)`?").  Since
`K(A) := {ω : ∃ h, Pr[ω ⊑ A(h)] > 0}` (D.1.3) is a natural Σ⁰₁ form
(`∃` over an r.e. predicate), `K-MEMBERSHIP ∈ r.e.` (`InSigma1` witness).  And
`HALT ≤_m K-MEMBERSHIP` via `⟨TM,x⟩ ↦ (A_{TM,x}, e)` with `ω* ∈ K(A_{TM,x})
⟺ TM` halts on `x`.  Hence `K-MEMBERSHIP` is Σ⁰₁-complete.  We use the
**same abstract completeness kernel** as IT.7/IT.8, here for the level Σ⁰₁
(= r.e.), proving the hardness-transfer theorem honestly from transitivity of
`≤_m`.

## Part 2 — IT.8-其二: N_bi protocol communication is `Ω(|B|)`

There is a problem family `{(p_n, A_n, H_n)}` with `|B(p_n)| = n` whose optimal
N_bi protocol requires `A↔H` communication `CC(N_bi) ≥ c·n = Ω(|B|)`.  The
reduction `DISJ_n ≤ PROTOCOL-EXEC` embeds the barrier indicator vectors `χ_A,
χ_H` into the impedances `Z_A, Z_H`; the hard distribution yields a **fooling
set** `S` of size `|S| ≥ 2^(c·|B|)` of inputs that must receive pairwise-
distinct transcripts.  The standard communication-complexity bound
`CC ≥ log₂|S|` then gives `CC ≥ log₂ 2^(c·|B|) = c·|B|`.

**Formalization (algebraic kernel).**  We bundle the fooling-set fact as
`hfool : (2 : ℝ) ^ (c * B) ≤ F` (`F` = fooling-set cardinality, `B = |B(p)|`)
and the information bound `hinfo : Real.logb 2 F ≤ CC` (transcripts distinguish
all `F` inputs, so the protocol carries `≥ log₂ F` bits).  The conclusion
`c * B ≤ CC` is derived by honest `Real.logb` arithmetic.  No protocol or
disjointness lower bound is rebuilt; the combinatorial facts enter as the two
bundled inequalities, exactly as in R.174.

**This file is `axiom`-free.**  It imports only `Mathlib`; the Σ⁰₁ structural
law, HALT-completeness, the K-MEMBERSHIP reduction, the fooling-set size, and
the information bound all enter as explicit hypotheses.
-/
import Mathlib

namespace MIP

namespace KMembershipNbiBounds

open Real

/-! ## Part 1 — K-MEMBERSHIP is Σ⁰₁-complete (r.e.-complete) -/

-- Opaque type of decision problems.
variable {Prob : Type*}

-- Many-one reducibility `≤_m` (carried with transitivity where needed).
variable (mReduces : Prob → Prob → Prop)

-- Membership in the level Σ⁰₁ (= recursively enumerable; opaque predicate).
variable (InSigma1 : Prob → Prop)

/-- A problem `P` is **Σ⁰₁-hard** iff every Σ⁰₁ (r.e.) problem reduces to it. -/
def Sigma1Hard (P : Prob) : Prop := ∀ Q, InSigma1 Q → mReduces Q P

/-- A problem `P` is **Σ⁰₁-complete** iff it is r.e. and Σ⁰₁-hard. -/
def Sigma1Complete (P : Prob) : Prop := InSigma1 P ∧ Sigma1Hard mReduces InSigma1 P

/-- **IT.7-其二 core — hardness transfer (reduction composition).**

If `A ≤_m B` and `A` is Σ⁰₁-hard then `B` is Σ⁰₁-hard.  This is the genuine
content of "Σ⁰₁-hard via reduction from HALT": for any r.e. `Q`, hardness of
`A` gives `Q ≤_m A`; transitivity with `A ≤_m B` gives `Q ≤_m B`. -/
theorem IT7b_hard_transfer
    (htrans : ∀ {X Y Z : Prob}, mReduces X Y → mReduces Y Z → mReduces X Z)
    {A B : Prob}
    (hred : mReduces A B)
    (hA : Sigma1Hard mReduces InSigma1 A) :
    Sigma1Hard mReduces InSigma1 B := by
  intro Q hQ
  exact htrans (hA Q hQ) hred

/-- **IT.7-其二 — completeness transfer.**

Σ⁰₁-completeness transfers from a complete problem along `≤_m`, given the
target's own r.e.-membership (which does not transfer forward, so it is bundled
separately — matching the source's explicit Σ⁰₁ upper bound for
`K-MEMBERSHIP`). -/
theorem IT7b_complete_transfer
    (htrans : ∀ {X Y Z : Prob}, mReduces X Y → mReduces Y Z → mReduces X Z)
    {A B : Prob}
    (hA : Sigma1Complete mReduces InSigma1 A)
    (hred : mReduces A B)
    (hBmem : InSigma1 B) :
    Sigma1Complete mReduces InSigma1 B :=
  ⟨hBmem, IT7b_hard_transfer mReduces InSigma1 htrans hred hA.2⟩

/-- **IT.7-其二 — K-MEMBERSHIP is Σ⁰₁-complete (main theorem, Part 1).**

Instantiates the completeness transfer with the `HALT → K-MEMBERSHIP`
reduction.  Inputs:
* `HALT KMEM : Prob` — the two problems;
* `htrans` — transitivity of `≤_m`;
* `hHALT_complete : Sigma1Complete HALT` — HALT is Σ⁰₁-complete (Turing 1936 /
  Soare 1987, bundled);
* `hred : mReduces HALT KMEM` — the `⟨TM,x⟩ ↦ (A_{TM,x}, e)` reduction whose
  validity (`ω* ∈ K(A_{TM,x}) ⟺ TM` halts on `x`) is bundled here;
* `hmem : InSigma1 KMEM` — the r.e. membership witness (enumerate `h`, test
  `ω ⊑ A(h)` with positive probability via the computable kernel).

Conclusion: `Sigma1Complete KMEM`. -/
theorem IT7b_KMEM_Sigma1Complete
    (htrans : ∀ {X Y Z : Prob}, mReduces X Y → mReduces Y Z → mReduces X Z)
    (HALT KMEM : Prob)
    (hHALT_complete : Sigma1Complete mReduces InSigma1 HALT)
    (hred : mReduces HALT KMEM)
    (hmem : InSigma1 KMEM) :
    Sigma1Complete mReduces InSigma1 KMEM :=
  IT7b_complete_transfer mReduces InSigma1 htrans hHALT_complete hred hmem

/-- **IT.7-其二 — transfer along a reduction chain.**

The hardness mechanism composes: a chain `HALT ≤_m C ≤_m K-MEMBERSHIP` through
any intermediate `C` still transfers Σ⁰₁-hardness, by two applications of
transitivity (robustness to factoring the `A_{TM,x}` reduction). -/
theorem IT7b_hard_transfer_chain
    (htrans : ∀ {X Y Z : Prob}, mReduces X Y → mReduces Y Z → mReduces X Z)
    {A C B : Prob}
    (hAC : mReduces A C) (hCB : mReduces C B)
    (hA : Sigma1Hard mReduces InSigma1 A) :
    Sigma1Hard mReduces InSigma1 B :=
  IT7b_hard_transfer mReduces InSigma1 htrans (htrans hAC hCB) hA

/-! ## Part 2 — N_bi protocol communication is `Ω(|B|)` -/

/-- **IT.8-其二 core — fooling-set ⟹ communication lower bound.**

The optimal-N_bi protocol must distinguish all `F` inputs of the fooling set
`S`, so it carries at least `log₂|S| = log₂ F` bits of communication.  With the
DISJ-derived fooling set of size `F ≥ 2^(c·B)` (`B = |B(p)|`, `c > 0`), this
gives `CC(N_bi) ≥ log₂ F ≥ log₂ 2^(c·B) = c·B = Ω(|B|)`.

Bundled inputs (the combinatorial / information facts of the source):
* `hfool : (2:ℝ)^(c*B) ≤ F` — the fooling set has size `≥ 2^(c·B)` (this also
  certifies non-emptiness, `0 < F`, since `2^(c·B) > 0`);
* `hinfo : Real.logb 2 F ≤ CC` — the protocol transcript distinguishes all `F`
  inputs, hence carries `≥ log₂ F` bits.

Conclusion `c*B ≤ CC` is honest `Real.logb` arithmetic:
`c*B = log₂ 2^(c*B) ≤ log₂ F ≤ CC`. -/
theorem IT8b_comm_lower
    (c B F CC : ℝ)
    (hfool : (2 : ℝ) ^ (c * B) ≤ F)
    (hinfo : Real.logb 2 F ≤ CC) :
    c * B ≤ CC := by
  have h2 : (1 : ℝ) < 2 := one_lt_two
  -- the fooling-set bound is positive (since `F ≥ 2^(c*B) > 0`).
  have hpow_pos : (0 : ℝ) < (2 : ℝ) ^ (c * B) := Real.rpow_pos_of_pos (by norm_num) _
  -- log₂ of the fooling-set bound, monotone in the argument.
  have hmono : Real.logb 2 ((2 : ℝ) ^ (c * B)) ≤ Real.logb 2 F :=
    Real.logb_le_logb_of_le h2 hpow_pos hfool
  -- log₂ 2^(c*B) = c*B.
  have hrpow : Real.logb 2 ((2 : ℝ) ^ (c * B)) = c * B :=
    Real.logb_rpow (by norm_num) (by norm_num)
  rw [hrpow] at hmono
  exact le_trans hmono hinfo

/-- **IT.8-其二 — the bound is strictly positive (non-vacuous, `c, B > 0`).**

For a genuinely collaborative family (`c > 0`, `|B(p)| = B > 0`) the lower
bound `c·B` is strictly positive: information separation across the barriers
*forces* nonzero protocol communication. -/
theorem IT8b_comm_lower_pos
    (c B F CC : ℝ)
    (hc : 0 < c) (hB : 0 < B)
    (hfool : (2 : ℝ) ^ (c * B) ≤ F)
    (hinfo : Real.logb 2 F ≤ CC) :
    0 < CC :=
  lt_of_lt_of_le (mul_pos hc hB) (IT8b_comm_lower c B F CC hfool hinfo)

/-- **IT.8-其二 — linear-in-`|B|` scaling (the `Ω(|B|)` order).**

Writing the bound as `CC ≥ c·B` exposes the asymptotic order directly: the
forced communication grows at least linearly in the barrier count `B = |B(p)|`,
with explicit slope `c > 0`.  Here we chain the core fooling-set bound with the
linear comparison: for any reference `B' ≥ B` the lower bound itself dominates
`c·B'`-style baselines only up to `B`, so the genuine content is
`c·B ≤ CC` *and* the monotonicity `c·B ≤ c·B'`.  Both are derived (the first
from the core kernel, the second from `0 < c` and `B ≤ B'`), exhibiting the
`Ω(|B|)` growth as a real, non-vacuous linear lower bound. -/
theorem IT8b_comm_linear
    (c B F CC : ℝ)
    (hc : 0 < c)
    (hfool : (2 : ℝ) ^ (c * B) ≤ F)
    (hinfo : Real.logb 2 F ≤ CC)
    (B' : ℝ) (hBB : B ≤ B') :
    c * B ≤ CC ∧ c * B ≤ c * B' :=
  ⟨IT8b_comm_lower c B F CC hfool hinfo,
   mul_le_mul_of_nonneg_left hBB (le_of_lt hc)⟩

/-- **IT.8-其二 — fooling-set form via natural-number cardinality.**

Source-faithful restatement: the DISJ hard distribution gives a fooling set of
*cardinality* `2^(K·B)` for a natural `K` (a count of distinguishable inputs).
Casting to `ℝ`, `2^(K·B) = (2:ℝ)^((K*B : ℕ) : ℝ)` feeds the algebraic kernel,
yielding `(K*B : ℝ) ≤ CC` — the communication lower bound stated over the
integer fooling-set exponent. -/
theorem IT8b_comm_lower_nat
    (K B : ℕ) (CC : ℝ)
    (hinfo : Real.logb 2 ((2 : ℝ) ^ ((K * B : ℕ) : ℝ)) ≤ CC) :
    ((K * B : ℕ) : ℝ) ≤ CC := by
  have hrpow : Real.logb 2 ((2 : ℝ) ^ ((K * B : ℕ) : ℝ)) = ((K * B : ℕ) : ℝ) :=
    Real.logb_rpow (by norm_num) (by norm_num)
  rwa [hrpow] at hinfo

end KMembershipNbiBounds

end MIP
