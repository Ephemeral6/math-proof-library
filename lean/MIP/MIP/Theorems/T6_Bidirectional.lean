/-
Theorem T.6 — Bidirectional emergence.

Reference: `proofs/T6.md`.

**Statement.** Let `π*` be the optimal bidirectional protocol that
assigns each barrier `b ∈ B(p)` to the solver with lower impedance.
Then

    (i)   N_bi(p, A, H)  ≤  N(p, A, H),
    (ii)  N_bi(p, A, H)  ≤  N(p, H, A),
    (iii) N_bi(p, A, H)  ≤  |B(p)| · n_max,

with `n_max` an upper bound on per-barrier intervention count (T.8).

**STATUS: PARTIAL.** Requires D.4.4 (`N_bi` definition), D.4.12
(protocol formalisation), `B_A / B_S / B_H` barrier-type decomposition,
T.1, T.8, L.6, L.7. None are in the opaque MIP signatures yet.

We provide an *atomic kernel*: under the per-barrier intervention-count
upper bound assumption (`n_b ≤ n_max(b)`), the sum bound `Σ n_b ≤ |B| · max`
follows trivially. This is the pure-math fragment of (iii).
-/
import MIP.Axioms
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

open scoped BigOperators

namespace Bidirectional

/-- **Pure-math kernel for T.6 (iii).**

If a finite set `B` of barriers has per-barrier cost `n : B → ℕ` with
uniform upper bound `nmax`, then `Σ_{b ∈ B} n b ≤ |B| · nmax`. -/
theorem T6_kernel
    {ι : Type*} (B : Finset ι) (n : ι → ℕ) (nmax : ℕ)
    (h : ∀ b ∈ B, n b ≤ nmax) :
    ∑ b ∈ B, n b ≤ B.card * nmax := by
  calc ∑ b ∈ B, n b
      ≤ ∑ _b ∈ B, nmax := Finset.sum_le_sum h
    _ = B.card * nmax := by simp [Finset.sum_const, mul_comm]

/-- **Bidirectional bound bundle (Path B form).**

T.6's three inequalities rest on infrastructure absent from the opaque
MIP signatures: the bidirectional protocol `π*` (D.4.12), the cost
operator `N_bi` (D.4.4), the directional costs `N(p,A,H)` / `N(p,H,A)`,
the barrier-type decomposition `B_A / B_S / B_H`, and the optimality
lemmas L.6 / L.7. Following the `MIP.UEA.RestrSpec` idiom we package all
of this missing structure as a single `Prop`:

* `B`     — the barrier set `B(p)` (D.4.4), a finite index set;
* `n`     — the per-barrier intervention count `n_b`;
* `nmax`  — the uniform upper bound from T.8, with `hbound : n_b ≤ nmax`;
* `N_bi`  — the bidirectional cost, with `hdef : N_bi = Σ_{b∈B} n_b`
            (this is the content of D.4.4 / D.4.12 for `π*`);
* `N_AH`, `N_HA` — the directional costs, with `hAH : N_bi ≤ N_AH`
            and `hHA : N_bi ≤ N_HA` (the conclusions of L.6 / L.7
            optimality, carried as hypotheses since the protocol
            machinery is not yet formalised). -/
structure BidirectionalBound {ι : Type*}
    (B : Finset ι) (n : ι → ℕ) (nmax N_bi N_AH N_HA : ℕ) : Prop where
  /-- T.8: per-barrier count is uniformly bounded by `nmax`. -/
  hbound : ∀ b ∈ B, n b ≤ nmax
  /-- D.4.4 / D.4.12: the bidirectional cost is the sum of per-barrier costs. -/
  hdef : N_bi = ∑ b ∈ B, n b
  /-- L.6: optimality vs. the `A → H` direction. -/
  hAH : N_bi ≤ N_AH
  /-- L.7: optimality vs. the `H → A` direction. -/
  hHA : N_bi ≤ N_HA

/-- **T.6 (Bidirectional Emergence).**

Under the `BidirectionalBound` bundle (which packages the protocol /
cost / optimality infrastructure of D.4.4, D.4.12, T.8, L.6, L.7), the
optimal bidirectional protocol `π*` satisfies the three inequalities

    (i)   N_bi ≤ N(p, A, H),
    (ii)  N_bi ≤ N(p, H, A),
    (iii) N_bi ≤ |B(p)| · n_max.

What is **bundled vs. proven**:

* (i) `hAH` and (ii) `hHA` are *bundled* — they are the L.6 / L.7
  optimality conclusions, carried as hypotheses because the
  protocol-optimality machinery is not in the opaque signatures.
* (iii) is *proven* here, from the bundle's `hbound` and `hdef`, by
  rewriting `N_bi = Σ_{b∈B} n_b` and applying the unchanged kernel
  `T6_kernel`. -/
theorem T6_Bidirectional {α : Type} (_p : Problem α) (_A _H : Agent α)
    {ι : Type*} (B : Finset ι) (n : ι → ℕ) (nmax N_bi N_AH N_HA : ℕ)
    (hb : BidirectionalBound B n nmax N_bi N_AH N_HA) :
    N_bi ≤ N_AH ∧ N_bi ≤ N_HA ∧ N_bi ≤ B.card * nmax := by
  refine ⟨hb.hAH, hb.hHA, ?_⟩
  -- (iii): rewrite `N_bi` as the per-barrier sum, then invoke the kernel.
  rw [hb.hdef]
  exact T6_kernel B n nmax hb.hbound

end Bidirectional

end MIP
