# R3 Agent 4 — Scaling-Law Family Cross-Derivations

**Agent role.** R3-4 in the 10-agent parallel R3 exploration. Group: Scaling-law family
(R.95, R.150, R.150a, R.56, R.98, R.156, R.157, R.197, R.152).

**Deliverables.** 6 new Lean files in `MIP/Discoveries/`, each chaining ≥ 2 existing
R-results from the `Results/` tree. **All files compile, zero `sorry`, zero new `axiom`.**

---

## Files

### 1. `R3_Agent4_SingularityFromScaling.lean` — chain (A): R.95 + R.56

**Theme.** Geometric data growth on R.95's power-law `N(D) = c_N · D^(−γκ)` produces
R.56's geometric-decay singularity-time precondition.

| Thm | Statement |
|---|---|
| `A1_geometric_decay_from_scaling` | `D(t) = D₀·ρ^t ⟹ E_t = (c_N·D₀^(−γκ)) · (ρ^(−γκ))^t` |
| `A2_singularity_time_from_scaling` | **R.95 + R.56 closed-form:** `t ≥ log(E₀/ε) / (γκ · log ρ) ⟹ E_t ≤ ε` |
| `A3_singularity_time_closed_form` | Records the closed-form threshold as a definitional identity |
| `A4_steeper_scaling_faster_singularity` | `γκ₁ < γκ₂ ⟹ t*(γκ₂) < t*(γκ₁)` (strict monotone) |

**R-deps.** R.95 (`R_95_scaling_closed_form`, `R_95_loglog_slope`, `R_95_monotone_decay`),
R.56 (`R_56_threshold`).

---

### 2. `R3_Agent4_DegenerationBoundary.lean` — chain (B): R.150 + R.150a

**Theme.** The Chinchilla compute-optimal locus is the hyperbola `N · D = C`; substituting
R.150a's Heaps reduction `N_param = (c_N · c_K) · D^β` into the hyperbola gives a
single-line boundary in log-log coordinates.

| Thm | Statement |
|---|---|
| `B1_hyperbola_identity` | R.150 hyperbola `N_param · D = C` |
| `B2_compute_data_boundary` | **R.150 + R.150a:** `(c_N · c_K) · D^(β+1) = C` |
| `B3_data_budget_on_boundary` | Inverse: `D^k = C / c` from `c · D^k = C` |
| `B4_loglog_boundary_slope` | `log N_param = log(c_N·c_K) + β · log D` (slope `β`) |
| `B5_chinchilla_one_to_one_limit` | `β = 1` ⟹ `N_param = (c_N·c_K) · D` (Hoffmann 1:1) |

**R-deps.** R.150 (`R_150_chinchilla_allocation`),
R.150a (`R_150a_heaps_reduction`, `R_150a_chinchilla_one_to_one`).

---

### 3. `R3_Agent4_GompertzHalfLife.lean` — chain (D): R.156 + R.157

**Theme.** Substitute R.156's half-life identity `T = τ_{1/2} / log 2` into R.157's
Gompertz steady state `κ* = exp(−2/(α·τ̄))`.

| Thm | Statement |
|---|---|
| `D1_kappa_star_in_half_life` | **R.156 + R.157:** `κ* = exp(−2 · log 2 / (α · τ_{1/2}))` |
| `D2_critical_half_life` | `α · τ_{1/2} = 2 · log 2 ⟹ α · τ̄ = 2` |
| `D3_half_life_from_kappa_star` | Inverse iff: `τ_{1/2}·α = 2·log 2 ↔ α·τ̄ = 2` |
| `D4_critical_kappa_value` | At critical, `exp(−2·log 2/(α·τ_{1/2})) = exp(−1)` |

**R-deps.** R.156 (`half_life_identity`), R.157 (`R_157_steady_state`, `R_157_critical_value`).

---

### 4. `R3_Agent4_DegenerationCollapse.lean` — chain (F): R.150a + R.152

**Theme.** R.150a's uncovered-fraction monotonicity transfers via the demand-min to
R.152's coverage-collapse time.

| Thm | Statement |
|---|---|
| `F1_collapse_time_monotone` | Pointwise monotone `T_ω(D)` ⟹ `T_collapse(D) = min_ω T_ω(D)` monotone |
| `F2_collapse_time_power_law` | `T_ω(D) = c_ω · D^(−α_D)` for all ω ⟹ `inf' T = c_min · D^(−α_D)` |
| `F3_degeneration_implies_collapse_bound` | R.150a's uncovered fraction strictly decays in `D` |
| `F4_collapse_time_realised` | R.152 min characterisation: `∃ ω₀ ∈ R, inf' T = T ω₀` |

**R-deps.** R.150a (`R_150a_uncovered_decay`, `R_150a_loss_degeneration`),
R.152 (`R_152_collapse_time`).

---

### 5. `R3_Agent4_ChinchillaSingularity.lean` — **HEADLINE 3-CHAIN** (E): R.95 + R.150 + R.56

**Theme.** Travel along R.150's Chinchilla hyperbola by compute-doubling
`C ↦ ρ²·C` (i.e. `D ↦ ρ·D`); substitute into R.95's power-law emergence cost; apply R.56
to bound the singularity time.

| Thm | Statement |
|---|---|
| `E1_three_chain_geometric_form` | **R.95 + R.150:** `E_t = (c_N·D₀^(−γκ)) · (ρ^(−γκ))^t` |
| `E2_chinchilla_singularity_bound` | **HEADLINE — R.95+R.150+R.56:** `t ≥ log(E₀/ε)/(γκ·log ρ) ⟹ E_t ≤ ε` |
| `E3_faster_compute_faster_singularity` | `ρ₁ < ρ₂ ⟹ t*(ρ₂) < t*(ρ₁)` (compute axis monotone) |
| `E4_steeper_scaling_faster_singularity` | `γκ₁ < γκ₂ ⟹ t*(γκ₂) < t*(γκ₁)` (scaling axis monotone) |
| `E5_allocation_sanity` | R.150 allocation identity as the algebraic backbone |

**R-deps.** R.95 (`R_95_scaling_closed_form`), R.150 (`R_150_chinchilla_allocation`),
R.56 (`R_56_threshold`).

**Headline interpretation.** Along the Chinchilla compute-optimal locus, the
singularity-arrival time has the closed form

> **t*(ε)  =  log(E₀/ε) / (γκ · log ρ)**

where `γκ` is the R.95 scaling exponent and `ρ` is the per-step compute multiplier
forced by the R.150 hyperbola. The bound is **inversely proportional to the product
`γκ · log ρ`** — both axes amplify each other.

---

### 6. `R3_Agent4_GompertzSingularity.lean` — chain (G): R.56 + R.98

**Theme.** Evaluate R.98's Gompertz closure `κ(t) = exp(log κ₀ · exp(−α·(t − t_c)))`
at R.56's singularity arrival time `t = t*`.

| Thm | Statement |
|---|---|
| `G1_kappa_at_singularity` | `κ(t*) = exp(log κ₀ · exp(−α·(t* − t_c)))` (definitional) |
| `G2_kappa_monotone_in_t` | Time monotonicity of Gompertz closure (under `0 < κ₀ < 1`, `α > 0`) |
| `G3_kappa_saturation_at_infinity` | R.98 saturation `κ(t) → 1` as `t → ∞` |
| `G4_threshold_to_closure` | **R.56 + R.98:** `ε₁ < ε₂ ⟹ κ(t*(ε₂)) < κ(t*(ε₁))` |

**R-deps.** R.56 (`R_56_threshold`), R.98 (`kappa`, `R_98_saturation`).

---

## Compilation status

All 6 files compile clean under
```
cd C:\Users\12729\Desktop\Math\lean\MIP
lake env lean MIP/Discoveries/R3_Agent4_<File>.lean
```
with **zero errors, zero `sorry`, zero new `axiom`**. Warnings are limited to
`unusedVariables` / `unusedSectionVars` (cosmetic; no functional impact).

## R-result citations summary

| File | R-deps |
|---|---|
| `R3_Agent4_SingularityFromScaling` | R.95, R.56 |
| `R3_Agent4_DegenerationBoundary` | R.150, R.150a |
| `R3_Agent4_GompertzHalfLife` | R.156, R.157 |
| `R3_Agent4_DegenerationCollapse` | R.150a, R.152 |
| `R3_Agent4_ChinchillaSingularity` | R.95, R.150, R.56 (3-chain) |
| `R3_Agent4_GompertzSingularity` | R.56, R.98 |

**Total: 6 files, 26 theorems, 8 distinct R-results cited (R.56, R.95, R.98, R.150, R.150a, R.152, R.156, R.157).**

## Notes on chains not formalised

* Chain **(C) R.95 + R.197** — heterogeneous-decay scaling exponent shift. R.95 lives
  on `ℝ` with `Real.rpow`; R.197 lives on a heterogeneous Finset team structure with
  `Finset.sup'` (max-half-life). The composition would need a non-trivial bridge:
  an explicit map from R.197's `teamTau : Ω → ι → ℝ` into a single effective
  exponent on R.95's scaling form. This would require introducing a Finset-indexed
  parametric scaling family rather than a clean algebraic substitution.
  **Status: OBSERVATION** (documented here rather than faked).

  The cross-derivation would read informally as: "the per-element `−γκ` exponent of
  R.95 gets replaced by an `ω`-dependent `−γκ_ω` and the team's effective rate is
  `min_{ω ∈ R} γκ_ω`" — but this requires a definition of `γκ_ω` that does not exist
  in the current R-results and would need to be invented (axiomatically introduced),
  violating the "no new axiom" constraint.
