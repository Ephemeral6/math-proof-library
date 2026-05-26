/-
Theorem T.31 — FEP-MIP Free Energy Decomposition.

Reference: `proofs/T31.md` (A 条件, Σ* metric / second-order expansion).

**Statement.** Under FEP-MIP degeneracy conditions (F1)–(F4), the
Friston variational free energy `F(s̃, μ)` decomposes as

    F  =  Φ₀(Y, p)  +  C_train  =  N(p, Y) · Π  +  C_train,

with `Π = 1/Z` (Friston precision = inverse MIP impedance).

**Proof outline.**
* Step 1 (R.408): Surprise `−log p(s̃ | m) = Φ₀(Y, p)`.
* Step 2 (T.8): `Φ₀ = N · Π` via Ohm law.
* Step 3 (R.408 step 3): Precision = inverse impedance in `d_Σ → 0`.
* Step 4 (R.402): KL_MIP^post = Friston Complexity.

**STATUS: SIGNATURE / KERNEL.** Requires `Friston-F`, `Complexity`,
`Π`, `Z`, all opaque. The pure algebraic identity
`F = A + B + 0 = A + B` is trivial; the substantive content is the
*equality of these specific functionals*. We state the additive
decomposition kernel.
-/
import MIP.Axioms
import MIP.Theorems.T18_4_Goodhart  -- imports `CTrain`

namespace MIP

open MIP.Goodhart (CTrain)

namespace FEP

/-- **Friston precision Π and the associated `F` functional.**

Opaque pending the formal FEP-MIP infrastructure. -/
opaque Precision {α : Type} : Agent α → ℝ

/-- **Variational free energy `F` of an agent on a problem.** Opaque. -/
opaque FreeEnergy {α : Type} : Agent α → Problem α → ℝ

/-- **The Friston complexity term** (= KL_MIP^post = `CTrain`).
Encoded as a separate symbol identified with `CTrain` between two
agents (a prior and a posterior). -/
noncomputable def Complexity {α : Type} (Y_prior Y_post : Agent α) : ℝ :=
  (CTrain Y_post Y_prior : ℝ)

/-- **T.31.kernel — pure additive decomposition.**

If `F = surprise + complexity` and `surprise = N · Π`, then
`F = N · Π + complexity`. Pure linear algebra. -/
theorem T31_decomposition_kernel
    (F surprise complexity N piVal : ℝ)
    (h_decomp : F = surprise + complexity)
    (h_ohm : surprise = N * piVal) :
    F = N * piVal + complexity := by
  rw [h_decomp, h_ohm]

/-- **T.31 (FEP-MIP decomposition) — signature form.**

The MIP-side relation: given the (sorried) `surprise_eq_Phi0` and
`precision_inv_Z` hypotheses, `F` admits the named decomposition. -/
theorem T31_FreeEnergy_decomposition
    {α : Type} (Y_prior Y_post : Agent α) (p : Problem α)
    (surprise : ℝ)
    (h_surprise : surprise = (Phi0 Y_post p).toReal)
    (h_F : FreeEnergy Y_post p = surprise + Complexity Y_prior Y_post) :
    FreeEnergy Y_post p
      = (Phi0 Y_post p).toReal + (CTrain Y_post Y_prior : ℝ) := by
  rw [h_F, h_surprise]
  rfl

end FEP

end MIP
