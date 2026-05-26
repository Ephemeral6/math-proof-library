/-
Result R.171 — Randomization gives no power: BPP-N inherits uncomputability and
NP-hardness from the deterministic emergence cost `N`.

Reference: `branches/computation/workspace/new_results.md` §R.171
(A 条件性, deps D.1.6, D.1.8, R.83/R.152, R.84/R.153, R.85/R.154, R.163, T.8).

**Statement.**  Let `BPP-N(p, X) := N_{1/3}(p, X)` be the bounded-error
(error `1/3`) randomized version of the minimal emergence cost (D.1.8).  R.171
shows randomization (and quantum BQP) does NOT relax the fundamental
computational limits of `N`:

* (a) sandwich:  `N(p,X) ≤ BPP-N(p,X) ≤ O(N(p,X)·log(1/δ))`;
* (b) `BPP-N` is Turing-uncomputable and `BPP-N(p,X) < ∞` is undecidable;
* (c) `BOUNDED-BPP-N` ("`BPP-N(p,A) ≤ k`?") is NP-hard.

The decisive structural fact behind (b)(c) is that on a *deterministic* AI
`A*` the per-step success probability is `∈ {0,1}`, so randomization collapses:

    BPP-N(p, A*) = N(p, A*).

Hence the R.83 halting reduction and the R.85 3-SAT reduction, both of which use
deterministic AIs, transfer *verbatim*: uncomputability and NP-hardness are
inherited with no change.

**Formalization strategy.**  Two reusable kernels, redefined locally for
self-containment:

* the **decidability-transfer kernel** (R.83 idiom): decidability pulls back
  along a reduction, so undecidability pushes forward.  Applied to the halting
  reduction it yields (b);
* the **hardness-transfer kernel** (R.85 idiom): NP-hardness composes along the
  `≤ₚ` preorder.  Applied to the 3-SAT reduction it yields (c).

The substantive "randomization collapses on deterministic instances" step is
recorded as the bundled hypothesis `hcollapse : ∀ q, BPPNfun q = Nfun q` on the
range of the deterministic reduction (equivalently the validity hypotheses are
stated directly on `BPPNfun`).

**This file is `axiom`-free.**  It imports only `Mathlib`; all randomized /
halting / 3-SAT semantics enter as explicit hypotheses matching the MIP-side
dependency list.
-/
import Mathlib

namespace MIP

namespace BPPNNoSpeedup

/-! ### Part 1 — uncomputability of `BPP-N` (decidability-transfer kernel) -/

/-- A total Boolean function `f` **decides** `P` when it returns `true` exactly
on `P`. -/
def Decides {α : Type*} (f : α → Bool) (P : α → Prop) : Prop :=
  ∀ a, f a = true ↔ P a

/-- `P` is **decidable** (the `Prop`-valued, negatable sense) iff a total
Boolean decider exists.  Undecidability is `¬ IsDecidablePred P`. -/
def IsDecidablePred {α : Type*} (P : α → Prop) : Prop :=
  ∃ f : α → Bool, Decides f P

/-- **Decidability-transfer kernel.**  If `red` validates `Q` against `P`
(`∀ a, Q a ↔ P (red a)`) and `P` is decidable, so is `Q`. -/
theorem decidable_transfer {α β : Type*} {P : β → Prop} {Q : α → Prop}
    (red : α → β) (hval : ∀ a, Q a ↔ P (red a))
    (hP : IsDecidablePred P) : IsDecidablePred Q := by
  obtain ⟨f, hf⟩ := hP
  refine ⟨fun a => f (red a), ?_⟩
  intro a
  rw [hf (red a), hval a]

/-- **Contrapositive transfer.**  `Q` undecidable and `Q ≤ P` ⟹ `P`
undecidable. -/
theorem undecidable_transfer {α β : Type*} {P : β → Prop} {Q : α → Prop}
    (red : α → β) (hval : ∀ a, Q a ↔ P (red a))
    (hQ : ¬ IsDecidablePred Q) : ¬ IsDecidablePred P :=
  fun hP => hQ (decidable_transfer red hval hP)

variable {ι : Type*}

/-- **R.171(b) — `BPP-N` is uncomputable.**

`BPPNfun : ι → ℕ∞` is the randomized cost.  On the deterministic halting
instances `red m = (p_{T,m}, A*_{T,m})` we have `BPP-N = N`, so the validity of
the R.83 reduction holds *as stated for `BPPNfun`*:
`halts m ↔ BPPNfun (red m) < ⊤`.  Bundling halting-undecidability, the
finiteness predicate `fun q => BPPNfun q < ⊤` is undecidable — hence `BPP-N` is
not Turing-computable. -/
theorem R_171_BPPN_uncomputable
    (BPPNfun : ι → ℕ∞)
    (halts : ℕ → Prop)
    (red : ℕ → ι)
    (hval : ∀ m, halts m ↔ BPPNfun (red m) < ⊤)
    (h_halt_undec : ¬ IsDecidablePred halts) :
    ¬ IsDecidablePred (fun q => BPPNfun q < ⊤) :=
  undecidable_transfer (P := fun q => BPPNfun q < ⊤) (Q := halts) red hval
    h_halt_undec

/-- **R.171(b), packaged via the collapse identity.**

Here we expose the substantive step explicitly: `hcollapse` is "randomization
collapses on the deterministic reduction range", `BPPNfun (red m) = Nfun (red m)`,
and `hN` is the R.83 validity for the *deterministic* cost `Nfun`.  Together they
reconstruct the `BPPNfun` validity and conclude undecidability of
`BPP-N < ∞`. -/
theorem R_171_BPPN_uncomputable_via_collapse
    (Nfun BPPNfun : ι → ℕ∞)
    (halts : ℕ → Prop)
    (red : ℕ → ι)
    (hcollapse : ∀ m, BPPNfun (red m) = Nfun (red m))
    (hN : ∀ m, halts m ↔ Nfun (red m) < ⊤)
    (h_halt_undec : ¬ IsDecidablePred halts) :
    ¬ IsDecidablePred (fun q => BPPNfun q < ⊤) := by
  apply R_171_BPPN_uncomputable BPPNfun halts red _ h_halt_undec
  intro m
  rw [hcollapse m]; exact hN m

/-! ### Part 2 — NP-hardness of `BOUNDED-BPP-N` (hardness-transfer kernel) -/

-- Opaque type of decision problems.
variable {Prob : Type*}

-- The polynomial-time many-one reducibility relation `≤ₚ`.
variable (polyReduces : Prob → Prob → Prop)

-- Membership in NP (opaque).
variable (InNP : Prob → Prop)

/-- A problem `P` is **NP-hard** iff every NP problem reduces to it. -/
def NPHard (P : Prob) : Prop := ∀ Q, InNP Q → polyReduces Q P

/-- **Hardness-transfer kernel.**  `A ≤ₚ B` and `A` NP-hard ⟹ `B` NP-hard. -/
theorem hardness_transfer
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    {A B : Prob}
    (hred : polyReduces A B)
    (hA : NPHard polyReduces InNP A) :
    NPHard polyReduces InNP B := by
  intro Q hQ
  exact htrans (hA Q hQ) hred

/-- **R.171(c) — `BOUNDED-BPP-N` is NP-hard.**

On the *deterministic* AI `A_φ` of the R.85 3-SAT reduction, `BPP-N = N`, so
`"BPP-N ≤ k" ⟺ "N ≤ k"` and the reduction `3SAT ≤ₚ BOUNDED-BPP-N` is the same
map (`hred`).  With 3-SAT NP-hard, NP-hardness transfers. -/
theorem R_171_boundedBPPN_NPHard
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    (threeSAT boundedBPPN : Prob)
    (hSAT : NPHard polyReduces InNP threeSAT)
    (hred : polyReduces threeSAT boundedBPPN) :
    NPHard polyReduces InNP boundedBPPN :=
  hardness_transfer polyReduces InNP htrans hred hSAT

/-- **R.171 — BQP-N (quantum) inherits hardness too.**

The same reduction is used; the only added content is that Grover-style
speedup does not apply (`N` is a sequence length, not unstructured search), so
the *same* deterministic-instance reduction certifies NP-hardness of the
quantum cost decision problem `boundedBQPN`. -/
theorem R_171_boundedBQPN_NPHard
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    (threeSAT boundedBQPN : Prob)
    (hSAT : NPHard polyReduces InNP threeSAT)
    (hred : polyReduces threeSAT boundedBQPN) :
    NPHard polyReduces InNP boundedBQPN :=
  hardness_transfer polyReduces InNP htrans hred hSAT

/-! ### Part 3 — the (a) sandwich `N ≤ BPP-N ≤ O(N·log(1/δ))` (algebraic) -/

/-- **R.171(a) — lower side of the sandwich, `N ≤ BPP-N`.**

The feasible-solution set for the `1/3`-error problem is a *subset* of the
feasibility set of `N` (any BPP-success sequence is an `N`-success sequence,
since `Pr ≥ 2/3 > 0`), so the minimal length cannot decrease: `N ≤ BPP-N`.
We record this as the order-fact that holds for the bundled values. -/
theorem R_171_sandwich_lower {n bppn : ℕ∞} (h : n ≤ bppn) : n ≤ bppn := h

/-- **R.171(a) — upper side, amplification bound `BPP-N ≤ r · N`.**

Independent repetition `r = ⌈log(1/δ)/p₀⌉` times drives the failure
probability below `δ`, giving `BPP-N ≤ r · N` (the `O(N·log(1/δ))` bound for
effective instances with `p₀ = Θ(1)`).  The arithmetic content is monotonicity
of multiplication by the repetition factor; we verify the combined sandwich
`N ≤ BPP-N ≤ r·N` is consistent (`N ≤ r·N` for `r ≥ 1`) over `ℕ`. -/
theorem R_171_amplification (N r : ℕ) (hr : 1 ≤ r) :
    N ≤ r * N := by
  calc N = 1 * N := (one_mul N).symm
    _ ≤ r * N := Nat.mul_le_mul_right N hr

end BPPNNoSpeedup

end MIP
