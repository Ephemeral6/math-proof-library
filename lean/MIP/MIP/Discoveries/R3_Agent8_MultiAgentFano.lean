/-
  STATUS: DISCOVERY
  AGENT: R3 Agent 8
  DIRECTION: C — R.510 (multi-agent N two-sided squeeze) + R.811 (collab
             μ-Fano lower bound) ⟹ collaboration lower bound on the
             multi-agent collective N in terms of the Fano potential.

  SUMMARY:
    Two-result composition giving an information-theoretic lower bound
    on the *collective* multi-agent emergence cost.

    R.811 (`R_811_collab_fano_lower`, `R_811_lower_pos`): each
    questioner-collaboration contributes a μ-Fano lower bound
      `N(p, X, Y_i) ≥ Φ₀ / log|M_{Y_i}^{→X}|`
    derived from the R.480 accumulation `Φ₀ ≤ N · log(card M)`.

    R.510 (`R_510_collective_le_individual`, `R_510_floor_le_collective`,
    `R_510_two_sided_squeeze`): the multi-agent collective
      `N(k) = min_i N(p, A_s, A_i)`
    is squeezed between the barrier floor `|B(p)|` and each individual.

    Compose: when each per-questioner `N i` is a real-valued Fano-lower-
    bounded quantity, the collective minimum `N(k) = min_i N i` is *itself*
    Fano-bounded — by the *largest* readable-alphabet bound (i.e. the
    *strongest* questioner sets the tight Fano floor).

    Concretely:
      1. **Per-questioner Fano floor.** Each `N i ≥ Φ₀ / log|M i|`
         (R.811).
      2. **Collective Fano floor.** Since `N(k) ≤ N i` (R.510), the
         collective `N(k)` is bounded below by the *minimum* of the
         Fano lower bounds, i.e. by the strongest questioner's bound
         `Φ₀ / log(max_i card M i)`.
      3. **Collective Fano: combined two-sided floor.** Combining with
         R.510's barrier-floor `|B|`, the collective `N(k)` satisfies
         `max(|B|, Φ₀ / log(max_i card M i)) ≤ N(k) ≤ N i`.

  R-DEPS:
    • MIP.Results.R510_MultiAgentN  (R_510_collective_le_individual,
                                     R_510_floor_le_collective,
                                     R_510_two_sided_squeeze,
                                     R_510_collective_attained)
    • MIP.Results.R811_CollabFano   (R_811_collab_fano_lower,
                                     R_811_lower_pos,
                                     R_811_antitone_in_alphabet)
-/
import MIP.Results.R510_MultiAgentN
import MIP.Results.R811_CollabFano

namespace MIP

namespace R3_Agent8_MultiAgentFano

open scoped BigOperators

/-! ### Part 1 — Per-questioner Fano floor for `N i`.

R.811 says each per-questioner cost `N i` is bounded below by
`Φ₀ / log(cardM i)` provided `1 < cardM i` and the R.480 accumulation
hypothesis holds. We package this as the "Fano-lower-bounded family"
hypothesis. -/

/-- **R.811 ⊕ R.510 — per-questioner Fano floor (recorded).**

If `Phi0 ≤ N i * log(cardM i)` and `1 < cardM i`, then
`Phi0 / log(cardM i) ≤ N i` (R.811 verbatim, parameterised by `i`). -/
theorem per_questioner_fano_floor
    (N Phi0 cardM : ℝ)
    (hcardM : 1 < cardM)
    (hfano : Phi0 ≤ N * Real.log cardM) :
    Phi0 / Real.log cardM ≤ N :=
  R811_CollabFano.R_811_collab_fano_lower N Phi0 cardM hcardM hfano

/-! ### Part 2 — Collective Fano floor: weakest readable-alphabet bound is
the strongest. -/

/-- **R.811 ⊕ R.510 — Fano floor transports to the collective via R.510.**

If `N(k) ≤ N i` (R.510 collective-≤-individual) and `Phi0 / log(cardM i) ≤
N i` (R.811 per-questioner Fano), then we *cannot* in general conclude
`Phi0 / log(cardM i) ≤ N(k)`. But if the Fano floor holds *for the
particular `i` that attains the collective minimum* (the strongest
questioner), then we do conclude `Phi0 / log(cardM i₀) ≤ N(k) = N i₀`.

We state this in the precise form: if `i₀` attains the inf and the Fano
floor holds at `i₀`, then it transports to the collective. -/
theorem collective_fano_floor
    {ι : Type} [Fintype ι] (N : ι → ℝ)
    (hne : (Finset.univ : Finset ι).Nonempty)
    (Phi0 : ℝ) (cardM : ι → ℝ)
    (i₀ : ι)
    (hattain : Finset.univ.inf' hne N = N i₀)
    (hcardM₀ : 1 < cardM i₀)
    (hfano₀ : Phi0 ≤ N i₀ * Real.log (cardM i₀)) :
    Phi0 / Real.log (cardM i₀) ≤ Finset.univ.inf' hne N := by
  rw [hattain]
  exact R811_CollabFano.R_811_collab_fano_lower (N i₀) Phi0 (cardM i₀)
    hcardM₀ hfano₀

/-! ### Part 3 — Combined two-sided floor: max(`|B|`, Fano) ≤ `N(k)`.

R.510 gives the barrier floor `|B| ≤ N(k)`. R.811 (via Part 2) gives a
Fano-style floor `Phi0 / log(cardM i₀) ≤ N(k)`. The combined floor is the
max of the two. -/

/-- **R.510 ⊕ R.811 — combined two-sided collective bound with both floors.**

Combine the R.510 barrier floor `|B| ≤ N(k)` and the R.811 Fano floor (at
the strongest questioner `i₀`) `Phi0 / log(cardM i₀) ≤ N(k)`. Both
inequalities hold simultaneously; the maximum is also a lower bound. -/
theorem collective_two_sided_with_fano
    {ι : Type} [Fintype ι] (N : ι → ℝ)
    (hne : (Finset.univ : Finset ι).Nonempty)
    (B Phi0 : ℝ) (cardM : ι → ℝ)
    (hfloor : ∀ i, B ≤ N i)
    (i₀ : ι)
    (hattain : Finset.univ.inf' hne N = N i₀)
    (hcardM₀ : 1 < cardM i₀)
    (hfano₀ : Phi0 ≤ N i₀ * Real.log (cardM i₀)) :
    B ≤ Finset.univ.inf' hne N
      ∧ Phi0 / Real.log (cardM i₀) ≤ Finset.univ.inf' hne N
      ∧ ∀ i, Finset.univ.inf' hne N ≤ N i := by
  refine ⟨?_, ?_, ?_⟩
  · exact MultiAgentN.R_510_floor_le_collective N hne B hfloor
  · exact collective_fano_floor N hne Phi0 cardM i₀ hattain hcardM₀ hfano₀
  · intro i
    exact MultiAgentN.R_510_collective_le_individual N hne i

/-! ### Part 4 — Antitone in the readable alphabet: the *largest* readable
alphabet gives the *smallest* Fano bound. So the strongest-questioner's
readable alphabet (largest `cardM`) drives the tightest Fano floor — and
that floor still lower-bounds the collective. -/

/-- **R.811 antitone (alphabet) ⊕ R.510 — readable-alphabet monotonicity
propagates to the collective Fano floor.**

If `c₁ ≤ c₂` with `1 < c₁` (both readable alphabet sizes valid) and
`Phi0 ≥ 0`, then `Phi0 / log c₂ ≤ Phi0 / log c₁` (R.811 antitone). So if
the per-questioner Fano floor `Phi0 / log c₁ ≤ N` holds, the weaker
`Phi0 / log c₂ ≤ N` also does — useful for selecting a single uniform
Fano floor across the family.

We use this to give: if the *strongest-questioner* alphabet `cardM i₀` is
known to be at most `cardMmax` (an upper-bound alphabet across the team),
then the Fano floor with `cardMmax` is *weaker* but valid for the
collective. -/
theorem collective_fano_uniform_alphabet
    {ι : Type} [Fintype ι] (N : ι → ℝ)
    (hne : (Finset.univ : Finset ι).Nonempty)
    (Phi0 cardMmax : ℝ) (cardM : ι → ℝ)
    (hPhi0 : 0 ≤ Phi0)
    (i₀ : ι)
    (hattain : Finset.univ.inf' hne N = N i₀)
    (hcardM₀ : 1 < cardM i₀)
    (hcardMle : cardM i₀ ≤ cardMmax)
    (hfano₀ : Phi0 ≤ N i₀ * Real.log (cardM i₀)) :
    Phi0 / Real.log cardMmax ≤ Finset.univ.inf' hne N := by
  -- per-questioner tight Fano floor at i₀
  have h_tight : Phi0 / Real.log (cardM i₀) ≤ Finset.univ.inf' hne N :=
    collective_fano_floor N hne Phi0 cardM i₀ hattain hcardM₀ hfano₀
  -- weaker, uniform Fano floor with the larger alphabet
  have h_weaker : Phi0 / Real.log cardMmax ≤ Phi0 / Real.log (cardM i₀) :=
    R811_CollabFano.R_811_antitone_in_alphabet Phi0 (cardM i₀) cardMmax
      hPhi0 hcardM₀ hcardMle
  exact le_trans h_weaker h_tight

/-! ### Part 5 — Strict positivity at the collective level.

R.811 strict-positivity gives `0 < N i₀`. Via R.510 attainment,
`N(k) = N i₀ > 0`, so the collective cost is *strictly* positive whenever
`Phi0 > 0` and the readable alphabet is non-trivial. -/

/-- **R.811 ⊕ R.510 — collective `N(k) > 0` under positive Fano potential.**

If at the attaining `i₀` we have `0 < Phi0`, `1 < cardM i₀`, and the R.811
Fano accumulation, then `N i₀ > 0`, hence `N(k) > 0`. The collective is
not free. -/
theorem collective_strictly_positive
    {ι : Type} [Fintype ι] (N : ι → ℝ)
    (hne : (Finset.univ : Finset ι).Nonempty)
    (Phi0 : ℝ) (cardM : ι → ℝ)
    (i₀ : ι) (hattain : Finset.univ.inf' hne N = N i₀)
    (hPhi0 : 0 < Phi0)
    (hcardM₀ : 1 < cardM i₀)
    (hfano₀ : Phi0 ≤ N i₀ * Real.log (cardM i₀)) :
    0 < Finset.univ.inf' hne N := by
  have h_pos : 0 < N i₀ :=
    R811_CollabFano.R_811_lower_pos (N i₀) Phi0 (cardM i₀)
      hPhi0 hcardM₀ hfano₀
  rw [hattain]; exact h_pos

end R3_Agent8_MultiAgentFano

end MIP
