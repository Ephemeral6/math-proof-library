/-
Theorem T.4 — Framework Equivalence.

Reference: `proofs/T4.md`.

**Statement.** With `F*` an optimal framework:

    N(p, A, F*) = 0  ⟺  Φ₀(A, p, F*) = 0
                    ⟺  q₀^{F*} is information-equivalent (Reach_X)
                        to "preexecuting the optimal σ*".

**Proof.**
* `N = 0 ⟺ Φ₀ = 0`: A.1 directly.
* `N = 0 ⟺ Reach(s_0^{F*}) ⊇ S_p*`: from D.4.7 reachability semantics.

**STATUS: PARTIAL.** Needs `Reach`, `S_p*` (solution-state set),
framework operator `F : Σ* → Σ*` (D.4.7), all opaque. We give a stub
relying on `A.1` for the `N = 0 ⟺ Φ₀ = 0` part (provable cleanly).
-/
import MIP.Axioms

namespace MIP

open MIP.Axioms

namespace FrameworkEquiv

/-- **Framework-augmented initial query / agent**.

In the NL formulation, applying framework `F` to problem `p` gives a
modified initial query `q₀^F := F(q₀)`. We model this abstractly as a
modified agent `X^F` whose distribution mirrors `X` on the framework-
augmented history. -/
noncomputable def withFramework {α : Type} (F : Str α → Str α)
    (X : Agent α) : Agent α :=
  fun h => X (F h)

/-- **Emergence degree under a framework.** -/
noncomputable def NF {α : Type} (p : Problem α) (F : Str α → Str α)
    (X : Agent α) : ℕ∞ :=
  N p (withFramework F X)

/-- **Initial emergence potential under a framework.** -/
noncomputable def Phi0F {α : Type} (X : Agent α) (F : Str α → Str α)
    (p : Problem α) : ENNReal :=
  Phi0 (withFramework F X) p

/-- **T.4(a) — `N = 0 ⟺ Φ₀ = 0` under a framework.**

Direct consequence of A.1 applied to `withFramework F X`. -/
theorem T4_NeqZero_iff_Phi0_eqZero
    {α : Type} (p : Problem α) (X : Agent α) (F : Str α → Str α) :
    NF p F X = 0 ↔ Phi0F X F p = 0 := by
  unfold NF Phi0F
  exact Axioms.A1 p _

end FrameworkEquiv

end MIP
