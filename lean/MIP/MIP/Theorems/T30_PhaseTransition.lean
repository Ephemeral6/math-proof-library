/-
Theorem T.30 — Three-Phase Transition.

Reference: `proofs/T30.md` (A 条件性).

**Statement.** A training trajectory `{A_t}` satisfying the prerequisites
R.79, R.96, R.134 (v2) traverses three crossover surfaces in strict
temporal order:

    t_cov  <  t*  <  t_aut,

where
* `t_cov` = first time `|K(A_t)| ≥ |R(p)|` (coverage; A.2 satisfied),
* `t*`   = first time `K^M(A_t) ⊇ K^M(H)` (collaboration alignment),
* `t_aut` = first time `Φ₀(A_t) < δ` (autonomy; A.1 satisfied).

**Proof outline.**
* First crossover: A.2 + Heaps law (`|K(A_t)| ~ t^β`).
* Second crossover: ITA + Gompertz (`κ`).
* Third crossover: Gompertz + Heaps composition.

**STATUS: SIGNATURE / KERNEL.** Requires `t_cov`/`t*`/`t_aut` as
functionals of the training trajectory, plus Gompertz / Heaps growth.
None in the opaque API. We capture the *temporal ordering* as a
clean ordered-triple kernel.
-/
import MIP.Axioms

namespace MIP

namespace PhaseTransition

/-- **Pure kernel: strict ordering of three positive reals.**

Given three crossover times `t_cov, t_star, t_aut` and proofs of the
two strict inequalities, we package the strict ordering. -/
theorem T30_strict_ordering_kernel
    (t_cov t_star t_aut : ℝ)
    (h1 : t_cov < t_star) (h2 : t_star < t_aut) :
    t_cov < t_aut ∧ t_cov < t_star ∧ t_star < t_aut :=
  ⟨lt_trans h1 h2, h1, h2⟩

/-- **The three crossover times as functionals.** Opaque pending the
training-trajectory API. -/
opaque crossover_times {α : Type} : (ℕ → Agent α) → Problem α → ℝ × ℝ × ℝ

/-- **Phase-transition prerequisite bundle (Path B form).**

The growth-law prerequisites R.79 (Heaps law for `|K(A_t)|`), R.96
(ITA + Gompertz for the collaboration crossover), and R.134 (Gompertz /
Heaps composition for the autonomy crossover) are not yet expressible
at the current opaque signature layer. Following the `RestrSpec` idiom,
we package their *conclusions* — the two strict crossover inequalities
they yield — as a single `Prop` predicate carried as a hypothesis:

* `(crossover_times Xs p).1 < (crossover_times Xs p).2.1`
  (first crossover: coverage `t_cov` strictly precedes collaboration `t*`,
  from R.79 + A.2 + Heaps law),
* `(crossover_times Xs p).2.1 < (crossover_times Xs p).2.2`
  (second crossover: collaboration `t*` strictly precedes autonomy
  `t_aut`, from R.96 + R.134 / ITA + Gompertz).

Concrete callers establish this bundle by deriving the two crossover
times from the Heaps/Gompertz growth analysis once the training-trajectory
API is in the signatures. -/
def PhaseTransitionPrereq {α : Type} (Xs : ℕ → Agent α) (p : Problem α) : Prop :=
  ((crossover_times Xs p).1 < (crossover_times Xs p).2.1)
  ∧
  ((crossover_times Xs p).2.1 < (crossover_times Xs p).2.2)

/-- **T.30 (Three-Phase Transition) — signature form.**

For any training trajectory whose growth-law prerequisites R.79 / R.96 /
R.134 hold (bundled as `PhaseTransitionPrereq`, i.e. the two strict
crossover inequalities they yield), the three crossover times occur in
strict three-phase order:

    t_cov  <  t*  <  t_aut,

stated as the full conjunction `t_cov < t* ∧ t* < t_aut ∧ t_cov < t_aut`.
The content is carried by `T30_strict_ordering_kernel`, applied to the two
inequalities destructured from the prerequisite bundle. -/
theorem T30_phase_transition
    {α : Type} (Xs : ℕ → Agent α) (p : Problem α)
    (h : PhaseTransitionPrereq Xs p) :
    (crossover_times Xs p).1 < (crossover_times Xs p).2.1
      ∧ (crossover_times Xs p).2.1 < (crossover_times Xs p).2.2
      ∧ (crossover_times Xs p).1 < (crossover_times Xs p).2.2 := by
  obtain ⟨h_ord_1, h_ord_2⟩ := h
  obtain ⟨h_trans, h_first, h_second⟩ :=
    T30_strict_ordering_kernel
      (crossover_times Xs p).1 (crossover_times Xs p).2.1
      (crossover_times Xs p).2.2 h_ord_1 h_ord_2
  exact ⟨h_first, h_second, h_trans⟩

end PhaseTransition

end MIP
