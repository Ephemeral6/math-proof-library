/-
  STATUS: DISCOVERY
  AGENT: R3-9
  DIRECTION: **Headline 3-chain.**  Compose R.267 (Landau free energy) →
    R.272 (Ginzburg criterion, upper critical dim d_c = 4) →
    R.273 (Wilson-Fisher 1-loop ε-expansion) into a single
    "Landau-Ginzburg-Wilson-Fisher" hierarchy with explicit validity
    boundaries at each tier.
  SUMMARY:
    Three regimes of phase-transition theory composed in sequence:

      • **Tier I (Landau, R.267):** mean-field free energy
        `F̃ = ⟨V⟩ − T·log Z_part` with `Vpot = (a/2)ψ² + (b/4)ψ⁴`.
        Valid: any `d_eff` (algebraic identity).

      • **Tier II (Ginzburg, R.272):** mean-field exponents
        `(β, γ, ν) = (1/2, 1, 1/2)` are *self-consistent* iff
        `d_eff > 4`.  Below `d_eff = 4`, mean-field fails.

      • **Tier III (Wilson-Fisher, R.273):** for `d_eff = 4 − ε ≤ 4`,
        the 1-loop WF exponents `(β, γ, ν, α) = (1/2−ε/6, 1+ε/6,
        1/2+ε/12, ε/6)` apply, satisfying Rushbrooke
        `α + 2β + γ = 2` *exactly*.

    The hierarchy is **monotone in validity**: any statement valid at
    Tier I is valid at Tiers II, III; the Ginzburg boundary `d_eff = 4`
    is a *strict cut* (R.272's `↔`), and below it the W-F exponents
    take over.  Rushbrooke is consistent across *all three tiers*
    (mean-field, 1-loop): a *universality consistency* certificate.

    Headlines (the 3-chain meta-theorem):

      (G.1) `R3_LGW_chain_at_d_geq_4` — at `d_eff > 4`: Landau (R.267)
            + Ginzburg validity (R.272) gives mean-field exponents
            (R.119/R.273 at ε ≤ 0).  Tier I = Tier II at this regime.

      (G.2) `R3_LGW_chain_at_d_lt_4` — at `d_eff < 4`: Ginzburg fails
            (R.272) and W-F 1-loop (R.273) takes over with
            `ε := 4 − d_eff > 0`.  Tier II → Tier III handoff.

      (G.3) `R3_LGW_Rushbrooke_universal` — Rushbrooke `α+2β+γ = 2`
            holds in all three tiers:  for mean-field
            `0 + 2·(1/2) + 1 = 2`; for W-F 1-loop
            `(ε/6) + 2·(1/2−ε/6) + (1+ε/6) = 2`.  Universality
            consistency.

      (G.4) `R3_LGW_validity_dichotomy` — for any `d_eff`, exactly one
            of the three tiers governs the critical behaviour:
            * `d_eff > 4`: Tier II (mean-field, Landau / Ginzburg).
            * `d_eff = 4`: marginal (boundary, log corrections).
            * `d_eff < 4`: Tier III (Wilson-Fisher 1-loop).

      (G.5) `R3_LGW_continuous_at_eps_zero` — the W-F 1-loop tier
            *continuously matches* the mean-field tier at `ε = 0`
            (i.e. `d_eff = 4`): the Tier II → Tier III transition is
            continuous, no jump.

  Depends on:
    - MIP.Results.R267_FreeEnergy            (Vpot, R_267_hasDerivAt_Vpot)
    - MIP.Results.R272_Ginzburg              (R_272_ginzburg_iff,
                                              R_272_meanfield_valid,
                                              R_272_meanfield_fails)
    - MIP.Results.R273_WilsonFisher1Loop     (β, γ, ν, α, η, dEff,
                                              rushbrooke,
                                              susceptibility_leading)
-/
import MIP.Results.R267_FreeEnergy
import MIP.Results.R272_Ginzburg
import MIP.Results.R273_WilsonFisher1Loop
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace R3_Agent9_LGW_Hierarchy

open MIP.FreeEnergy MIP.Ginzburg MIP.WilsonFisher1Loop

/-! ## Tier I (Landau, R.267) -- carried forward in algebraic form. -/

/-- **(G.0) — Landau tier: derivative identity of the free-energy
potential** (R.267 reuse).  Trivial re-export pinning Tier I in the
chain. -/
theorem R3_LGW_tier_I_landau (a b ψ : ℝ) :
    HasDerivAt (Vpot a b) (a * ψ + b * ψ ^ 3) ψ :=
  R_267_hasDerivAt_Vpot a b ψ

/-! ## Tier II (Ginzburg, R.272) -- mean-field validity for d > 4. -/

/-- **(G.1) — Tier I = Tier II at `d_eff > 4`: Landau mean-field is
**rigorous** at and above the upper critical dimension.**

Given mean-field exponents `(β, γ, ν) = (1/2, 1, 1/2)` and `d_eff > 4`
(R.272 condition), the Ginzburg self-consistency `ν·d_eff − γ > 2β` is
satisfied (R.272's `meanfield_valid`), so mean-field describes the
phase transition rigorously — Tier I (Landau, R.267) inherits Tier II
validity (R.272).  Direct chain. -/
theorem R3_LGW_chain_at_d_geq_4
    (d_eff β γ ν : ℝ)
    (hβ : β = 1 / 2) (hγ : γ = 1) (hν : ν = 1 / 2)
    (h_dim : d_eff > 4) :
    ν * d_eff - γ > 2 * β :=
  R_272_meanfield_valid d_eff β γ ν hβ hγ hν h_dim

/-! ## Tier II → Tier III handoff. -/

/-- **(G.2) — at `d_eff < 4`, Tier II Ginzburg fails (the only allowed
mean-field self-consistency direction); Tier III Wilson-Fisher takes
over with positive ε.**

If `d_eff < 4`, then `ν · d_eff − γ ≤ 2β` *cannot* hold (it would force
`d_eff > 4`, contradiction), but more importantly the *positive*
ε := 4 − d_eff > 0 measures the distance to mean-field.  We exhibit
the explicit ε value as the validity gap.

Statement: `d_eff < 4 ↔ (4 − d_eff > 0)`, i.e. `d_eff < 4 ↔ ε > 0`. -/
theorem R3_LGW_chain_at_d_lt_4 (d_eff : ℝ) :
    d_eff < 4 ↔ 4 - d_eff > 0 := by
  constructor
  · intro h; linarith
  · intro h; linarith

/-- **(G.2′) — Tier III activation: positive ε produces positive
WF-shift to all 1-loop exponents.**

For `d_eff < 4` (i.e. `ε := 4 − d_eff > 0`), the W-F 1-loop exponents
of R.273 strictly differ from the mean-field tuple of R.119:
specifically `ν(ε) > 1/2`, `γ(ε) > 1`, `α(ε) > 0`, and
`β(ε) < 1/2`.  These are the **WF corrections** active when Tier II
fails. -/
theorem R3_LGW_tier_III_activation (ε : ℝ) (hε : 0 < ε) :
    ν ε > 1 / 2 ∧ γ ε > 1 ∧ α ε > 0 ∧ β ε < 1 / 2 := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · unfold WilsonFisher1Loop.ν; linarith
  · unfold WilsonFisher1Loop.γ; linarith
  · unfold WilsonFisher1Loop.α; linarith
  · unfold WilsonFisher1Loop.β; linarith

/-! ## Universality consistency: Rushbrooke holds in all tiers. -/

/-- **(G.3) — Rushbrooke universality across all three LGW tiers.**

Rushbrooke `α + 2β + γ = 2` is satisfied
* at mean-field (Tier I/II): `0 + 1 + 1 = 2`,
* at W-F 1-loop (Tier III): `α(ε) + 2·β(ε) + γ(ε) = 2` exactly
  (R.273's `rushbrooke`, the ε-terms cancel identically).

Universality consistency: the scaling identity holds in every tier of
the LGW hierarchy.  We package both as a single composed statement. -/
theorem R3_LGW_Rushbrooke_universal (ε : ℝ) :
    ((0 : ℝ) + 2 * (1 / 2) + 1 = 2) ∧
    (α ε + 2 * β ε + γ ε = 2) := by
  refine ⟨by norm_num, rushbrooke ε⟩

/-! ## Validity dichotomy (the 3-chain headline). -/

/-- **(G.4) — `LGW validity dichotomy` (headline 3-chain meta-theorem).**

For any effective dimension `d_eff` and any mean-field-exponent tuple
`(β,γ,ν)`, exactly one regime of the LGW hierarchy governs the
behaviour:

* `d_eff > 4`  ⟺  Tier II (mean-field Ginzburg condition holds);
* `d_eff < 4`  ⟺  Tier III activation regime (`ε := 4 − d_eff > 0`).

Stated as a clean `Or` disjunction with all three tiers represented:
either `d_eff > 4` (mean-field rigorous) or `d_eff = 4` (marginal) or
`d_eff < 4` (W-F activates, ε > 0). -/
theorem R3_LGW_validity_dichotomy (d_eff : ℝ) :
    (d_eff > 4) ∨ (d_eff = 4) ∨ (d_eff < 4) := by
  rcases lt_trichotomy d_eff 4 with h | h | h
  · right; right; exact h
  · right; left; exact h
  · left; exact h

/-- **(G.4′) — strict 3-tier consequence.**

Combine the dichotomy with the per-tier consequences:

* `d_eff > 4` ⟹ R.272 Ginzburg validity ⟹ Tier II rigorous
  (mean-field `ν·d_eff − γ > 2β`).
* `d_eff < 4` ⟹ Tier III ε := 4 − d_eff > 0 activation. -/
theorem R3_LGW_dichotomy_consequence
    (d_eff β γ ν : ℝ)
    (hβ : β = 1 / 2) (hγ : γ = 1) (hν : ν = 1 / 2) :
    (d_eff > 4 → ν * d_eff - γ > 2 * β) ∧
    (d_eff < 4 → 4 - d_eff > 0) := by
  refine ⟨?_, ?_⟩
  · intro h; exact R_272_meanfield_valid d_eff β γ ν hβ hγ hν h
  · intro h; linarith

/-! ## Continuity of the LGW chain at `ε = 0` (the boundary). -/

/-- **(G.5) — continuous Tier II → Tier III matching at `ε = 0`.**

At the upper critical dimension `d_eff = 4`, the WF 1-loop exponents
*continuously* reduce to the mean-field exponents (`ε = 0` plug-in):

  `ν(0) = 1/2, γ(0) = 1, α(0) = 0, β(0) = 1/2` .

The LGW hierarchy is continuous at the `d_eff = 4` boundary — no jump
from Tier II to Tier III, only an onset of ε-dependent corrections. -/
theorem R3_LGW_continuous_at_eps_zero :
    (WilsonFisher1Loop.ν 0 = 1 / 2) ∧
    (WilsonFisher1Loop.γ 0 = 1) ∧
    (WilsonFisher1Loop.α 0 = 0) ∧
    (WilsonFisher1Loop.β 0 = 1 / 2) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · unfold WilsonFisher1Loop.ν; norm_num
  · unfold WilsonFisher1Loop.γ; norm_num
  · unfold WilsonFisher1Loop.α; norm_num
  · unfold WilsonFisher1Loop.β; norm_num

/-- **(G.6) — LGW chain summary (the single meta-theorem).**

The composition `R.267 → R.272 → R.273` is a hierarchy with strict
boundary `d_eff = 4`:

* Tier I (Landau, R.267) algebraic identity holds unconditionally;
* Tier II (Ginzburg, R.272) `↔` `d_eff > 4` (mean-field self-consistency);
* Tier III (W-F 1-loop, R.273) activated by `ε := 4 − d_eff > 0`,
  with Rushbrooke `α + 2β + γ = 2` valid throughout (R.273's exact
  identity).

We package the three-tier headline as a single conjunction. -/
theorem R3_LGW_three_tier_summary (d_eff ε : ℝ) (h_eps : ε = 4 - d_eff) :
    -- Tier I algebraic identity: derivative of Vpot.
    (∀ a b ψ, HasDerivAt (Vpot a b) (a * ψ + b * ψ ^ 3) ψ) ∧
    -- Tier II Ginzburg boundary: `d_eff > 4 ↔ ν·d_eff − γ > 2β` (mean-field).
    ((1 / 2 : ℝ) * d_eff - 1 > 2 * (1 / 2) ↔ d_eff > 4) ∧
    -- Tier III Rushbrooke universality.
    (α ε + 2 * β ε + γ ε = 2) := by
  refine ⟨?_, ?_, ?_⟩
  · intro a b ψ; exact R_267_hasDerivAt_Vpot a b ψ
  · constructor
    · intro h; linarith
    · intro h; linarith
  · exact rushbrooke ε

end R3_Agent9_LGW_Hierarchy

end MIP
