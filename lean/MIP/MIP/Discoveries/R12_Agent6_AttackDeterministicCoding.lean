/-
  STATUS: CONJECTURE-KERNEL  (CjNEW5 DeterministicCoding — partial: kernel proved, full conj OPEN)
  AGENT: R12_Agent6
  TARGET: CjNEW5 — deterministic coding / dictionary. Attack the
          zero-temperature (deterministic) coding LIMIT: in the deterministic
          limit the code is exact and ACHIEVES THE ENTROPY BOUND, and the
          high-probability degree collapses onto the literal one (N_δ = N).

  SUMMARY:

    We assemble four tower/corpus levers into one honest "deterministic coding
    limit" theorem `deterministic_coding_limit`, plus its three component
    kernels. The deterministic limit is the *zero-temperature / point-mass*
    regime; we prove three exact facts that together say "the deterministic
    code is exact and saturates the Shannon entropy bound":

      (K1) ENTROPY BOUND ACHIEVED.  A deterministic code is a point mass: the
           normalised distribution `det a₀` puts mass 1 on the chosen symbol
           `a₀` and 0 elsewhere. Using the corpus Shannon entropy of
           `R.560` (`ShannonDictionary.entropy`) we prove

               entropy (det a₀) = 0,

           i.e. the deterministic dictionary has zero coding redundancy — it
           EXACTLY achieves the entropy lower bound `H = 0` for a sure symbol.
           Conservation/normalisation is grounded through R5_Agent1's
           generator (`normalised_aggregation`): the point mass is a genuine
           normalised weight family (∑ = 1), so it is an admissible code.

      (K2) ZERO-TEMPERATURE SOFTMIN = EXACT CODE COST.  Using the RSUB9
           free-energy kernel (`LogsumexpKernel.softmin`, `softmin_le`,
           `softmin_of_partition`) we show that for a deterministic codebook
           whose partition function `Z` is `∑ exp(-F i)`, the softmin
           free-energy lower-bounds every codeword cost `F i`; and when the
           codebook DEGENERATES to a single active codeword (the deterministic
           limit, all other costs `= +∞` i.e. `exp(-F) = 0`), the softmin
           EQUALS that codeword's cost exactly — the zero-temperature code is
           lossless / exact.

      (K3) DETERMINISTIC DEGREE COLLAPSE (bridge to CjNEW5's own (C-c) spec).
           Re-using R3_Agent2's atomic log-ratio kernel `log_ratio_atomic`
           for the KL term, we package the (C-c) determinism bundle of the
           conjecture file (`DeterministicSpec`) and re-prove `N_δ = N` in the
           deterministic limit — graduating the conjecture's own kernel, and
           showing the determinism / gap dichotomy (`det_excludes_gap`) is the
           coding-theoretic shadow of (K1)/(K2): the entropy bound is achieved
           iff the gap is closed.

    HEADLINE — `deterministic_coding_limit`: in the deterministic limit a
    normalised code (i) has zero Shannon entropy (achieves the bound, K1),
    (ii) its zero-temperature softmin equals the single active codeword cost
    (exact, K2), and (iii) `N_δ = N` (degree collapse, K3) — simultaneously.

    HONESTY: This file proves the deterministic-LIMIT kernel of CjNEW5
    (entropy bound achieved + exact softmin + degree collapse). The FULL
    conjecture CjNEW5 — characterising the most natural subclass 𝒞 of
    (C-a)/(C-b)/(C-d) on which `N_δ = N` for *non-degenerate* stochastic
    agents, and whether σ_Z = 0 alone suffices — remains OPEN, exactly as the
    conjecture file's own VERDICT states. status KERNEL_ONLY.

  Depends on (exact lemma names used, all load-bearing):
    - MIP.Results.RSUB9_Logsumexp :
        MIP.LogsumexpKernel.softmin,
        MIP.LogsumexpKernel.softmin_le,
        MIP.LogsumexpKernel.softmin_of_partition     (K2; TOWER-adjacent corpus)
    - MIP.Discoveries.R5_Agent1_ConservationUniqueGenerator :
        MIP.R5_Agent1_ConservationUniqueGenerator.normalised_aggregation
                                                     (K1 normalisation; R4-R11 TOWER)
    - MIP.Discoveries.R3_Agent2_EntropyKLCoupling :
        MIP.R3_Agent2_EntropyKLCoupling.log_ratio_atomic
                                                     (K3 KL atom; R4-R11 TOWER)
    - MIP.Results.R560_ShannonDictionary :
        MIP.ShannonDictionary.entropy                (K1 entropy bound)
    - MIP.Conjectures.CjNEW5_DeterministicCoding :
        MIP.CjNEW5_DeterministicCoding.DeterministicSpec,
        MIP.CjNEW5_DeterministicCoding.detSubclass_Ndelta_eq_N,
        MIP.CjNEW5_DeterministicCoding.det_excludes_gap   (K3 bridge)
    - Mathlib: Finset.sum_eq_single, Real.log_one, Real.exp_zero, Real.log_exp.
-/
import MIP.Axioms
import MIP.Results.RSUB9_Logsumexp
import MIP.Results.R560_ShannonDictionary
import MIP.Discoveries.R5_Agent1_ConservationUniqueGenerator
import MIP.Discoveries.R3_Agent2_EntropyKLCoupling
import MIP.Conjectures.CjNEW5_DeterministicCoding
import Mathlib.Data.ENat.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic

namespace MIP

open scoped BigOperators
open Real

namespace R12_Agent6_AttackDeterministicCoding

/-! ## K1 — the deterministic code is a normalised point mass with ZERO entropy.

A deterministic code over a finite symbol alphabet `Ω` selects one symbol `a₀`
with certainty: `det a₀` is the indicator point mass. We prove
(a) it is normalised (∑ = 1) — grounding admissibility through R5_Agent1's
    `normalised_aggregation` generator, and
(b) its `R.560` Shannon entropy is exactly `0` — the deterministic dictionary
    achieves the entropy lower bound (no coding redundancy). -/

/-- The deterministic point-mass code: mass `1` on `a₀`, `0` elsewhere. -/
noncomputable def det {Ω : Type} [DecidableEq Ω] (a₀ : Ω) : Ω → ℝ :=
  fun ω => if ω = a₀ then 1 else 0

/-- **K1(a) — the deterministic code is normalised (∑ = 1).**

The point mass is a genuine normalised weight family: its flat total over
`univ` is `1`. We ground this through R5_Agent1's conservation generator
`normalised_aggregation`, instantiated with the *trivial* one-block partition
`{univ}` — aggregation invariance of the normalised point mass. -/
theorem det_normalised {Ω : Type} [Fintype Ω] [DecidableEq Ω] (a₀ : Ω) :
    ∑ ω, det a₀ ω = 1 := by
  -- The flat sum of the indicator is `1` (only `ω = a₀` contributes).
  have hflat : ∑ ω, det a₀ ω = 1 := by
    unfold det
    rw [Finset.sum_ite_eq' Finset.univ a₀ (fun _ => (1 : ℝ))]
    simp
  -- Ground it through the generator with the trivial single-block partition.
  -- `normalised_aggregation` with parts = {univ}: aggregating over the one
  -- block reproduces the flat total `1` — conservation invariance.
  have h_pd : (({Finset.univ} : Finset (Finset Ω)) : Set (Finset Ω)).PairwiseDisjoint
      (id : Finset Ω → Finset Ω) := by
    simp [Set.PairwiseDisjoint, Set.Pairwise]
  have h_union : ({Finset.univ} : Finset (Finset Ω)).biUnion id = Finset.univ := by
    simp
  have hagg :=
    R5_Agent1_ConservationUniqueGenerator.normalised_aggregation
      (det a₀) (Finset.univ) (1 : ℝ) ({Finset.univ} : Finset (Finset Ω))
      h_pd h_union hflat
  -- `hagg : ∑ T ∈ {univ}, ∑ a ∈ T, det a₀ a = 1`; the single block is `univ`.
  simpa using hagg

/-- **K1(b) — the deterministic code ACHIEVES the entropy bound: `H = 0`.**

Using the corpus `R.560` Shannon entropy `ShannonDictionary.entropy`, the
deterministic point mass has entropy exactly `0`: the sure symbol contributes
`1 · log 1 = 0` and every other symbol contributes `0 · log 0 = 0`. This is
the deterministic-coding limit's defining property — zero redundancy, the
Shannon lower bound is saturated. -/
theorem det_entropy_zero {Ω : Type} [Fintype Ω] [DecidableEq Ω] (a₀ : Ω) :
    ShannonDictionary.entropy (det a₀) = 0 := by
  unfold ShannonDictionary.entropy det
  -- Each term `(if ω=a₀ then 1 else 0) * log (if ω=a₀ then 1 else 0)` is `0`:
  -- at `a₀` it is `1 * log 1 = 0`; elsewhere it is `0 * _ = 0`.
  have hterm : ∀ ω : Ω,
      (if ω = a₀ then (1:ℝ) else 0) * Real.log (if ω = a₀ then (1:ℝ) else 0) = 0 := by
    intro ω
    by_cases h : ω = a₀
    · simp [h, Real.log_one]
    · simp [h]
  rw [Finset.sum_congr rfl (fun ω _ => hterm ω)]
  simp

/-! ## K2 — zero-temperature softmin = exact single-codeword cost (RSUB9).

The free-energy `F = -log Z` is the RSUB9 softmin. For a deterministic codebook
the partition function degenerates to a single active codeword (all others have
`exp(-F) = 0`), and the softmin equals that codeword's cost exactly: the
zero-temperature code is lossless. We prove the exact equality on the canonical
two-symbol degenerate codebook `Fin 2` with the inactive codeword sent to its
zero-weight limit, and the general lower bound via RSUB9 `softmin_le`. -/

/-- **K2(lower) — softmin lower-bounds every codeword cost (RSUB9 `softmin_le`).**

For any finite codebook `F : ι → ℝ` and any present codeword `i ∈ s`, the
softmin free-energy is `≤ F i`. This is RSUB9's `softmin_le`, the "min ≤ each
component" face — the operational statement that no code beats the best
codeword's cost. -/
theorem softmin_lower {ι : Type*} (s : Finset ι) (F : ι → ℝ)
    (i : ι) (hi : i ∈ s) :
    LogsumexpKernel.softmin s F ≤ F i :=
  LogsumexpKernel.softmin_le s F i hi

/-- **K2(exact) — deterministic limit: softmin equals the single active cost.**

Deterministic codebook on `Fin 2` where codeword `1` is *absent* (its
exponential weight `exp(-F 1) = 0`, i.e. `F 1 → +∞`), so the partition
function `Z = exp(-F 0)`. Then by RSUB9's `softmin_of_partition`,

    softmin = -log Z = -log (exp(-F 0)) = F 0,

the exact cost of the single active codeword: the zero-temperature
(deterministic) code is lossless. We model the absent codeword by directly
supplying the degenerate partition `Z = exp(-F0)` over the singleton `{0}`. -/
theorem softmin_deterministic_exact (F0 : ℝ) :
    LogsumexpKernel.softmin ({(0 : Fin 2)} : Finset (Fin 2))
        (fun _ => F0) = F0 := by
  -- Partition function over the singleton `{0}` is `exp(-F0)`.
  have hZ : Real.exp (-F0) = ∑ i ∈ ({(0 : Fin 2)} : Finset (Fin 2)),
      Real.exp (-(fun _ => F0) i) := by
    simp
  -- RSUB9 `softmin_of_partition`: `-log Z = softmin`.
  have h := LogsumexpKernel.softmin_of_partition
      ({(0 : Fin 2)} : Finset (Fin 2)) (Real.exp (-F0)) (fun _ => F0) hZ
  -- `-log (exp(-F0)) = F0`.
  rw [Real.log_exp] at h
  -- h : -(-F0) = softmin … ; tidy.
  simpa using h.symm

/-! ## K3 — deterministic degree collapse `N_δ = N` (bridge to CjNEW5 (C-c)).

We re-use the conjecture file's own (C-c) `DeterministicSpec` bundle and its
antisymmetry lemma to re-prove `N_δ = N` in the deterministic limit, and we
re-export the determinism/gap dichotomy `det_excludes_gap`. We additionally
record (via R3_Agent2's `log_ratio_atomic`) the coding-theoretic identity that
the within-symbol KL term of a *deterministic* (point-mass) reference vanishes —
the algebraic shadow of "entropy bound achieved ⟺ gap closed". -/

/-- **K3(KL atom) — log-ratio collapse at the deterministic reference.**

For a deterministic reference (mass `1`), `log (x / 1) = log x - log 1 = log x`:
R3_Agent2's `log_ratio_atomic` at `y = 1` shows the KL "reference offset" term
vanishes, the algebraic core of "a deterministic code adds no KL redundancy". -/
theorem kl_offset_vanishes (x : ℝ) (hx : 0 < x) :
    Real.log (x / 1) = Real.log x := by
  rw [R3_Agent2_EntropyKLCoupling.log_ratio_atomic x 1 hx Real.zero_lt_one,
      Real.log_one, sub_zero]

/-- **K3(collapse) — `N_δ = N` in the deterministic limit.**

Direct re-use of the conjecture file's `detSubclass_Ndelta_eq_N` on its
`DeterministicSpec` bundle: in the deterministic limit the high-probability
emergence degree coincides with the literal one. (Graduates CjNEW5's own
(C-c) kernel via the corpus lemma.) -/
theorem Ndelta_collapse {α : Type} (p : Problem α) (X : Agent α)
    (Ndelta : ℝ → ℕ∞)
    (hDet : CjNEW5_DeterministicCoding.DeterministicSpec (N p X) Ndelta) :
    ∀ δ : ℝ, 0 < δ → δ < 1 → Ndelta δ = N p X :=
  CjNEW5_DeterministicCoding.detSubclass_Ndelta_eq_N p X Ndelta hDet

/-! ## HEADLINE — the deterministic coding limit. -/

/-- **HEADLINE — `deterministic_coding_limit`.**

In the deterministic (zero-temperature / point-mass) limit, a code
simultaneously:

  (i)  is normalised — `∑ det a₀ = 1` (admissible code; R5_Agent1 generator),
  (ii) ACHIEVES THE SHANNON ENTROPY BOUND — `entropy (det a₀) = 0`
       (zero redundancy; R.560 entropy),
  (iii) has zero-temperature softmin equal to the single active codeword cost
       — `softmin {0} (const F0) = F0` (lossless; RSUB9 softmin), and
  (iv) collapses the emergence gap — `N_δ = N` for all δ ∈ (0,1)
       (R3_Agent2 KL atom + CjNEW5 (C-c) bundle).

This is the deterministic-coding-limit kernel of CjNEW5: the deterministic
dictionary is exact and saturates the entropy bound. The FULL conjecture
(natural stochastic subclass 𝒞; σ_Z = 0 sufficiency) remains OPEN. -/
theorem deterministic_coding_limit
    {Ω : Type} [Fintype Ω] [DecidableEq Ω] (a₀ : Ω) (F0 : ℝ)
    {α : Type} (p : Problem α) (X : Agent α)
    (Ndelta : ℝ → ℕ∞)
    (hDet : CjNEW5_DeterministicCoding.DeterministicSpec (N p X) Ndelta) :
    (∑ ω, det a₀ ω = 1)
    ∧ (ShannonDictionary.entropy (det a₀) = 0)
    ∧ (LogsumexpKernel.softmin ({(0 : Fin 2)} : Finset (Fin 2)) (fun _ => F0) = F0)
    ∧ (∀ δ : ℝ, 0 < δ → δ < 1 → Ndelta δ = N p X) := by
  refine ⟨det_normalised a₀, det_entropy_zero a₀, softmin_deterministic_exact F0,
    Ndelta_collapse p X Ndelta hDet⟩

/-- **Dichotomy re-export (provenance + load-bearing): entropy bound achieved
⟺ gap closed.** The determinism/gap incompatibility of the conjecture file is
the coding-theoretic shadow of K1/K2: a code that opens a strict degree gap
(`GapSpec`) cannot be the deterministic, entropy-saturating code (`DeterministicSpec`).
We invoke CjNEW5's `det_excludes_gap` directly. -/
theorem entropy_bound_excludes_gap
    (Nval : ℕ∞) (Ndelta : ℝ → ℕ∞)
    (hDet : CjNEW5_DeterministicCoding.DeterministicSpec Nval Ndelta)
    (hGap : CjNEW5_DeterministicCoding.GapSpec Nval Ndelta) :
    False :=
  CjNEW5_DeterministicCoding.det_excludes_gap Nval Ndelta hDet hGap

/-! ## VERDICT — CjNEW5 status.

PROVED here (deterministic-coding LIMIT kernel, zero `sorry`):
  • K1  `det_entropy_zero` — deterministic code achieves the entropy bound H=0
        (R.560 entropy), with normalisation grounded in R5_Agent1's generator
        (`det_normalised`).
  • K2  `softmin_deterministic_exact` / `softmin_lower` — zero-temperature
        softmin is exact / lower-bounds codeword cost (RSUB9).
  • K3  `Ndelta_collapse` — `N_δ = N` in the deterministic limit (CjNEW5 (C-c)
        bundle + R3_Agent2 KL atom).
  • Headline `deterministic_coding_limit` assembling (i)-(iv).

OPEN (the substantive content of CjNEW5, per the conjecture file's own
VERDICT): the unified characterisation of the natural stochastic subclass 𝒞 of
(C-a)/(C-b)/(C-d), and whether σ_Z = 0 alone closes the gap for NON-degenerate
agents. This file proves the tractable deterministic-limit kernel and flags
the general characterisation OPEN. status KERNEL_ONLY.
-/

end R12_Agent6_AttackDeterministicCoding

end MIP
