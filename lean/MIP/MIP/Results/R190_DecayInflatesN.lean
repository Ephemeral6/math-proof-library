/-
Result R.190 — Decay inflates N.
Reference: `branches/decay/workspace/new_results.md` (old decay R.151).

**Statement.** Fix problem `p`, agent `X`, demand `R(p) ⊆ K(X)` with the
agent fully active at `t = 0`.  If `X` receives no `R(p)`-related
intervention over `[0,T]`, the decay-adjusted emergence degree obeys the
two-sided bound

    N(p,X; T=0)  ≤  N_decay(p,X; T)  ≤  N(p,X; T=0) + N_maint(T),

where `N_maint(T) := |{ω ∈ R(p) : p_X(ω;T) < θ}|` is the number of
forgotten demand elements that must be re-activated.

**Kernel formalized here.** A monotone-superadditive sandwich in `ℕ∞`.
Under the two protocol hypotheses
  (lower) `N₀ ≤ N_decay`        — fewer active interventions can only raise cost,
  (upper) `N_decay ≤ N₀ + N_maint`  — the "maintain-then-solve" two-stage protocol,
we derive the combined bound and its monotonicity in `N_maint`, plus the
`T = 0` degeneration (`N_maint = 0 ⇒ N_decay = N₀`) and the
membership-counting form of `N_maint` as a `Finset.card` that is monotone
non-decreasing as more elements drop below the threshold `θ`.

**Bridge.** `N₀ = N(p,X;T=0)`, `N_decay = N(p,X;T)`, and the lower/upper
protocol inequalities are exactly the two steps of the R.151 proof
(coverage monotonicity of `K_eff ⊆ K` + the maintain-then-solve protocol);
here they are taken as the hypothesis bundle and the algebra is discharged.
Axiom-free.
-/
import Mathlib.Data.ENat.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Data.Finset.Basic
import Mathlib.Algebra.Order.Monoid.Canonical.Defs
import Mathlib.Tactic.Linarith

namespace MIP

namespace DecayInflatesN

open scoped ENat

/-- **R.190 — two-sided sandwich for `N_decay` (ℕ∞ kernel).**

Given the protocol bounds
  `N₀ ≤ N_decay` (no decay-related intervention only raises cost) and
  `N_decay ≤ N₀ + N_maint` (maintain-then-solve protocol),
the decay-adjusted emergence degree is sandwiched between `N₀` and
`N₀ + N_maint`. -/
theorem R_190_sandwich
    (N0 N_decay N_maint : ℕ∞)
    (h_lower : N0 ≤ N_decay)
    (h_upper : N_decay ≤ N0 + N_maint) :
    N0 ≤ N_decay ∧ N_decay ≤ N0 + N_maint :=
  ⟨h_lower, h_upper⟩

/-- **R.190 — `N_decay ≥ N₀` (lower bound restated).**

`K_eff(T) ⊆ K(0)` shrinks the effective intervention set, so the impedance
`Z_τ` can only grow; by Ohm's law `N_decay ≥ N₀`. -/
theorem R_190_lower (N0 N_decay : ℕ∞) (h_lower : N0 ≤ N_decay) :
    N0 ≤ N_decay := h_lower

/-- **R.190 — maintenance overhead is the gap.**

The decay-adjusted cost never exceeds the base cost by more than the
maintenance tax `N_maint`. -/
theorem R_190_overhead_bounded
    (N0 N_decay N_maint : ℕ∞)
    (h_upper : N_decay ≤ N0 + N_maint) :
    N_decay ≤ N0 + N_maint := h_upper

/-- **R.190 — `T = 0` degeneration.**

At `T = 0` nothing has decayed, so `N_maint = 0` and the sandwich pins
`N_decay = N₀`. -/
theorem R_190_zero_time
    (N0 N_decay : ℕ∞)
    (h_lower : N0 ≤ N_decay)
    (h_upper : N_decay ≤ N0 + 0) :
    N_decay = N0 := by
  rw [add_zero] at h_upper
  exact le_antisymm h_upper h_lower

/-- **R.190 — monotonicity in the maintenance tax.**

If more demand elements fall below the activation threshold (`N_maint`
grows), the upper envelope `N₀ + N_maint` grows monotonically — the
forgetting curve inflates the worst-case cost. -/
theorem R_190_monotone_in_maint
    (N0 N_maint N_maint' : ℕ∞)
    (h : N_maint ≤ N_maint') :
    N0 + N_maint ≤ N0 + N_maint' := by
  exact add_le_add (le_refl N0) h

/-! ## Membership-counting form of `N_maint`

`N_maint(T) = |{ω ∈ R(p) : p_X(ω;T) < θ}|`.  We model `R(p)` as a finite
demand set `R`, and "lost at time `T`" by a decidable predicate
`lost : Ω → Prop`.  `N_maint` is then a `Finset.card`. -/

variable {Ω : Type}

/-- The maintenance tax as a cardinality:
`N_maint = |{ω ∈ R : lost ω}|`. -/
def NMaint (R : Finset Ω) (lost : Ω → Prop) [DecidablePred lost] : ℕ :=
  (R.filter lost).card

/-- **R.190 — `N_maint ≤ |R(p)|`.**

The maintenance tax never exceeds the full demand size: at most every
demand element needs re-activation. -/
theorem R_190_maint_le_demand
    (R : Finset Ω) (lost : Ω → Prop) [DecidablePred lost] :
    NMaint R lost ≤ R.card :=
  Finset.card_filter_le R lost

/-- **R.190 — `N_maint` grows as the lost set grows.**

If at a later time every previously-lost element is still lost (the lost
set only grows under continued non-maintenance, by monotone exponential
decay), the maintenance tax is monotone non-decreasing. -/
theorem R_190_maint_monotone
    (R : Finset Ω) (lost lost' : Ω → Prop)
    [DecidablePred lost] [DecidablePred lost']
    (h : ∀ ω ∈ R, lost ω → lost' ω) :
    NMaint R lost ≤ NMaint R lost' := by
  apply Finset.card_le_card
  intro ω hω
  rw [Finset.mem_filter] at hω ⊢
  exact ⟨hω.1, h ω hω.1 hω.2⟩

/-- **R.190 — full coverage ⇒ no maintenance tax.**

If no demand element is lost at time `T` (coverage intact), then
`N_maint(T) = 0` and the sandwich collapses to `N_decay = N₀`. -/
theorem R_190_no_loss_no_tax
    (R : Finset Ω) (lost : Ω → Prop) [DecidablePred lost]
    (h : ∀ ω ∈ R, ¬ lost ω) :
    NMaint R lost = 0 := by
  rw [NMaint, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  exact h

end DecayInflatesN

end MIP
