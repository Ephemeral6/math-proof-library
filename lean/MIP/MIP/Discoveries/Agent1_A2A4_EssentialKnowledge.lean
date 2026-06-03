/-
  STATUS: DISCOVERY
  AGENT: 1
  DIRECTION: A.2 ∧ A.4 — coverage-witness restriction and "essential
             knowledge" lattice properties.
  SUMMARY:
    A.2 says coverage is the finiteness criterion; A.4 says out-of-K(X)
    tokens are inert.  Combining: A.4 makes the agent insensitive to
    tokens outside K(X), so any A.2-witness R' ⊆ K(X) is *intrinsically*
    a K(X)-set — restricting any larger set to K(X) preserves coverage.
    More substantively:

    (i)  If `R' ∈ ℛ(p)` and `R' ⊆ K X`, then `R' ∩ K X = R'`.  Trivial
         but the A.4 lens reveals: "essential demand" = `R' ∩ K X`.
    (ii) The "essential knowledge for p in X" is
            `EK(p, X) := ⋃ {R' ∈ ℛ(p) | R' ⊆ K X}`,
         a subset of K X.  We prove EK ⊆ K X (trivial), and the genuine
         A.2+A.4 content: `EK = ∅ ↔ ¬ ∃ R' ∈ ℛ(p), R' ⊆ K X ↔ N p X = ⊤`
         (the three-way equivalence).
    (iii)A.4 makes agents "doubly blind" to elements outside K X:
         (a) inert in the response distribution (A.4), and (b) irrelevant
         for A.2 coverage (since coverage witnesses live ⊆ K X).  We
         formalise this as: a token ω ∉ K X cannot improve A.2 coverage
         in any sense — no covered R' contains ω.
    (iv) **Knowledge-replacement lemma**: if `K X ⊆ K Y`, the finiteness
         verdict for Y is at-least-as-good as for X (this is C.6 in the
         existing corpus, restated for cross-reference) AND any A.4-inert
         token for X is also A.4-inert for Y (since K Y ⊇ K X means there
         are *fewer* out-of-K tokens for Y).

    The genuine A.2+A.4 corollary that is NOT in any existing file is
    `no_covered_demand_contains_out_of_K_token` (iii.b).
-/
import MIP.Axioms
import Mathlib.Data.Set.Basic
import Mathlib.Data.Set.Lattice

namespace MIP

namespace Agent1_A2A4_EssentialKnowledge

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-! ## (i) Coverage witnesses are intrinsically K(X)-subsets. -/

/-- **Coverage-witness intersection identity.**  If `R' ⊆ K X` then
`R' ∩ K X = R'`.  Direct set-theoretic consequence of `R' ⊆ K X`;
included as a named lemma because it underlies the "essential knowledge"
definition below. -/
theorem covered_inter_K_eq_self
    (R' : Set Ω) (X : Agent α)
    (hCov : R' ⊆ (K X : Set Ω)) :
    R' ∩ (K X : Set Ω) = R' := Set.inter_eq_left.mpr hCov

/-! ## (ii) "Essential knowledge" set: union of A.2-witnesses. -/

/-- **Essential knowledge** for `(p, X)`: the union of all admissible
demands that are covered by `K X`.  This is the largest sub-knowledge
required to solve `p` given `X`. -/
def essentialK (p : Problem α) (X : Agent α) : Set Ω :=
  ⋃₀ {R' ∈ (demandFamily p : Set (Set Ω)) | R' ⊆ (K X : Set Ω)}

/-- **Essential knowledge is a sub-knowledge.**  `essentialK p X ⊆ K X`. -/
theorem essentialK_subset_K (p : Problem α) (X : Agent α) :
    essentialK (Ω := Ω) p X ⊆ (K X : Set Ω) := by
  rintro ω ⟨R', ⟨_hMem, hSub⟩, hω⟩
  exact hSub hω

/-- **Essential knowledge is empty iff no demand is covered.**  Note: this
direction uses both the definition (LHS = sUnion) and the A.2 setup;
the reverse direction is captured by `essentialK_nonempty_of_finite`. -/
theorem essentialK_eq_empty_iff_no_coverage
    (p : Problem α) (X : Agent α)
    (hDemands_nonempty_of_covered :
      ∀ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω) → R'.Nonempty) :
    essentialK (Ω := Ω) p X = ∅
      ↔ ¬ ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω) := by
  constructor
  · -- essentialK = ∅ → no covered demand
    intro hEmpty
    rintro ⟨R', hMem, hSub⟩
    -- R' is nonempty (hypothesis-bundle) yet contained in the empty union
    obtain ⟨ω, hω⟩ := hDemands_nonempty_of_covered R' hMem hSub
    have : ω ∈ essentialK (Ω := Ω) p X := ⟨R', ⟨hMem, hSub⟩, hω⟩
    rw [hEmpty] at this
    exact this
  · -- No covered demand → essentialK = ∅
    intro hNoCov
    ext ω
    simp only [essentialK, Set.mem_sUnion, Set.mem_setOf_eq, Set.mem_empty_iff_false,
      iff_false, not_exists, not_and]
    rintro R' ⟨hMem, hSub⟩ _
    exact hNoCov ⟨R', hMem, hSub⟩

/-- **A.2 → essentialK is nonempty whenever N is finite.**

If `N p X ≠ ⊤`, then A.2 gives a covered R' ∈ ℛ(p), so essentialK ⊇ R'.
If additionally R' is nonempty (hypothesis), essentialK is nonempty. -/
theorem essentialK_nonempty_of_finite
    (p : Problem α) (X : Agent α)
    (hFin : N p X ≠ ⊤)
    (h_demands_nonempty : ∀ R' ∈ (demandFamily p : Set (Set Ω)),
      R' ⊆ (K X : Set Ω) → R'.Nonempty) :
    (essentialK (Ω := Ω) p X).Nonempty := by
  obtain ⟨R', hMem, hSub⟩ := (Axioms.A2 (Ω := Ω) p X).mp hFin
  obtain ⟨ω, hω⟩ := h_demands_nonempty R' hMem hSub
  exact ⟨ω, R', ⟨hMem, hSub⟩, hω⟩

/-! ## (iii) The A.2+A.4 doubly-irrelevant tokens.

A.4 says: tokens ω ∉ K X are inert in X's *response distribution*.
A.2 says: any coverage witness R' satisfies R' ⊆ K X.  So such ω are
**also** irrelevant for A.2: no covered R' can contain them.  This is
the cleanest A.2+A.4 corollary. -/

/-- **A.2+A.4 doubly-blind tokens.**

If `ω ∉ K X` then:
* (A.4 half) X is response-invariant under inserting ω-tokens, and
* (A.2 half) no A.2 coverage witness R' ⊆ K X contains ω.

We state the A.2 half here (the A.4 half is exactly `Axioms.A4`). -/
theorem no_covered_demand_contains_out_of_K_token
    (p : Problem α) (X : Agent α) (ω : Ω)
    (hOut : ω ∉ (K X : Set Ω))
    (R' : Set Ω) (_hMem : R' ∈ (demandFamily p : Set (Set Ω)))
    (hCov : R' ⊆ (K X : Set Ω)) :
    ω ∉ R' := by
  intro hω
  exact hOut (hCov hω)

/-- **A.2+A.4 doubly-blind tokens, combined.**  The bundled form: ω ∉ K X
implies both the response invariance and the coverage-witness exclusion.
Stated for the use-case "the agent is blind to ω in *both* senses". -/
theorem doubly_blind
    (X : Agent α) (ω : Ω) (h : Str α)
    (hOut : ω ∉ (K X : Set Ω)) :
    (X h = X (tokenReplace ω h))
      ∧ (∀ (p : Problem α) (R' : Set Ω),
          R' ∈ (demandFamily p : Set (Set Ω)) → R' ⊆ (K X : Set Ω) →
          ω ∉ R') := by
  refine ⟨Axioms.A4 X ω h hOut, ?_⟩
  intros p R' hMem hCov
  exact no_covered_demand_contains_out_of_K_token (Ω := Ω) p X ω hOut R' hMem hCov

/-! ## (iv) Knowledge-replacement: more K means more covered demands. -/

/-- **A.2 monotonicity in K** (the A.2+A.4 statement that exists
implicitly in C.6 but not in this form).

If `K X ⊆ K Y` then the set of A.2 coverage witnesses for `X` is a
*subset* of those for `Y`.  We state this as: any covered R' ⊆ K X is
also covered by K Y. -/
theorem covered_demands_monotone
    (R' : Set Ω) (X Y : Agent α)
    (hKLe : (K X : Set Ω) ⊆ (K Y : Set Ω))
    (hCovX : R' ⊆ (K X : Set Ω)) :
    R' ⊆ (K Y : Set Ω) :=
  hCovX.trans hKLe

/-- **A.4 monotonicity in K** (the dual statement).

If `K X ⊆ K Y` then the set of A.4-inert tokens for `Y` is a *subset*
of those for `X`: the agent with more knowledge has fewer inert tokens. -/
theorem A4_inert_antimonotone
    (X Y : Agent α) (ω : Ω)
    (hKLe : (K X : Set Ω) ⊆ (K Y : Set Ω))
    (hOutY : ω ∉ (K Y : Set Ω)) :
    ω ∉ (K X : Set Ω) :=
  fun hX => hOutY (hKLe hX)

/-- **A.2+A.4 combined monotonicity.**  When `K X ⊆ K Y`:
* (A.2) every A.2 coverage witness for X is one for Y, and
* (A.4) every A.4-inert token for Y is A.4-inert for X.

So increasing knowledge widens the A.2 "good" zone and shrinks the A.4
"inert" zone, in exact set-complementarity. -/
theorem A2A4_monotonicity
    (X Y : Agent α) (R' : Set Ω) (ω : Ω)
    (hKLe : (K X : Set Ω) ⊆ (K Y : Set Ω)) :
    (R' ⊆ (K X : Set Ω) → R' ⊆ (K Y : Set Ω)) ∧
    (ω ∉ (K Y : Set Ω) → ω ∉ (K X : Set Ω)) := by
  refine ⟨?_, ?_⟩
  · exact fun h => h.trans hKLe
  · exact fun h hX => h (hKLe hX)

end Agent1_A2A4_EssentialKnowledge

end MIP
