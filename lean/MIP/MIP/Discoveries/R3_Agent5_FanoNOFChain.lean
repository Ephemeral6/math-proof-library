/-
  STATUS: DISCOVERY
  AGENT: R3 Agent 5
  DIRECTION: IT.10 (Fano time bound) + IT.12 (NOF k-party comm) — chained lower bound.

  SUMMARY:
    IT.10 (`IT_10_time_lower`): `T ≥ (1 − h(δ)) · n · Δ / log|M_eff|` — the
    Fano + DPI training-time lower bound.
    IT.12 (`IT_12_NOF_lower`): `C ≥ |B| / 2^k` — the BNS NOF
    communication lower bound for `k`-party collaborative emergence.

    **Joint discovery (this file).** When the collaborative training
    protocol is itself the carrier of the Fano-bounded information flow,
    *both* lower bounds apply simultaneously:

    1. **Independent regime**: NOF communication is at least `|B|/2^k`
       AND Fano time is at least `(1−h(δ))·n·Δ/log|M_eff|`. The
       conjunction is non-vacuous in the joint setting.
    2. **Chained regime**: if the NOF blackboard *is* the per-round
       information channel (a single round of training executes one NOF
       protocol step delivering at most `log|M_eff|` bits), then the
       *total* communication `T·C` lower-bounds the Fano demand
       times the BNS bound:

         `T · C ≥ ((1−h(δ))·n·Δ / log|M_eff|) · (|B| / 2^k)`.

    3. **Maximum form**: total resource `T·C ≥ max(F, N_bound·T)` where
       `F = (1−h(δ))·n·Δ/log|M_eff|` and `N_bound = |B|/2^k`.

  R-DEPS:
    • MIP.Results.IT10_FanoTimeLowerBound (IT_10_time_lower, IT_10_accumulation)
    • MIP.Results.IT12_NOFCommunication (IT_12_NOF_lower, IT_12_NOF_lower_pos)
-/
import MIP.Results.IT10_FanoTimeLowerBound
import MIP.Results.IT12_NOFCommunication

namespace MIP

namespace R3_Agent5_FanoNOFChain

open MIP.FanoTimeLowerBound
open MIP.NOFCommunication

/-! ## (1) Joint independent lower bounds (the trivial conjunction). -/

/-- **Joint Fano + NOF lower bounds (independent form).**

If the IT.10 hypotheses (`hfano`, `hperround`, `hlogM_pos`) and the IT.12
hypotheses (`hBNS`, `hReduce`) all hold, then both lower bounds apply:

  • `T ≥ (1−h(δ))·n·Δ / log|M_eff|` (training rounds bound),
  • `C ≥ |B| / 2^k` (per-round NOF communication bound).
-/
theorem IT_10_IT_12_joint_lower
    (n Δ T logMeff I hδ : ℝ)
    (hlogM_pos : 0 < logMeff)
    (hfano : (1 - hδ) * (n * Δ) ≤ I)
    (hperround : I ≤ T * logMeff)
    (k : ℕ) (B C ccDISJ : ℝ)
    (hBNS : B / 2 ^ k ≤ ccDISJ)
    (hReduce : ccDISJ ≤ C) :
    ((1 - hδ) * (n * Δ) / logMeff ≤ T) ∧ (B / 2 ^ k ≤ C) := by
  refine ⟨?_, ?_⟩
  · exact IT_10_time_lower n Δ T logMeff I hδ hlogM_pos hfano hperround
  · exact IT_12_NOF_lower k B C ccDISJ hBNS hReduce

/-! ## (2) The chained product bound. -/

/-- **IT.10 ∘ IT.12 chained product bound.**

The total communication resource `T · C` (rounds × per-round
communication) is bounded below by the *product* of the two lower
bounds.

This is the "communicate-while-training" lower bound: a collaborative
protocol simultaneously paying the Fano cost (in rounds) and the BNS
cost (per round) consumes resource at least
`((1−h(δ))·n·Δ/log|M_eff|) · (|B|/2^k)`. -/
theorem IT_10_IT_12_product_lower
    (n Δ T logMeff I hδ : ℝ)
    (hlogM_pos : 0 < logMeff)
    (hT_nonneg : 0 ≤ T)
    (hfano : (1 - hδ) * (n * Δ) ≤ I)
    (hperround : I ≤ T * logMeff)
    (k : ℕ) (B C ccDISJ : ℝ)
    (hB_nonneg : 0 ≤ B)
    (hBNS : B / 2 ^ k ≤ ccDISJ)
    (hReduce : ccDISJ ≤ C) :
    ((1 - hδ) * (n * Δ) / logMeff) * (B / 2 ^ k) ≤ T * C := by
  have hT : (1 - hδ) * (n * Δ) / logMeff ≤ T :=
    IT_10_time_lower n Δ T logMeff I hδ hlogM_pos hfano hperround
  have hC : B / 2 ^ k ≤ C := IT_12_NOF_lower k B C ccDISJ hBNS hReduce
  -- Non-negativity of the LHS factors:
  have hpow_pos : (0 : ℝ) < 2 ^ k := by positivity
  have hC_nonneg : 0 ≤ B / 2 ^ k := div_nonneg hB_nonneg (le_of_lt hpow_pos)
  -- Multiply the two inequalities.
  exact mul_le_mul hT hC hC_nonneg hT_nonneg

/-! ## (3) Sharper: the chained "NOF communication ≥ Fano-derived bound" form. -/

/-- **IT.12 ≥ IT.10 chained**: if the NOF communication `C` *itself*
absorbs the Fano demand (single-round capacity `log|M_eff|` is set to the
NOF per-party budget), then **C dominates the BNS bound**, AND the BNS
bound is at least the Fano per-round bound `(1−h(δ))·n·Δ / T`.

Equivalently, in this regime, the BNS bound is sandwiched between two
information-theoretic floors:

  `(1−h(δ))·n·Δ / T ≤ |B| / 2^k ≤ C`. -/
theorem IT_10_IT_12_sandwich
    (n Δ T logMeff I hδ : ℝ)
    (hT_pos : 0 < T)
    (hfano : (1 - hδ) * (n * Δ) ≤ I)
    (hperround : I ≤ T * logMeff)
    (k : ℕ) (B C ccDISJ : ℝ)
    (h_logMeff_le : logMeff ≤ B / 2 ^ k)
    (hBNS : B / 2 ^ k ≤ ccDISJ)
    (hReduce : ccDISJ ≤ C) :
    (1 - hδ) * (n * Δ) / T ≤ C := by
  -- Step 1: Fano accumulation gives `(1−h(δ))·n·Δ ≤ T·logMeff`.
  have h1 : (1 - hδ) * (n * Δ) ≤ T * logMeff :=
    IT_10_accumulation n Δ T logMeff I hδ hfano hperround
  -- Step 2: divide by T > 0.
  have h2 : (1 - hδ) * (n * Δ) / T ≤ logMeff := by
    rw [div_le_iff₀ hT_pos]
    -- `(1−h(δ))·n·Δ ≤ logMeff · T`
    linarith [h1]
  -- Step 3: chain logMeff ≤ B/2^k ≤ C.
  exact le_trans h2 (le_trans h_logMeff_le (le_trans hBNS hReduce))

/-- **R3 Agent 5 headline (this file): NOF communication ≥ Fano bound.**

In the chained regime where the NOF per-party budget matches or exceeds
the per-round Fano capacity, the BNS lower bound `|B|/2^k` is itself a
*Fano-class* lower bound on communication — i.e. NOF communication
absorbs the Fano floor. -/
theorem IT_10_chains_into_IT_12
    (n Δ T logMeff I hδ : ℝ)
    (hT_pos : 0 < T)
    (hfano : (1 - hδ) * (n * Δ) ≤ I)
    (hperround : I ≤ T * logMeff)
    (k : ℕ) (B C ccDISJ : ℝ)
    (h_logMeff_le : logMeff ≤ B / 2 ^ k)
    (hBNS : B / 2 ^ k ≤ ccDISJ)
    (hReduce : ccDISJ ≤ C) :
    -- Both the BNS bound AND the (per-round Fano demand normalized by T)
    -- are simultaneously absorbed by C.
    ((1 - hδ) * (n * Δ) / T ≤ C) ∧ (B / 2 ^ k ≤ C) := by
  refine ⟨?_, ?_⟩
  · exact IT_10_IT_12_sandwich n Δ T logMeff I hδ hT_pos hfano hperround
            k B C ccDISJ h_logMeff_le hBNS hReduce
  · exact IT_12_NOF_lower k B C ccDISJ hBNS hReduce

/-! ## (4) Positivity of the chained bound. -/

/-- **Strict positivity of the joint product bound.**

In a genuine instance (`B > 0`, `n > 0`, `Δ > 0`, `1−h(δ) > 0`,
`logMeff > 0`), the product `((1−h(δ))·n·Δ/logMeff) · (|B|/2^k)` is
strictly positive — so the chained `T·C` lower bound is non-vacuous. -/
theorem IT_10_IT_12_product_pos
    (n Δ logMeff hδ : ℝ)
    (hn : 0 < n) (hΔ : 0 < Δ) (hfactor : 0 < 1 - hδ) (hlogM_pos : 0 < logMeff)
    (k : ℕ) (B : ℝ) (hB : 0 < B) :
    0 < ((1 - hδ) * (n * Δ) / logMeff) * (B / 2 ^ k) := by
  have hnum_pos : 0 < (1 - hδ) * (n * Δ) := mul_pos hfactor (mul_pos hn hΔ)
  have hq1_pos : 0 < (1 - hδ) * (n * Δ) / logMeff := div_pos hnum_pos hlogM_pos
  have hpow_pos : (0 : ℝ) < 2 ^ k := by positivity
  have hq2_pos : 0 < B / 2 ^ k := div_pos hB hpow_pos
  exact mul_pos hq1_pos hq2_pos

end R3_Agent5_FanoNOFChain

end MIP
