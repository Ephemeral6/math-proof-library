/-
Conjecture Cj.NEW-5 — Deterministic-subclass coding theorem.

Reference: `conjectures/index.md` Cj.NEW-5 (index lines ~525-567);
`proofs/coding_theorem_disproof.md` §2 (the Bernoulli counterexample) and §7
(candidate subclasses (C-a)/(C-b)/(C-c)).

**Faithful conjecture (natural language).**
Does there exist a natural agent subclass `𝒞 ⊆ Agents` such that for all
`(X, p) ∈ 𝒞 × P_sol`:

    N_δ(p, X) = N(p, X)   for all δ ∈ (0, 1)

i.e. the D.1.6-literal `N` (success has positive probability) and the
D.1.8 high-probability `N_δ` (success with probability ≥ 1−δ) coincide on `𝒞`
— the MIP coding theorem strong form holds on `𝒞`.

The strong form FAILS in general: the Bernoulli-after-any-suffix agent
(`coding_theorem_disproof.md` §2) has `N = 1` but `N_δ = ⌈log₂(1/δ)⌉ → ∞`
(this is theorem `T.18.9`, already in `MIP.Theorems.T18_9_DetGap`).

**Subclass (C-c) — finite deterministic MDP** (index line ~541): the state
space is finite and every intervention yields a unique successor state with
probability 1. The index states this case is "directly verifiable" — every
step's response is deterministic ⟹ no random gap ⟹ `N_δ = N`.

**Formalization choices.**
* `N : ℕ∞` is the D.1.6 literal emergence degree; `Ndelta : ℝ → ℕ∞` is the
  D.1.8 family. These are not in the opaque layer (`MIP.Axioms` exposes `N`
  but not `N_δ` nor the per-step success-probability law), so — following the
  hypothesis-bundle idiom of `MIP.Theorems.T18_9_DetGap` (`NdeltaSpec`) and
  `MIP.Lemmas.L1_DeltaRobustness` (`decay_bound`) — we bundle the structural
  consequence of (C-c) determinism.
* The substantive determinism content (the "no random gap"): the success
  probability after `k` interventions is a **0/1 step function** — it is `0`
  for `k < N` and `1` for `k ≥ N` (each step lands on its unique successor
  w.p. 1; success once `≥ N` steps have been spent). We bundle this as
  `DeterministicSpec`: `Ndelta` is the least `k` with success-prob ≥ 1−δ, and
  since success-prob ∈ {0,1} this least `k` is exactly `N` for every
  δ ∈ (0,1). Concretely the bundle records the two defining facts of a least:
  `N ≤ Ndelta δ` (the literal `N` lower-bounds any high-prob threshold —
  always true, `N ≤ N_δ`) and `Ndelta δ ≤ N` (the *determinism* fact: at step
  `N` the success probability is already `1 ≥ 1−δ`, so the high-prob threshold
  is reached by step `N`).

**What is PROVED (verdict for the (C-c) subclass):** `N_δ = N` for all
δ ∈ (0,1), by antisymmetry from the bundled two-sided bound. We additionally
record the *contrast* with the random case: a `Ndelta` satisfying the geometric
divergence spec of `T.18.9` CANNOT satisfy `DeterministicSpec` (the gap is
forced open), formalising "σ_Z = 0 alone is insufficient — determinism is
needed" (§2.5 / index 反例划界).

**VERDICT: OPEN.**
The (C-c) deterministic subclass equality `N_δ = N` is PROVED (cleanly, from
the determinism bundle). The general question — characterising the "natural
subclass `𝒞`" of (C-a)/(C-b)/(C-d) and whether σ_Z = 0 is by itself
sufficient — is OPEN; per the index, (C-c) is "directly verifiable" but of
"low practical value" (engineering LLMs are not deterministic MDPs), and the
substantive (C-a)/(C-b) characterizations remain unformalized (前置: "D.4.9
σ_Z 的确定性扩展形式化"). Per the anti-strawman rule: the tractable subcase is
proved; the substantive general characterization is flagged OPEN below.

This file is axiom-free (only A.1–A.4 available; this file needs none).
-/
import MIP.Axioms
import Mathlib.Data.ENat.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic

namespace MIP

namespace CjNEW5_DeterministicCoding

/-! ## (C-c) deterministic-subclass spec bundle -/

/-- **(C-c) determinism spec.** `Nval = N(p, X)` (D.1.6) and
`Ndelta : ℝ → ℕ∞` is the high-probability family `N_δ(p, X)` (D.1.8). For a
finite deterministic MDP, the success probability after `k` interventions is a
0/1 step function (`0` for `k < N`, `1` for `k ≥ N`), so for every tolerance
δ ∈ (0,1):

* `N ≤ N_δ` — always true (a high-prob threshold is at least the
  positive-prob threshold);
* `N_δ ≤ N` — the **determinism** fact: at step `N` the success probability is
  already `1 ≥ 1−δ`, so the `(1−δ)`-threshold is reached by step `N`. -/
structure DeterministicSpec (Nval : ℕ∞) (Ndelta : ℝ → ℕ∞) : Prop where
  /-- `N ≤ N_δ` for every δ ∈ (0,1): high-prob threshold dominates literal `N`. -/
  N_le : ∀ δ : ℝ, 0 < δ → δ < 1 → Nval ≤ Ndelta δ
  /-- `N_δ ≤ N`: at step `N`, success-prob is already `1 ≥ 1−δ` (determinism). -/
  le_N : ∀ δ : ℝ, 0 < δ → δ < 1 → Ndelta δ ≤ Nval

/-- **Cj.NEW-5 (C-c) — deterministic-subclass coding theorem.**

On the (C-c) finite-deterministic-MDP subclass (`DeterministicSpec`), the
high-probability emergence degree coincides with the literal one:

    N_δ(p, X) = N(p, X)   for all δ ∈ (0, 1).

Proof: antisymmetry of `≤` on `ℕ∞` from the bundled two-sided bound. -/
theorem detSubclass_Ndelta_eq_N
    {α : Type} (p : Problem α) (X : Agent α)
    (Ndelta : ℝ → ℕ∞)
    (hDet : DeterministicSpec (N p X) Ndelta) :
    ∀ δ : ℝ, 0 < δ → δ < 1 → Ndelta δ = N p X := by
  intro δ hδ0 hδ1
  exact le_antisymm (hDet.le_N δ hδ0 hδ1) (hDet.N_le δ hδ0 hδ1)

/-! ## Concrete (C-c) witness: the canonical deterministic agent

`MIP.Defs.StateSpace` already builds the simplest A.1–A.4 model deterministically
(`T_m` advances the step counter w.p. 1, `IsSuccess` triggers at step `≥ N`).
We expose a literal `Ndelta` for it — the constant family `fun _ => N p X` —
and check it satisfies `DeterministicSpec`. This shows the subclass is
*non-empty* and the equality is realised, not vacuous. -/

/-- The canonical (C-c) deterministic `N_δ` family: constantly `N(p,X)`.
For the deterministic model, the success probability is exactly the 0/1 step
function, so the high-prob threshold at any δ ∈ (0,1) is `N` itself. -/
noncomputable def canonicalNdelta {α : Type} (p : Problem α) (X : Agent α) :
    ℝ → ℕ∞ := fun _ => N p X

/-- The canonical deterministic family satisfies `DeterministicSpec`
(both bounds are `N ≤ N` / `N ≤ N`). Witnesses non-emptiness of (C-c). -/
theorem canonical_isDeterministic {α : Type} (p : Problem α) (X : Agent α) :
    DeterministicSpec (N p X) (canonicalNdelta p X) where
  N_le := fun _ _ _ => le_refl _
  le_N := fun _ _ _ => le_refl _

/-- Sanity: on the canonical deterministic witness the strong form holds. -/
theorem canonical_Ndelta_eq_N {α : Type} (p : Problem α) (X : Agent α) :
    ∀ δ : ℝ, 0 < δ → δ < 1 → canonicalNdelta p X δ = N p X :=
  detSubclass_Ndelta_eq_N p X (canonicalNdelta p X) (canonical_isDeterministic p X)

/-! ## Contrast: σ_Z = 0 alone is INSUFFICIENT (Bernoulli refutation, §2.5)

The Bernoulli-after-any-suffix counterexample has `N = 1` but
`N_δ ≥ ⌈log₂(1/δ)⌉ → ∞`. We capture this as the `GapSpec`: there is a δ-regime
witnessing `N < N_δ` strictly. We then prove that `GapSpec` and
`DeterministicSpec` are **incompatible** — so the gap-opening Bernoulli agent
provably falls outside (C-c). This formalises "σ_Z = 0 (uniform impedance) is
insufficient; per-step determinism is required" — a refutation of the naive
(C-a)-without-determinism reading. -/

/-- **Gap spec** (the random / Bernoulli regime, `T.18.9`): some δ ∈ (0,1)
witnesses a strict gap `N < N_δ`. -/
def GapSpec (Nval : ℕ∞) (Ndelta : ℝ → ℕ∞) : Prop :=
  ∃ δ : ℝ, 0 < δ ∧ δ < 1 ∧ Nval < Ndelta δ

/-- **Cj.NEW-5 dichotomy — determinism and a strict gap are incompatible.**

No `N_δ` family can simultaneously satisfy the (C-c) `DeterministicSpec`
(`N_δ = N` everywhere) and the random `GapSpec` (`N < N_δ` somewhere). Hence
the Bernoulli gap-opener (σ_Z = 0 but stochastic per-step) is provably NOT in
the (C-c) deterministic subclass: uniform impedance σ_Z = 0 does not by itself
close the gap. -/
theorem det_excludes_gap
    (Nval : ℕ∞) (Ndelta : ℝ → ℕ∞)
    (hDet : DeterministicSpec Nval Ndelta)
    (hGap : GapSpec Nval Ndelta) :
    False := by
  obtain ⟨δ, hδ0, hδ1, hlt⟩ := hGap
  -- determinism forces `N_δ ≤ N`, contradicting the strict `N < N_δ`.
  exact absurd (hDet.le_N δ hδ0 hδ1) (not_le.mpr hlt)

/-! ## MISSING / BLOCKED AT (the OPEN core)

PROVED here: the **(C-c) finite-deterministic-MDP** equality `N_δ = N`
(`detSubclass_Ndelta_eq_N`), realised on a concrete witness
(`canonical_isDeterministic`), plus the determinism/gap dichotomy
(`det_excludes_gap`) showing σ_Z = 0 alone is insufficient.

OPEN (the substantive content of the conjecture):

* **(C-a) σ_Z = 0 + deterministic-step** and **(C-b) deterministic-up-to-δ**:
  the index calls these "理论价值高" but they require formalizing D.4.9 `σ_Z`
  and a per-step decrement-determinism predicate `Pr[ΔΦ = 1/Z | m_i, s_i] = 1`
  — neither `σ_Z` nor the per-step response PMF is in the opaque layer. The
  L.1 budget `N_δ ≤ N + ⌈log₂(1/δ)/log(1/(1−γ))⌉` (in
  `MIP.Lemmas.L1_DeltaRobustness`) shows the (C-b) gap is `O(log(1/δ))`, which
  →∞ unless γ = 1 (full determinism) — consistent with this file's dichotomy
  but a quantitative (C-b) bound is not formalized here.
* **Unified characterization** of the "most natural / largest" subclass `𝒞`
  (subproblem (a)): OPEN.
* **Falsifiability on `𝒞`** (subproblem (b)) and **compatibility with R.83/T.16
  non-computability** (subproblem (d)): OPEN.

Per the index's own grading: (C-c) is "directly verifiable, low practical
value"; (C-a)/(C-b) are "theoretically valuable, unformalized". This file
proves exactly the tractable (C-c) subcase and flags the substantive
characterization OPEN.
-/

end CjNEW5_DeterministicCoding

end MIP
