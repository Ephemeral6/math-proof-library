/-
Lemma L.3* — Reverse atomic-barrier measure lower bound.
Reference: `lemmas/L3_star.md`.

**Statement.** Let `N*(p, A, H)` be the *reverse* emergence degree (H as solver,
A as questioner). For any atomic barrier `b ∈ B(p)`,

    N*_b ≥ 1 ,

where `N*_b` is the minimal number of interventions needed to break the single
barrier `b` under the optimal reverse protocol.

**Proof skeleton (from L3_star.md).** Symmetric to L.3 (swap A↔H). Construct a
zero-barrier problem `p₀` and a single-atomic-barrier problem `p_X`:
* (R3 monotonicity) `|B(p_X)| = 1 > 0 = |B(p₀)|` ⟹ `N*(p_X) > N*(p₀)`.
* (R1) `N*(p₀) = 0`.
* (R4 discreteness) `N* ∈ ℕ₀` ⟹ `N*(p_X) ≥ 1`.
* (R2 reverse additivity) `N*(p_X) = N*_b`.
Hence `N*_b ≥ 1`.

**Kernel formalized here.** The rigorous structural content is the elementary
`ℕ∞` fact that *strict positivity over a baseline of `0`* together with
*discreteness* (the value is an honest natural number, i.e. `≠ ⊤`) forces a
value `≥ 1`. We prove:

* `pos_discrete_ge_one`: for `x : ℕ∞`, `0 < x → 1 ≤ x` (R4 discreteness core).
* `reverse_atomic_ge_one`: packaging the R1/R2/R3 chain as the hypothesis
  `0 = Nstar p₀` (R1), `Nstar p₀ < Nstar pX` (R3 strict monotonicity), and
  `Nstar pX = NstarBarrier` (R2 reverse additivity), concluding
  `1 ≤ NstarBarrier`. This is the faithful `N*_b ≥ 1` of the lemma.

**Bridge.** `Nstar` is the opaque reverse emergence-degree measure
`μ* : Problem → ℕ∞`. The chain R1 (`N*(p₀)=0`), R3 (strict monotonicity in
barrier count), R2 (reverse additivity, single barrier) is taken as the
hypothesis bundle; the `ℕ∞` discreteness step `0 < x ⟹ 1 ≤ x` is the proven
kernel. Mirrors the trivial-model treatment of L.3/L.5 in `MIP.Defs.Barriers`.

This file is axiom-free (no A.1–A.4 needed; pure `ℕ∞` order arithmetic).
-/
import Mathlib.Data.ENat.Basic
import Mathlib.Order.Basic
import Mathlib.Tactic

namespace MIP

namespace Lemma_L3star

/-- **R4 discreteness core.** Over `ℕ∞ = ENat`, a strictly-positive value is
at least `1`: there is no value strictly between `0` and `1`. -/
theorem pos_discrete_ge_one (x : ℕ∞) (hx : 0 < x) : 1 ≤ x := by
  -- `ENat.one_le_iff_ne_zero` (or `Order.one_le_iff_lt_zero`-style): `1 ≤ x ↔ x ≠ 0`.
  exact ENat.one_le_iff_ne_zero.mpr (ne_of_gt hx)

/-- **L.3* — reverse atomic-barrier lower bound (`N*_b ≥ 1`).**

Package the R1/R2/R3/R4 chain of `L3_star.md`:

* `hR1` : `Nstar p₀ = 0`               (R1: zero-barrier problem ⟹ zero reverse degree),
* `hR3` : `Nstar p₀ < Nstar pX`        (R3: strict monotonicity, `|B(pX)| = 1 > 0`),
* `hR2` : `Nstar pX = NstarBarrier`    (R2: reverse additivity, single barrier),

with `Nstar : ℕ∞`-valued. The discreteness step `pos_discrete_ge_one` then gives

    1 ≤ NstarBarrier .  -/
theorem reverse_atomic_ge_one
    (Nstar_p0 Nstar_pX NstarBarrier : ℕ∞)
    (hR1 : Nstar_p0 = 0)
    (hR3 : Nstar_p0 < Nstar_pX)
    (hR2 : Nstar_pX = NstarBarrier) :
    1 ≤ NstarBarrier := by
  -- From R1 + R3: 0 < Nstar_pX.
  have hpos : 0 < Nstar_pX := by rw [← hR1]; exact hR3
  -- Discreteness: 1 ≤ Nstar_pX.
  have h1 : 1 ≤ Nstar_pX := pos_discrete_ge_one _ hpos
  -- R2 transports to the single-barrier reverse degree.
  rw [← hR2]; exact h1

/-- **L.3* — structural unit fact (trivial-model mirror of L.5).**

In the spirit of `MIP.Defs.Barriers`' trivial unit facts: the reverse
single-atomic-barrier measure, instantiated as the constant `1`, is `≥ 1`.
This is the concrete-model witness that the lemma's conclusion is realisable
(any model satisfying R1–R4 gives the same value by the reverse analogue of
T.7 uniqueness; the simplest such value is `1`). -/
theorem reverse_atomic_unit : (1 : ℕ∞) ≤ (1 : ℕ∞) := le_refl _

end Lemma_L3star

end MIP
