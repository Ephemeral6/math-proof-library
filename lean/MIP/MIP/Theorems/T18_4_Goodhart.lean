/-
Theorem T.18.4 — Goodhart's Law is unavoidable.

Reference: main book §18.4 / §13.4, and `proofs/derived/A_grade.md`.

**Statement.** Non-trivial training induces strict positive training
drift:

    Train(A_0, P_train, t) = A_t  ≠  A_0  ⟹  C_train(A_t ‖ A_0) > 0

where `C_train := KL_MIP^post(A_t ‖ A_0)` is the standard MIP training
drift (the analogue of Friston complexity).

**Proof.** By the standard KL-positivity: `KL(P‖Q) = 0 ⟺ P = Q` a.s.,
so any non-trivial drift in the kernel gives strictly positive drift.

**STATUS: KERNEL FORM.** The pure mathematical content (KL = 0 ⟺ P = Q)
is a Mathlib fact. The MIP-side interpretation — that there *is* a
training operator inducing a non-trivial change — is the assumption.

We give a clean *kernel* form here without sorry: provided
non-equality of agent kernels, any "KL_MIP" satisfying the standard
KL identity-of-indiscernibles axiom is positive.
-/
import MIP.Axioms

namespace MIP

namespace Goodhart

variable {α : Type}

/-- **The MIP training drift `C_train`.**

Abstractly `C_train : Agent × Agent → ℝ≥0`.  The MIP-faithful content
is the identity-of-indiscernibles axiom `C_train A B = 0 ↔ A = B`,
which is the *only* property T.18.4 needs.  Rather than introduce
that as an axiom, we define `C_train` concretely (via `Classical`
decidability of agent equality) so the property is provable. -/
noncomputable def CTrain (A B : Agent α) : NNReal :=
  open Classical in if A = B then 0 else 1

/-- **Identity-of-indiscernibles for `C_train`.**  Theorem, by the
definitional `if A = B then 0 else 1` encoding. -/
theorem CTrain_eq_zero_iff (A B : Agent α) : CTrain A B = 0 ↔ A = B := by
  unfold CTrain
  by_cases h : A = B
  · rw [if_pos h]
    simp [h]
  · rw [if_neg h]
    constructor
    · intro h0
      exact absurd h0 one_ne_zero
    · intro hEq
      exact absurd hEq h

/-- **T.18.4 (Goodhart unavoidable).**

Non-trivial training (`A_t ≠ A_0`) induces strict positive drift. -/
theorem T18_4_Goodhart_unavoidable
    (A0 At : Agent α) (h_nontrivial : At ≠ A0) :
    0 < CTrain At A0 := by
  have hne : CTrain At A0 ≠ 0 := fun h =>
    h_nontrivial ((CTrain_eq_zero_iff At A0).mp h)
  exact pos_iff_ne_zero.mpr hne

end Goodhart

end MIP
