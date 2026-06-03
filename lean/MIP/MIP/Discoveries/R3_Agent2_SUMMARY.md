# R3 Agent 2 — Conservation-law family compositions

**Group:** Conservation-law family.
**Agent:** R3 Agent 2.
**Status:** All five files compile clean; zero `sorry`, zero new `axiom`.

## Deliverables (5 files)

Each file chains ≥ 2 existing R-results and lives under
`MIP/Discoveries/R3_Agent2_*.lean`.

### 1. `R3_Agent2_Equipartition.lean` — direction (A)

**Depends on:** `T.18.10`, `R-SUB.1`, `R-SUB.7`.

- `weighted_constant_collapse` — algebraic kernel:
  `∑ π_S · c = c` whenever `∑ π_S = 1` (T.18.10).
- `equipartition_HK_eq` — **headline single-line equipartition
  identity**: `H_K = H(π) + c` when every `H_S = c`.
- `uniform_partition_entropy_kernel` — algebraic kernel:
  uniform `π_S = 1/m` ⟹ partition entropy contribution `= log m`.
- `equipartition_uniform_HK_eq` — uniform π + constant `H_S = log k`
  collapses `H_K` to `log m + log k`.
- `uniform_mass_conservation` — sanity check: uniform `π_S = 1/m`
  satisfies T.18.10's `∑ π_S = 1`.

### 2. `R3_Agent2_TrainCostFreeEnergy.lean` — direction (C)

**Depends on:** `R-SUB.14` (Ctrain ≥ KL via DPI), `R-SUB.11`
(reciprocal free-energy bound `r · log(K/π)`).

- `train_cost_ge_freeEnergy_gap` — **headline KL-energy bound**:
  `C_train ≥ free-energy gap` when KL ≥ that gap.
- `train_cost_ge_RSUB11_bound` — closed form using
  `ReciprocalFreeEnergy.bound r Kcard π`.
- `train_cost_ge_RSUB11_bound_nonneg` — adds R-SUB.11
  informativeness: bound is nonneg in the MIP regime.
- `train_cost_nonneg_chain` — Gibbs + DPI: `C_train ≥ 0`.
- `train_cost_gap_lower_bound` — quantitative: gap in `C_train`
  between two phases ≥ `r · log(π_b / πₐ)` (R-SUB.11 reciprocal gap
  transferred through DPI).

### 3. `R3_Agent2_NoetherR121.lean` — direction (D)

**Depends on:** `R.107` (Noether kernels), `R.121` (energy/Galilean
conservation).

- `R121_is_Noether_current_of_R107` — **R.121 N1 is the
  t-translation Noether current of R.107**.
- `R121_momentum_is_Noether_current_of_R107` — R.121 N2 is R.107
  momentum kernel.
- `R121_galilean_charge_zero_deriv_free` — R.121 N3 from R.107
  free-system kernel.
- `R107_R121_free_Noether_chain` — combined free-system Noether
  chain.
- `R121_energy_value_eq_R107_Legendre` — R.121's `Energy` value form
  equals R.107's Legendre transform.
- `D_summary_energy_chain` — single-line summary corollary.

### 4. `R3_Agent2_WassersteinKL.lean` — direction (G)

**Depends on:** `R-SUB.14`, `R.148.a` (Wasserstein restatement of
R.132).

- `wasserstein_KL_joint_bound` — **joint conjunction**:
  `C_train ≥ KL ∧ N + N* = 2·N_bi + W_1`.
- `train_cost_wasserstein_floor` — conditional Wasserstein-floor on
  `C_train`.
- `train_cost_role_asymmetry_floor` — `C_train ≥ (N + N* − 2·N_bi)
  − slack` (transferring role-asymmetry budget).
- `train_cost_typeS_compat` — Type-S degenerate case (`W_1 = 0`
  ⟹ symmetric collaboration; `C_train ≥ KL` still holds).

**Honest dead-end note in file:** a clean direct chain `C_train ≥
W_1` is **not** derivable from R-SUB.14 + R.148.a alone — the
generic Pinsker direction is `W_1 ≤ KL`, not the other way. We
state the conditional version with a slack variable instead.

### 5. `R3_Agent2_EntropyKLCoupling.lean` — **HEADLINE 3-CHAIN** (F)

**Depends on (three R-results):** `T.18.10` + `R-SUB.7` chain rule
+ `R-SUB.13` KL chain rule.

- `log_ratio_atomic` — shared algebraic atom of R-SUB.7 and R-SUB.13.
- `atom_3chain` — **atomic 3-chain identity**: per-ω log-ratio
  splits as log-cardinality + within-S log-ratio.
- `sum_3chain_per_subdomain` — sum form on one subdomain.
- `entropy_KL_partitioned_identity` — **HEADLINE 3-chain identity**
  at the partition level.
- `entropy_KL_with_mass_conservation` — combined statement carrying
  T.18.10's `∑ π_S = 1` explicitly.
- `mass_conservation_from_NNReal` — sanity: T.18.10 hypothesis is
  automatically satisfied for genuine NNReal activation
  distributions.

### 6. `R3_Agent2_Mu0MassConservation.lean` — bonus direction (E)

**Depends on:** `T.18.10`, `R-SUB.1`, `R-SUB.5`.

- `mu0_bounded_by_partition_extremes` — algebraic kernel.
- `mu0_decomp_from_T1810` — **mass-conserving μ₀-decomposition**:
  `min_S μ_S ≤ μ_total ≤ max_S μ_S`, with `∑ π_S = 1`
  *automatically* from T.18.10.
- `mu0_convex_combination_bound` — μ₀ ∈ [0,1] when each μ_S ∈ [0,1].
- `product_mass_conservation` — **product-of-conservations**
  identity: independent partitions yield a joint distribution.

## Compositional structure (which R-result each file chains)

| File | T.18.10 | R-SUB.1 | R-SUB.5 | R-SUB.7 | R-SUB.11 | R-SUB.13 | R-SUB.14 | R.107 | R.121 | R.148.a |
|---|---|---|---|---|---|---|---|---|---|---|
| Equipartition | ✓ | ✓ | | ✓ | | | | | | |
| TrainCostFreeEnergy | | | | | ✓ | | ✓ | | | |
| NoetherR121 | | | | | | | | ✓ | ✓ | |
| WassersteinKL | | | | | | | ✓ | | | ✓ |
| **EntropyKLCoupling (HEADLINE)** | ✓ | ✓ | | ✓ | | ✓ | | | | |
| Mu0MassConservation | ✓ | ✓ | ✓ | | | | | | | |

Every file chains ≥ 2 R-results. The headline 3-chain
`EntropyKLCoupling` cites **T.18.10 + R-SUB.7 + R-SUB.13**.

## Reusable kernels exposed

- **Mass-conservation collapse** (`weighted_constant_collapse`,
  `mu0_bounded_by_partition_extremes`): the algebraic fact that
  `∑ π_S = 1` lets us collapse `∑ π_S · f(S)` to its constant case.
- **Log-ratio atom** (`log_ratio_atomic`, `atom_3chain`): the
  shared algebraic atom of all chain rules (entropy and KL).
- **DPI + R-SUB.11 reciprocal bound chain**: the algebraic core
  of the "training cost in free-energy units" composition.
- **Product-of-conservations**
  (`product_mass_conservation`): two independent conservation
  laws compose multiplicatively on a joint partition.

## Honest negative findings (DEAD END notes inside files)

- **`R3_Agent2_WassersteinKL.lean`** — direct `C_train ≥ W_1`
  is not derivable from R-SUB.14 + R.148.a (Pinsker-direction
  obstruction). We provide only the conditional / slack form.

## Compile verification

All files were compiled individually:
```
lake env lean MIP/Discoveries/R3_Agent2_Equipartition.lean         # clean
lake env lean MIP/Discoveries/R3_Agent2_TrainCostFreeEnergy.lean   # clean
lake env lean MIP/Discoveries/R3_Agent2_NoetherR121.lean           # clean
lake env lean MIP/Discoveries/R3_Agent2_WassersteinKL.lean         # clean
lake env lean MIP/Discoveries/R3_Agent2_EntropyKLCoupling.lean     # clean (HEADLINE 3-chain)
lake env lean MIP/Discoveries/R3_Agent2_Mu0MassConservation.lean   # clean
```

Only the standard `unused variable` linter warnings appear; **zero
`sorry`, zero new `axiom`**.
