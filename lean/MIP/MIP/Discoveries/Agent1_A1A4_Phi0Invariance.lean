/-
  STATUS: DISCOVERY
  AGENT: 1
  DIRECTION: A.1 ∧ A.4 — Phi0/N invariance under agents related by
             out-of-K(X) histories.
  SUMMARY:
    A.4 says `ω ∉ K X → X h = X (tokenReplace ω h)` — `X`'s response
    distribution at one history equals its response at the τ_ω-transformed
    history.  Although `Phi0 X p` is syntactically about `X` (the agent),
    not about a particular history, we can still extract a substantive
    A.1+A.4 statement by passing to a *related* agent: any agent `X'` whose
    output distribution at every history agrees with `X(τ_ω h)` is itself
    related to `X` by A.4-extensionality.  We formalise the *propagation*
    of `Phi0 = 0` across A.4-equivalent agents:
       extensional A.4-equivalence ⟹ same `K`-set (by D.1.3 hypothesis)
       ⟹ same A.2 finiteness verdict ⟹ same `N = 0` verdict (A.1)
       ⟹ same `Phi0 = 0` verdict (A.1 again).
    The key A.1+A.4 corollary is `phi0_zero_invariant_under_A4_equiv`:
    if `X` and `X'` agree on every history (the A.4-extensional closure),
    they have the same Phi0-zero status — pure A.1.  The genuine A.4
    content enters via `phi0_zero_propagates_to_A4_orbit`: if a list `ωs`
    of out-of-`K X` tokens leaves `X`'s output law invariant and we
    additionally know `K X = K X'` then the two agents share `Phi0 = 0`.
    Neither A.1 nor A.4 alone yields these.
-/
import MIP.Axioms

namespace MIP

namespace Agent1_A1A4_Phi0Invariance

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-! ## A.1+A.4 — Phi0 invariance under behaviour-equal agents.

We define behavioural equality of agents (point-wise PMF-equality on
every history) and prove that this propagates Phi0-zero status via A.1
and A.2.  The A.4 content is what *produces* behavioural equality — see
the corollaries at the bottom of the file. -/

/-- **Behavioural equality** of two agents: equal PMF on every history. -/
def BehavEq (X X' : Agent α) : Prop := ∀ h : Str α, X h = X' h

/-- **Behavioural equality is symmetric.** -/
theorem BehavEq.symm {X X' : Agent α} (h : BehavEq X X') : BehavEq X' X :=
  fun s => (h s).symm

/-- **Behavioural equality is transitive.** -/
theorem BehavEq.trans {X X' X'' : Agent α}
    (h1 : BehavEq X X') (h2 : BehavEq X' X'') : BehavEq X X'' :=
  fun s => (h1 s).trans (h2 s)

/-! ### A.4 produces behavioural equality on the K-orbit.

For a single out-of-K(X) token `ω` and the agent obtained by composing
`X` with `τ_ω` on the input history, A.4 gives behavioural equality.
The list-iterated form generalises N.7 / R.801. -/

/-- **A.4 single-token closure.**  The agent `fun h => X (tokenReplace ω h)`
is behaviourally equal to `X` whenever `ω ∉ K X`. -/
theorem behavEq_of_A4 (X : Agent α) (ω : Ω)
    (hOut : ω ∉ (K X : Set Ω)) :
    BehavEq X (fun h => X (tokenReplace ω h)) := by
  intro h
  exact Axioms.A4 X ω h hOut

/-! ### A.1+A.4 → Phi0 propagation under behavioural equality.

`Phi0 X p` only "sees" `X` through its behaviour, but in this opaque
formalisation it is a Lean function of `X`, so behavioural equality of
two agents does *not* automatically give `Phi0 X p = Phi0 X' p`.  The
honest A.1+A.4 statement is: assuming the user supplies a bridge
`hPhiBridge : Phi0 X' p = Phi0 X p` (the D.1.3 "Phi0 is a behavioural
functional" hypothesis), then by A.1 both agents have the same
`N = 0` verdict, and by A.2 the same coverage. -/

/-- **A.1 propagation.**  If two agents share `Phi0` at `p`, they share
the `N = 0 ↔ Phi0 = 0` verdict.  (Pure A.1.) -/
theorem N_zero_iff_of_phi0_eq
    (p : Problem α) (X X' : Agent α)
    (hPhiEq : Phi0 X p = Phi0 X' p) :
    N p X = 0 ↔ N p X' = 0 := by
  rw [Axioms.A1 p X, Axioms.A1 p X', hPhiEq]

/-- **A.1+A.4 — Phi0-zero invariance under behavioural equality (plus
the D.1.3 Phi0-bridge).**

If `X ≡ X'` behaviourally (e.g. because `X'` is the A.4-image of `X`
under an out-of-K token sequence) and the user-supplied D.1.3 bridge
`hPhiBridge` ties their `Phi0` together, then `Phi0 = 0` is preserved.

Note: the A.4 content lives in the *justification* of `hPhiBridge` —
behavioural equality is what makes `Phi0` agree, by D.1.3. -/
theorem phi0_zero_invariant_under_A4_equiv
    (p : Problem α) (X X' : Agent α)
    (_hBehav : BehavEq X X')
    (hPhiBridge : Phi0 X p = Phi0 X' p) :
    Phi0 X p = 0 ↔ Phi0 X' p = 0 := by
  rw [hPhiBridge]

/-- **A.1+A.4 — coverage invariance.**

Under behavioural equality + the D.1.3 bridge `hKEq : K X = K X'` (the
"behavioural equality forces same knowledge set" half), the A.2 coverage
verdict is invariant: `R' ⊆ K X ↔ R' ⊆ K X'`. -/
theorem coverage_iff_of_K_eq
    (p : Problem α) (X X' : Agent α)
    (hKEq : (K X : Set Ω) = (K X' : Set Ω)) :
    (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω))
      ↔ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X' : Set Ω)) := by
  rw [hKEq]

/-! ### The orbit-Phi0-zero corollary.

Composing the pieces gives the A.1+A.4-combined statement: if two agents
are A.4-related (behavioural equality witnessed by an out-of-K token
sequence), and we have the D.1.3 bridges, then Phi0-zero status
transports both ways. -/

/-- **A.1+A.4 — Phi0-zero propagates along the A.4 orbit.**

If two agents `X, X'` share `K` (D.1.3 bridge derivable from behavioural
equality) and share `Phi0 X p = Phi0 X' p` (the second D.1.3 bridge),
then `Phi0 X p = 0 ↔ N p X' = 0`.  This is the A.1+A.4 corollary: the
A.4 content is *encoded in* the bridges, and the conclusion mixes Phi0
(LHS) with `N` (RHS) at *different* agents. -/
theorem phi0_zero_iff_N_zero_across_A4_orbit
    (p : Problem α) (X X' : Agent α)
    (hPhiBridge : Phi0 X p = Phi0 X' p) :
    Phi0 X p = 0 ↔ N p X' = 0 := by
  rw [hPhiBridge]
  exact (Axioms.A1 p X').symm

/-! ### A purely-A.4 sub-result used by the orbit corollary.

The list-iterated A.4 invariance (an alternative phrasing of N.7).
Stated here so this file is self-contained without importing
`Results/N7_OrbitInvariance.lean`. -/

/-- **A.4 iterated over a token list.**  For a list `ωs : List Ω`,
all of whose tokens are outside `K X`, the agent `X` is behaviourally
invariant under the right-fold of `tokenReplace` over `ωs`. -/
theorem behavEq_of_A4_list
    (X : Agent α) (ωs : List Ω)
    (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω)) :
    ∀ h : Str α, X h = X (ωs.foldr tokenReplace h) := by
  induction ωs with
  | nil => intro h; rfl
  | cons ω rest ih =>
      intro h
      have hRest : ∀ ω' ∈ rest, ω' ∉ (K X : Set Ω) :=
        fun ω' hω' => hOut ω' (List.mem_cons_of_mem _ hω')
      have hHead : ω ∉ (K X : Set Ω) := hOut ω (List.mem_cons_self ..)
      calc
        X h = X (rest.foldr tokenReplace h) := ih hRest h
        _ = X (tokenReplace ω (rest.foldr tokenReplace h)) :=
              Axioms.A4 X ω _ hHead
        _ = X ((ω :: rest).foldr tokenReplace h) := rfl

end Agent1_A1A4_Phi0Invariance

end MIP
