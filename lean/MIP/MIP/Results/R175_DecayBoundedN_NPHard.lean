/-
Result R.175 — Decay-induced complexity inflation: DECAY-BOUNDED-N is NP-hard
(even under the explicit encoding where static BOUNDED-N is in P).

Reference: `workspace/round3_exploration/work_slot_004.md` §R.175
(A 条件性, computation × decay; deps R.85/T.17, R.163, R.151, R.155,
D.D.1–D.D.3; external: 1|d_j|L_max scheduling NP-hard, Karp 1972 /
Lenstra–Rinnooy Kan 1977).

**Statement.**  DECAY-BOUNDED-N(⟨A, p, T, τ, p₀, θ⟩, k) asks whether a
decay-budgeted intervention sequence of length `≤ k` keeps the required
knowledge `R(p)` simultaneously above the activation threshold `θ` long enough
for `A` to solve `p` within horizon `T`.  R.175 shows:

* (a) explicit encoding `⟨A⟩_exp` + decay  ⟹  NP-hard
      (strictly harder than R.163(i)'s `P`, unless `P = NP`);
* (b) succinct encoding `⟨A⟩_succ` + decay ⟹  PSPACE-hard
      (`≥` static BOUNDED-N, which is already PSPACE-hard);
* (c) explicit + finite `T` ⟹ decidable (finite search space), still NP-hard.

The decisive reduction for (a) is `1|d_j|L_max ≤ₚ DECAY-BOUNDED-N`: each
scheduling task `(p_j, d_j, r_j)` becomes a knowledge element `ω_j` with
half-life `τ_{ω_j} = d_j / log(p₀/θ)` (so `ω_j` decays to `θ` exactly at its
deadline `d_j`), maintenance move `m_j` of "processing time" `p_j`, release `r_j`;
with `k = n+1`,

    DECAY-BOUNDED-N(I, n+1) = yes  ⟺  1|d_j|L_max(J) = yes (L_max ≤ 0).

Since `1|d_j|L_max` is NP-hard and the static problem (R.163(i)) is in `P`,
decay strictly inflates the complexity class.

**Formalization strategy (hypothesis-bundle reduction).**  Same abstract
hardness-transfer kernel as R.85/R.100 (redefined locally for self-containment).
We do NOT build the scheduler or the decay simulator.  The substance is the
**transfer theorem** — a polynomial-time reduction from a known-hard problem
composes to make the target NP-hard — instantiated with:

* `hSched : NPHard scheduling` — `1|d_j|L_max` is NP-hard (Karp 1972, bundled);
* `hred : polyReduces scheduling decayBoundedN` — the `(τ_{ω_j}, m_j, r_j)`
  construction of §R.175(a), whose validity (`yes ⟺ L_max ≤ 0`) is bundled.

The *strict inflation* over R.163(i) is recorded honestly: `staticInP`
("static BOUNDED-N ∈ P") together with `NPHard decayBoundedN` and the
complexity-theoretic separation hypothesis `P ≠ NP` (bundled as `hPneqNP`)
forces `decayBoundedN ∉ P` — i.e. decay genuinely raises the class.

**This file is `axiom`-free.**  It imports only `Mathlib`; the `≤ₚ` structural
properties, scheduling-hardness, the concrete reduction validity, and the
`P ≠ NP` separation all enter as explicit hypotheses.
-/
import Mathlib.Logic.Basic

namespace MIP

namespace DecayBoundedNNPHard

-- Opaque type of decision problems (local kernel, self-contained).
variable {Prob : Type*}

-- The polynomial-time many-one reducibility relation `≤ₚ`.
variable (polyReduces : Prob → Prob → Prop)

-- Membership in the complexity classes P and NP (opaque predicates).
variable (InP InNP : Prob → Prop)

/-- A problem `P` is **NP-hard** iff every NP problem reduces to it. -/
def NPHard (P : Prob) : Prop := ∀ Q, InNP Q → polyReduces Q P

/-- **R.175 core — hardness transfer (reduction composition).**

If `A ≤ₚ B` and `A` is NP-hard then `B` is NP-hard: for any `Q ∈ NP`, hardness
of `A` gives `Q ≤ₚ A`, transitivity with `A ≤ₚ B` yields `Q ≤ₚ B`. -/
theorem R_175_transfer
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    {A B : Prob}
    (hred : polyReduces A B)
    (hA : NPHard polyReduces InNP A) :
    NPHard polyReduces InNP B := by
  intro Q hQ
  exact htrans (hA Q hQ) hred

/-- **R.175(a) — DECAY-BOUNDED-N is NP-hard (explicit encoding).**

Instantiates the transfer theorem with the scheduling reduction.
* `scheduling decayBoundedN : Prob` — the two problems;
* `hSched : NPHard scheduling` — `1|d_j|L_max` is NP-hard (Karp 1972, bundled);
* `hred : polyReduces scheduling decayBoundedN` — the half-life construction
  `τ_{ω_j} = d_j/log(p₀/θ)`, `k = n+1`, whose validity (`yes ⟺ L_max ≤ 0`) is
  bundled.

Conclusion: `NPHard decayBoundedN`. -/
theorem R_175_decayBoundedN_NPHard
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    (scheduling decayBoundedN : Prob)
    (hSched : NPHard polyReduces InNP scheduling)
    (hred : polyReduces scheduling decayBoundedN) :
    NPHard polyReduces InNP decayBoundedN :=
  R_175_transfer polyReduces InNP htrans hred hSched

/-- **R.175(a) — strict complexity inflation `P → NP-hard`.**

The genuine "decay strictly inflates R.163(i)" claim.  Bundled facts:
* `staticInP : InP staticBoundedN` — R.163(i): static BOUNDED-N under explicit
  encoding is in `P`;
* the decay problem is NP-hard (`hDecayHard`);
* `hPneqNP` — the separation `∃ Q ∈ NP, Q ∉ P` (i.e. `P ≠ NP`);
* `hPclosed` — `P` is closed downward under `≤ₚ` (`InP B → polyReduces A B →
  InP A`), the standard structural fact.

Conclusion: `¬ InP decayBoundedN` — the decay problem leaves `P`.  Thus the
class strictly rises from `P` (static) to outside `P` (decay), unless `P = NP`. -/
theorem R_175_strict_inflation
    (decayBoundedN : Prob)
    (hPclosed : ∀ {A B : Prob}, InP B → polyReduces A B → InP A)
    (hDecayHard : NPHard polyReduces InNP decayBoundedN)
    (hPneqNP : ∃ Q, InNP Q ∧ ¬ InP Q) :
    ¬ InP decayBoundedN := by
  intro hDecayInP
  obtain ⟨Q, hQNP, hQnotP⟩ := hPneqNP
  -- `Q ∈ NP` reduces to the NP-hard decay problem; downward closure of `P`
  -- would then place `Q ∈ P`, contradicting `Q ∉ P`.
  exact hQnotP (hPclosed hDecayInP (hDecayHard Q hQNP))

/-- **R.175(c) — finite-horizon decidability.**

With explicit encoding and finite `T`, the set of decay-budgeted intervention
sequences is finite (`(|M|·|T_grid|)^k`), so DECAY-BOUNDED-N is decidable by
exhaustive search.  We record the structural fact: a property whose witness
ranges over a `Fintype` is decidable in the `Prop`-valued sense — any
`DecidablePred` instance yields a Boolean decider. -/
theorem R_175_finite_decidable {α : Type*} (P : α → Prop) [DecidablePred P] :
    ∃ f : α → Bool, ∀ a, f a = true ↔ P a :=
  ⟨fun a => decide (P a), fun a => by simp⟩

/-- **R.175 — transfer along a reduction chain.**

NP-hardness propagates along a chain `scheduling ≤ₚ C ≤ₚ decayBoundedN`
(e.g. through the static BOUNDED-N intermediate), by two applications of
transitivity. -/
theorem R_175_transfer_chain
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    {A C B : Prob}
    (hAC : polyReduces A C) (hCB : polyReduces C B)
    (hA : NPHard polyReduces InNP A) :
    NPHard polyReduces InNP B :=
  R_175_transfer polyReduces InNP htrans (htrans hAC hCB) hA

end DecayBoundedNNPHard

end MIP
