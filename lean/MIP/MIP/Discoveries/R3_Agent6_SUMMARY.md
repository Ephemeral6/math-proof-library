# R3 Agent 6 — Degeneration family discoveries

**Group:** Degeneration family (R.400–R.433).
**Mandate:** ≥ 4 R3 files each citing ≥ 2 R-results, plus one headline multi-result chain.
**Status:** 5 files compile cleanly, all `axiom`-free / `sorry`-free.

## Files delivered

| # | File | Items | R-deps | Compiles |
|---|------|-------|--------|----------|
| 1 | `R3_Agent6_FourPrimitiveCompleteness.lean` | (D) + (G) **HEADLINE** | R.421, R.422, R.423, R.424, R.432, R.433 | ✅ (warnings only) |
| 2 | `R3_Agent6_FristonChain.lean` | (B) Friston degeneration chain | R.408, R.409, R.410 | ✅ |
| 3 | `R3_Agent6_MDL_PACBayes.lean` | (H) MDL + PAC-Bayes joint | R.405, R.406 | ✅ |
| 4 | `R3_Agent6_ICL_RLHF.lean` | (E) ICL + RLHF joint degeneration | R.400, R.402 | ✅ |
| 5 | `R3_Agent6_GammaKappaReduction.lean` | (C) γ_κ conjecture vs verified | R.411, R.418 | ✅ |
| 6 | `R3_Agent6_BlindSpotPlurality.lean` | (F) Blind spot meets plurality | R.430, R.432 | ✅ |

## DEAD END: item (A) PAC → NTK → IB chain

The corpus has **no** NTK R-result and **no** Information Bottleneck R-result:

```
$ rg -l "NTK|InfoBottle|InformationBottleneck|NeuralTangent" lean/MIP/MIP/Results/
(no matches)
```

Type-honest verdict: the chain PAC → NTK → IB **cannot be formalised here** — only the PAC endpoint (R.406) and an isolated MutualInformation result (R.144) exist; neither connects to a "degenerates to" predicate the way R.405 / R.408 do. Logging as DEAD END per the mandate ("Honest DEAD ENDS on chains that don't actually fit type-wise").

## Headline theorem (item D + G)

`R3_A6_four_primitive_completeness` (file 1, last theorem). Citations:

- **R.421** `R_421_effect_nonneg` (R-primitive sign of knowledge injection)
- **R.422** `R_422_effect_formula` / `R_422_effect_nonneg` (T-primitive impedance reduction)
- **R.423** `R_423_recip_antitone` (C-primitive 1/κ blow-up)
- **R.424** `R_424_i_log_additive_three`, `R_424_ii_RT_independent`, `R_424_iii_precedence` (interaction)
- **R.432** `R_432_var_decrease_via_VarPhi`, `R_432_mean_invariant` (P signature)
- **R.433** `R_433_push_own_coord`, `R_433_push_fixes_others`, `R_433_pushes_independent` (orthogonal basis)

The single statement bundles:

1. orthogonal 4-coordinate push (R.433);
2. R × T multiplicative cost reduction with no cross-term (R.421 + R.422 + R.424);
3. R/T/C log-additive decomposition `log N = log r + log L + log Z` (R.424);
4. C precedence (no coverage ⟹ ΔN_C = 0; R.424);
5. P signature: `E[N]` invariant + strict `Var[N]` drop (R.432);
6. pairwise commutativity of pushes (R.433).

## Degeneration transitivity map

```
                   ┌──────────────────────────────────────┐
                   │              MIP CORE                │
                   │  (A.1–A.4 axioms, central relation   │
                   │     N = r · |log κ| · Z)             │
                   └──────────────────────────────────────┘
                                    │
        ┌──────────┬────────┬───────┴────────┬──────────┬──────────┐
        │          │        │                │          │          │
        ▼          ▼        ▼                ▼          ▼          ▼
     R.400      R.402    R.405            R.406      R.407      R.408
   (ICL/A.2)  (RLHF KL)  (Kolmogorov)   (PAC-Bayes) (Goodhart) (FEP single-agent)
       │         │            │              │           │          │
       │         │            │              │           │          │
   K-frozen    Er-β·KL     K(p|X) ≤      err_S +      ∃ω∈R_true   F = Φ₀ + C_train
   cov ⇔ N<∞   alignment   N·logM+c       sqrt(KL/   ω∉K_t       Z·Π = 1
               tax                          2m)
       │         │            │              │           │          │
       │         │            │              │           │          ▼
       │         │            │              │           │       R.409 — variable map
       │         │            │              │           │          (forces C_train = KL)
       │         │            │              │           │          │
       │         │            │              │           │          ▼
       │         │            │              │           │       R.410 — propositions
       │         │            │              │           │          (a) perception
       │         │            │              │           │          (d) Hebbian Gompertz
       │         │            │              │           │          (e) value = −Surprise
       │         │            │              │           │
       └────┬────┘            │              │           │
            │                 │              │           │
       Item (E) [file 4]      │              │           │     Item (B) [file 2]
       ICL + RLHF             │              │           │     Friston chain
            │                 │              │           │
            │                 └──────┬───────┘           │
            │                        │                   │
            │                 Item (H) [file 3]          │
            │                 MDL + PAC-Bayes            │
            │                                            │
            └────────────── orthogonal axes ─────────────┘
            (knowledge cov. vs. policy KL vs. blind spot)

                   ┌──────────────────────────────────────┐
                   │   PRIMITIVE SUBLATTICE (R-T-C-P)     │
                   └──────────────────────────────────────┘
                                    │
            ┌──────────┬────────┬───┴───┬──────────┬──────────┐
            ▼          ▼        ▼       ▼          ▼          ▼
         R.421      R.422    R.423   R.424      R.432      R.433
         (R: |K|↑) (T: Z⁻¹↑) (C: κ↑) (interact) (P: H_K↑)  (4D basis)
                                          │
                          Item (D + G) [file 1, HEADLINE]
                          Four-primitive completeness
                          ─────────────────────────────
                          R.421 + R.422 + R.423 + R.424 + R.432 + R.433

                   ┌──────────────────────────────────────┐
                   │       SELF / EXTERNAL BLIND SPOT     │
                   └──────────────────────────────────────┘
                                    │
                          R.430 (Cantor anti-diagonal)
                          R.432 (plurality variance)
                                    │
                          Item (F) [file 6]
                          Plurality blind spot
                                    │
                          ┌─────────┴──────────┐
                          ▼                    ▼
                   joint self-blindness  additive impedance gap

                   ┌──────────────────────────────────────┐
                   │      γ_κ SCALING LAW (R.411/R.418)   │
                   └──────────────────────────────────────┘
                                    │
                     R.411 (Cj.50: γ_κ = 2β − 1/s, NOT forced)
                     R.418 (verified: γ_κ = β · η, forced under (a)/(b-IV)/(c)/(d))
                                    │
                          Item (C) [file 5]
                          γ_κ reduction
                                    │
                          ┌─────────┴──────────┐
                          ▼                    ▼
                       Cj.50 ⇔ R.418     forced η = 2 − 1/(β·s)

                   ┌──────────────────────────────────────┐
                   │           DEAD END                   │
                   └──────────────────────────────────────┘

                     Item (A) PAC → NTK → IB  ✗
                     NTK and IB R-results do NOT exist in MIP/Results/.
                     Type-honest: not formalisable from this corpus.
```

## Degeneration table (which theory degenerates to MIP under what condition)

| Source theory | R-file | Degeneration condition | Yielded MIP fact |
|---|---|---|---|
| In-context learning | R.400 | K frozen + A.2 coverage | `N(p,A) < ∞ ↔ R(p) ⊆ K(A)` |
| RLHF / DPO | R.402 | β ≥ 0, KL ≥ 0 (Gibbs) | `J = Er − β·KL ≤ Er`, alignment tax `β·KL` |
| Kolmogorov / MDL | R.405 | Bundled universal-machine min + channel cap | `N ≥ (K(p\|X) − c)/log\|M\|` |
| PAC-Bayes | R.406 | err_S ≥ 0, KL ≥ 0, m > 0 | `err_S ≤ err_S + √(KL/2m)`, → err_S as m → ∞ |
| Goodhart / reward hacking | R.407 | A.2 fails on `R_true` while `R_proxy ⊆ K_t` | `N_true^t = ∞`, `N_proxy^t < ∞` |
| Friston FEP (single-agent) | R.408 | F1–F4: X inert, Y agent, continuous time, K(Y) generative | `F = Φ₀ + C_train`, `Z · Π = 1` |
| Friston ↔ MIP rows | R.409 | F4 dictionary | 13 row equalities; `C_train = KL`; `H_K = H[q]`; row 9/13 = gaps |
| Friston propositions | R.410 | (a)(d)(e) single-agent; (b)(c) need multi-agent | perception descent; Hebbian = κ Gompertz; value = −Surprise |
| γ_κ scaling | R.411 | (C1)–(C4) | Cj.50 declared `γ_κ = 2β − 1/s`, **not forced** |
| γ_κ verified | R.418 | Heaps + b-IV + Z slow + coverage | `γ_κ = β · η` (forced) |

## Reusable observations

1. **Hypothesis-bundle pattern is robust.** Every degeneration result here uses the "bundle (F1)–(F4)" or "(C1)–(C4)" pattern: list the modelling premises as `structure` fields and let the theorem chain them by `rw`/`linarith`. The compositions in this report (files 1, 2, 4) work because all R-results bundle their hypotheses the same way.

2. **Disambiguation by `local notation` is the right pattern for cross-namespace meanN/varN.** R.432 and R.433 both define `meanN`/`varN`. In file 1 we use `local notation "meanN_P" => PluralityPrimitive.meanN` to make joint composition feasible without `open` collisions.

3. **R.418 reduces R.411 to a single equation in η.** The non-trivial cross-derivation (file 5) is the equivalence `γκ = 2β − 1/s ↔ η = 2 − 1/(β·s)` (under R.418's `γκ = β·η`). This makes Cj.50 *checkable* as a prediction for the b-IV residual exponent — a concrete consequence of R.418 being forced where R.411 is not.

4. **(F) Plurality additive impedance.** R.430's blind-spot impedance gap composes additively over a plurality (file 6, theorem (iii)+(iv)): `Σ Z_self − Σ Z_ext = Σ δ`. This is a clean "sum-of-finite-decompositions" pattern that other multi-agent / multi-engine results can reuse.

## Theorems proved (consolidated bullet list)

- `R3_A6_four_primitive_completeness` (HEADLINE) — R.421+R.422+R.423+R.424+R.432+R.433
- `R3_A6_fourPush_coords` — R.433
- `R3_A6_RTC_log_decomposition` — R.424
- `R3_A6_RT_joint_effect_nonneg` — R.421+R.422
- `R3_A6_P_orthogonal_to_RTC` — R.432
- `R3_A6_friston_unified` — R.408+R.409+R.410
- `R3_A6_friston_F_unified`, `R3_A6_friston_NPi_plus_KL`, `R3_A6_friston_ZPi_consistent`, `R3_A6_friston_value_nonpos` — R.408+R.409, R.408+R.410
- `R3_A6_MDL_PACBayes_joint` — R.405+R.406
- `R3_A6_pacbayes_dominated_by_MDL`, `R3_A6_joint_sandwich`, `R3_A6_joint_asymptotic` — R.405+R.406
- `R3_A6_KL_budget_for_ICL_emergence` — R.400+R.402
- `R3_A6_joint_tax_and_coverage`, `R3_A6_ICL_after_RLHF_K_fixed`, `R3_A6_RLHF_beta_increase_decouples_ICL` — R.400+R.402
- `R3_A6_Cj50_R418_equivalence` — R.411+R.418
- `R3_A6_forced_eta`, `R3_A6_Cj50_realisable_iff`, `R3_A6_R411_R418_witnesses` — R.411+R.418
- `R3_A6_plurality_self_blind`, `R3_A6_plurality_impedance_additive`, `R3_A6_plurality_total_gap`, `R3_A6_plurality_var_reduction_under_blindspot`, `R3_A6_bool_plurality_witness` — R.430+R.432
