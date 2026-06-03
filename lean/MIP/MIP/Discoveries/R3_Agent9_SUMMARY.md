# R3 Agent 9 — Thermodynamics family cross-derivations

**Family:** Thermodynamics (R.119, R.122, R.123, R.267-R.281)
**Constraint:** zero `sorry`, zero new `axiom`, every theorem cites ≥ 2 R-results.
**Total:** 6 files, 35 theorems composing across 9 thermodynamic R-results.

## File index

| # | File | Items | R-deps (≥ 2) |
|---|---|---|---|
| 1 | `R3_Agent9_CVJumpFromLandau.lean` | 6 | R.267 + R.269 |
| 2 | `R3_Agent9_FDTCorrelationScaling.lean` | 5 | R.270 + R.271 |
| 3 | `R3_Agent9_WilsonFisher12Loop.lean` | 14 | R.119 + R.273 + R.280 |
| 4 | `R3_Agent9_GinzburgTricritical.lean` | 7 | R.272 + R.276 |
| 5 | `R3_Agent9_JarzynskiHTheorem.lean` | 9 | R.122 + R.123 + R.270 + R.281 |
| 6 | `R3_Agent9_LGW_Hierarchy.lean` | **headline 3-chain** (8) | R.267 + R.272 + R.273 |

## Theorem inventory

### File 1 — CV jump from Landau (R.267 + R.269)

Compose R.267 (Landau free energy `F̃ = ⟨V⟩ − T·log Z_part`) with R.269
(specific-heat jump `ΔC_V = T_c·a₀²/(2b)`):

- `R3_Vpot_eq_Fmin_at_eq` — R.269 Fmin equals R.267 Vpot at the equilibrium
  `ψ_eq² = −a/b`. **(bridges R.267 ↔ R.269)**
- `R3_canonical_F_via_Fmin` — full free-energy form after substitution.
- `R3_partition_piece_constant_slope` — the partition-function piece
  `−T·log Z` is `T`-linear ⇒ contributes 0 to the second derivative.
- `R3_CV_jump_from_Landau` — composed CV jump.
- `R3_CV_jump_pos_compose` — composed positivity.
- `R3_full_F_via_Fmin` — full free energy `F = E − T·log Z_part`.

### File 2 — FDT × correlation length (R.270 + R.271)

Compose R.270 (FDT `Var = T·χ`, `χ = 1/a`) with R.271 (correlation
length `ξ² = 1/a`, `a·ξ² = 1`):

- `R3_chi_eq_xi_sq` — mean-field FDT-OZ identity `χ = ξ²`.
  **(joins R.270 + R.271)**
- `R3_FDT_via_xi` — variance from correlation length: `Var = T·ξ²`.
- `R3_thermometer_through_xi` — `Var/ξ² = T` (variance per correlation
  volume is the temperature).
- `R3_FDT_variance_diverges` — `Tendsto (T · ξ²) (𝓝[>] 0) atTop`:
  critical divergence of FDT variance as `ε → 0⁺`.
- `R3_a_var_eq_T` — algebraic kernel `(a₀·ε) · Var = T`.

### File 3 — Wilson-Fisher 1-loop / 2-loop (R.119 + R.273 + R.280)

Compose mean-field (R.119), 1-loop WF (R.273), and 2-loop WF (R.280):

- 1-loop corrections (R.119 → R.273):
  - `R3_one_loop_nu_correction` — `ν - 1/2 = ε/12` (positive shift).
  - `R3_one_loop_gamma_correction` — `γ - 1 = ε/6`.
  - `R3_one_loop_alpha_correction` — `α - 0 = ε/6`.
  - `R3_one_loop_beta_correction` — `β - 1/2 = -ε/6` (negative).
  - `R3_meanfield_recovery_at_eps_zero` — continuity at `ε = 0`.

- 2-loop corrections (R.273 → R.280):
  - `R3_two_loop_nu_correction_to_one_loop` — `Δν = 7·ε²/162`.
  - `R3_nu_two_loop_ge_one_loop` — sign: 2-loop ν ≥ 1-loop ν.
  - `R3_nu_correction_positive` — strict positivity for `ε ≠ 0`.
  - `R3_alpha_two_loop_correction` — `Δα = −29·ε²/324` (negative).
  - `R3_alpha_two_loop_le_one_loop` — sign: 2-loop α ≤ 1-loop α.
  - `R3_alpha_correction_negative` — strict negativity for `ε ≠ 0`.
  - `R3_gamma_two_loop_correction` — `Δγ = +25·ε²/324`.
  - `R3_gamma_two_loop_ge_one_loop` — sign.

- Combined R.119 → R.280 shift:
  - `R3_combined_two_loop_shift_nu`, `…_gamma`, `…_alpha`.
  - `R3_combined_shift_at_eps_one` — ε = 1 (d = 3) numerical values.

### File 4 — Ginzburg at the tricritical point (R.272 + R.276)

Compose R.272 (Ginzburg criterion, `d_c = 4` from MF exponents) with
R.276 (tricritical Landau, `2c² = 9ab`):

- `R3_tricritical_ginzburg_iff` — tricritical exponents `(β,γ,ν)
  = (1/4, 1, 1/2)` give Ginzburg `↔ d_eff > 3`.
  **(shifts the upper critical dimension from 4 to 3)**
- `R3_tricritical_meanfield_valid` — forward direction.
- `R3_tricritical_meanfield_fails` — failure at `d_eff ≤ 3`.
- `R3_dc_shift_at_tricritical` — `Δd_c = -1`.
- `R3_tricritical_validity_at_d4` — d = 4 case (with margin 1/2).
- `R3_tricritical_existence_witness` — chains R.276's `∃ ψ ≠ 0` with
  Ginzburg condition.
- `R3_dimensional_boundary_pair` — side-by-side `d > 4` vs `d > 3`
  certifications.

### File 5 — Jarzynski + H-theorem + FDT (R.122 + R.123 + R.270 + R.281)

Two compositions:

**(F) Jarzynski + Boltzmann H-theorem (R.281 + R.122):**
- `R3_jarzynski_reversible_id` — equilibrium endpoint.
- `R3_clausius_implies_entropy_inequality` — `⟨Asym⟩ ≥ ΔF̃ ⇒
  T·ΔS_B ≤ E_Asym`.
- `R3_strict_entropy_production` — strict H-theorem from strict Asym.
- `R3_Htheorem_equilibrium_endpoint` — Jarzynski equality at reversible limit.
- `R3_SB_gap_from_Ncomp_ratio` — `S_B(t₂) − S_B(t₁) ≥ 0` from R.122.b.

**(I) Two-temperature FDT violation (R.123 + R.270):**
- `R3_FDT_violation_magnitude` — `Var − T_ent·χ = (T_kin − T_ent)·χ`.
  **(explicit violation magnitude in two-temp regime)**
- `R3_FDT_violation_sign` — sign matches `T_kin − T_ent`.
- `R3_FDT_violation_vanishes_iff` — equality criterion.
- `R3_var_Tent_product` — R.123 product identity composed with R.270 FDT.

### File 6 — Landau-Ginzburg-Wilson-Fisher hierarchy (headline 3-chain)

**(G) Headline 3-chain meta-theorem:** R.267 + R.272 + R.273.

Three tiers of phase-transition theory with explicit validity
boundaries:

- `R3_LGW_tier_I_landau` — Tier I algebraic identity (R.267 derivative).
- `R3_LGW_chain_at_d_geq_4` — Tier I → Tier II at `d_eff > 4`.
- `R3_LGW_chain_at_d_lt_4` — Tier II → Tier III handoff: `d_eff < 4
  ↔ ε := 4 − d_eff > 0`.
- `R3_LGW_tier_III_activation` — positive ε WF-shifts to all exponents.
- `R3_LGW_Rushbrooke_universal` — Rushbrooke `α + 2β + γ = 2` holds in
  all three tiers (universality across the LGW hierarchy).
- `R3_LGW_validity_dichotomy` — exactly one of `d > 4`, `d = 4`, `d < 4`
  governs.
- `R3_LGW_dichotomy_consequence` — `d > 4 ⟹ Ginzburg validity`;
  `d < 4 ⟹ ε > 0 activation`.
- `R3_LGW_continuous_at_eps_zero` — continuous Tier II ↔ Tier III
  matching at `ε = 0` (no jump).
- `R3_LGW_three_tier_summary` — single meta-theorem packaging all three.

## Compilation status

All six files compile clean with `lake env lean ...` (zero errors,
only minor unused-variable warnings on signature hypotheses kept for
documentation).

## Key composition statements (the "headline" theorems)

1. **CV jump from F̃ second derivative:** R.267 + R.269 →
   `ΔC_V = T_c·a₀²/(2b)` from `−T·∂²F̃/∂T²` discontinuity.

2. **χ = ξ² (FDT-OZ identity):** R.270 + R.271 → at mean-field
   (`η = 0`) the FDT response is exactly the squared correlation length.

3. **2-loop ν correction is positive:** R.273 + R.280 →
   `ν₂ − ν₁ = 7·ε²/162 > 0`.

4. **Ginzburg shift at tricritical point:** R.272 + R.276 → upper
   critical dim drops from `d_c = 4` (mean-field) to `d_c^{tri} = 3`
   (tricritical), `Δd_c = −1`.

5. **FDT violation in two-temperature steady state:** R.123 + R.270 →
   `Var − T_ent·χ = (T_kin − T_ent)·χ`, with sign tracking the
   temperature gap.

6. **LGW hierarchy (headline):** R.267 + R.272 + R.273 → three-tier
   structure with strict boundary `d_eff = 4`, continuous matching at
   `ε = 0`, Rushbrooke universality throughout.
