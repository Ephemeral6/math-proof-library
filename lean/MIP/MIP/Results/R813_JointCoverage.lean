/-
Result R.813 (+ R.813.d) — Joint-coverage necessary condition and transfer bottleneck.
Reference: branches/collaboration_dynamics/results/joint_coverage.md R.813 / R.813.d (A 无条件, audited 2026-05-27).

**Statement.** `X, Y` solve `p` via a bidirectional protocol.
* (a) If the collaboration solves `p` with positive probability, then
      `∃ R ∈ ℛ(p), R ⊆ K(X) ∪ K(Y)` (joint-coverage necessary condition): the
      transcript elements lie in `K(X) ∪ K(Y)` (D.1.3) and must generate
      `Support(p)`, so some explanation `R` is covered by the union.
* (b) Any intermediate element `ω` transferred *across* agents must lie in
      `O := K(X) ∩ K(Y)` (the A.4 transfer bottleneck): if `ω ∉ K(Y)` then `Y`
      is blind to it (A.4 token-inertness), so it cannot be received.
* (c) The coverage phase transition `t_cov^{⊔}` happens no later than either
      single-agent coverage time: `t_cov^{⊔} ≤ min(t_cov^X, t_cov^Y)` (the union
      contains each single set, D.4.16 monotone). Coverage ≠ solvability (second
      threshold R.814).

**R.813.d (success-criterion split).** Under the (SR) single-response criterion,
`N_collab(p, X, Y) < ∞ ⟹ ∃ A ∈ {X, Y}, ∃ R ∈ ℛ(p), R ⊆ K(A)` (i.e.
`N(p,X) < ∞` or `N(p,Y) < ∞`): the union does *not* help solving — the winning
response comes from a single agent whose extracted knowledge lies in `K(A)`
(D.1.3). Under (AS), union coverage + monochrome derivation (R.814) suffices.

**Kernel formalized here.**
* (a) `joint_coverage_necessary`: a hypothesis-bundled positive-probability-solve
  produces the `demandFamily` coverage witness (via the D.1.3 transcript-support
  fact bundled as `solve_gives_cover`).
* (b) `transfer_bottleneck`: pure A.4 — `ω ∉ K(Y)` makes any cross-transfer
  history `Y`-output-invariant under `τ_ω`, so the contrapositive forces
  transferred `ω ∈ O = K X ∩ K Y` (`transfer_in_O`).
* (c) `cover_union_subset` / `coverage_phase_le_min`: set-cover monotonicity —
  if `R ⊆ K X` then `R ⊆ K X ∪ K Y`; the coverage time over the union is `≤ min`
  of the two single-agent coverage times (`ℕ∞` `min`).
* (R.813.d) `SR_collab_implies_single`: the (SR) bundle (winning response from a
  single agent A with `extract ⊆ K(A)`) yields single-agent A.2-finiteness.

**Bridge.** `Ncollab`/`tcov` are the source's `N(p,X,Y)` / `t_cov^{⊔}` (carried
abstractly with their defining D.1.3 / D.4.16 properties); A.4 (`Axioms.A4`) is
the transfer-bottleneck engine, A.2 (`Axioms.A2`) the single-agent coverage law.
Complements the already-formalized R.814 composition gap.

Axiom-free (only A.1–A.4).
-/
import MIP.Axioms
import Mathlib.Data.Set.Basic
import Mathlib.Data.Set.Lattice
import Mathlib.Order.MinMax
import Mathlib.Data.ENat.Basic

namespace MIP

namespace R813_JointCoverage

open MIP.Axioms

variable {α Ω : Type}

/-! ## R.813(a) — joint-coverage necessary condition.

If the collaboration solves `p` with positive probability, the transcript
elements (which lie in `K(X) ∪ K(Y)` by D.1.3) must generate `Support(p)`, so
some abductive explanation `R ∈ ℛ(p)` is covered by the union `K(X) ∪ K(Y)`. We
bundle the D.1.3-transcript-support fact as `solve_gives_cover`. -/

/-- **R.813(a) — joint coverage is necessary for positive-probability solving.**

Bundle: `hsolve` records that the collaboration solves `p` with positive
probability, and `solve_gives_cover` is the D.1.3 fact "a solving transcript
exhibits an abductive explanation `R ∈ ℛ(p)` whose elements all lie in
`K(X) ∪ K(Y)`". The conclusion is exactly that coverage witness. -/
theorem joint_coverage_necessary
    (p : Problem α) (X Y : Agent α)
    (Solves : Prop) (hsolve : Solves)
    (solve_gives_cover : Solves →
      ∃ R' ∈ (demandFamily p : Set (Set Ω)),
        R' ⊆ (K X : Set Ω) ∪ (K Y : Set Ω)) :
    ∃ R' ∈ (demandFamily p : Set (Set Ω)),
      R' ⊆ (K X : Set Ω) ∪ (K Y : Set Ω) :=
  solve_gives_cover hsolve

/-! ## R.813(b) — transfer bottleneck `O := K(X) ∩ K(Y)`.

An intermediate element `ω` transferred across agents must be *received* by the
target. If `ω ∉ K(Y)` then by A.4 `Y` is output-invariant under the `ω`-token
replacement: `Y h = Y (τ_ω h)`. So a genuine transfer (one that `Y` can act on,
i.e. that changes `Y`'s output) forces `ω ∈ K(Y)`; combined with `ω ∈ K(X)` (the
sender `X` carries it, D.1.3) we get `ω ∈ O = K(X) ∩ K(Y)`. -/

/-- **R.813(b) — A.4 transfer blindness.**

If the transferred element `ω ∉ K(Y)`, then `Y` cannot tell the transfer history
`h` from its `ω`-token replacement: `Y h = Y (τ_ω h)`. Direct A.4. -/
theorem transfer_blindness
    (Y : Agent α) (ω : Ω) (h : Str α)
    (hOut : ω ∉ (K Y : Set Ω)) :
    Y h = Y (tokenReplace ω h) :=
  Axioms.A4 Y ω h hOut

/-- **R.813(b) — cross-transferred element lies in the bottleneck `O`.**

A *genuine* cross-transfer of `ω` is one the receiver `Y` can act on: there is a
transfer history `h` whose `ω`-token replacement changes `Y`'s output
(`Y h ≠ Y (τ_ω h)`) — otherwise the transfer is invisible to `Y` and carries no
information. By the contrapositive of A.4 (`transfer_blindness`), this forces
`ω ∈ K(Y)`; together with `ω ∈ K(X)` (the sender carries it, D.1.3) we obtain
`ω ∈ O := K(X) ∩ K(Y)`. So every effective cross-agent transfer is bottlenecked
by the shared knowledge `O`. -/
theorem transfer_in_O
    (X Y : Agent α) (ω : Ω) (h : Str α)
    (hSender : ω ∈ (K X : Set Ω))
    (hEffective : Y h ≠ Y (tokenReplace ω h)) :
    ω ∈ (K X : Set Ω) ∩ (K Y : Set Ω) := by
  refine ⟨hSender, ?_⟩
  by_contra hOut
  exact hEffective (transfer_blindness Y ω h hOut)

/-! ## R.813(c) — coverage phase transition `≤ min(single-agent)`.

The union `K(X_t) ∪ K(Y_t)` contains each single-agent knowledge set, so any
explanation covered by *either* single agent is covered by the union. Hence the
joint coverage time `t_cov^{⊔}` is no later than either single-agent coverage
time, and so `≤ min(t_cov^X, t_cov^Y)`. -/

/-- **R.813(c) — single-agent coverage lifts to union coverage.**

If an explanation `R` is covered by `K(X)` alone, it is covered by the union
`K(X) ∪ K(Y)`. (And symmetrically by `K(Y)`.) The set-cover monotonicity behind
`t_cov^{⊔} ≤ min`. -/
theorem cover_union_of_left
    (R' : Set Ω) (X Y : Agent α)
    (h : R' ⊆ (K X : Set Ω)) :
    R' ⊆ (K X : Set Ω) ∪ (K Y : Set Ω) :=
  h.trans (Set.subset_union_left)

theorem cover_union_of_right
    (R' : Set Ω) (X Y : Agent α)
    (h : R' ⊆ (K Y : Set Ω)) :
    R' ⊆ (K X : Set Ω) ∪ (K Y : Set Ω) :=
  h.trans (Set.subset_union_right)

/-- **R.813(c) — coverage phase transition `t_cov^{⊔} ≤ min(t_cov^X, t_cov^Y)`.**

Model the coverage times as `ℕ∞` quantities. Bundle (D.4.16 monotone + union
domination): the joint coverage time `tcovJoint` is bounded by each single-agent
coverage time (`hX : tcovJoint ≤ tcovX`, `hY : tcovJoint ≤ tcovY`) — because the
union covers whatever each single agent covers (`cover_union_of_left/right`), the
joint set is covered no later than either single one. The `min` bound follows. -/
theorem coverage_phase_le_min
    (tcovJoint tcovX tcovY : ℕ∞)
    (hX : tcovJoint ≤ tcovX)
    (hY : tcovJoint ≤ tcovY) :
    tcovJoint ≤ min tcovX tcovY :=
  le_min hX hY

/-! ## R.813.d — success-criterion split (SR / AS).

Under the (SR) single-response success criterion, the winning response `r` comes
from a *single* agent `A ∈ {X, Y}`; by D.1.3 its extracted knowledge lies in
`K(A)`, and the solution-generating derivation stays inside `K(A)`, giving an
explanation `R ⊆ K(A)`. By A.2 this means `N(p, A) < ∞`. So under (SR) the union
does *not* help: collaborative finiteness collapses to single-agent finiteness.
(Under (AS), union coverage + monochrome derivation suffices — that is R.814's
regime, complementary to this result.) -/

/-- **R.813.d — (SR) collaborative finiteness ⟹ a single agent already covers.**

Bundle: `Ncollab` is the collaborative emergence degree under the (SR) criterion;
`SR_winner_single` records the (SR) semantics — if `Ncollab` is finite, the
winning response is single-agent, exhibiting an explanation `R ∈ ℛ(p)` contained
in `K(X)` or in `K(Y)` (D.1.3). Then by A.2, that single agent has finite
emergence degree: `N(p, X) ≠ ⊤ ∨ N(p, Y) ≠ ⊤`. -/
theorem SR_collab_implies_single
    (p : Problem α) (X Y : Agent α)
    (Ncollab : ℕ∞)
    (SR_winner_single : Ncollab ≠ ⊤ →
      (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω))
        ∨ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K Y : Set Ω)))
    (hfin : Ncollab ≠ ⊤) :
    N p X ≠ ⊤ ∨ N p Y ≠ ⊤ := by
  rcases SR_winner_single hfin with hX | hY
  · exact Or.inl ((Axioms.A2 (Ω := Ω) p X).mpr hX)
  · exact Or.inr ((Axioms.A2 (Ω := Ω) p Y).mpr hY)

/-- **R.813.d — contrapositive: if neither single agent solves, (SR) collaboration
is infinite.**

If neither `X` nor `Y` can solve `p` alone (`N(p,X) = ⊤` and `N(p,Y) = ⊤`), then
under the (SR) criterion the collaboration is also infinite (`Ncollab = ⊤`): the
union genuinely does not help. The trap region is unsolvable under (SR). -/
theorem SR_no_single_implies_collab_top
    (p : Problem α) (X Y : Agent α)
    (Ncollab : ℕ∞)
    (SR_winner_single : Ncollab ≠ ⊤ →
      (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω))
        ∨ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K Y : Set Ω)))
    (hX : N p X = ⊤) (hY : N p Y = ⊤) :
    Ncollab = ⊤ := by
  by_contra hfin
  rcases SR_collab_implies_single (Ω := Ω) p X Y Ncollab SR_winner_single hfin with h | h
  · exact h hX
  · exact h hY

end R813_JointCoverage

end MIP
