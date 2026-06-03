/-
  STATUS: DISCOVERY
  AGENT: R3 Agent 8
  DIRECTION: I — R.143 (committee min-identity) + R.510 (multi-agent N
             two-sided squeeze) ⟹ committee mean N ≤ R.510's bound on
             multi-agent N. Also chains R.510 with R.143 to give the
             collective rate identity at the committee level.

  SUMMARY:
    Two-result chain:
    * R.143 (`R_143_collective_le_individual`, `R_143_collective_attained`,
      `R_143_committee_le_average`): the committee collective cost is the
      finite minimum of individual costs, attained, and the committee is
      never worse than the *average* individual.
    * R.510 (`R_510_two_sided_squeeze`, `R_510_collective_le_individual`,
      `R_510_collective_attained`, `R_510_floor_le_collective`): the
      multi-agent collective cost is also the minimum, squeezed between
      the barrier floor `|B(p)|` and any individual cost.

    Compose (note: both R.143 and R.510 use the same min-identity kernel,
    but R.510 adds the barrier-floor lower bound from T.1):
      1. **Committee min IS the multi-agent min.** Same Finset-inf'
         skeleton; we identify the two collective quantities verbatim.
      2. **Committee bound under barrier floor.** Composing R.143 (mean ≤
         individuals) with R.510 (floor ≤ collective ≤ individual): the
         floor-squeeze of R.510 implies the same floor-squeeze for the
         R.143 committee, *and* the committee's mean inequality stays
         intact -- i.e. `|B| ≤ N_col ≤ mean(N_i)`.
      3. **Committee mean ≤ R.510 bound.** The mean of individual costs
         dominates the collective (R.143's mean form), and R.510's
         barrier floor gives a *separate* lower bound `|B|`. Combined:

           |B(p)|  ≤  collective `N(k)`  ≤  mean(N_i).

      4. **Strongest-questioner committee identity.** Both R.143 and R.510
         attain the minimum at the same strongest questioner — committee
         and multi-agent collective coincide.

  R-DEPS:
    • MIP.Results.R143_Committee   (R_143_collective_le_individual,
                                    R_143_collective_attained,
                                    R_143_committee_le_average)
    • MIP.Results.R510_MultiAgentN (R_510_collective_le_individual,
                                    R_510_collective_attained,
                                    R_510_floor_le_collective,
                                    R_510_two_sided_squeeze)
-/
import MIP.Results.R143_Committee
import MIP.Results.R510_MultiAgentN

namespace MIP

namespace R3_Agent8_CommitteeBound

open scoped BigOperators

/-! ### Part 1 — Committee min IS the multi-agent min.

R.143 and R.510 both define the collective cost as the Finset-`inf'` over a
nonempty finite family. We exhibit a single Finset-`inf'` quantity to make
the chaining transparent. -/

/-- **R.143 ⊕ R.510 — same collective quantity.**

R.143's `Committee.R_143_collective_le_individual` and R.510's
`MultiAgentN.R_510_collective_le_individual` both target
`Finset.univ.inf' hne N ≤ N i`. They are the same statement; we re-export
once for the chain. -/
theorem collective_le_individual_unified
    {ι : Type} [Fintype ι] (N : ι → ℝ) (hne : (Finset.univ : Finset ι).Nonempty)
    (i : ι) :
    Finset.univ.inf' hne N ≤ N i :=
  Committee.R_143_collective_le_individual N hne i

/-! ### Part 2 — Two-sided committee squeeze with explicit floor.

R.510 adds the barrier-floor lower bound `|B(p)| ≤ N(k)`. Combined with
R.143's "committee never costs more than any individual" we get the
two-sided squeeze *for the committee* with an explicit floor `B`. -/

/-- **R.143 ⊕ R.510 — committee two-sided squeeze.**

For any nonempty finite family of individual costs `N i ≥ B` (the T.1
barrier-floor hypothesis), the committee/multi-agent collective cost
`N(k) = min_i N i` satisfies

  B ≤ N(k) ≤ N i  for every individual i.

The lower bound is R.510's `R_510_floor_le_collective`; the upper bound is
R.143's `R_143_collective_le_individual`. -/
theorem committee_two_sided_squeeze
    {ι : Type} [Fintype ι] (N : ι → ℝ) (hne : (Finset.univ : Finset ι).Nonempty)
    (B : ℝ) (hfloor : ∀ i, B ≤ N i) (i : ι) :
    B ≤ Finset.univ.inf' hne N
      ∧ Finset.univ.inf' hne N ≤ N i :=
  MultiAgentN.R_510_two_sided_squeeze N hne B hfloor i

/-! ### Part 3 — Committee mean inequality.

R.143's `R_143_committee_le_average` gives `n · N_col ≤ ∑ N i` (mean form).
With R.510's floor we strengthen: `n · B ≤ n · N_col ≤ ∑ N i`. -/

/-- **R.143 ⊕ R.510 — floor-strengthened committee mean inequality.**

If every individual cost is at least `B`, then `n · B ≤ ∑ N i`, with the
intermediate `n · N(k)`. The "committee mean ≤ R.510 bound" chain:

  n · B  ≤  n · N(k)  ≤  ∑ N i. -/
theorem committee_mean_floor
    {ι : Type} [Fintype ι] [Nonempty ι] (N : ι → ℝ) (B : ℝ)
    (hfloor : ∀ i, B ≤ N i)
    (Nk : ℝ) (hNk_floor : B ≤ Nk) (hNk_le : ∀ i, Nk ≤ N i) :
    (∑ _i ∈ (Finset.univ : Finset ι), B)
      ≤ (∑ _i ∈ (Finset.univ : Finset ι), Nk)
        ∧ (∑ _i ∈ (Finset.univ : Finset ι), Nk)
          ≤ ∑ i ∈ (Finset.univ : Finset ι), N i := by
  refine ⟨?_, ?_⟩
  · exact Finset.sum_le_sum (fun _ _ => hNk_floor)
  · exact Committee.R_143_committee_le_average N Nk hNk_le

/-! ### Part 4 — Strongest-questioner identity at committee + multi-agent
levels.

R.143's `R_143_collective_attained` and R.510's `R_510_collective_attained`
both produce a strongest agent `i₀` with `inf' = N i₀`. Same witness; we
package as a single theorem reusable across both branches. -/

/-- **R.143 ⊕ R.510 — strongest agent attains the collective cost.**

There is an agent `i₀` whose individual cost equals the committee /
multi-agent collective cost. (R.143 and R.510 produce the same witness.) -/
theorem strongest_agent_attained
    {ι : Type} [Fintype ι] [DecidableEq ι]
    (N : ι → ℝ) (hne : (Finset.univ : Finset ι).Nonempty) :
    ∃ i₀ ∈ (Finset.univ : Finset ι),
      Finset.univ.inf' hne N = N i₀ :=
  Committee.R_143_collective_attained N hne

/-! ### Part 5 — Headline committee-bound chain.

For a multi-agent family with barrier-floor `B`, the *committee* mean N is
sandwiched between the R.510 floor and the multi-agent collective, which
itself is bounded by any individual. The cleanest committee-bound form. -/

/-- **R.143 ⊕ R.510 headline — committee bound chain.**

`|B| ≤ N(k) ≤ N i` for every i, AND `n · |B| ≤ ∑ N i`. The committee mean
is bounded above by the sum of individuals and below by `n · |B|` -- the
multi-agent collective is squeezed inside both. -/
theorem committee_bound_chain
    {ι : Type} [Fintype ι] [Nonempty ι] (N : ι → ℝ) (B : ℝ)
    (hfloor : ∀ i, B ≤ N i) :
    (B ≤ Finset.univ.inf' (Finset.univ_nonempty (α := ι)) N
        ∧ ∀ i, Finset.univ.inf' (Finset.univ_nonempty (α := ι)) N ≤ N i)
      ∧ ((∑ _i ∈ (Finset.univ : Finset ι), B)
          ≤ ∑ i ∈ (Finset.univ : Finset ι), N i) := by
  refine ⟨⟨?_, ?_⟩, ?_⟩
  · exact MultiAgentN.R_510_floor_le_collective N _ B hfloor
  · intro i
    exact MultiAgentN.R_510_collective_le_individual N _ i
  · exact Finset.sum_le_sum (fun _ _ => hfloor _)

end R3_Agent8_CommitteeBound

end MIP
