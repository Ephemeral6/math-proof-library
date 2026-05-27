/-
Result R.815 — No-Injection / Activation-Only Theorem.
Reference: branches/collaboration_dynamics/results/joint_coverage.md R.815 (A 无条件, audited 2026-05-27).

**Statement.** For agents `X, Y` satisfying A.4, under *pure dialogue* (no
parameter update): `ω ∉ K(X) ⟹ ∀ h, 𝓛(X(h)) = 𝓛(X(τ_ω(h)))`. Corollary:
pure dialogue cannot inject `ω ∈ K(Y) \ K(X)` into `X`; it can only *activate*
(A.3 recombination of elements already inside `K(X)`), never expand `|K(X)|`.
Knowledge growth comes only from the training operator acting on external data.

**Kernel formalized here.** The no-injection identity is the *direct* content
of A.4: any token replacement for an out-of-`K(X)` element is inert on `X`'s
output distribution at every history `h` (`no_injection_step`). We then iterate
this over a *list* of out-of-`K(X)` tokens (`no_injection_seq`) — modelling a
whole dialogue turn from `Y` consisting only of `ω`-tokens with `ω ∉ K(X)`,
which leaves `X`'s output law unchanged. The key collaboration instance: for
`ω ∈ K(Y) \ K(X)`, `Y` emitting `ω` is inert on `X` (`no_injection_cross`), so
`K(X)` is invariant under dialogue with `Y`.

**Bridge.** "K(X) not expanded" = the output law (hence its support K(X), via
D.1.3) is fixed under all such inert insertions; activation (A.3) only
recombines `e` with `K(e) ⊆ K(X)`, never adding a new element to `K(X)`.

Axiom-free (only A.1–A.4).
-/
import MIP.Axioms

namespace MIP

namespace R815_NoInjection

open MIP.Axioms

variable {α Ω : Type}

/-- **R.815 (per-token, no-injection step).**

The direct A.4 statement: if `ω ∉ K(X)` then inserting an `ω`-token into any
history `h` (the operator `τ_ω`) leaves `X`'s output distribution unchanged.
`Y` "saying `ω`" to `X` when `ω ∉ K(X)` is *inert*. -/
theorem no_injection_step
    (X : Agent α) (ω : Ω) (h : Str α)
    (hOut : ω ∉ (K X : Set Ω)) :
    X h = X (tokenReplace ω h) :=
  Axioms.A4 X ω h hOut

/-- **R.815 (cross-agent instance).**

The collaboration form: for `ω ∈ K(Y) \ K(X)` — an element `Y` knows but `X`
does not — `Y` emitting `ω` into the dialogue is inert on `X`'s output law.
This is exactly the "transport bottleneck": `X` cannot acquire `ω` by dialogue.

Hypotheses bundle the membership `ω ∈ K Y` and non-membership `ω ∉ K X` as the
set-difference condition `ω ∈ K Y \ K X`. -/
theorem no_injection_cross
    (X Y : Agent α) (ω : Ω) (h : Str α)
    (hCross : ω ∈ ((K Y : Set Ω) \ (K X : Set Ω))) :
    X h = X (tokenReplace ω h) :=
  Axioms.A4 X ω h hCross.2

/-- **R.815 (iterated, dialogue-turn form).**

A whole dialogue turn from `Y` is a *list* `ωs : List Ω` of knowledge tokens.
If **every** token in the turn lies outside `K(X)`, then folding the
`τ`-insertions across the entire turn leaves `X`'s output law unchanged at
every history — `X(h) = X(foldr τ over ωs of h)`. Pure dialogue consisting of
elements `X` does not know is globally inert.

Proof: induction on the token list, each step is `no_injection_step`. -/
theorem no_injection_seq
    (X : Agent α) (ωs : List Ω) (h : Str α)
    (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω)) :
    X h = X (ωs.foldr (fun ω hh => tokenReplace ω hh) h) := by
  induction ωs with
  | nil => rfl
  | cons ω rest ih =>
    -- Output law is unchanged across the inner `rest` insertions …
    have hRest : ∀ ω ∈ rest, ω ∉ (K X : Set Ω) := fun ω hω =>
      hOut ω (List.mem_cons_of_mem _ hω)
    have hHead : ω ∉ (K X : Set Ω) := hOut ω (List.mem_cons_self ..)
    -- … and then the head `τ_ω` insertion is itself inert by A.4.
    calc
      X h = X (rest.foldr (fun ω hh => tokenReplace ω hh) h) := ih hRest
      _ = X (tokenReplace ω (rest.foldr (fun ω hh => tokenReplace ω hh) h)) :=
            Axioms.A4 X ω _ hHead
      _ = X ((ω :: rest).foldr (fun ω hh => tokenReplace ω hh) h) := rfl

/-- **R.815 (no-expansion corollary, A.2 form).**

Because pure dialogue does not change `X`'s output distribution on any history
for out-of-`K(X)` tokens, it cannot change `K(X)` (the output support, D.1.3),
hence cannot change which abductive explanations of a problem `p` lie inside
`K(X)`. Concretely: solvability of `p` by `X` (A.2) is *exactly* a statement
about `K X`, so any dialogue that leaves `K X` fixed leaves solvability fixed.

We state the invariance against an explicit hypothesis `h_K : K X' = K X`
recording that the post-dialogue agent `X'` has the *same* knowledge set
(the no-injection conclusion at the knowledge-set level). Then `N(p, X') < ∞ ⟺
N(p, X) < ∞`: dialogue never turns an A.2 failure into a success. -/
theorem no_injection_solvability_invariant
    (p : Problem α) (X X' : Agent α)
    (h_K : (K X' : Set Ω) = (K X : Set Ω)) :
    N p X' ≠ ⊤ ↔ N p X ≠ ⊤ := by
  rw [Axioms.A2 (Ω := Ω) p X', Axioms.A2 (Ω := Ω) p X, h_K]

end R815_NoInjection

end MIP
