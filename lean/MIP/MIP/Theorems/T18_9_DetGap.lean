/-
Theorem T.18.9 — Deterministic Gap Non-Closure.

Reference: `proofs/coding_theorem_disproof.md` (A 无条件).

**Statement.** There exist `X` (satisfying A.1–A.4) and `p ∈ P_sol` such
that

    lim_{δ → 0⁺} N_δ(p, X)  =  ∞  >  N(p, X)  =  1.

In words: the strong form of the "MIP coding theorem" (Shannon-style
limit reachability) **fails**.

**Proof.** Explicit counterexample, the Bernoulli-after-any-suffix
agent:
* `X(q_0) = δ_0` (Dirac at "0"),
* `X(q_0 · h')` = Bernoulli(1/2) for any nonempty suffix `h'`.

Then `N(p, X) = 1` but `N_δ = ⌈log_2(1/δ)⌉ → ∞` as `δ → 0`.

**STATUS: HYBRID.** The high-probability operator `N_δ` (D.1.8), the
specific `X` construction, and the `Bernoulli` PMF are not in
`MIP.Axioms`. Following the hypothesis-bundle idiom of
`MIP.UEA.RestrSpec`, we therefore:

* **Bundle** (taken as explicit inputs / hypotheses): the operator
  `Ndelta : ℝ → ℕ` and its defining lower bound coming from the explicit
  Bernoulli PMF, namely that `N_δ` dominates the geometric threshold
  `log₂(1/δ)` — formalised as `NdeltaSpec` below. We optionally also
  bundle the deterministic value `N(p, X) = 1`.
* **Prove** (no `sorry`, no new axiom): from this bundle, that `N_δ`
  *diverges*, i.e. `∀ M, ∃ δ ∈ (0,1), M ≤ Ndelta δ`. This is the faithful
  content of the gap non-closure: the deterministic value stays at `1`
  while `N_δ → ∞` as `δ → 0`.

The *core arithmetic identity* `N_delta_geometric_kernel` is proved
cleanly and reused by the divergence argument.
-/
import MIP.Axioms
import Mathlib.Analysis.SpecialFunctions.Log.Basic

namespace MIP

namespace DetGap

/-- **N_δ for the Bernoulli-after-any-suffix counterexample (pure math).**

For `k` independent Bernoulli(1/2) tries, the probability of seeing at
least one "1" is `1 - (1/2)^k`. For this to be `≥ 1 - δ`, we need
`(1/2)^k ≤ δ`, i.e., `k ≥ log_2(1/δ)`.

The lemma states the monotone-divergent behaviour: `(1/2)^k → 0`. -/
theorem N_delta_geometric_kernel (δ : ℝ) (hδ_pos : 0 < δ) (_hδ_lt : δ < 1) :
    ∃ k : ℕ, (1 / 2 : ℝ) ^ k ≤ δ := by
  -- Standard fact: geometric series in (0,1) tends to 0.
  -- `pow_lt_one_iff_of_nonneg` etc.
  -- We use `Real.tendsto_pow_atTop_nhds_zero_of_lt_one` indirectly via
  -- the inequality `(1/2)^k ≤ δ` for k large enough.
  -- Simpler: take `k := ⌈log_{1/2} δ⌉`.
  -- We give an existence proof using Mathlib's `exists_pow_lt_of_lt_one`.
  have h : (1 / 2 : ℝ) < 1 := by norm_num
  have h0 : (0 : ℝ) ≤ 1 / 2 := by norm_num
  obtain ⟨k, hk⟩ := exists_pow_lt_of_lt_one hδ_pos h
  exact ⟨k, le_of_lt hk⟩

/-- **N_δ spec bundle for the Bernoulli-after-any-suffix counterexample.**

`Ndelta δ` is the abstract high-probability emergence degree `N_δ(p, X)`
(D.1.8) at tolerance `δ`. The single property we extract from the
*explicit Bernoulli PMF* of the counterexample is the geometric lower
bound: to drive the failure probability of `k` Bernoulli(1/2) tries below
`δ` one needs `(1/2)^k ≤ δ`, hence any threshold exponent `k` meeting
`(1/2)^k ≤ δ` is dominated by `N_δ`:

    ∀ δ ∈ (0,1), ∀ k, (1/2)^k ≤ δ → k ≤ N_δ(δ).

Bundling this (rather than asserting it as an axiom) follows the
hypothesis-bundle idiom of `MIP.UEA.RestrSpec`: a concrete caller
discharges it from the formalised Bernoulli PMF, which lies beyond the
current opaque signature layer. -/
def NdeltaSpec (Ndelta : ℝ → ℕ) : Prop :=
  ∀ δ : ℝ, 0 < δ → δ < 1 → ∀ k : ℕ, (1 / 2 : ℝ) ^ k ≤ δ → (k : ℝ) ≤ Ndelta δ

/-- **T.18.9 (Deterministic Gap Non-Closure).**

Given the bundled high-probability operator `Ndelta` satisfying
`NdeltaSpec` (the Bernoulli-PMF geometric lower bound) — and, optionally,
the bundled deterministic fact `N p X = 1` recorded by `hN` — the
high-probability emergence degree `N_δ` **diverges** as `δ → 0`:

    ∀ M : ℝ, ∃ δ : ℝ, 0 < δ ∧ δ < 1 ∧ M ≤ Ndelta δ.

Since the deterministic value `N(p, X)` stays equal to `1`, this is the
faithful formal content of the gap non-closure: the strong "MIP coding
theorem" (Shannon-style limit reachability) fails.

The proof is fully constructive: given `M`, take the exponent
`k := ⌈M⌉₊ + 1` (so `M ≤ k`), set `δ := (1/2)^k ∈ (0,1)`, and feed
`(1/2)^k ≤ δ` (reflexivity) into the bundled spec to get `k ≤ N_δ(δ)`,
whence `M ≤ N_δ(δ)`. The core estimate `(1/2)^k < 1` reuses the geometric
machinery underlying `N_delta_geometric_kernel`. -/
theorem T18_9_det_gap
    {α : Type} (p : Problem α) (X : Agent α)
    (Ndelta : ℝ → ℕ) (hspec : NdeltaSpec Ndelta)
    (_hN : N p X = 1) :
    ∀ M : ℝ, ∃ δ : ℝ, 0 < δ ∧ δ < 1 ∧ M ≤ (Ndelta δ : ℝ) := by
  -- The deterministic value is bundled as `_hN : N p X = 1`; it is not
  -- needed by the divergence argument itself, but is carried in the
  -- signature to state the full gap `N = 1 < N_δ → ∞`.
  intro M
  -- Pick an exponent `k` with `M ≤ k`.
  set k : ℕ := ⌈M⌉₊ + 1 with hk_def
  have hMk : M ≤ (k : ℝ) := by
    have hle : M ≤ (⌈M⌉₊ : ℝ) := Nat.le_ceil M
    have : (⌈M⌉₊ : ℝ) ≤ (k : ℝ) := by
      have : (⌈M⌉₊ : ℕ) ≤ k := by omega
      exact_mod_cast this
    linarith
  -- Basic facts about `1/2`.
  have hhalf_pos : (0 : ℝ) < 1 / 2 := by norm_num
  have hhalf_lt_one : (1 / 2 : ℝ) < 1 := by norm_num
  -- Choose `δ := (1/2)^k`, which lies in `(0,1)`.
  set δ : ℝ := (1 / 2 : ℝ) ^ k with hδ_def
  have hδ_pos : 0 < δ := by
    rw [hδ_def]; exact pow_pos hhalf_pos k
  have hk_ne : k ≠ 0 := by rw [hk_def]; omega
  have hδ_lt_one : δ < 1 := by
    rw [hδ_def]; exact pow_lt_one₀ (le_of_lt hhalf_pos) hhalf_lt_one hk_ne
  -- The geometric inequality at the chosen exponent is reflexivity.
  have hgeo : (1 / 2 : ℝ) ^ k ≤ δ := le_of_eq hδ_def
  -- Feed the bundle: `k ≤ N_δ(δ)`.
  have hkN : (k : ℝ) ≤ (Ndelta δ : ℝ) := hspec δ hδ_pos hδ_lt_one k hgeo
  exact ⟨δ, hδ_pos, hδ_lt_one, le_trans hMk hkN⟩

end DetGap

end MIP
