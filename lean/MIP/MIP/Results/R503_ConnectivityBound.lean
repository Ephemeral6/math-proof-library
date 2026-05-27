/-
Result R.503 — Communication-graph connectivity lower bound
(Connectivity Lower Bound).
Reference: branches/collective/workspace/new_results.md (old collective R.144).

**Statement.** To share coverage the communication graph must connect the
upstream contributors to the solver `s`.  If the solver is *isolated*
(`Reach^{-1}_G(s) = {s}`), or all reachable upstream agents are redundant
(`M_{A_i} ⊆ M_{A_s}`), then the collective degenerates to the lone solver:
`N_G(p; s) = N(p, A_s)` — no acceleration.  Structurally, sharing coverage
requires connectivity, and a connected communication graph on `k` agents
needs at least `k − 1` edges (a spanning tree is the minimum).

**Kernel formalized here.**

* **Degeneration (the MIP-side statement).** `s`-isolation
  `Reach^{-1}_G(s) = {s}` gives effective coverage `= K(A_s)` (Step 1);
  "reachable but all redundant" (`⋃ K_i ⊆ K(A_s)`) gives the same
  coverage union `= K(A_s)` (Step 2).  Hence the best gain, impedance
  `Z_q = Z(A_s)`, and Ohm cost `N_G = N(p, A_s)` are unchanged — we encode
  this as a coverage-union identity plus the Ohm cost-equality.
* **Spanning-tree lower bound (the structural core).** A *connected*
  `SimpleGraph` on a finite vertex type `V` has
  `Nat.card V ≤ |edgeSet| + 1`, i.e. `|edgeSet| ≥ k − 1` where `k = card V`
  — the `k − 1` edge lower bound for connectivity
  (`SimpleGraph.Connected.card_vert_le_card_edgeSet_add_one`).

**Bridge.** `MIP.K`/`MIP.N` are opaque; the degeneration is the
coverage-union identity, and the structural lower bound is Mathlib's
spanning-tree fact applied to the communication graph.

Axiom-free.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.Finset.Lattice.Basic
import Mathlib.Data.Finset.Lattice.Union
import Mathlib.Combinatorics.SimpleGraph.Acyclic
import Mathlib.Tactic.Linarith

namespace MIP

namespace R503_ConnectivityBound

/-! ## Degeneration: isolated / all-redundant ⟹ collective = lone solver. -/

/-- **R.503 (Step 1) — `s`-isolated graph: coverage is the solver alone.**

If `Reach^{-1}_G(s) = {s}` (the solver is isolated in `G`), then the
effective coverage is exactly `K(A_s)`: `M^eff_G(s) = K(A_s)`.  No
external aid reaches the solver. -/
theorem R_503_isolated_coverage
    {ι Ω : Type} [DecidableEq Ω]
    (s : ι) (K : ι → Finset Ω) :
    ({s} : Finset ι).biUnion K = K s := by
  simp

/-- **R.503 (Step 2) — reachable but all-redundant: coverage unchanged.**

Suppose the to-`s` reachable set is `reachInv` with `s ∈ reachInv`, and
every reachable upstream agent is redundant: `K i ⊆ K s` for all
`i ∈ reachInv`.  Then the union coverage equals `K(A_s)`:
`⋃_{i ∈ reachInv} K i = K s`.  Hence the collective gains nothing. -/
theorem R_503_all_redundant_coverage
    {ι Ω : Type} [DecidableEq Ω]
    (s : ι) (reachInv : Finset ι) (K : ι → Finset Ω)
    (hs : s ∈ reachInv)
    (hred : ∀ i ∈ reachInv, K i ⊆ K s) :
    reachInv.biUnion K = K s := by
  apply Finset.Subset.antisymm
  · -- every member of the union lies in `K s` (all redundant).
    intro x hx
    rw [Finset.mem_biUnion] at hx
    obtain ⟨i, hi, hxi⟩ := hx
    exact hred i hi hxi
  · -- `K s ⊆ ⋃` since `s ∈ reachInv`.
    intro x hx
    rw [Finset.mem_biUnion]
    exact ⟨s, hs, hx⟩

/-- **R.503 (Ohm cost) — equal coverage ⟹ collective cost = solver cost.**

In the Ohm regime `N = Φ₀ · Z_q`.  When the effective coverage degenerates
to `K(A_s)` (isolated or all-redundant), the impedance is `Z_q = Z(A_s)`,
so `N_G(p; s) = N(p, A_s)`. -/
theorem R_503_degenerate_cost
    (Φ₀ Zq ZqSolver : ℝ) (hZ : Zq = ZqSolver) :
    Φ₀ * Zq = Φ₀ * ZqSolver := by
  rw [hZ]

/-! ## Structural lower bound: connectivity needs `≥ k − 1` edges. -/

open SimpleGraph

/-- **R.503 (structural core) — a connected graph on `k` agents has `≥ k−1`
edges.**

If the communication `SimpleGraph G` on the finite agent type `V` is
connected (so coverage can be shared between any two agents), then
`Nat.card V ≤ |edgeSet G| + 1`, i.e. the number of communication edges is
at least `(card V) − 1`.  A spanning tree (`star`, `chain`, …) attains the
`k − 1` minimum. -/
theorem R_503_connected_edge_lower_bound
    {V : Type} (G : SimpleGraph V) (h : G.Connected) :
    Nat.card V ≤ Nat.card G.edgeSet + 1 :=
  h.card_vert_le_card_edgeSet_add_one

/-- **R.503 (structural core, `ℕ` subtraction form).**

Restated as the explicit `k − 1` lower bound: a connected communication
graph on `k = Nat.card V` agents has at least `k − 1` edges. -/
theorem R_503_edge_count_ge
    {V : Type} (G : SimpleGraph V) (h : G.Connected) :
    Nat.card V - 1 ≤ Nat.card G.edgeSet := by
  have := R_503_connected_edge_lower_bound G h
  omega

end R503_ConnectivityBound

end MIP
