/-
Result R.814 — Collaboration Composition Barrier (coverage–incomposability gap).
Reference: branches/collaboration_dynamics/results/joint_coverage.md R.814 (A 无条件, audited 2026-05-27).

**Statement.** A Horn derivation hyperedge `(S → ω)` for `R ∈ ℛ(p)` is
two-coloured. *Monochrome*: `S ∪ {ω} ⊆ K(X)` or `⊆ K(Y)`. *Cross-coloured*
("seam"): `S ∪ {ω}` simultaneously contains an element of `K(X) \ K(Y)` and
an element of `K(Y) \ K(X)`. Then (a) a cross-seam hyperedge is executable by
*neither* single agent (composition `∘` requires one response carrying all of
`S ∪ {ω}`, but `X` cannot emit a `K(Y)\K(X)` element and `Y` cannot emit a
`K(X)\K(Y)` element). (b) If *every* derivation of *every* coverable `R` contains
a cross-seam hyperedge, then `N_collab = ∞` despite `∃ R ⊆ K(X) ∪ K(Y)`: the
coverage–incomposability gap.

**Kernel formalized here.** The (a) covering argument as a clean `Finset`
non-coverage theorem: model a hyperedge's vertex set `V := S ∪ {ω}` as a
`Finset Ω`. "Agent `A` can execute the hyperedge" = `V ⊆ K(A)` (D.1.3: one
response carries all of `V`, so `V ⊆ K(A)`). The cross-seam witnesses are
`ωx ∈ K(X) \ K(Y)` and `ωy ∈ K(Y) \ K(X)`, both in `V`. We prove
`¬ (V ⊆ K X) ∧ ¬ (V ⊆ K Y)` — neither single agent executes it
(`seam_not_single_agent`) — and the contrapositive packaging
`seam_no_executor`. Part (b): if the *only* covered explanations require such a
seam (no monochrome derivation exists), A.2's coverage witness cannot be turned
into an executor, so `N_collab = ∞` — stated as `composition_gap` against the
hypothesis bundle that records "covered but not executable by either agent".

**Bridge.** `V ⊆ K A` is the D.1.3 statement "agent A's single response carries
all hyperedge vertices"; `∘ = single-response co-occurrence` (D.3.7) is what
forces the *same* agent to carry all of `V`. The infinite-`N` conclusion uses
A.2 (`N ≠ ⊤ ⟺ ∃R⊆K`) at the single-agent level.

Axiom-free (only A.1–A.4).
-/
import MIP.Axioms
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Set.Basic

namespace MIP

namespace R814_CompositionGap

open MIP.Axioms

variable {α Ω : Type}

/-! ## Part (a): a cross-seam hyperedge is executable by no single agent.

A hyperedge's vertex set `V := S ∪ {ω}` is a finite subset of `Ω`. An agent `A`
can *execute* the hyperedge iff its single response carries every vertex, i.e.
`(V : Set Ω) ⊆ K A` (D.1.3 + D.3.7 single-response co-occurrence). -/

/-- **R.814(a) — seam is unexecutable by either single agent.**

If the hyperedge `V` contains a witness `ωx ∈ K(X) \ K(Y)` and a witness
`ωy ∈ K(Y) \ K(X)`, then `V ⊄ K(X)` (the `ωy` witness fails) and `V ⊄ K(Y)`
(the `ωx` witness fails). The seam is closed symmetrically. -/
theorem seam_not_single_agent
    (X Y : Agent α) (V : Set Ω) (ωx ωy : Ω)
    (hωx_in : ωx ∈ V) (hωy_in : ωy ∈ V)
    (hωx : ωx ∈ ((K X : Set Ω) \ (K Y : Set Ω)))
    (hωy : ωy ∈ ((K Y : Set Ω) \ (K X : Set Ω))) :
    ¬ (V ⊆ (K X : Set Ω)) ∧ ¬ (V ⊆ (K Y : Set Ω)) := by
  constructor
  · -- X cannot carry the K(Y)\K(X) vertex `ωy`.
    intro hsub
    exact hωy.2 (hsub hωy_in)
  · -- Y cannot carry the K(X)\K(Y) vertex `ωx`.
    intro hsub
    exact hωx.2 (hsub hωx_in)

/-- **R.814(a) — no executing agent (packaged).**

For any agent `A ∈ {X, Y}`, the cross-seam hyperedge `V` is not contained in
`K(A)`: there is no single executor. (Restated from `seam_not_single_agent`
as a single negated disjunction.) -/
theorem seam_no_executor
    (X Y : Agent α) (V : Set Ω) (ωx ωy : Ω)
    (hωx_in : ωx ∈ V) (hωy_in : ωy ∈ V)
    (hωx : ωx ∈ ((K X : Set Ω) \ (K Y : Set Ω)))
    (hωy : ωy ∈ ((K Y : Set Ω) \ (K X : Set Ω))) :
    ¬ (V ⊆ (K X : Set Ω) ∨ V ⊆ (K Y : Set Ω)) := by
  have ⟨hX, hY⟩ := seam_not_single_agent X Y V ωx ωy hωx_in hωy_in hωx hωy
  rintro (h | h)
  · exact hX h
  · exact hY h

/-- **R.814(a) — Finset form (executable vertex set).**

Identical content with `V : Finset Ω`, matching the hyperedge-as-finset model
(`V = S ∪ {ω}`). Useful for the discrete derivation-graph layer. -/
theorem seam_not_single_agent_finset
    [DecidableEq Ω]
    (X Y : Agent α) (V : Finset Ω) (ωx ωy : Ω)
    (hωx_in : ωx ∈ V) (hωy_in : ωy ∈ V)
    (hωx : ωx ∈ (K X : Set Ω)) (hωx' : ωx ∉ (K Y : Set Ω))
    (hωy : ωy ∈ (K Y : Set Ω)) (hωy' : ωy ∉ (K X : Set Ω)) :
    ¬ ((V : Set Ω) ⊆ (K X : Set Ω)) ∧ ¬ ((V : Set Ω) ⊆ (K Y : Set Ω)) := by
  refine seam_not_single_agent X Y (V : Set Ω) ωx ωy ?_ ?_ ⟨hωx, hωx'⟩ ⟨hωy, hωy'⟩
  · exact_mod_cast hωx_in
  · exact_mod_cast hωy_in

/-! ## Part (b): coverage–incomposability gap.

When the union covers an explanation but every coverable explanation needs a
cross-seam (no monochrome derivation), the collaboration fails: `N(p, A) = ⊤`
for each single agent `A`, even though `∃ R ⊆ K(X) ∪ K(Y)`. -/

/-- **R.814(b) — coverage does not imply single-agent solvability.**

The covering hypothesis `∃ R ∈ ℛ(p), R ⊆ K(X) ∪ K(Y)` (joint coverage, R.813a)
does *not* yield `∃ R ∈ ℛ(p), R ⊆ K(X)` nor `⊆ K(Y)`: union coverage is
strictly weaker than single-agent coverage. We make this precise: from the
*incomposability* bundle — `X` does not single-handedly cover (`¬∃R⊆K X`) and
`Y` does not (`¬∃R⊆K Y`) — A.2 forces `N(p,X) = ⊤` and `N(p,Y) = ⊤`. So the
gap "covered jointly, solvable by neither single agent" is realised. -/
theorem composition_gap
    (p : Problem α) (X Y : Agent α)
    (hX_nocover : ¬ ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω))
    (hY_nocover : ¬ ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K Y : Set Ω)) :
    N p X = ⊤ ∧ N p Y = ⊤ := by
  constructor
  · -- A.2: N ≠ ⊤ ⟺ coverage; coverage fails, so N = ⊤.
    by_contra hN
    exact hX_nocover ((Axioms.A2 (Ω := Ω) p X).mp hN)
  · by_contra hN
    exact hY_nocover ((Axioms.A2 (Ω := Ω) p Y).mp hN)

/-- **R.814(b) — the gap, with explicit joint-coverage witness.**

The full coverage–incomposability statement: there *is* a joint-coverage
witness `R₀ ⊆ K(X) ∪ K(Y)` (so R.813(a) holds and the problem looks
collaboratively addressable), yet — because no single agent covers any
explanation — *both* single-agent emergence degrees are infinite. The
collaboration must rely on cross-seam transport, which R.814(a) shows is
unexecutable: hence (modulo the bridge to `N_collab`) the second threshold. -/
theorem composition_gap_with_witness
    (p : Problem α) (X Y : Agent α)
    (R₀ : Set Ω) (hR₀_mem : R₀ ∈ (demandFamily p : Set (Set Ω)))
    (hR₀_cover : R₀ ⊆ (K X : Set Ω) ∪ (K Y : Set Ω))
    (hX_nocover : ¬ ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω))
    (hY_nocover : ¬ ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K Y : Set Ω)) :
    (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω) ∪ (K Y : Set Ω))
      ∧ N p X = ⊤ ∧ N p Y = ⊤ :=
  ⟨⟨R₀, hR₀_mem, hR₀_cover⟩, composition_gap p X Y hX_nocover hY_nocover⟩

end R814_CompositionGap

end MIP
