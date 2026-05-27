/-
Result R.801 = T.33 — Universal Expert Accessibility (UEA).

Reference: `proofs/derived/A4_grade.md` §R.801 (= T.33, A 无条件).

**Statement.** A.3's "`K(e) ⊆ K(A)`" premise is *removable* under A.4: for any
expert intervention `e ∈ Σ* \ M`, any history `h`, and any `ε > 0`, there is a
meta-cognitive sequence `(m₁,…,m_k) ∈ M^k` of length `k ≤ C_{e'}·log(1/ε)` with

    d_TV( L(π(r) | h·e),  L(π(r') | h·m₁···m_k) ) < ε ,

where `e' := Restr_{K(A)}(e)` is the `K(A)`-projection of `e`.  The premise
`K(e) ⊆ K(A)` of A.3 is *not* required of `e` itself.

**Proof (three steps).**
* (Step 1 — A.4 projection.)  Replacing every token of the augmented history
  `h·e` lying outside `K(A)` leaves `X`'s output unchanged (iterate A.4); the
  tokens of `e` outside `K(A)` are exactly the ones stripped to form `e'`, so
  `X(h·e) = X(h·e')`, and the projection `e'` satisfies `K(e') ⊆ K(A)` (the
  out-of-`K` part is invisible).
* (Step 2 — A.3 on `e'`.)  Since `e'` meets A.3's premise
  `expertKnowledge e' ⊆ K X`, A.3 supplies a meta-sequence `ms ⊆ M` with
  `|ms| ≤ C_{e'}·log(1/ε)` and `d_TV(X(h·e'), X(h·ms)) ≤ ε`.
* (Step 3 — combine.)  By Step 1 `X(h·e) = X(h·e')`, so the TV bound transports
  to `d_TV(X(h·e), X(h·ms)) ≤ ε`, *without* assuming `K(e) ⊆ K(A)`.

**MIP axioms used.** `MIP.Axioms.A4` (Step 1 projection invariance) and
`MIP.Axioms.A3` (Step 2 meta-sequence existence on the projection).  No new
`axiom` is introduced.

**Lean kernel.** The `K(A)`-projection of the augmented history is modelled, as
in R.802, by a finite fold `projectOut` of out-of-`K` token replacements (the
`Restr_{K(A)}` operator lifted to the whole history `h·e`).
`projection_invariance` is the Step-1 A.4 iteration; `uea_core` is the
"projection satisfies A.3's premise + A.3 applies" lemma; `uea` is the bundled
accessibility statement with the length and TV-distance bounds and *no*
`K(e) ⊆ K(A)` precondition on `e`.
-/
import MIP.Axioms

namespace MIP

namespace UniversalExpertAccessibility

open MIP.Axioms

variable {α Ω : Type}

/-- The `Restr_{K(A)}` projection fold (mirrors R.802's `replaceOutside`,
redefined locally so the file stands alone).

`projectOut s ωs` applies `τ_{ω₁} ∘ ⋯ ∘ τ_{ωₙ}` to the history `s`, substituting
the out-of-`K(A)` tokens `ωs` by their placeholder images.  Applied to the
augmented history `h·e` with `ωs = tokens(e) \ K(A)`, it produces `h·e'` where
`e' = Restr_{K(A)}(e)`. -/
def projectOut (s : Str α) (ωs : List Ω) : Str α :=
  List.foldr tokenReplace s ωs

@[simp] theorem projectOut_nil (s : Str α) :
    projectOut s ([] : List Ω) = s := rfl

@[simp] theorem projectOut_cons (s : Str α) (ω : Ω) (ωs : List Ω) :
    projectOut s (ω :: ωs) = tokenReplace ω (projectOut s ωs) := rfl

/-- **R.801 Step 1 — A.4 projection invariance.**

If every token in `ωs` lies outside `K(X)`, then `X`'s output on the history
`s` agrees with its output on the projected history `projectOut s ωs`.  This is
the iteration of A.4 that turns `X(h·e)` into `X(h·e')`. -/
theorem projection_invariance
    (X : Agent α) (s : Str α) (ωs : List Ω)
    (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω)) :
    X s = X (projectOut s ωs) := by
  induction ωs with
  | nil => rfl
  | cons ω rest ih =>
    have hOut_rest : ∀ ω' ∈ rest, ω' ∉ (K X : Set Ω) :=
      fun ω' hω' => hOut ω' (List.mem_cons_of_mem ω hω')
    have hOut_head : ω ∉ (K X : Set Ω) := hOut ω (List.mem_cons_self ..)
    calc
      X s = X (projectOut s rest) := ih hOut_rest
      _ = X (tokenReplace ω (projectOut s rest)) :=
            Axioms.A4 X ω (projectOut s rest) hOut_head
      _ = X (projectOut s (ω :: rest)) := by rw [projectOut_cons]

/-- **R.801 core — the projection `e'` satisfies A.3's premise, so A.3 applies.**

Let `e ∈ Σ* \ M` be an expert intervention and `e' := Restr_{K(A)}(e)` its
`K(X)`-projection.  The hypotheses are:

* `hMem' : e' ∉ M` — the projection is still a non-meta (expert) string;
* `hCover' : expertKnowledge e' ⊆ K X` — the Step-1 fact `K(e') ⊆ K(A)`
  (`Restr`'s defining property; the generalized L.F corollary (1)).

Then A.3 (applied to `e'`, *not* `e`) yields a meta-sequence `ms ⊆ M` with the
length bound `|ms| ≤ C_{e'}·log(1/ε)` and `d_TV(X(h·e'), X(h·ms)) ≤ ε`.  The
point is that A.3's premise is discharged for `e'` even when it *fails* for `e`. -/
theorem uea_core
    (X : Agent α) (e' h : Str α) (ε : NNReal) (hε : 0 < ε)
    (hMem' : e' ∉ (MetaSet : Set (Str α)))
    (hCover' : (expertKnowledge e' : Set Ω) ⊆ (K X : Set Ω)) :
    ∃ (ms : List (Str α)),
      (∀ m ∈ ms, m ∈ (MetaSet : Set (Str α)))
        ∧ (ms.length : ℝ) ≤ (Cₑ e' : ℝ) * Real.log (1 / (ε : ℝ))
        ∧ tvDist
              (X (extendHist h e'))
              (X (extendHist h (ms.foldl List.append []))) ≤ ε :=
  Axioms.A3 (Ω := Ω) X e' h ε hε hMem' hCover'

/-- **R.801 = T.33 (UEA) — Universal Expert Accessibility.**

For *any* expert intervention `e ∈ Σ* \ M` (with **no** `K(e) ⊆ K(A)`
precondition), any history `h`, and any `ε > 0`, there is a meta-cognitive
sequence `ms ⊆ M` of length `≤ C_{e'}·log(1/ε)` whose effect after `h` is within
total-variation distance `ε` of `e`'s effect:

    d_TV( X(h·e),  X(h·ms) ) ≤ ε ,        with `e' := Restr_{K(A)}(e)`.

The `K(e) ⊆ K(A)` premise of A.3 is replaced by the *projection* data, stated at
the level of the augmented histories `H := h·e` and `H' := h·e'` (this avoids
assuming `τ_ω` commutes with the prefix `h` — exactly the R.802 modelling):
* `ωs` — the out-of-`K(X)` tokens of `e`, with `hOut : ∀ ω ∈ ωs, ω ∉ K X`;
* `hProj : extendHist h e' = projectOut (extendHist h e) ωs` — the augmented
  history `h·e'` is the `K(X)`-projection of `h·e`;
* `hMem'`, `hCover'` — the projection `e'` lies in `Σ* \ M` and meets A.3's
  premise.

Step 1 (A.4 via `projection_invariance`) gives `X(h·e) = X(h·e')`; Step 2 (A.3
via `uea_core`) bounds `d_TV(X(h·e'), X(h·ms))`; Step 3 combines them.  The TV
bound on `e` itself holds with the A.3 premise discharged on the
*invisible-stripped* `e'`. -/
theorem uea
    (X : Agent α) (e e' h : Str α) (ε : NNReal) (hε : 0 < ε)
    (ωs : List Ω)
    (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω))
    (hProj : extendHist h e' = projectOut (extendHist h e) ωs)
    (hMem' : e' ∉ (MetaSet : Set (Str α)))
    (hCover' : (expertKnowledge e' : Set Ω) ⊆ (K X : Set Ω)) :
    ∃ (ms : List (Str α)),
      (∀ m ∈ ms, m ∈ (MetaSet : Set (Str α)))
        ∧ (ms.length : ℝ) ≤ (Cₑ e' : ℝ) * Real.log (1 / (ε : ℝ))
        ∧ tvDist
              (X (extendHist h e))
              (X (extendHist h (ms.foldl List.append []))) ≤ ε := by
  -- Step 2: A.3 on the projection `e'` (its premise is discharged).
  obtain ⟨ms, hMs, hLen, hTV⟩ := uea_core (Ω := Ω) X e' h ε hε hMem' hCover'
  refine ⟨ms, hMs, hLen, ?_⟩
  -- Step 1: A.4 projection invariance gives `X(h·e) = X(h·e')`.
  have hEq : X (extendHist h e) = X (extendHist h e') := by
    rw [hProj]
    exact projection_invariance X (extendHist h e) ωs hOut
  -- Step 3: transport the TV bound through `hEq`.
  rw [hEq]
  exact hTV

end UniversalExpertAccessibility

end MIP
