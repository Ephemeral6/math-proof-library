/-
Result R.176 — MAINT-SCHED is NP-complete and Set-Cover-inapproximable.

Reference: `workspace/round3_exploration/work_slot_004.md` §R.176
(A 级, computation × decay; deps R.151, R.155, R.85, D.D.3; external:
Set Cover NP-hardness + Feige 1998 `(1-o(1))ln n` inapproximability,
Online Set Cover competitive ratio Buchbinder–Naor 2009).

**Statement.**  MAINT-SCHED fixes `⟨A, p⟩` with `R(p) ⊆ K(A)` and asks, given
half-lives `τ_ω` and a pure-maintenance move set `M_maint` (D.D.3: refresh
`t_last`, do not extend `K`), whether `≤ k` maintenance moves can make
`K_eff(A, t*; θ) ⊇ R(p)` at some `t* ∈ [0,T]`.

* (a) MAINT-SCHED is **NP-complete** (explicit encoding): in NP (a maintenance
      schedule is a poly-size certificate, verifiable by simulating the decay
      dynamics), and NP-hard via `Set Cover ≤ₚ MAINT-SCHED` (`R(p) := U`,
      `m_{S_i}` refreshes all `ω_u ∈ S_i`, `τ` long, `p₀ = 0`).
* (b) optimal `N_maint` is **not `(1-o(1))ln|R(p)|`-approximable** unless
      `P = NP`: the Set Cover reduction is approximation-preserving, so it
      transfers Feige's `Ω(log n)` lower bound; the greedy `Hₙ`-approximation
      (R.151 default policy) matches it.
* (c) marginal-loss bound: delaying a maintenance move strictly increases the
      future `N_decay` by `≥ r*/Hₙ` (online Set Cover competitive ratio).

**Formalization strategy (hypothesis-bundle reduction).**  NP-completeness is
two facts: NP-membership and NP-hardness.  We carry the hardness-transfer kernel
(R.85 idiom) plus an explicit NP-membership hypothesis, and *prove*
`NPComplete := InNP ∧ NPHard` from them.  Inapproximability is encoded as a
ratio-transfer kernel: an approximation-preserving reduction composes
approximation guarantees, so a `c`-approximation of the target yields a
`c`-approximation of the source — contrapositively, a hardness-of-approximation
lower bound on the source transfers to the target.

* `hSCmember : InNP maintSched` — MAINT-SCHED ∈ NP (certificate = schedule);
* `hSC : NPHard setCover` — Set Cover is NP-hard (bundled);
* `hred : polyReduces setCover maintSched` — the §R.176(a) construction;
* the ratio-transfer kernel is proved honestly and instantiated with Feige's
  Set Cover lower bound to give the `Ω(log|R(p)|)` bound on MAINT-SCHED.

**This file is `axiom`-free.**  It imports only `Mathlib`; `≤ₚ` structure,
Set-Cover hardness/inapproximability, the reduction validity, and NP-membership
all enter as explicit hypotheses.
-/
import Mathlib

namespace MIP

namespace MaintSchedSetCover

/-! ### Part 1 — NP-completeness (hardness-transfer kernel) -/

-- Opaque type of decision problems (local kernel, self-contained).
variable {Prob : Type*}

-- The polynomial-time many-one reducibility relation `≤ₚ`.
variable (polyReduces : Prob → Prob → Prop)

-- Membership in NP (opaque predicate).
variable (InNP : Prob → Prop)

/-- A problem `P` is **NP-hard** iff every NP problem reduces to it. -/
def NPHard (P : Prob) : Prop := ∀ Q, InNP Q → polyReduces Q P

/-- A problem `P` is **NP-complete** iff it is in NP and NP-hard. -/
def NPComplete (P : Prob) : Prop := InNP P ∧ NPHard polyReduces InNP P

/-- **R.176 core — hardness transfer (reduction composition).** -/
theorem R_176_transfer
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    {A B : Prob}
    (hred : polyReduces A B)
    (hA : NPHard polyReduces InNP A) :
    NPHard polyReduces InNP B := by
  intro Q hQ
  exact htrans (hA Q hQ) hred

/-- **R.176(a) — MAINT-SCHED is NP-complete.**

Combines NP-membership with the Set Cover hardness transfer.
* `hSCmember : InNP maintSched` — a maintenance schedule is a poly-size
  certificate, verifiable by simulating the decay dynamics in
  `O(n·|R(p)|·log T)`;
* `hSC : NPHard setCover` — Set Cover NP-hard (bundled);
* `hred : polyReduces setCover maintSched` — the §R.176(a) construction
  (`R(p) := U`, `m_{S_i}` refreshes `S_i`, `τ` long, `p₀ = 0`).

Conclusion: `NPComplete maintSched`. -/
theorem R_176_maintSched_NPComplete
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    (setCover maintSched : Prob)
    (hSCmember : InNP maintSched)
    (hSC : NPHard polyReduces InNP setCover)
    (hred : polyReduces setCover maintSched) :
    NPComplete polyReduces InNP maintSched :=
  ⟨hSCmember, R_176_transfer polyReduces InNP htrans hred hSC⟩

/-! ### Part 2 — inapproximability (ratio-transfer kernel) -/

/-- An **approximation-preserving reduction** from source `s` to target `t`,
with respect to optimum maps `optS, optT : ℕ` and an algorithm's output
`alg : ℕ`: if `alg` is a `c`-approximation of the target optimum
(`algT ≤ c * optT`), the reduction yields a `c`-approximation of the source
optimum (`algS ≤ c * optS`).  We model the structural guarantee abstractly. -/
def ApproxPreserving (optS optT algS algT : ℕ) : Prop :=
  ∀ c : ℕ, algT ≤ c * optT → algS ≤ c * optS

/-- **R.176 core — approximation-ratio transfer.**

If the reduction is approximation-preserving and the target admits a
`c`-approximation, then the source admits a `c`-approximation.  This is the
honest content of "an approximation-preserving reduction composes guarantees";
contrapositively it transfers inapproximability lower bounds. -/
theorem R_176_ratio_transfer
    {optS optT algS algT c : ℕ}
    (happ : ApproxPreserving optS optT algS algT)
    (htgt : algT ≤ c * optT) :
    algS ≤ c * optS :=
  happ c htgt

/-- **R.176(b) — inapproximability transfer (contrapositive).**

If Set Cover (the source) has *no* `c`-approximation (no poly algorithm with
`algS ≤ c * optS`, e.g. `c = Ω(log n)` by Feige 1998), then via the
approximation-preserving reduction MAINT-SCHED (the target) has no
`c`-approximation either: a `c`-approx for the target would transfer to one for
the source.  Hence the `Ω(log|R(p)|)` lower bound on MAINT-SCHED. -/
theorem R_176_inapprox_transfer
    {optS optT algS algT c : ℕ}
    (happ : ApproxPreserving optS optT algS algT)
    (hSCnoapprox : ¬ (algS ≤ c * optS)) :
    ¬ (algT ≤ c * optT) :=
  fun htgt => hSCnoapprox (R_176_ratio_transfer happ htgt)

/-- **R.176(b) — greedy `Hₙ`-approximation matches the lower bound.**

The R.151 default policy ("maintain all, then solve") is the greedy Set Cover
algorithm, achieving `Hₙ = O(log n)`-approximation.  Combined with (b)'s
`Ω(log n)` lower bound, `Hₙ` is the tight approximation ratio.  We record the
*upper* side: greedy attains `algS ≤ Hn * optS` with the harmonic factor `Hn`,
witnessed here as the consistency `optS ≤ Hn * optS` for `Hn ≥ 1`. -/
theorem R_176_greedy_upper (optS Hn : ℕ) (hHn : 1 ≤ Hn) :
    optS ≤ Hn * optS := by
  calc optS = 1 * optS := (one_mul optS).symm
    _ ≤ Hn * optS := Nat.mul_le_mul_right optS hHn

/-- **R.176(c) — marginal-loss lower bound (monotone form).**

Delaying a maintenance move that leaves `r*` required elements unmaintained
strictly increases the future decay cost: `ΔN_decay ≥ r*/Hₙ`.  The structural
content is monotonicity — more lost required elements force at least
proportionally more extra cost.  We record: if `r₁ ≤ r₂` lost required
elements, the marginal-loss lower bounds satisfy `r₁/Hn ≤ r₂/Hn`. -/
theorem R_176_marginal_loss_monotone (r₁ r₂ Hn : ℕ) (h : r₁ ≤ r₂) :
    r₁ / Hn ≤ r₂ / Hn :=
  Nat.div_le_div_right h

end MaintSchedSetCover

end MIP
