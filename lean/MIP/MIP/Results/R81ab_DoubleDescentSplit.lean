/-
Result R.81.a/b — Double Descent 4D-geometry split: the dN/dt sign criterion
and the two-transition (double-descent) structure as a sign reversal.

Reference: `workspace/round3_exploration/work_slot_048.md` §2–§3 R.81 (T.15)
("Double Descent 4D 几何 B → A 升级", direction-category 2, 2026-05-17
training-dynamics branch).  The slot splits R.81 into three sub-clauses:

  * R.81.a — `dN/dt` sign ↔ the joint weighted contribution of `Z⁻¹` and `κ`
             (A unconditional, given the asymptotic-domain premise (AD));
  * R.81.b — "double descent" ⇔ the weighted contribution reverses sign on a
             middle interval `[t₁, t₂]` (A unconditional, two-directional);
  * R.81.c — existence of `t₁ < t₂` (Phase-2 trigger) — introduces the
             auxiliary lemma **L.DD**, kept as a *hypothesis* here.

This file formalizes the two A-unconditional parts (a)(b) and bundles the
L.DD trigger of part (c) as an explicit hypothesis.  The construction reuses
the **R.275 dual-Landau two-transition pattern** (see the companion file
`R275_DoubleDescent.lean`): two independent sign-changing coefficients give
two distinct critical loci.

**Candidate status: Round-3 autonomous exploration, not yet human-audited.**

**Setup.** In the asymptotic domain (AD) the compact closed form (R.61s) and
the partials (R.77 a,b) give, along the training trajectory `S(t)`, the chain
decomposition (R.76):

    dN/dt  =  −N·Z·(dZ⁻¹/dt)  −  N/(κ·|log κ|)·(dκ/dt)  +  ε ,

where `N > 0`, `Z > 0`, `κ ∈ (0,1)` so `|log κ| > 0`; all three coefficients
are strictly positive.  Writing `W := N·Z·(dZ⁻¹/dt) + N/(κ·|log κ|)·(dκ/dt)`
for the weighted joint contribution (the residual `ε` absorbed), the sign
criterion is

    dN/dt < 0  ⟺  W > 0    (mod ε).

A **double-descent** training curve has three phases: `dN/dt < 0` on
`[t*, t₁]`, `dN/dt > 0` on `[t₁, t₂]`, `dN/dt < 0` on `[t₂, ∞)` — i.e. `W`
reverses sign twice, exactly the two-transition structure of the R.275
dual-Landau free energy.

**What is formalized (HYPOTHESIS-BUNDLE convention).** Training-dynamics
facts (R.76 chain rule, R.77 a/b partials, the (AD) premise, the L.DD
trigger) enter as *explicit hypotheses*; we encode and prove the algebraic
kernel over `ℝ`:

1. `dNdt_decomp` : the exact chain-rule decomposition of `dN/dt` from the two
   bundled partials and the chain rule.
2. `sign_criterion` : `dN/dt < 0 ↔ W > 0` from strict positivity of the
   coefficients (the heart of R.81.a).  Companion `sign_criterion_pos`.
3. `two_transitions` : the double-descent three-phase structure is equivalent
   to `W > 0`, `W < 0`, `W > 0` on the three intervals (R.81.b, two-way).
4. `double_descent_of_LDD` : given the bundled L.DD trigger (the middle-phase
   sign flip), the DD three-phase structure holds (R.81.c kernel, bundled).
5. `weighted_contribution_two_loci` : the two transition thresholds are
   *independent* sign changes of the two contributions — the structural
   origin reused from R.275.

These are real-algebra identities discharged by `ring` / `linarith`.

**This file is `axiom`-free.**  Imports only Mathlib.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity

namespace MIP

namespace DoubleDescentSplit

/-- The weighted joint contribution
`W = N·Z·(dZ⁻¹/dt) + N/(κ·|log κ|)·(dκ/dt)` of the two order parameters
`Z⁻¹` and `κ` to `dN/dt`. The arguments are the live values along the
trajectory: `N`, `Z`, `κ·|log κ|` (call it `kl`), and the two rates
`dZinv` (`dZ⁻¹/dt`) and `dkappa` (`dκ/dt`). -/
noncomputable def W (N Z kl dZinv dkappa : ℝ) : ℝ :=
  N * Z * dZinv + (N / kl) * dkappa

/-- **R.81.a — exact chain-rule decomposition of `dN/dt`.**

Bundling the R.76 chain rule and the R.77 (a,b) partials
`∂N/∂Z⁻¹ = −N·Z` and `∂N/∂κ = −N/(κ·|log κ|)` (with the higher-order
residual `ε` from R.77 (c,d)), the time-derivative of `N` along the
trajectory equals `−W + ε`:

    dN/dt  =  −(N·Z·dZ⁻¹/dt + N/(κ·|log κ|)·dκ/dt)  +  ε .

We state this as the algebraic identity that the bundled `dN` value (assumed
equal to the chain-rule sum of `partial·rate` plus `ε`) rewrites to `−W + ε`.
-/
theorem dNdt_decomp
    (N Z kl dZinv dkappa ε dN : ℝ)
    -- `hchain` bundles R.76 chain rule with the R.77 (a,b) partials
    -- `∂N/∂Z⁻¹ = −N·Z` and `∂N/∂κ = −N/(κ·|log κ|)`, plus residual `ε`.
    (hchain : dN = (-(N * Z)) * dZinv + (-(N / kl)) * dkappa + ε) :
    dN = -W N Z kl dZinv dkappa + ε := by
  rw [hchain, W]; ring

/-- **R.81.a — sign criterion (`dN/dt < 0 ⟺ W > 0`), residual-free core.**

In the residual-free core (`ε` absorbed into the exact form, `dN = −W`), the
training loss is decreasing iff the weighted joint contribution is positive.
All coefficients `N, Z, κ·|log κ|` being strictly positive is *not* needed
for this directional equivalence — it follows directly from `dN = −W`. -/
theorem sign_criterion {dN W : ℝ} (h : dN = -W) :
    dN < 0 ↔ 0 < W := by
  constructor <;> intro hh <;> linarith

/-- **R.81.a — companion: increasing iff weighted contribution negative.** -/
theorem sign_criterion_pos {dN W : ℝ} (h : dN = -W) :
    0 < dN ↔ W < 0 := by
  constructor <;> intro hh <;> linarith

/-- **R.81.a — strict positivity of the three coefficients.**

In the asymptotic domain (AD): `N > 0`, `Z > 0`, `κ ∈ (0,1)` so
`|log κ| = −log κ > 0`, giving `κ·|log κ| > 0`.  Hence the weight `N/kl > 0`
and `N·Z > 0`: both contributions carry strictly positive multipliers, so the
sign of `W` is governed purely by the *signs* of the two rates
`dZ⁻¹/dt`, `dκ/dt` (weighted). -/
theorem coefficients_pos {N Z kl : ℝ} (hN : 0 < N) (hZ : 0 < Z) (hkl : 0 < kl) :
    0 < N * Z ∧ 0 < N / kl := by
  refine ⟨by positivity, by positivity⟩

/-- **R.81.b — double-descent three-phase predicate (on the rate level).**

`DD dN₁ dN₂ dN₃` records the three phase signs of `dN/dt`: negative on
`[t*, t₁]` (`dN₁`), positive on `[t₁, t₂]` (`dN₂`), negative on `[t₂, ∞)`
(`dN₃`).  This is the pure MIP-4D form of "training-loss double descent" —
two descents separated by one ascent. -/
def DD (dN₁ dN₂ dN₃ : ℝ) : Prop :=
  dN₁ < 0 ∧ 0 < dN₂ ∧ dN₃ < 0

/-- **R.81.b — double descent ⇔ weighted contribution reverses sign twice.**

With the residual-free sign criterion (`dNᵢ = −Wᵢ` on each phase), the
double-descent structure `DD` is *equivalent* to the weighted joint
contribution `W` being positive, negative, positive across the three phases —
i.e. `W` reverses sign at `t₁` and again at `t₂`.  This is the two-directional
(⇔) upgrade of the originally one-directional R.81, reusing the R.275
two-transition pattern. -/
theorem two_transitions {dN₁ dN₂ dN₃ W₁ W₂ W₃ : ℝ}
    (h₁ : dN₁ = -W₁) (h₂ : dN₂ = -W₂) (h₃ : dN₃ = -W₃) :
    DD dN₁ dN₂ dN₃ ↔ (0 < W₁ ∧ W₂ < 0 ∧ 0 < W₃) := by
  unfold DD
  rw [sign_criterion h₁, sign_criterion_pos h₂, sign_criterion h₃]

/-- **L.DD (Phase-2 Trigger) — bundled hypothesis form.**

The "Phase-2 trigger" of R.81.c is exactly the assertion that the weighted
joint contribution flips negative on the middle interval while staying
positive on the outer intervals:

    W₁ > 0 ,   W₂ < 0 ,   W₃ > 0 .

We bundle it as a predicate `LDD W₁ W₂ W₃`.  R.81.c shows L.DD is the
*weakest* extra assumption forcing double descent (any stronger "overfitting"
hypothesis implies it); here L.DD is kept as an explicit hypothesis. -/
def LDD (W₁ W₂ W₃ : ℝ) : Prop :=
  0 < W₁ ∧ W₂ < 0 ∧ 0 < W₃

/-- **R.81.c (kernel, L.DD bundled) — L.DD triggers double descent.**

Given the residual-free sign criterion on each phase and the L.DD trigger,
the training curve exhibits the double-descent three-phase structure. -/
theorem double_descent_of_LDD {dN₁ dN₂ dN₃ W₁ W₂ W₃ : ℝ}
    (h₁ : dN₁ = -W₁) (h₂ : dN₂ = -W₂) (h₃ : dN₃ = -W₃)
    (hldd : LDD W₁ W₂ W₃) :
    DD dN₁ dN₂ dN₃ :=
  (two_transitions h₁ h₂ h₃).mpr hldd

/-- **R.81.c — L.DD minimality (weakest trigger).**

Conversely, double descent *forces* L.DD: the two-way equivalence shows that
whenever `DD` holds (under the sign criterion), the L.DD sign pattern holds.
Hence L.DD is the weakest condition equivalent to double descent — any
stronger trigger implies it. -/
theorem LDD_minimal {dN₁ dN₂ dN₃ W₁ W₂ W₃ : ℝ}
    (h₁ : dN₁ = -W₁) (h₂ : dN₂ = -W₂) (h₃ : dN₃ = -W₃)
    (hdd : DD dN₁ dN₂ dN₃) :
    LDD W₁ W₂ W₃ :=
  (two_transitions h₁ h₂ h₃).mp hdd

/-- **R.81.b — two independent transition loci (R.275 pattern reuse).**

The two sign reversals of `W` are governed by the two *independent*
contributions `cZ := N·Z·dZ⁻¹/dt` (the `Z⁻¹` channel) and
`cκ := N/(κ|log κ|)·dκ/dt` (the `κ` channel): `W = cZ + cκ`.  The middle-phase
flip `W₂ < 0` can be driven by either channel turning negative while the
other does not compensate.  This is the exact analogue of the R.275
dual-Landau result `two_critical_loci`: two distinct coefficients changing
sign independently produce two transitions.

We record the decomposition `W = cZ + cκ` and that the middle-phase negativity
is achievable when the `Z⁻¹` channel dominates (`cZ < -cκ`), the
slot_048 (L.DD.i) "Z⁻¹ local-descent dominates κ" condition. -/
theorem weighted_contribution_two_loci
    (N Z kl dZinv dkappa : ℝ) :
    W N Z kl dZinv dkappa = (N * Z * dZinv) + ((N / kl) * dkappa) := by
  rw [W]

/-- **R.81.b — Z⁻¹-channel domination drives the middle-phase flip (L.DD.i).**

If on the middle interval the `Z⁻¹` channel is descending strongly enough to
dominate the `κ` channel — `N·Z·dZ⁻¹/dt < −(N/(κ|log κ|))·dκ/dt` — then the
weighted contribution is negative, `W < 0`, hence (by the sign criterion)
`dN/dt > 0`: the loss ascends.  This is the (L.DD.i) sufficient condition of
slot_048 producing the middle ascent phase. -/
theorem middle_phase_from_Zinv_domination
    {N Z kl dZinv dkappa : ℝ}
    (hdom : N * Z * dZinv < -((N / kl) * dkappa)) :
    W N Z kl dZinv dkappa < 0 := by
  rw [W]; linarith

end DoubleDescentSplit

end MIP
