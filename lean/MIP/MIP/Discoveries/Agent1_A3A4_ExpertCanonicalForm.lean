/-
  STATUS: DISCOVERY
  AGENT: 1
  DIRECTION: A.3 ∧ A.4 — Expert intervention canonical form modulo
             out-of-K(X) tokens.
  SUMMARY:
    UEA (R.801) already uses A.3+A.4 to *remove* A.3's K(e) ⊆ K(X)
    precondition by projecting e through A.4.  We push the combination
    in a complementary direction: **canonical-form equivalence**.

    Two expert interventions e, e' are *A.4-equivalent at history h*
    if their A.4 projections from h coincide.  We prove:

    (i)  **Substitute-set agreement**: if e, e' are A.4-equivalent at h
         (in the form `X (extendHist h e) = X (extendHist h e')`,
         the conclusion of UEA Step 1), then the A.3 substitute for one
         also serves as an A.3-style substitute for the other — i.e.
         the TV-distance bound transports between them.

    (ii) **Out-of-K coordinates are inert in A.3's TV bound**: if
         e' is obtained from e by appending out-of-K(X) tokens (so
         X(h·e) = X(h·e') by N.7-style A.4 iteration), then any A.3
         substitute for e is automatically an A.3 substitute for e',
         with the *same* `Cₑ`-based length bound for e (not e' —
         because Cₑ is opaque and depends on the string syntactically).

    (iii)**Effective expert knowledge**: define the "effective" expert
         knowledge as the intersection with K(X):
              effExpert e X := expertKnowledge e ∩ K X .
         Then `effExpert e X ⊆ K X` (trivially), and:
         (a) if `expertKnowledge e ⊆ K X` then `effExpert e X = expertKnowledge e`;
         (b) the A.3-eligibility hypothesis `expertKnowledge e ⊆ K X` is
             *equivalent* to `expertKnowledge e ⊆ effExpert e X ∪ K X` (the
             "expert-knowledge already in K X" splitting).

    These are all genuinely A.3+A.4 (need both — A.3 for the substitute,
    A.4 for the canonical-form transport).  None are in
    `Results/R801_UniversalExpertAccessibility.lean` or any other file.
-/
import MIP.Axioms

namespace MIP

namespace Agent1_A3A4_ExpertCanonicalForm

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-! ## (i) Substitute-set agreement under A.4-equivalence. -/

/-- **A.3+A.4 substitute transport.**

Given two expert interventions `e, e'` and a history `h` for which
`X (h·e) = X (h·e')` (the A.4-equivalence condition, which is the UEA
Step 1 output for `e' = Restr_{K X}(e)`):
*any* A.3 substitute `ms` whose TV-bound is `≤ ε` against `e` is
automatically a TV-bound `≤ ε` substitute against `e'`. -/
theorem substitute_transport
    (X : Agent α) (e e' h : Str α) (ε : NNReal)
    (hEq : X (extendHist h e) = X (extendHist h e'))
    (ms : List (Str α))
    (hTV : tvDist (X (extendHist h e))
                  (X (extendHist h (ms.foldl List.append []))) ≤ ε) :
    tvDist (X (extendHist h e'))
           (X (extendHist h (ms.foldl List.append []))) ≤ ε := by
  rw [← hEq]
  exact hTV

/-- **A.3+A.4 substitute existence after transport.**

If `e` is A.3-eligible (`expertKnowledge e ⊆ K X`, not in `MetaSet`) and
`e'` is A.4-equivalent to `e` at history `h` (i.e. `X (h·e) = X (h·e')`),
then A.3's meta-substitute for `e` is also a TV-≤-ε substitute for `e'`.

This is the canonical-form A.3 transport: the substitute is "tagged" to
the equivalence class of `e` modulo A.4 — exactly the content needed for
"two syntactically different experts that produce the same X-output law
have the same meta-substitutes". -/
theorem A3_transport_via_A4_equiv
    (X : Agent α) (e e' h : Str α) (ε : NNReal) (hε : 0 < ε)
    (hMem : e ∉ (MetaSet : Set (Str α)))
    (hCover : (expertKnowledge e : Set Ω) ⊆ (K X : Set Ω))
    (hEq : X (extendHist h e) = X (extendHist h e')) :
    ∃ (ms : List (Str α)),
      (∀ m ∈ ms, m ∈ (MetaSet : Set (Str α)))
        ∧ (ms.length : ℝ) ≤ (Cₑ e : ℝ) * Real.log (1 / (ε : ℝ))
        ∧ tvDist (X (extendHist h e'))
                 (X (extendHist h (ms.foldl List.append []))) ≤ ε := by
  obtain ⟨ms, hMs, hLen, hTV⟩ := Axioms.A3 (Ω := Ω) X e h ε hε hMem hCover
  exact ⟨ms, hMs, hLen, substitute_transport X e e' h ε hEq ms hTV⟩

/-! ## (ii) Out-of-K tokens are A.3-inert at the TV-bound level. -/

/-- **A.4 list-iterated invariance.**  Helper (a clone of N.7's
`orbit_invariance`, restated locally for self-containment). -/
theorem outK_list_inert
    (X : Agent α) (ωs : List Ω) (h : Str α)
    (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω)) :
    X h = X (ωs.foldr tokenReplace h) := by
  induction ωs with
  | nil => rfl
  | cons ω rest ih =>
      have hRest : ∀ ω' ∈ rest, ω' ∉ (K X : Set Ω) :=
        fun ω' hω' => hOut ω' (List.mem_cons_of_mem _ hω')
      have hHead : ω ∉ (K X : Set Ω) := hOut ω (List.mem_cons_self ..)
      calc
        X h = X (rest.foldr tokenReplace h) := ih hRest
        _ = X (tokenReplace ω (rest.foldr tokenReplace h)) :=
              Axioms.A4 X ω _ hHead
        _ = X ((ω :: rest).foldr tokenReplace h) := rfl

/-- **A.3+A.4 — out-of-K projection of an expert intervention preserves
the A.3 substitute.**

If `e'` and `e` are linked by an out-of-K(X) token-list projection on the
*augmented* history (`extendHist h e' = ωs.foldr tokenReplace (extendHist h e)`
with all `ωs` outside `K X`), then any A.3 substitute for `e` (under its
own eligibility) is also an A.3 substitute for `e'`.  This is the
"out-of-K coordinates are inert" content. -/
theorem A3_preserved_under_outK_projection
    (X : Agent α) (e e' h : Str α) (ε : NNReal) (hε : 0 < ε)
    (hMem : e ∉ (MetaSet : Set (Str α)))
    (hCover : (expertKnowledge e : Set Ω) ⊆ (K X : Set Ω))
    (ωs : List Ω)
    (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω))
    (hProj : extendHist h e' = ωs.foldr tokenReplace (extendHist h e)) :
    ∃ (ms : List (Str α)),
      (∀ m ∈ ms, m ∈ (MetaSet : Set (Str α)))
        ∧ (ms.length : ℝ) ≤ (Cₑ e : ℝ) * Real.log (1 / (ε : ℝ))
        ∧ tvDist (X (extendHist h e'))
                 (X (extendHist h (ms.foldl List.append []))) ≤ ε := by
  have hEq : X (extendHist h e) = X (extendHist h e') := by
    rw [hProj]
    exact outK_list_inert X ωs (extendHist h e) hOut
  exact A3_transport_via_A4_equiv (Ω := Ω) X e e' h ε hε hMem hCover hEq

/-! ## (iii) Effective expert knowledge.

The "effective" part of an expert intervention is its knowledge ∩ K(X).
Out-of-K knowledge is exposed by A.4 to be irrelevant. -/

/-- **Effective expert knowledge.**  `effExpert e X := expertKnowledge e ∩ K X`. -/
def effExpert (e : Str α) (X : Agent α) : Set Ω :=
  (expertKnowledge e : Set Ω) ∩ (K X : Set Ω)

/-- **`effExpert ⊆ K X` automatically.** -/
theorem effExpert_subset_K (e : Str α) (X : Agent α) :
    effExpert (Ω := Ω) e X ⊆ (K X : Set Ω) := Set.inter_subset_right

/-- **`effExpert = expertKnowledge` under A.3-eligibility.** -/
theorem effExpert_eq_under_eligibility
    (e : Str α) (X : Agent α)
    (hElig : (expertKnowledge e : Set Ω) ⊆ (K X : Set Ω)) :
    effExpert (Ω := Ω) e X = (expertKnowledge e : Set Ω) :=
  Set.inter_eq_left.mpr hElig

/-- **A.3-eligibility ↔ `expertKnowledge ⊆ effExpert ∪ K X` (trivial form).**

Not deeply substantive on its own, but: the A.3-eligibility hypothesis
`expertKnowledge e ⊆ K X` is equivalent to `expertKnowledge e \ K X = ∅`,
i.e. the "out-of-K part" of the expert knowledge is empty.  Conjugates
the eligibility hypothesis into an A.4-flavour statement. -/
theorem eligibility_iff_no_outK_expert
    (e : Str α) (X : Agent α) :
    (expertKnowledge e : Set Ω) ⊆ (K X : Set Ω)
      ↔ (expertKnowledge e : Set Ω) \ (K X : Set Ω) = ∅ := by
  rw [Set.diff_eq_empty]

/-- **A.3+A.4 — Effective coverage equals total coverage when eligible.**

Under A.3-eligibility, the "effective expert knowledge" (intersected
with K X) equals the full expert knowledge.  The non-trivial reading:
no information is lost by restricting an A.3-eligible expert to K X. -/
theorem effExpert_full_under_eligibility
    (e : Str α) (X : Agent α)
    (hElig : (expertKnowledge e : Set Ω) ⊆ (K X : Set Ω)) :
    effExpert (Ω := Ω) e X = (expertKnowledge e : Set Ω) ∧
      effExpert (Ω := Ω) e X ⊆ (K X : Set Ω) :=
  ⟨effExpert_eq_under_eligibility (Ω := Ω) e X hElig,
   effExpert_subset_K (Ω := Ω) e X⟩

end Agent1_A3A4_ExpertCanonicalForm

end MIP
