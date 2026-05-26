/-
Result R.806 — Augmentation coverage invariance (ACI).

Reference: `proofs/derived/A4_grade.md` R.806 (A 无条件).

**Statement.** Under the modular-coupling decomposition,

    N(p, X_total) < ∞  ⟺  (∃ R ∈ ℛ(p), R ⊆ K_b)  ⟺  N(p, X_base) < ∞ ,

where `K_b := K(X_base)`; i.e. an augmented system's finiteness of
emergence degree is governed entirely by the *base* knowledge `K_b`.

**Proof.** By the bare–dressed decomposition (R.804 / T.34), the total
system's effective knowledge support equals `K_b`:
`K(X_total) = K(X_base)`.  Each of the two finiteness conditions is, by
A.2, equivalent to `∃ R ∈ ℛ(p), R ⊆ K(·)`; since the two knowledge sets
coincide, the two conditions coincide.

**Lean kernel.** R.804/T.34 (the support-equality `K(X_total) = K(X_base)`)
is upstream, so it enters as an explicit hypothesis `h_K`.  We rewrite both
sides of the desired equivalence through `MIP.Axioms.A2` and `h_K`.

**This file is `axiom`-free** apart from the project's foundational
`MIP.Axioms.A2`.
-/
import MIP.Axioms

namespace MIP

namespace AugmentationCoverage

open MIP.Axioms

variable {α Ω : Type}

/-- **R.806 (ACI) — middle ⟺ total form.**

`N(p, X_total) < ∞  ⟺  ∃ R ∈ ℛ(p), R ⊆ K_b`, where the support-equality
`K(X_total) = K_b` is the R.804/T.34 conclusion supplied as `h_K`.  This is
just A.2 for `X_total` with its knowledge set rewritten to `K_b`. -/
theorem aug_coverage_total_iff_cover
    (p : Problem α) (X_total X_base : Agent α)
    (h_K : (K X_total : Set Ω) = (K X_base : Set Ω)) :
    N p X_total ≠ ⊤
      ↔
    ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X_base : Set Ω) := by
  rw [Axioms.A2 (Ω := Ω) p X_total, h_K]

/-- **R.806 (ACI) — base ⟺ cover form.**

`N(p, X_base) < ∞  ⟺  ∃ R ∈ ℛ(p), R ⊆ K_b`.  Verbatim A.2 for `X_base`. -/
theorem aug_coverage_base_iff_cover
    (p : Problem α) (X_base : Agent α) :
    N p X_base ≠ ⊤
      ↔
    ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X_base : Set Ω) :=
  Axioms.A2 (Ω := Ω) p X_base

/-- **R.806 (ACI) — coverage invariance.**

The augmented system's emergence degree is finite iff the base system's is:

    N(p, X_total) ≠ ⊤  ⟺  N(p, X_base) ≠ ⊤ ,

given the bare–dressed support-equality `K(X_total) = K(X_base)` (R.804 /
T.34, taken as the hypothesis `h_K`).

Augmentation cannot rescue an A.2 failure: no matter how strong `X_aug`
is, if `K_b` fails to cover any abductive explanation of `p`, then `N`
remains `∞`. -/
theorem aug_coverage_invariance
    (p : Problem α) (X_total X_base : Agent α)
    (h_K : (K X_total : Set Ω) = (K X_base : Set Ω)) :
    N p X_total ≠ ⊤ ↔ N p X_base ≠ ⊤ := by
  rw [aug_coverage_total_iff_cover (Ω := Ω) p X_total X_base h_K,
      aug_coverage_base_iff_cover (Ω := Ω) p X_base]

/-- **R.806 (ACI) — full three-way equivalence.**

The complete R.806 chain

    N(p, X_total) ≠ ⊤  ⟺  (∃ R ∈ ℛ(p), R ⊆ K_b)  ⟺  N(p, X_base) ≠ ⊤ ,

packaged as a single conjunction of equivalences. -/
theorem aug_coverage_three_way
    (p : Problem α) (X_total X_base : Agent α)
    (h_K : (K X_total : Set Ω) = (K X_base : Set Ω)) :
    (N p X_total ≠ ⊤
        ↔ ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X_base : Set Ω))
      ∧ ((∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X_base : Set Ω))
        ↔ N p X_base ≠ ⊤) :=
  ⟨aug_coverage_total_iff_cover (Ω := Ω) p X_total X_base h_K,
   (aug_coverage_base_iff_cover (Ω := Ω) p X_base).symm⟩

end AugmentationCoverage

end MIP
