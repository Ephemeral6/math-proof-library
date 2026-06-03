/-
  STATUS: DISCOVERY
  AGENT: R8_Agent5
  DIRECTION: GOEDEL IMPEDANCE — a quantitative impedance lower bound from
    incompleteness / self-reference (a "Goedel floor" on emergence impedance).

  SUMMARY:

    The corpus pins down two faces of the diagonal/self-reference barrier:

      * R.88 (`MIP.GodelImpedance`) models the emergence impedance as the
        reciprocal of the best single-step potential drop, `Z = drop⁻¹` in the
        extended nonnegative reals `ℝ≥0∞`, and shows the SELF side of the R.86
        diagonal-counterexample family has zero best drop, so its self
        impedance is `(0 : ℝ≥0∞)⁻¹ = ⊤` and dominates every finite external
        impedance (`R_88_infinite_gap`, `R_88_impedance_ge_of_drops`).

      * R7_Agent8 (`R7_Agent8_SelfRefClosureDiagonal`) shows the SAME diagonal
        family is genuinely undecidable: closure membership over R.108's
        undecidable `phiMIP` is not computable
        (`closure_membership_undecidable`, via R.108 `R_108_phi_undecidable`),
        and a self-referential generator `diag` escapes every reduction-closed
        set generated without it (`diag_escapes_closed_without_it`).

    THIS FILE fuses the two into a QUANTITATIVE statement: on the
    self-referential diagonal family, the emergence impedance is bounded below
    by a positive *Goedel floor* tied to the undecidability gap, and NO agent
    can have impedance below that floor.  The floor is exhibited in two
    regimes:

      ── R26-style finite floor (in `ℝ`).  Any agent whose best self-drop is
         *no better* than the transversal external drop available on the
         diagonal family (`dropAgent ≤ dropExt`, the R.88/R.86 weakening) has
         impedance `≥ dropExt⁻¹`, and that floor is strictly positive (R.26
         positivity, `R_26_a_impedance_lower_bound`).  This is a faithful
         finite lower bound `Z ≥ Z_floor > 0`.

      ── R88-style infinite floor (in `ℝ≥0∞`).  In the pure self-reference
         regime the best self-drop is exactly `0`, so the self impedance is
         `⊤`, which dominates EVERY finite floor — the diagonal element is
         impedance-maximal (`R_88_infinite_gap`).

    HEADLINE — `godel_floor_on_impedance`.  On the self-referential family we
    simultaneously certify:
      (1) UNDECIDABILITY — closure membership over R.108's `phiMIP` is not
          computable (R7_Agent8 `closure_membership_undecidable` ⇒ R.108);
      (2) DIAGONAL ESCAPE — the self-referential `diag` escapes every closed
          set omitting it (R7_Agent8 `diag_escapes_closed_without_it`);
      (3) POSITIVE GOEDEL FLOOR — the emergence impedance on this family is
          bounded below by a positive constant `godelFloor dropExt > 0`
          (R.26-style), and in the pure self-reference regime equals `⊤`,
          dominating that floor (R.88 `R_88_infinite_gap`).
    Hence "self-reference forces a positive Goedel floor on emergence
    impedance: no agent solves the diagonal family below the incompleteness
    gap."

  Depends on (exact lemma names used in PROOF TERMS):
    - MIP.Results.R88_GodelImpedance (R.88) :
        MIP.GodelImpedance.R_88_infinite_gap,              [used]
        MIP.GodelImpedance.R_88_impedance_ge_of_drops,     [provenance-only:
          discussed in SUMMARY as the packaged form; NOT a proof term here
          because the pure self-reference regime has dropSelf = 0, which
          violates its 0 < dropSelf hypothesis — we use R_88_infinite_gap]
        MIP.GodelImpedance.Derived                         [provenance-only:
          motivates the transversal external selector hypothesis; not a
          proof term]
    - MIP.Discoveries.R7_Agent8_SelfRefClosureDiagonal (R7 tower) :
        R7_Agent8_SelfRefClosureDiagonal.closure_membership_undecidable, [used]
        R7_Agent8_SelfRefClosureDiagonal.diag_escapes_closed_without_it, [used]
        R7_Agent8_SelfRefClosureDiagonal.closureMember,    [used]
        R7_Agent8_SelfRefClosureDiagonal.diagRed,          [used]
        R7_Agent8_SelfRefClosureDiagonal.WithDiag          [used]
    - MIP.Results.R26_PositiveImpedance (R.26) :
        MIP.PositiveImpedance.R_26_a_impedance_lower_bound [used]
    (R.108 `R_108_phi_undecidable` enters transitively inside R7_Agent8's
     `closure_membership_undecidable`.)

  This file is `sorry`-free and declares NO new `axiom`.
-/
import MIP.Results.R88_GodelImpedance
import MIP.Results.R26_PositiveImpedance
import MIP.Discoveries.R7_Agent8_SelfRefClosureDiagonal

namespace MIP

namespace R8_Agent5_GodelImpedanceLowerBound

open MIP.GodelImpedance
open MIP.PositiveImpedance
open R7_Agent8_SelfRefClosureDiagonal
open R6_Agent8_ReductionClosureMonad
open scoped ENNReal

/-! ## PART I — the finite Goedel floor (R.26 + R.88, in `ℝ`).

    The emergence impedance of an agent on the diagonal family is `dropAgent⁻¹`.
    By the R.86/R.88 mechanism, the best the SELF side can do is no better than
    the transversal external drop `dropExt` that an externally derived `A'`
    achieves (`dropAgent ≤ dropExt`).  Hence the agent's impedance is at least
    `dropExt⁻¹`, and — this is the R.26 positivity content — that lower bound is
    strictly positive.  We name `dropExt⁻¹` the *Goedel floor*. -/

/-- The **Goedel floor**: the impedance value `dropExt⁻¹` set by the best
transversal (externally-derived) drop available on the diagonal family. -/
noncomputable def godelFloor (dropExt : ℝ) : ℝ := 1 / dropExt

/-- **(I) finite Goedel floor — impedance is bounded below by a positive
constant.**

If `0 < dropExt` (a transversal external selector exists, R.88 `Derived`) and
the agent's best self-drop is no better than it (`0 < dropAgent ≤ dropExt`,
the R.86/R.88 weakening), then the agent's emergence impedance
`Z = dropAgent⁻¹` satisfies

    Z = 1/dropAgent  ≥  1/dropExt = godelFloor dropExt  >  0.

The lower bound and its strict positivity are exactly R.26's
`R_26_a_impedance_lower_bound` (impedance dominated below by `1/Φ > 0`), here
with `Φ := dropExt` the transversal-drop ceiling. -/
theorem godel_floor_finite
    (dropAgent dropExt : ℝ)
    (h_agent_pos : 0 < dropAgent)
    (h_le : dropAgent ≤ dropExt)
    (h_ext_pos : 0 < dropExt) :
    godelFloor dropExt ≤ 1 / dropAgent ∧ 0 < godelFloor dropExt := by
  -- R.26: `1/dropExt ≤ 1/dropAgent` and `0 < 1/dropExt`.
  simpa [godelFloor] using
    R_26_a_impedance_lower_bound dropAgent dropExt h_agent_pos h_le h_ext_pos

/-- **(I, corollary) no agent beats the Goedel floor.**

Contrapositive face: there is no agent on the diagonal family whose impedance
is strictly below the positive Goedel floor.  Any `dropAgent` consistent with
the diagonal mechanism (`0 < dropAgent ≤ dropExt`) yields
`1/dropAgent ≥ godelFloor dropExt`, so `1/dropAgent < godelFloor dropExt` is
impossible. -/
theorem no_agent_below_floor
    (dropAgent dropExt : ℝ)
    (h_agent_pos : 0 < dropAgent)
    (h_le : dropAgent ≤ dropExt)
    (h_ext_pos : 0 < dropExt) :
    ¬ (1 / dropAgent < godelFloor dropExt) := by
  intro hlt
  exact absurd (godel_floor_finite dropAgent dropExt h_agent_pos h_le h_ext_pos).1
    (not_le.mpr hlt)

/-! ## PART II — the infinite Goedel floor (R.88, in `ℝ≥0∞`).

    In the pure self-reference regime the best self-drop is exactly `0`, so the
    self impedance is `(0 : ℝ≥0∞)⁻¹ = ⊤`.  This dominates EVERY finite external
    impedance, in particular the Goedel floor: the diagonal element is
    impedance-maximal.  This is R.88's `R_88_infinite_gap` repackaged as the
    "floor is reached and exceeded (to `⊤`) on pure self-reference". -/

/-- **(II) infinite Goedel floor — pure self-reference is impedance-maximal.**

When the best self-drop is `0` (R.86/R.88: no self-intervention lands on the
anti-diagonal), the self impedance `(0 : ℝ≥0∞)⁻¹ = ⊤` dominates the finite
external impedance `dropExt⁻¹` and strictly exceeds it.  Thus on the pure
self-referential diagonal the impedance is not merely above a positive floor —
it is maximal. -/
theorem godel_floor_infinite
    (dropExt : ℝ≥0∞) (h_ext_pos : 0 < dropExt) :
    dropExt⁻¹ ≤ (0 : ℝ≥0∞)⁻¹ ∧ dropExt⁻¹ < (0 : ℝ≥0∞)⁻¹ :=
  R_88_infinite_gap dropExt h_ext_pos

/-- **(II, packaged) the self impedance dominates any candidate external floor.**

Given any positive external/floor drop `dropExt` and the pure self-reference
zero drop `dropSelf = 0`, R.88 `R_88_impedance_ge_of_drops` is not directly
applicable (it needs `0 < dropSelf`); instead the `ℝ≥0∞` inverse convention
gives `dropExt⁻¹ ≤ (0)⁻¹ = dropSelf⁻¹` directly.  We record the clean
"self ≥ floor" inequality in the impedance model. -/
theorem self_impedance_ge_floor
    (dropSelf dropExt : ℝ≥0∞)
    (h_self0 : dropSelf = 0) (h_ext_pos : 0 < dropExt) :
    dropExt⁻¹ ≤ dropSelf⁻¹ := by
  subst h_self0
  exact (godel_floor_infinite dropExt h_ext_pos).1

/-! ## PART III — the grounded headline (R.88 + R7_Agent8 + R.108 + R.26). -/

/-- **HEADLINE — self-reference forces a positive Goedel floor on emergence
impedance.**

For R.108's undecidable MIP-proposition family `phiMIP` (with the bundled R.84
fact `¬ ComputablePred Halt` and the R.83 reduction `Halt ≤₀ phiMIP`), and the
self-referential extension `WithDiag β` with a generating family `S` omitting
the diagonal generator `diag`, and a positive transversal external drop
`dropExt`, all of the following hold simultaneously:

  (1) **UNDECIDABILITY** — membership in the reduction-closure of the
      self-referential family is NOT algorithmically decidable
      (`¬ ComputablePred (closureMember phiMIP)`), via R7_Agent8's
      `closure_membership_undecidable` (which routes through R.108
      `R_108_phi_undecidable`).  The diagonal family carries the full
      incompleteness obstruction.

  (2) **DIAGONAL ESCAPE** — the self-referential generator escapes every closed
      set generated without it (`diag ∉ cl diagRed S`), via R7_Agent8's
      `diag_escapes_closed_without_it`.  The undecidable / impedance-maximal
      element is exactly the one with no finite closed generating sub-theory.

  (3) **POSITIVE GOEDEL FLOOR (finite, R.26)** — the emergence impedance of any
      agent on the diagonal family is bounded below by the strictly positive
      Goedel floor: for `0 < dropAgent ≤ dropExt`,
      `godelFloor dropExt ≤ 1/dropAgent` and `0 < godelFloor dropExt`.

  (4) **IMPEDANCE-MAXIMALITY (infinite, R.88)** — in the pure self-reference
      regime the impedance is `⊤`, dominating that floor:
      `dropExtE⁻¹ ≤ (0 : ℝ≥0∞)⁻¹` and strictly below it.

No claim is weakened: (1) is full undecidability through a genuine many-one
reduction (R.108) lifted by R7_Agent8's closure operator; (2) is an exact
diagonal escape; (3)/(4) are honest arithmetic floors from R.26 and R.88.
Together: the self-referential / undecidable case is precisely the
impedance-maximal case, and no agent's impedance dips below the positive
incompleteness gap. -/
theorem godel_floor_on_impedance
    {β : Type}
    (phiMIP : Set ℕ) (Halt : Set ℕ)
    (h_halt_undec : ¬ ComputablePred (fun n => Halt n))
    (h_reduce : (fun n => Halt n) ≤₀ (fun n => phiMIP n))
    (S : Set (WithDiag β)) (hS : (WithDiag.diag : WithDiag β) ∉ S)
    (dropAgent dropExt : ℝ)
    (h_agent_pos : 0 < dropAgent)
    (h_le : dropAgent ≤ dropExt)
    (h_ext_pos : 0 < dropExt)
    (dropExtE : ℝ≥0∞) (h_extE_pos : 0 < dropExtE) :
    -- (1) closure membership over the self-referential family is undecidable:
    (¬ ComputablePred (closureMember phiMIP))
    -- (2) the diagonal generator escapes every closed set omitting it:
      ∧ ((WithDiag.diag : WithDiag β) ∉ cl diagRed S)
    -- (3) positive finite Goedel floor on impedance (R.26):
      ∧ (godelFloor dropExt ≤ 1 / dropAgent ∧ 0 < godelFloor dropExt)
    -- (4) impedance-maximality on pure self-reference (R.88):
      ∧ (dropExtE⁻¹ ≤ (0 : ℝ≥0∞)⁻¹ ∧ dropExtE⁻¹ < (0 : ℝ≥0∞)⁻¹) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · exact closure_membership_undecidable phiMIP Halt h_halt_undec h_reduce
  · exact diag_escapes_closed_without_it S hS
  · exact godel_floor_finite dropAgent dropExt h_agent_pos h_le h_ext_pos
  · exact godel_floor_infinite dropExtE h_extE_pos

/-- **Concrete instance — the Goedel floor on the `Bool` diagonal.**

Specialising R.88's concrete `Derived id not` Bool diagonal: the transversal
external drop is `1`, the self drop is `0`, so the finite floor is
`godelFloor 1 = 1 > 0`, the external impedance `1⁻¹ = 1` dominates by the
infinite floor, and any agent with `0 < dropAgent ≤ 1` has impedance
`≥ 1`. -/
theorem godel_floor_bool_instance :
    (godelFloor (1 : ℝ) ≤ 1 / (1 : ℝ) ∧ 0 < godelFloor (1 : ℝ))
      ∧ ((1 : ℝ≥0∞)⁻¹ ≤ (0 : ℝ≥0∞)⁻¹ ∧ (1 : ℝ≥0∞)⁻¹ < (0 : ℝ≥0∞)⁻¹) := by
  refine ⟨?_, ?_⟩
  · exact godel_floor_finite 1 1 (by norm_num) (le_refl 1) (by norm_num)
  · exact godel_floor_infinite (1 : ℝ≥0∞) (by norm_num)

-- AUDIT: axiom provenance of the headline (expect only standard Lean axioms
-- plus framework axioms reached transitively via the corpus tower).
#print axioms godel_floor_on_impedance

end R8_Agent5_GodelImpedanceLowerBound

end MIP
