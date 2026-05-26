/-
Theorem T.5 — Flywheel acceleration.

Reference: `proofs/T5.md`.

**Statement.** Let `A_t` be the generation-`t` agent and assume

    |B_t(p)|  ≤  (1 - α) · |B_{t-1}(p)|

with `α ∈ (0, 1)` the per-generation barrier reduction rate. Let `T_max`
be a global upper bound on the entanglement `T(p, A_t) := N/|B|`. Then

    E[N(p, A_t)]  ≤  T_max · (1 - α)^t · E[N(p, A_0)].

**Proof.**
* `|B_t| ≤ (1-α)^t · |B_0|`: induction on `t`.
* `N(p, A_t) ≤ T_max · |B_t|` (T.8 + entanglement def).
* `|B_0| ≤ N(p, A_0)` (T.1, applied to `A_0`).
* Combine and take expectation.

**STATUS: PARTIAL.** Needs `barrierCard`, T.1, T.8. The
pure-math kernel (geometric decay implies geometric expectation
bound) is provable independently.
-/
import MIP.Theorems.T1_LowerBound
import MIP.Theorems.T3_Entanglement
import Mathlib.Algebra.Order.Group.Basic

namespace MIP

open MIP.Entanglement (barrierCard)

namespace Flywheel

/-- **Geometric decay kernel.** If `b_t ≤ (1 - α) · b_{t-1}` for `t ≥ 1`
with `0 ≤ 1 - α`, then `b_t ≤ (1 - α)^t · b_0`. -/
theorem T5_geometric_decay_kernel
    (b : ℕ → ℝ) (α : ℝ) (hα_le : 0 ≤ 1 - α)
    (h_decay : ∀ t, b (t + 1) ≤ (1 - α) * b t) :
    ∀ t, b t ≤ (1 - α) ^ t * b 0 := by
  intro t
  induction t with
  | zero => simp
  | succ n ih =>
    calc b (n + 1)
        ≤ (1 - α) * b n := h_decay n
      _ ≤ (1 - α) * ((1 - α) ^ n * b 0) :=
          mul_le_mul_of_nonneg_left ih hα_le
      _ = (1 - α) ^ (n + 1) * b 0 := by ring

/-- **Flywheel data bundle (hypothesis-bundle idiom).**

Following the `MIP.UEA.RestrSpec` pattern: the pieces of T.5 that live
beyond the current opaque signature layer — the barrier measure
`b t = |B_t(p)|`, the entanglement value `Nt t = N(p, A_t)`, and the
two structural links (T.1 and T.8) — are bundled as explicit fields
rather than asserted as fresh axioms.

* `b t`     : the barrier cardinality `|B_t(p)|` as a real number.
* `Nt t`    : the entanglement count `N(p, A_t)` as a real number.
* `α`       : the per-generation barrier reduction rate; `Tmax` the
              global entanglement bound `T_max`.
* `hα_le`   : `0 ≤ 1 - α`  (the decay factor is nonnegative).
* `hTmax`   : `0 ≤ Tmax`.
* `decay`   : `|B_{t+1}| ≤ (1-α) · |B_t|`  (per-generation reduction).
* `t8`      : `N(p, A_t) ≤ T_max · |B_t|`  (**T.8** + entanglement def;
              *bundled*).
* `t1_base` : `|B_0| ≤ N(p, A_0)`  (**T.1** applied to `A_0`; *bundled*).

The geometric assembly below is *proven* from these fields via
`T5_geometric_decay_kernel`. -/
structure FlywheelData where
  /-- Barrier measure `|B_t(p)|` as a real number. -/
  b : ℕ → ℝ
  /-- Entanglement value `N(p, A_t)` as a real number. -/
  Nt : ℕ → ℝ
  /-- Per-generation barrier reduction rate. -/
  α : ℝ
  /-- Global entanglement upper bound `T_max`. -/
  Tmax : ℝ
  /-- The decay factor `1 - α` is nonnegative. -/
  hα_le : 0 ≤ 1 - α
  /-- The global entanglement bound is nonnegative. -/
  hTmax : 0 ≤ Tmax
  /-- Per-generation barrier reduction `|B_{t+1}| ≤ (1-α) · |B_t|`. -/
  decay : ∀ t, b (t + 1) ≤ (1 - α) * b t
  /-- **T.8 link (bundled):** `N(p, A_t) ≤ T_max · |B_t|`. -/
  t8 : ∀ t, Nt t ≤ Tmax * b t
  /-- **T.1 link (bundled):** `|B_0| ≤ N(p, A_0)`. -/
  t1_base : b 0 ≤ Nt 0

/-- **T.5 (Flywheel) — deterministic per-trajectory bound.**

Given a `FlywheelData` bundle (the T.1/T.8 links and the barrier /
entanglement measures), the entanglement count contracts geometrically:

    N(p, A_t)  ≤  T_max · (1 - α)^t · N(p, A_0).

This is the faithful core of real T.5; the `E[·]` version is the same
inequality under a monotone expectation, which we do not need to model.

* *Bundled* (taken as fields): T.1 (`t1_base`), T.8 (`t8`), and the
  per-generation reduction (`decay`).
* *Proven* (the geometric assembly): everything below, with the
  geometric decay supplied by `T5_geometric_decay_kernel`. -/
theorem T5_Flywheel (D : FlywheelData) :
    ∀ t, D.Nt t ≤ D.Tmax * (1 - D.α) ^ t * D.Nt 0 := by
  intro t
  -- Step (geometric decay): `|B_t| ≤ (1-α)^t · |B_0|` from the kernel.
  have hgeo : D.b t ≤ (1 - D.α) ^ t * D.b 0 :=
    T5_geometric_decay_kernel D.b D.α D.hα_le D.decay t
  -- `0 ≤ (1-α)^t`, needed to push the T.1 base link through.
  have hpow_nonneg : (0 : ℝ) ≤ (1 - D.α) ^ t := pow_nonneg D.hα_le t
  -- Chain: `Nt t ≤ Tmax · |B_t| ≤ Tmax · ((1-α)^t · |B_0|)`
  --              ≤ Tmax · ((1-α)^t · Nt 0)`.
  calc D.Nt t
      ≤ D.Tmax * D.b t := D.t8 t
    _ ≤ D.Tmax * ((1 - D.α) ^ t * D.b 0) :=
        mul_le_mul_of_nonneg_left hgeo D.hTmax
    _ ≤ D.Tmax * ((1 - D.α) ^ t * D.Nt 0) := by
        -- `|B_0| ≤ Nt 0` (T.1 base) times the nonneg factor `(1-α)^t`,
        -- then by the nonneg factor `Tmax`.
        apply mul_le_mul_of_nonneg_left _ D.hTmax
        exact mul_le_mul_of_nonneg_left D.t1_base hpow_nonneg
    _ = D.Tmax * (1 - D.α) ^ t * D.Nt 0 := by ring

end Flywheel

end MIP
