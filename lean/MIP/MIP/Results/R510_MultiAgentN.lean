/-
Result R.510-R.515 — Multi-agent collective emergence cost `N(k)`:
two-sided squeeze, strongest-questioner identity, and the `k²+1`
dimension count.

Reference: `workspace/round3_exploration/work_slot_010.md` (R.510-512),
`work_slot_012.md` / `work_slot_019.md` (R.514 harmonic / Jaccard),
`work_slot_025.md` (R.551 dimension ladder, the `k²+1` count reused for
the multi-agent observable tuple). MIP round-3 collective branch.

**Candidate status: Round-3 autonomous exploration, not yet
human-audited.**

**Statement (the crisp kernels).** For a solver `A_s` collaborating with a
finite family of `k` questioners `A : ι → Agent`, write
`N i := N(p, A_s, A_i)` for the per-questioner emergence cost.  The
collective cost `N(k)` is governed by:

* **R.510 (two-sided squeeze).** `N(k) = min_i N i`, and it is squeezed
  between the floor `|B(p)|` (every cost is at least the barrier count,
  T.1) and any individual cost: `|B| ≤ N(k) ≤ N i` for all `i`.

* **R.514 (strongest questioner dominates).** With `Z i := 1 / N i` the
  per-questioner *reciprocal* cost (the "questioner strength"), the
  collective reciprocal is the maximum:
  `N(k)⁻¹ = max_i Z i`.  Equivalently `1 / (min_i N i) = max_i (1 / N i)`
  — the single strongest questioner sets the collective rate.  This is
  the reciprocal/harmonic dual of the min-identity (R.143).

* **R.510/R.551 (dimension count).** The `k`-agent observable tuple
  `(N_ij over ordered pairs, N_self per agent, N_bi^team, Asym^team)`
  has naive dimension `k(k−1) + k + 2 = k² + 2`; one homogeneous linear
  conservation law (R.150) removes one degree of freedom, giving the
  admissible set `Ω_k` dimension `k² + 1`.  Here we prove the two
  combinatorial identities `k(k−1) + k + 2 = k² + 2` and
  `(k² + 2) − 1 = k² + 1` underlying that count.

We bundle the collaboration structure (each `N i > 0`, the floor `|B|`,
the squeeze relations) as explicit hypotheses, matching the MIP-side
dependence on T.1 / D.3.9 / R.150.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Finset.Lattice.Fold
import Mathlib.Data.Finset.Max
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace MultiAgentN

open scoped BigOperators

/-! ## R.510 — two-sided squeeze of the collective cost `N(k) = min_i N i`. -/

/-- **R.510 (i) — collective cost is the finite minimum (lower bound).**

If `N(k) := min_i N i` over a nonempty finite family of per-questioner
costs, then `N(k) ≤ N i` for every questioner `i`: the collective never
costs more than any single questioner. -/
theorem R_510_collective_le_individual
    {ι : Type} [Fintype ι] (N : ι → ℝ) (hne : (Finset.univ : Finset ι).Nonempty)
    (i : ι) :
    Finset.univ.inf' hne N ≤ N i :=
  Finset.inf'_le N (Finset.mem_univ i)

/-- **R.510 (ii) — the minimum is attained (strongest questioner exists).**

In a finite family the `min` is attained: there is a questioner `i₀`
whose individual cost equals the collective cost `N(k)`. -/
theorem R_510_collective_attained
    {ι : Type} [Fintype ι] [DecidableEq ι]
    (N : ι → ℝ) (hne : (Finset.univ : Finset ι).Nonempty) :
    ∃ i₀ ∈ (Finset.univ : Finset ι),
      Finset.univ.inf' hne N = N i₀ := by
  obtain ⟨i₀, hi₀, h_min⟩ := Finset.exists_min_image Finset.univ N hne
  refine ⟨i₀, hi₀, ?_⟩
  apply le_antisymm
  · exact Finset.inf'_le N hi₀
  · exact Finset.le_inf' hne N (fun i _ => h_min i (Finset.mem_univ i))

/-- **R.510 (iii) — barrier floor as a lower bound for the collective.**

If every individual cost is at least the barrier count `B` (T.1:
`N(p, A_s, A_i) ≥ |B(p)|`), then so is the collective cost
`N(k) = min_i N i`.  Combined with `R_510_collective_le_individual`
this is the *two-sided squeeze* `|B| ≤ N(k) ≤ N i`. -/
theorem R_510_floor_le_collective
    {ι : Type} [Fintype ι] (N : ι → ℝ) (hne : (Finset.univ : Finset ι).Nonempty)
    (B : ℝ) (hfloor : ∀ i, B ≤ N i) :
    B ≤ Finset.univ.inf' hne N :=
  Finset.le_inf' hne N (fun i _ => hfloor i)

/-- **R.510 — full two-sided squeeze.**

`|B| ≤ N(k) ≤ N i` for every questioner `i`: the collective cost sits
between the universal barrier floor (T.1) and any individual
questioner's cost. -/
theorem R_510_two_sided_squeeze
    {ι : Type} [Fintype ι] (N : ι → ℝ) (hne : (Finset.univ : Finset ι).Nonempty)
    (B : ℝ) (hfloor : ∀ i, B ≤ N i) (i : ι) :
    B ≤ Finset.univ.inf' hne N ∧ Finset.univ.inf' hne N ≤ N i :=
  ⟨R_510_floor_le_collective N hne B hfloor,
   R_510_collective_le_individual N hne i⟩

/-! ## R.514 — strongest-questioner reciprocal identity `N(k)⁻¹ = max_i Z_i`. -/

/-- **R.514 — reciprocal of a positive minimum is the maximum of reciprocals.**

For a nonempty finite family of strictly positive costs `N i`, the
reciprocal of the collective minimum equals the maximum of the
reciprocals:

    (min_i N i)⁻¹ = max_i (N i)⁻¹ .

Reading `Z i := (N i)⁻¹` as questioner *strength*, this is
`N(k)⁻¹ = max_i Z i`: the single strongest questioner (largest `Z`)
sets the collective rate.  This is the harmonic / reciprocal dual of the
min-identity `N(k) = min_i N i` (R.510, R.143). -/
theorem R_514_strongest_questioner
    {ι : Type} [Fintype ι] (N : ι → ℝ) (hne : (Finset.univ : Finset ι).Nonempty)
    (hpos : ∀ i, 0 < N i) :
    (Finset.univ.inf' hne N)⁻¹ = Finset.univ.sup' hne (fun i => (N i)⁻¹) := by
  -- `inf'` of positives is positive, so we may reason with reciprocals.
  have hinf_pos : 0 < Finset.univ.inf' hne N :=
    (Finset.lt_inf'_iff hne).mpr (fun i _ => hpos i)
  apply le_antisymm
  · -- (min N)⁻¹ ≤ max (N⁻¹): pick the minimiser i₀ and use its reciprocal.
    obtain ⟨i₀, hi₀, h_eq⟩ := Finset.exists_mem_eq_inf' hne N
    rw [h_eq]
    exact Finset.le_sup' (fun i => (N i)⁻¹) hi₀
  · -- max (N⁻¹) ≤ (min N)⁻¹: each (N i)⁻¹ ≤ (min N)⁻¹ since min N ≤ N i.
    apply Finset.sup'_le hne
    intro i _
    have hle : Finset.univ.inf' hne N ≤ N i := Finset.inf'_le N (Finset.mem_univ i)
    exact one_div (N i) ▸ one_div (Finset.univ.inf' hne N) ▸
      (one_div_le_one_div_of_le hinf_pos hle)

/-- **R.514 (corollary) — collective rate set by the strongest questioner.**

If `i₀` is a strongest questioner (`(N i₀)⁻¹` is maximal, i.e. `N i₀` is
minimal), then `N(k) = N i₀` and `N(k)⁻¹ = (N i₀)⁻¹`.  The collective
behaves exactly as the single best questioner. -/
theorem R_514_collective_eq_best
    {ι : Type} [Fintype ι] (N : ι → ℝ) (hne : (Finset.univ : Finset ι).Nonempty)
    (i₀ : ι) (hbest : ∀ i, N i₀ ≤ N i) :
    Finset.univ.inf' hne N = N i₀ := by
  apply le_antisymm
  · exact Finset.inf'_le N (Finset.mem_univ i₀)
  · exact Finset.le_inf' hne N (fun i _ => hbest i)

/-! ## R.510 / R.551 — the `k² + 1` dimension count (combinatorial identities). -/

/-- **R.510/R.551 (naive dimension).**

The `k`-agent observable tuple has `k(k−1)` ordered-pair costs `N_ij`,
`k` self-aid costs `N_self(A_i)`, plus `N_bi^team` and `Asym^team`, for a
naive dimension

    k(k−1) + k + 2 = k² + 2 .

Pure arithmetic identity over `ℕ`. -/
theorem R_551_naive_dim (k : ℕ) :
    k * (k - 1) + k + 2 = k * k + 2 := by
  rcases k with _ | k
  · rfl
  · -- k+1 ≥ 1, so (k+1)-1 = k and (k+1)·k + (k+1) = (k+1)·(k+1).
    have h : (k + 1) - 1 = k := Nat.succ_sub_one k
    rw [h]; ring

/-- **R.510/R.551 (dimension after the conservation law).**

The single homogeneous linear conservation law (R.150, the `k`-agent
cognitive-gap conservation) removes exactly one degree of freedom from
the naive `k² + 2`-dimensional observable space, giving the admissible
set `Ω_k` dimension

    (k² + 2) − 1 = k² + 1 .

Pure arithmetic identity over `ℕ`. -/
theorem R_551_dim_after_conservation (k : ℕ) :
    (k * k + 2) - 1 = k * k + 1 := by
  omega

/-- **R.510/R.551 — full dimension count `dim Ω_k = k² + 1`.**

Chaining the naive count and the single-constraint reduction: starting
from the `k(k−1) + k + 2` raw observables and removing one degree of
freedom for the conservation law yields `dim Ω_k = k² + 1`. -/
theorem R_551_dim_omega (k : ℕ) :
    (k * (k - 1) + k + 2) - 1 = k * k + 1 := by
  rw [R_551_naive_dim k, R_551_dim_after_conservation k]

/-- **R.551 (iv) — symmetric submanifold dimension is `3`, independent of `k`.**

In the fully `S_k`-symmetric team (all `N_ij` equal, all `N_self` equal),
the four reduced coordinates `(N̄, N̄_self, N_bi^team, Asym^team)` satisfy
one conservation relation, leaving `4 − 1 = 3` free parameters.  The count
`3` is a constant function of `k` — the symmetric "dual-algebra phase
space" has intrinsic dimension `3` regardless of team size. -/
theorem R_551_symmetric_dim (k : ℕ) :
    (fun _ : ℕ => (4 : ℕ) - 1) k = 3 :=
  rfl

end MultiAgentN

end MIP
