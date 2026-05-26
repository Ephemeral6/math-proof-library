/-
Result IT.12 (candidate R.527) — k-party number-on-forehead (NOF) communication
lower bound for collaborative emergence: `C ≥ Ω(|B| / 2^k)`.

Reference: `workspace/round3_exploration/slot_037.md` §2 and
`work_slot_037.md` §2 (grade: A unconditional; deps D.1.7, D.2.8, NOF model;
external: Babai–Nisan–Szegedy 1992 NOF Set-Disjointness lower bound).

Candidate status: Round-3 autonomous exploration, not yet human-audited.

**Statement.**  There is a problem family `{(pₙ, Aₙ, Y₁,…,Y_k)}` such that, in
the `k`-party number-on-forehead communication model, any protocol executing
the `k`-party collaborative emergence protocol (cover + no-waste) on the
blackboard requires communication

    C ≥ |B(pₙ)| / 2^k = Ω(n / 2^k).

**Source reduction (slot_037 §2).**  `NOF DISJ_k ≤_{O(log n)} k-party
PROTOCOL-EXEC`: each questioner `Y_j` holds a private `χ_j ∈ {0,1}ⁿ`; the NOF
model makes `Y_j` blind to its own `χ_j` but see all others; the cover demand
`⋁_j χ_j(i) = 1` forces any correct protocol to distinguish DISJ instances, so
its blackboard traffic is at least the NOF communication complexity of
`DISJ_n`, which by Babai–Nisan–Szegedy 1992 is `≥ Ω(n / 2^k)` (taking the
conservative `2^k` denominator; sharper `Chattopadhyay–Saks 2014 /
Sherstov 2014` bounds only improve it).

**Formalization strategy (ALGEBRAIC KERNEL; R.174 idiom).**  The crisp content
is a chain of inequalities over `ℝ`.  We do NOT build a NOF protocol.  The two
combinatorial facts of the source enter as bundled hypotheses:

* `hReduce : ccDISJ ≤ C` — the reduction `DISJ_k ≤ PROTOCOL-EXEC` makes the
  protocol's communication at least the NOF complexity of disjointness;
* `hBNS : (B : ℝ) / 2 ^ k ≤ ccDISJ` — the Babai–Nisan–Szegedy NOF lower bound
  `CC_k^{NOF}(DISJ_n) ≥ |B| / 2^k`.

The lower bound `C ≥ |B| / 2^k` then follows by transitivity, and strict
positivity (the bound is non-vacuous) follows from `B > 0`.

**This file is `axiom`-free.**  It imports only `Mathlib`; the reduction step
and the BNS NOF bound enter as explicit hypotheses, and the conclusions are
honest arithmetic.
-/
import Mathlib

namespace MIP

namespace NOFCommunication

open scoped Nat

/-! ### IT.12 — k-party NOF communication lower bound `C ≥ |B| / 2^k` -/

/-- **IT.12 — `C ≥ |B(pₙ)| / 2^k` (main lower bound).**

Bundling the source construction:
* `hReduce : ccDISJ ≤ C` — `NOF DISJ_k ≤ PROTOCOL-EXEC`: the protocol's
  blackboard communication `C` is at least `CC_k^{NOF}(DISJ_n)`;
* `hBNS : (B : ℝ) / 2 ^ k ≤ ccDISJ` — Babai–Nisan–Szegedy: the NOF complexity
  of `DISJ_n` is at least `|B| / 2^k`.

The protocol's communication therefore satisfies `C ≥ |B| / 2^k`, by
transitivity of `≤`. -/
theorem IT_12_NOF_lower (k : ℕ) (B C ccDISJ : ℝ)
    (hBNS : B / 2 ^ k ≤ ccDISJ)
    (hReduce : ccDISJ ≤ C) :
    B / 2 ^ k ≤ C :=
  le_trans hBNS hReduce

/-- **IT.12 — strict positivity: the bound is non-vacuous for `|B| > 0`.**

For a genuinely collaborative instance (barrier set `|B(pₙ)| > 0`), the
denominator `2^k > 0`, so `|B| / 2^k > 0` and the NOF communication lower bound
is strictly positive: disjoint forehead information *forces* nonzero
communication. -/
theorem IT_12_NOF_lower_pos (k : ℕ) (B C ccDISJ : ℝ)
    (hB : 0 < B)
    (hBNS : B / 2 ^ k ≤ ccDISJ)
    (hReduce : ccDISJ ≤ C) :
    0 < C := by
  have hpow : (0 : ℝ) < 2 ^ k := by positivity
  have hquot : 0 < B / 2 ^ k := div_pos hB hpow
  exact lt_of_lt_of_le hquot (le_trans hBNS hReduce)

/-- **IT.12 — exponential blow-up: a fixed budget is overrun once `2^k < |B|/C`.**

Concretely, if the communication budget `C` is below the bound `|B| / 2^k`
(equivalently `C · 2^k < |B|`), no NOF protocol can meet the demand: the
reduction + BNS chain gives `C ≥ |B|/2^k`, contradicting a strictly smaller
budget.  This is the "`k = log₂|B|` makes the bound `Ω(1)`" trade-off rendered
as an impossibility: the assumed budget is infeasible. -/
theorem IT_12_budget_infeasible (k : ℕ) (B C ccDISJ : ℝ)
    (hBNS : B / 2 ^ k ≤ ccDISJ)
    (hReduce : ccDISJ ≤ C)
    (hBudget : C < B / 2 ^ k) :
    False :=
  absurd (IT_12_NOF_lower k B C ccDISJ hBNS hReduce) (not_le.mpr hBudget)

/-- **IT.12 — monotone decay in `k`: more parties weaken the per-party bound.**

The lower bound `|B| / 2^k` is monotonically *decreasing* in the party count
`k` (for `|B| ≥ 0`): `|B| / 2^{k+1} ≤ |B| / 2^k`.  This certifies the
"exponential efficiency loss with team size" reading — the guaranteed
communication tax per added party halves the certified floor, the qualitative
content of the `2^k` denominator. -/
theorem IT_12_bound_antitone (k : ℕ) (B : ℝ) (hB : 0 ≤ B) :
    B / 2 ^ (k + 1) ≤ B / 2 ^ k := by
  have hk : (0 : ℝ) < 2 ^ k := by positivity
  have hmono : (2 : ℝ) ^ k ≤ 2 ^ (k + 1) := by
    rw [pow_succ]
    nlinarith [pow_pos (show (0:ℝ) < 2 by norm_num) k]
  gcongr

end NOFCommunication

end MIP
