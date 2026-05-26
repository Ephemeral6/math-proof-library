/-
Result R.417 — Joint free energy conservation law (the F-form of R.132).

Reference: `workspace/multiagent_fep_mip.md` §R.417 (A 条件, Ohm regime +
second-order Z=1/Π domain, 2026-05-16 multi-agent FEP-MIP block),
steps 1-2 + corollary R.417.c.

**Statement.** In the (F1')-(F4) degeneration, applying the R.408 master
equation `F_i = N(p, Y_i, Y_j)·Π_{i|j} + KL_{MIP,i}` to each agent and
substituting the R.132 conservation law `N + N* = 2·N_bi + Asym`, the joint
free energy decomposes (in the Ohm / uniform-precision regime where
`Π_{1|2} = Π_{2|1} = Π̄`) as

        F_1 + F_2 = (2·N_bi + Asym)·Π̄ + KL_1 + KL_2.

**Corollary R.417.c (Type S).** In a Type-S collaboration field
(D.2.9 / R.73), `Z_A(b) = Z_H(b)` for all `b`, which forces
`Asym = 0`, `N = N* = N_bi`, `Π_{1|2} = Π_{2|1} = Π̄`, and `KL_1 = KL_2`
(full symmetry). Then the two agents' free energies are *strictly equal*,
        F_1 = F_2,
a proposition not stated explicitly in Friston's literature but pinned down
by the MIP collaboration-field classification.

This file encodes:
1. the joint-FE decomposition identity (algebraic, tied to R.132), and
2. the Type-S symmetric equality `F_1 = F_2`,
bundling the per-agent master equation as definitional inputs.

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace JointFreeEnergy

/-! ## Part 1: joint free-energy decomposition (R.132 F-form) -/

/-- **R.417 (steps 1-2) — joint free-energy decomposition.**

Per the R.408 master equation each agent has `F_i = N_i·Π̄ + KL_i`
(uniform-precision Ohm regime: `Π_{1|2} = Π_{2|1} = Π̄`). Substituting the
R.132 conservation law `N + N* = 2·N_bi + Asym` gives

    F_1 + F_2 = (2·N_bi + Asym)·Π̄ + KL_1 + KL_2.

**Proof.** Pure algebra: `F_1 + F_2 = (N + N*)·Π̄ + (KL_1 + KL_2)`, then
rewrite `N + N*`. -/
theorem R_417_joint_decomposition
    (F1 F2 N N_star N_bi Asym Pibar KL1 KL2 : ℝ)
    (h_F1 : F1 = N * Pibar + KL1)
    (h_F2 : F2 = N_star * Pibar + KL2)
    (h_R132 : N + N_star = 2 * N_bi + Asym) :
    F1 + F2 = (2 * N_bi + Asym) * Pibar + KL1 + KL2 := by
  rw [h_F1, h_F2]
  -- (N·Π̄ + KL1) + (N*·Π̄ + KL2) = (N + N*)·Π̄ + (KL1 + KL2).
  have hfactor : N * Pibar + KL1 + (N_star * Pibar + KL2)
      = (N + N_star) * Pibar + (KL1 + KL2) := by ring
  rw [hfactor, h_R132]
  ring

/-- **R.417.b — symmetric-saturation simplification (R.131).**

At R.131 symmetric saturation `N = N*`, the joint decomposition simplifies:
the cross term vanishes and `F_1 + F_2 = 2·N·Π̄ + KL_1 + KL_2`. With
`N = N* = N_bi` (saturation) this is the "clean" `2 N_bi + Asym + KL` form
with `Asym = 2(N − N_bi)`. -/
theorem R_417_b_symmetric_form
    (F1 F2 N Pibar KL1 KL2 : ℝ)
    (h_F1 : F1 = N * Pibar + KL1)
    (h_F2 : F2 = N * Pibar + KL2) :
    F1 + F2 = 2 * N * Pibar + KL1 + KL2 := by
  rw [h_F1, h_F2]; ring

/-! ## Part 2: Type-S strict symmetry `F_1 = F_2` (corollary R.417.c) -/

/-- **R.417.c — Type-S joint free energy: `F_1 = F_2`.**

In a Type-S collaboration field the dual impedances coincide
(`Z_A = Z_H`), which (D.4.15 P3 + R.69 saturation) forces full symmetry of
the F-decomposition data:
* `N = N*` (symmetric intervention counts),
* `Π_{1|2} = Π_{2|1} = Π̄` (equal precisions), and
* `KL_1 = KL_2` (equal complexity drifts).

Under these the two agents' free energies are *strictly equal*. -/
theorem R_417_c_typeS_symmetry
    (F1 F2 N N_star Pi12 Pi21 KL1 KL2 : ℝ)
    (h_F1 : F1 = N * Pi12 + KL1)
    (h_F2 : F2 = N_star * Pi21 + KL2)
    (h_N : N = N_star)
    (h_Pi : Pi12 = Pi21)
    (h_KL : KL1 = KL2) :
    F1 = F2 := by
  rw [h_F1, h_F2, h_N, h_Pi, h_KL]

/-- **R.417.c — Type-S full saturation closed form.**

In Type S, additionally `N = N* = N_bi = |B|·Φ̄` and `Asym = 0`, so the
joint free energy is `F_1 + F_2 = 2·N_bi·Π̄ + KL_1 + KL_2 = 2·F_1 = 2·F_2`
(using the strict symmetry). The per-agent free energy is exactly half the
joint. -/
theorem R_417_c_typeS_half
    (F1 F2 N_bi Asym Pibar KL1 KL2 : ℝ)
    (h_F1 : F1 = N_bi * Pibar + KL1)
    (h_F2 : F2 = N_bi * Pibar + KL2)
    (h_Asym : Asym = 0)
    (h_KL : KL1 = KL2) :
    F1 = F2 ∧ F1 + F2 = 2 * F1 ∧
      F1 + F2 = (2 * N_bi + Asym) * Pibar + KL1 + KL2 := by
  have hEq : F1 = F2 := by rw [h_F1, h_F2, h_KL]
  refine ⟨hEq, by linarith, ?_⟩
  rw [h_F1, h_F2, h_Asym]; ring

end JointFreeEnergy

end MIP
