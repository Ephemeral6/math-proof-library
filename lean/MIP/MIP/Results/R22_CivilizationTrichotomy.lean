/-
Result R.22 — Civilization-activity trichotomy.

Reference: `proofs/derived/R22.md` and `proofs/derived/A_grade.md` R.22
(A 无条件, direct corollary of C.9, 2026 derived branch).

**Statement.** Every civilization activity that changes the emergence
state `N(p, A)` of an unsolved problem falls into *exactly one* of three
classes, mirroring the C.9 trichotomy of unsolved problems:

* **Type I** — *reduce the emergence degree* `N` (train/optimize on a
  Type-I problem `p ∈ P_sol`, `R(p) ⊆ K(A)`, `N(p,A) > N_practical`);
* **Type II** — *expand the knowledge* `K` (acquire the missing elements
  of `R(p) ⊄ K(A)`, turning a Type-II problem into Type I);
* **Type III** — *redefine the problem set* `P` (modify or recreate the
  problem when `p ∉ P_sol`).

The classification acts on the *primitive targeted* by the activity:
each activity targets exactly one of the three primitives `{N, K, P}`.
We model the targeted primitive abstractly as a three-valued tag and
prove the resulting class assignment is **exhaustive** (every activity
is classified) and **pairwise disjoint** (no activity is two types).
Exhaustiveness and disjointness are inherited from C.9.

**This file is `axiom`-free.**  R.22 is stated as a self-contained
classification theorem: the C.9 dependence enters only through the fact
that an activity targets exactly one primitive (encoded by the
three-valued `Primitive` tag), which is faithful to the source.
-/
import Mathlib.Logic.Basic

namespace MIP

namespace CivilizationTrichotomy

/-- The three primitives an activity can act on, per C.9 / R.22:
the emergence degree `N`, the knowledge set `K`, or the problem set `P`.
This is the *target* of a civilization activity. -/
inductive Primitive
  | N  -- reduce emergence degree
  | K  -- expand knowledge
  | P  -- redefine the problem set
deriving DecidableEq, Repr

/-- The three civilization-activity types of R.22.

* `TypeI`  — reduce `N`;
* `TypeII` — expand `K`;
* `TypeIII`— redefine `P`.

These are in bijection with the targeted `Primitive`. -/
inductive ActivityType
  | TypeI    -- reduce N
  | TypeII   -- expand K
  | TypeIII  -- redefine P
deriving DecidableEq, Repr

/-- An abstract civilization activity, characterised (per C.9) by the
single primitive it targets. -/
structure Activity where
  /-- The primitive this activity acts on.  By C.9 it is exactly one. -/
  target : Primitive

/-- The R.22 classifier: an activity's type is determined by the
primitive it targets.  `N ↦ TypeI`, `K ↦ TypeII`, `P ↦ TypeIII`. -/
def classify (act : Activity) : ActivityType :=
  match act.target with
  | Primitive.N => ActivityType.TypeI
  | Primitive.K => ActivityType.TypeII
  | Primitive.P => ActivityType.TypeIII

/-- An activity *is* Type I iff it reduces `N` (targets the `N` primitive). -/
def isTypeI   (act : Activity) : Prop := classify act = ActivityType.TypeI
/-- An activity *is* Type II iff it expands `K` (targets the `K` primitive). -/
def isTypeII  (act : Activity) : Prop := classify act = ActivityType.TypeII
/-- An activity *is* Type III iff it redefines `P` (targets the `P` primitive). -/
def isTypeIII (act : Activity) : Prop := classify act = ActivityType.TypeIII

/-- **R.22 — exhaustiveness.**

Every civilization activity is classified into one of the three types.
Inherited from C.9's exhaustiveness of the problem trichotomy. -/
theorem R_22_exhaustive (act : Activity) :
    isTypeI act ∨ isTypeII act ∨ isTypeIII act := by
  unfold isTypeI isTypeII isTypeIII classify
  cases act.target with
  | N => exact Or.inl rfl
  | K => exact Or.inr (Or.inl rfl)
  | P => exact Or.inr (Or.inr rfl)

/-- **R.22 — pairwise disjointness.**

No civilization activity is simultaneously two of the three types:
the classes `{I, II, III}` are pairwise disjoint.  Inherited from C.9's
mutual exclusivity. -/
theorem R_22_disjoint (act : Activity) :
    ¬ (isTypeI act ∧ isTypeII act) ∧
    ¬ (isTypeI act ∧ isTypeIII act) ∧
    ¬ (isTypeII act ∧ isTypeIII act) := by
  unfold isTypeI isTypeII isTypeIII
  refine ⟨?_, ?_, ?_⟩
  · rintro ⟨h1, h2⟩
    rw [h1] at h2
    exact ActivityType.noConfusion h2
  · rintro ⟨h1, h3⟩
    rw [h1] at h3
    exact ActivityType.noConfusion h3
  · rintro ⟨h2, h3⟩
    rw [h2] at h3
    exact ActivityType.noConfusion h3

/-- **R.22 — classification is a genuine trichotomy (existence + uniqueness).**

Every activity satisfies *exactly one* of the three predicates: at least
one (exhaustive) and no two together (disjoint). -/
theorem R_22_trichotomy (act : Activity) :
    (isTypeI act ∨ isTypeII act ∨ isTypeIII act) ∧
    ¬ (isTypeI act ∧ isTypeII act) ∧
    ¬ (isTypeI act ∧ isTypeIII act) ∧
    ¬ (isTypeII act ∧ isTypeIII act) :=
  ⟨R_22_exhaustive act,
    (R_22_disjoint act).1, (R_22_disjoint act).2.1, (R_22_disjoint act).2.2⟩

end CivilizationTrichotomy

end MIP
