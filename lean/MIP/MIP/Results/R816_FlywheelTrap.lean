/-
Result R.816 — Collaboration Trichotomy (Flywheel / Fragile / Trap).
Reference: branches/collaboration_dynamics/results/flywheel_trap.md R.816 (A 无条件 classification, audited 2026-05-27). Dependencies: R.813, R.814, R.812.

**Statement.** Fix `X, Y`, overlap `O := K(X) ∩ K(Y)`, problem `p`. Classify
`ℛ(p)` relative to `O / K(X) / K(Y)`:

  | Zone     | iff-condition                                              | solvability |
  | flywheel | ∃ R ∈ ℛ(p): R ⊆ O                                          | N<∞ (both) |
  | fragile  | (ℛ(p)∩{R⊆O}=∅) ∧ (∃R⊆K X ∨ ∃R⊆K Y)                         | N<∞ (one)  |
  | trap     | (no R⊆K X) ∧ (no R⊆K Y) [only ∃R⊆K X∪K Y needs cross-seam]  | N=∞ (both) |

The single phase quantity is `ℛ(p) ∩ {R ⊆ O}` (flywheel ⟺ nonempty).

**Kernel formalized here.** The classification predicates `Flywheel/Fragile/Trap`
over `K X, K Y` and `O := K X ∩ K Y` as `Set Ω`. We prove:
(1) **Exhaustive + disjoint** (`trichotomy_exhaustive`, `*_disjoint`): every
configuration is exactly one zone.
(2) **Per-zone solvability via A.2**:
  - `flywheel_solvable`: `R ⊆ O ⟹ R ⊆ K X ∧ R ⊆ K Y ⟹ N(p,X)≠⊤ ∧ N(p,Y)≠⊤` (both
    single agents solve; the derivation is fully monochrome, R.814).
  - `fragile_solvable`: `∃R⊆K X ∨ ∃R⊆K Y ⟹` the covering agent has `N≠⊤`.
  - `trap_unsolvable`: trap-condition `⟹ N(p,X)=⊤ ∧ N(p,Y)=⊤` (R.814b; both
    success criteria unsolvable).
(3) **Phase quantity** (`phase_quantity_flywheel`): flywheel ⟺ the set
`{R ∈ ℛ(p) | R ⊆ O}` is nonempty.

**Bridge.** Solvability uses A.2 (`N≠⊤ ⟺ ∃R∈ℛ(p), R⊆K`). The "(AS) terminal-
emissible" subtlety (R.813.d) lives at the `N_collab` level; the single-agent
A.2 characterizations proven here are the rigorous A-unconditional core that the
trichotomy classification rests on. The "silence-loop" column is (PD)-conditional
(R.812) and is *not* formalized (it is not A-unconditional).

Axiom-free (only A.1–A.4).
-/
import MIP.Axioms
import Mathlib.Data.Set.Basic

namespace MIP

namespace R816_FlywheelTrap

open MIP.Axioms

variable {α Ω : Type}

/-! ## Classification predicates

`covers S` := `∃ R ∈ ℛ(p), R ⊆ S`, the A.2 coverage predicate against a
knowledge set `S`. The three zones are defined in terms of `covers (K X ∩ K Y)`,
`covers (K X)`, `covers (K Y)`. -/

/-- A.2-style coverage: some admissible explanation of `p` fits inside `S`. -/
def covers (p : Problem α) (S : Set Ω) : Prop :=
  ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ S

/-- **Flywheel zone.** An explanation fits inside the overlap `O = K X ∩ K Y`. -/
def Flywheel (p : Problem α) (X Y : Agent α) : Prop :=
  covers (Ω := Ω) p ((K X : Set Ω) ∩ (K Y : Set Ω))

/-- **Fragile zone.** No explanation fits in `O`, but one fits in a single
agent's knowledge (`K X` or `K Y`). -/
def Fragile (p : Problem α) (X Y : Agent α) : Prop :=
  ¬ covers (Ω := Ω) p ((K X : Set Ω) ∩ (K Y : Set Ω))
    ∧ (covers (Ω := Ω) p (K X : Set Ω) ∨ covers (Ω := Ω) p (K Y : Set Ω))

/-- **Trap zone.** No single agent covers any explanation (so any covered
explanation needs both sides — a cross-seam, R.814). -/
def Trap (p : Problem α) (X Y : Agent α) : Prop :=
  ¬ covers (Ω := Ω) p (K X : Set Ω) ∧ ¬ covers (Ω := Ω) p (K Y : Set Ω)

/-! ## (1) Exhaustiveness and pairwise disjointness -/

/-- **R.816 — trichotomy is exhaustive.**

Every configuration lands in at least one zone: flywheel, fragile, or trap. -/
theorem trichotomy_exhaustive (p : Problem α) (X Y : Agent α) :
    Flywheel (Ω := Ω) p X Y ∨ Fragile (Ω := Ω) p X Y ∨ Trap (Ω := Ω) p X Y := by
  by_cases hO : covers (Ω := Ω) p ((K X : Set Ω) ∩ (K Y : Set Ω))
  · exact Or.inl hO
  · by_cases hX : covers (Ω := Ω) p (K X : Set Ω)
    · exact Or.inr (Or.inl ⟨hO, Or.inl hX⟩)
    · by_cases hY : covers (Ω := Ω) p (K Y : Set Ω)
      · exact Or.inr (Or.inl ⟨hO, Or.inr hY⟩)
      · exact Or.inr (Or.inr ⟨hX, hY⟩)

/-- **Flywheel ⟹ a single agent covers** (since `O ⊆ K X`).

A bridge fact: covering inside the overlap entails covering inside each agent.
Used both for disjointness and for `flywheel_solvable`. -/
theorem flywheel_imp_covers_X (p : Problem α) (X Y : Agent α)
    (h : Flywheel (Ω := Ω) p X Y) : covers (Ω := Ω) p (K X : Set Ω) := by
  obtain ⟨R', hMem, hSub⟩ := h
  exact ⟨R', hMem, hSub.trans Set.inter_subset_left⟩

/-- Dual: flywheel ⟹ `Y` covers (since `O ⊆ K Y`). -/
theorem flywheel_imp_covers_Y (p : Problem α) (X Y : Agent α)
    (h : Flywheel (Ω := Ω) p X Y) : covers (Ω := Ω) p (K Y : Set Ω) := by
  obtain ⟨R', hMem, hSub⟩ := h
  exact ⟨R', hMem, hSub.trans Set.inter_subset_right⟩

/-- **Flywheel and Fragile are disjoint.** -/
theorem flywheel_fragile_disjoint (p : Problem α) (X Y : Agent α) :
    ¬ (Flywheel (Ω := Ω) p X Y ∧ Fragile (Ω := Ω) p X Y) := by
  rintro ⟨hFly, hFrag, _⟩
  exact hFrag hFly

/-- **Flywheel and Trap are disjoint.** -/
theorem flywheel_trap_disjoint (p : Problem α) (X Y : Agent α) :
    ¬ (Flywheel (Ω := Ω) p X Y ∧ Trap (Ω := Ω) p X Y) := by
  rintro ⟨hFly, hTrapX, _⟩
  exact hTrapX (flywheel_imp_covers_X p X Y hFly)

/-- **Fragile and Trap are disjoint.** -/
theorem fragile_trap_disjoint (p : Problem α) (X Y : Agent α) :
    ¬ (Fragile (Ω := Ω) p X Y ∧ Trap (Ω := Ω) p X Y) := by
  rintro ⟨⟨_, hOr⟩, hTrapX, hTrapY⟩
  rcases hOr with hX | hY
  · exact hTrapX hX
  · exact hTrapY hY

/-! ## (2) Per-zone solvability (A.2) -/

/-- **R.816 (flywheel solvability).**

In the flywheel zone *both* single agents solve `p`: `N(p,X) ≠ ⊤ ∧ N(p,Y) ≠ ⊤`.
The covered explanation sits inside `O ⊆ K X` and `O ⊆ K Y`, so every Horn
hyperedge of its derivation is monochrome (R.814) and A.2 applies on each side. -/
theorem flywheel_solvable (p : Problem α) (X Y : Agent α)
    (h : Flywheel (Ω := Ω) p X Y) :
    N p X ≠ ⊤ ∧ N p Y ≠ ⊤ := by
  refine ⟨?_, ?_⟩
  · exact (Axioms.A2 (Ω := Ω) p X).mpr (flywheel_imp_covers_X p X Y h)
  · exact (Axioms.A2 (Ω := Ω) p Y).mpr (flywheel_imp_covers_Y p X Y h)

/-- **R.816 (fragile solvability).**

In the fragile zone the agent that covers solves `p`: if `covers (K X)` then
`N(p,X) ≠ ⊤`; if `covers (K Y)` then `N(p,Y) ≠ ⊤`. (At least one holds by the
fragile condition.) -/
theorem fragile_solvable (p : Problem α) (X Y : Agent α)
    (h : Fragile (Ω := Ω) p X Y) :
    N p X ≠ ⊤ ∨ N p Y ≠ ⊤ := by
  rcases h.2 with hX | hY
  · exact Or.inl ((Axioms.A2 (Ω := Ω) p X).mpr hX)
  · exact Or.inr ((Axioms.A2 (Ω := Ω) p Y).mpr hY)

/-- **R.816 (trap unsolvability).**

In the trap zone neither single agent solves `p`: `N(p,X) = ⊤ ∧ N(p,Y) = ⊤`.
This is R.814(b) restricted to the single-agent A.2 level — it holds under both
the (SR) and (AS) success criteria, since neither agent covers any explanation. -/
theorem trap_unsolvable (p : Problem α) (X Y : Agent α)
    (h : Trap (Ω := Ω) p X Y) :
    N p X = ⊤ ∧ N p Y = ⊤ := by
  refine ⟨?_, ?_⟩
  · by_contra hN
    exact h.1 ((Axioms.A2 (Ω := Ω) p X).mp hN)
  · by_contra hN
    exact h.2 ((Axioms.A2 (Ω := Ω) p Y).mp hN)

/-! ## (3) Phase quantity -/

/-- **R.816 — phase quantity.**

The single order parameter of the trichotomy is `ℛ(p) ∩ {R ⊆ O}`: the system is
in the flywheel zone *iff* this set is nonempty. (Crossing this boundary —
losing the in-overlap explanation — is the flywheel→fragile/trap phase
transition.) -/
theorem phase_quantity_flywheel (p : Problem α) (X Y : Agent α) :
    Flywheel (Ω := Ω) p X Y
      ↔ { R' | R' ∈ (demandFamily p : Set (Set Ω))
                ∧ R' ⊆ (K X : Set Ω) ∩ (K Y : Set Ω) }.Nonempty := by
  constructor
  · rintro ⟨R', hMem, hSub⟩
    exact ⟨R', hMem, hSub⟩
  · rintro ⟨R', hMem, hSub⟩
    exact ⟨R', hMem, hSub⟩

/-- **R.816 — full trichotomy bundle.**

Exhaustiveness + the three solvability characterizations, packaged. Given any
`X, Y, p`, exactly one zone holds, and the solvability column is determined:
flywheel ⟹ both solve, fragile ⟹ one solves, trap ⟹ neither solves. -/
theorem trichotomy (p : Problem α) (X Y : Agent α) :
    (Flywheel (Ω := Ω) p X Y ∨ Fragile (Ω := Ω) p X Y ∨ Trap (Ω := Ω) p X Y)
      ∧ (Flywheel (Ω := Ω) p X Y → N p X ≠ ⊤ ∧ N p Y ≠ ⊤)
      ∧ (Fragile (Ω := Ω) p X Y → N p X ≠ ⊤ ∨ N p Y ≠ ⊤)
      ∧ (Trap (Ω := Ω) p X Y → N p X = ⊤ ∧ N p Y = ⊤) :=
  ⟨trichotomy_exhaustive p X Y,
   flywheel_solvable p X Y,
   fragile_solvable p X Y,
   trap_unsolvable p X Y⟩

end R816_FlywheelTrap

end MIP
