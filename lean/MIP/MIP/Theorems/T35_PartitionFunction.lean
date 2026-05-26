/-
Theorem T.35 — MIP Partition Function double inequality.

Reference: `workspace/partition_function_theorem.md` §3.2 (A 无条件).

**Statement.** For all `X` and `p ∈ P_sol`:

    -log Z(X,p)  ≤  Φ₀(X,p)  ≤  min_{R ⊆ K(X)} Φ₀(X,p;R)

where
* `Z(X,p) := Σ_{R ∈ ℛ(p), R ⊆ K(X)} exp(-Φ₀(X,p;R))`,
* `Φ₀(X,p;R)` is the path-restricted emergence potential.

**Proof.**
* Upper bound: `E_{R*} ⊆ E_success`, so `Pr[success] ≥ Pr[E_{R*}] =
  exp(-Φ₀(X,p;R*))`. Take min over R*, then negative log.
* Lower bound: Boole / union bound on the (`R`-indexed) cover of
  `E_success`. ∎

**Strategy.** Both inequalities reduce to elementary facts about
probabilities/exponentials. The Boole step is the only non-trivial
ingredient. We give a *pure-math kernel* (`T35_kernel_*`) that proves
each bound from an abstract probability-mass interface, with no `sorry`,
and a higher-level MIP statement reduces to it.
-/
import MIP.Axioms
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

open scoped BigOperators
open Real

namespace PartitionFunction

/-! ## Pure-math kernels. -/

/-- **Lower-bound kernel (-log Z ≤ Φ).**
If `0 < q ≤ Σ b i` with all `b i ≥ 0`, then `-log (Σ b i) ≤ -log q`. -/
theorem T35_lower_kernel
    {ι : Type*} (s : Finset ι) (b : ι → ℝ) (q : ℝ)
    (_hb : ∀ i ∈ s, 0 ≤ b i) (hq_pos : 0 < q)
    (h_union : q ≤ ∑ i ∈ s, b i) :
    -Real.log (∑ i ∈ s, b i) ≤ -Real.log q := by
  have hsum_pos : 0 < ∑ i ∈ s, b i := lt_of_lt_of_le hq_pos h_union
  have : Real.log q ≤ Real.log (∑ i ∈ s, b i) :=
    Real.log_le_log hq_pos h_union
  linarith

/-- **Upper-bound kernel (Φ ≤ min Φ_R).**
If for every `R` we have `exp(-φ R) ≤ q`, with `q > 0`, then
`-log q ≤ min φ R`. (We state the existential form, which is enough.) -/
theorem T35_upper_kernel
    {ι : Type*} (R : ι) (φ : ι → ℝ) (q : ℝ)
    (_hq_pos : 0 < q) (h_subset : Real.exp (-(φ R)) ≤ q) :
    -Real.log q ≤ φ R := by
  -- From exp(-φ R) ≤ q: -φ R ≤ log q ⟹ -log q ≤ φ R.
  have hpos : 0 < Real.exp (-(φ R)) := Real.exp_pos _
  have hle : -(φ R) ≤ Real.log q := by
    have : Real.log (Real.exp (-(φ R))) ≤ Real.log q :=
      Real.log_le_log hpos h_subset
    rwa [Real.log_exp] at this
  linarith

/-! ## MIP-level signatures.

Path-indexed emergence potential, partition function. Opaque at the
present signature layer — the full ℛ(p) / cl_H / extract / E_R / Pr
infrastructure is not yet in `MIP.Axioms`. -/

variable {α : Type}

/-- Path-indexed emergence potential `Φ₀(X, p; R)`. Opaque. -/
opaque PhiPath : Agent α → Problem α → (Set Nat) → ℝ

/-- Family of "feasible covering paths" indexed by some `ι`. Opaque. -/
opaque feasiblePaths : Agent α → Problem α → Finset Nat

/-- `Z(X, p) = Σ_R exp(-Φ₀(X, p; R))` over the (finite) feasible path set. -/
noncomputable def Z (X : Agent α) (p : Problem α) : ℝ :=
  ∑ R ∈ feasiblePaths X p,
    Real.exp (-(PhiPath X p ({R} : Set Nat)))

/-- **T.35 (Partition Function Theorem) — formal stub.**

Stated as an "elementary" property: when the success probability
`q := Pr[X solves p]` satisfies `0 < q` and is sandwiched between
`exp(-PhiPath …)` (some single path covers ⊆ E_success) and `Z X p`
(Boole over the path family), the corresponding log inequalities
follow from `T35_lower_kernel` / `T35_upper_kernel`.

The MIP-specific premise — that `Pr[X solves p]` IS such a `q` — depends
on the (sorry-ed) probabilistic interpretation of `Phi0` and `PhiPath`.

We package T.35 in *kernel form* and the user combines the two kernels
once the probability layer is available. -/
theorem T35_PartitionFunction_kernel
    (X : Agent α) (p : Problem α) (q : ℝ) (hq_pos : 0 < q)
    (R0 : Nat) (_hR0 : R0 ∈ feasiblePaths X p)
    (h_lower : q ≤ Z X p)
    (h_upper : Real.exp (-(PhiPath X p ({R0} : Set Nat))) ≤ q) :
    -Real.log (Z X p) ≤ -Real.log q ∧
      -Real.log q ≤ PhiPath X p ({R0} : Set Nat) := by
  refine ⟨?_, ?_⟩
  · -- Reduce to T35_lower_kernel.
    apply T35_lower_kernel (feasiblePaths X p)
      (fun R => Real.exp (-(PhiPath X p ({R} : Set Nat))))
      q (fun i _ => (Real.exp_pos _).le) hq_pos
    simpa [Z] using h_lower
  · exact T35_upper_kernel R0 (fun R => PhiPath X p ({R} : Set Nat)) q hq_pos h_upper

end PartitionFunction

end MIP
