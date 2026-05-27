/-
Result R.194 — Decay-modified Ohm's law.
Reference: `branches/decay/workspace/new_results.md` (old decay R.155).

**Statement.** T.8 Ohm's law `N = ⌈Φ₀·Z⌉` acquires, under knowledge decay,
an additive maintenance correction:

    N_decay(p,X; T)  =  N_maint(T)  +  ⌈Φ₀(X,p) · Z_τ(X,T)⌉ ,

a two-stage decomposition: stage 1 re-activates the `N_maint = |R_lost(T)|`
forgotten demand elements; stage 2 solves on the maintained ("effective
fully active") knowledge space, costing `⌈Φ₀·Z_τ⌉` by T.8.  The two
intervention classes have disjoint effect (maintenance refreshes `t_last`,
solving lowers `Φ`), so the costs add.

**Properties.** `T = 0 ⇒ N_maint = 0 ⇒ N_decay = ⌈Φ₀·Z⌉` (recovers T.8);
`N_decay ≥ ⌈Φ₀·Z_τ⌉` (solve cost is a lower bound); `N_decay` is monotone
in the maintenance tax.

**Kernel formalized here.** The additive `ℕ∞` identity built on the
project's `ceilENat` (`⌈·⌉ : ENNReal → ℕ∞`), reusing
`MIP.Defs.StateSequence`.  We define `N_decay := N_maint + ⌈Φ₀·Z_τ⌉` and
prove: the two-stage identity, the `T=0` degeneration to T.8 form, the
solve-cost lower bound, and monotonicity in `N_maint`.

**Bridge.** `ceilENat (Φ₀·Z_τ)` is the decay-adjusted T.8 solve cost;
`N_maint` the maintenance tax of R.190; the disjoint-effect lemma of R.155
justifies the sum.  Mirrors the `T8_*` style of `StateSequence.lean`.
Axiom-free.
-/
import MIP.Defs.StateSequence
import Mathlib.Data.ENat.Basic
import Mathlib.Data.ENNReal.Basic

namespace MIP

namespace DecayModifiedOhm

open scoped ENat

/-- **R.194 — decay-modified emergence degree.**

`N_decay = N_maint + ⌈Φ₀·Z_τ⌉`: the maintenance tax plus the T.8 solve
cost on the effective (decay-adjusted) impedance `Z_τ`. -/
noncomputable def NDecay (Phi0 Ztau : ENNReal) (Nmaint : ℕ∞) : ℕ∞ :=
  Nmaint + ceilENat (Phi0 * Ztau)

/-- **R.194 — two-stage decomposition (defining identity).**

The decay-adjusted cost is exactly the maintenance tax plus the
decay-adjusted T.8 solve cost. -/
theorem R_194_two_stage (Phi0 Ztau : ENNReal) (Nmaint : ℕ∞) :
    NDecay Phi0 Ztau Nmaint = Nmaint + ceilENat (Phi0 * Ztau) := rfl

/-- **R.194 — `T = 0` degeneration to T.8.**

At `T = 0` nothing has decayed (`N_maint = 0`) and the effective impedance
equals the static one (`Z_τ = Z`), so `N_decay = ⌈Φ₀·Z⌉` — exactly the
T.8 Ohm law. -/
theorem R_194_recovers_ohm (Phi0 Z : ENNReal) :
    NDecay Phi0 Z 0 = ceilENat (Phi0 * Z) := by
  unfold NDecay
  rw [zero_add]

/-- **R.194 — solve cost is a lower bound.**

The maintenance tax can only add, so the decay-adjusted cost is at least
the T.8 solve cost on `Z_τ`. -/
theorem R_194_solve_lower (Phi0 Ztau : ENNReal) (Nmaint : ℕ∞) :
    ceilENat (Phi0 * Ztau) ≤ NDecay Phi0 Ztau Nmaint := by
  unfold NDecay
  exact le_add_self

/-- **R.194 — maintenance tax is a lower bound.**

Symmetrically, the decay-adjusted cost is at least the maintenance tax. -/
theorem R_194_maint_lower (Phi0 Ztau : ENNReal) (Nmaint : ℕ∞) :
    Nmaint ≤ NDecay Phi0 Ztau Nmaint := by
  unfold NDecay
  exact le_self_add

/-- **R.194 — monotone in the maintenance tax.**

More forgotten demand elements (larger `N_maint`) inflate the decay cost. -/
theorem R_194_monotone_maint
    (Phi0 Ztau : ENNReal) (Nmaint Nmaint' : ℕ∞) (h : Nmaint ≤ Nmaint') :
    NDecay Phi0 Ztau Nmaint ≤ NDecay Phi0 Ztau Nmaint' := by
  unfold NDecay
  exact add_le_add h (le_refl _)

/-- **R.194 — monotone in the decay-adjusted impedance.**

A larger effective impedance `Z_τ` (smaller effective intervention set
under decay) raises the solve cost, hence the decay-adjusted total.
Uses `ceilENat_le_ceilENat` from `StateSequence.lean`. -/
theorem R_194_monotone_Ztau
    (Phi0 Ztau Ztau' : ENNReal) (Nmaint : ℕ∞) (h : Ztau ≤ Ztau') :
    NDecay Phi0 Ztau Nmaint ≤ NDecay Phi0 Ztau' Nmaint := by
  unfold NDecay
  refine add_le_add (le_refl _) ?_
  apply ceilENat_le_ceilENat
  exact mul_le_mul' (le_refl Phi0) h

end DecayModifiedOhm

end MIP
