# R3 Agent 5 — Impossibility-theorem family cross-compositions

**STATUS**: 7 files, all compile, zero `sorry`, zero new `axiom`.

## Files produced

| File | Items | R-deps chained | Headline |
|---|---|---|---|
| `R3_Agent5_OODReducesToFiniteN.lean` | A | T.18.1 + T.18.6 + A.2 | OOD-detection uncomputable under bijective `enc` (strengthens R2 Agent 9, which stopped at image-level complementarity) |
| `R3_Agent5_AlignmentNPHard.lean` | B | T.18.2 + T.18.5 + A.2 | `AlignmentWitness` inherits NP-hardness from BOUNDED-N; `CoverageWitness` likewise |
| `R3_Agent5_RiceIncompleteness.lean` | D | R.172 + R.108 | `IsDecidablePred ⇐ ComputablePred` bridge — Rice is strictly stronger than algorithmic incompleteness |
| `R3_Agent5_SelfModelGoodhart.lean` | E | T.18.3 + T.18.4 | `GhSelfGap` = TV-distance + CTrain; strictly positive under non-degeneracy regardless of training triviality |
| `R3_Agent5_FanoNOFChain.lean` | F | IT.10 + IT.12 | Joint Fano + NOF bound; product bound `T·C ≥ ((1−h(δ))nΔ/log\|M\|)·(\|B\|/2^k)`; sandwich form when `logMeff ≤ \|B\|/2^k` |
| `R3_Agent5_HeadlineChain.lean` | **G** | **T.18.1 + R.173 + R.108** | **THE HEADLINE 3-CHAIN**: uncomputability + Kolmogorov + incompleteness on the same `FiniteN` target |
| `R3_Agent5_IndependenceMap.lean` | H | All T.18.* | Independence-vs-implication map of the T.18.* family |

Counts: 7 files, ≥ 2 R-deps each. All > 4 files threshold met.

## Headline 3-chain (item G)

`R3_Agent5_HeadlineChain.lean :: T18_1_R173_R108_FINAL_3chain`

Under hypotheses:
- T.18.1 halting reduction bundle (`HaltReductionBundle`),
- R.173 quantity bundle (`Kσ ≤ Nval·logM`, `KpA − c₀ ≤ Kσ`, `0 < logM`),
- R.108 reduction premise (`Halt ≤₀ phiMIP`) + halting incomputability,

The 3-chain produces the conjunction:
1. `¬ ComputablePred (PredOnN enc)` — T.18.1 layer,
2. `(KpA − c₀)/logM ≤ Nval` — R.173 Kolmogorov floor,
3. `¬ ComputablePred phiMIP` — R.108 algorithmic-incompleteness layer.

All three layers are independently nontrivial yet cohere on the same `FiniteN` target.

## Independence-vs-implication map of T.18.*

The current `MIP/Theorems/T18_*.lean` corpus has 9 statements:

| # | Theorem | Substrate | Independent of |
|---|---|---|---|
| T.18.1 | `FiniteN` uncomputable | halting / `ComputablePred` | All others |
| T.18.2 | BOUNDED-N NP-hard | `NPHardReduction` bundle | All others |
| T.18.3 | Self-model imperfect | `agentTVDist` (opaque) | All others |
| T.18.4 | Goodhart unavoidable | `CTrain` (Classical) | All others |
| **T.18.5** | **Alignment impossibility** | covers from A.2 | **Imports T.18.6** |
| T.18.6 | Extrapolation wall | A.2 | All others |
| T.18.7 | Metric unification | `coord` (opaque) | All others |
| T.18.9 | Det-gap non-closure | Bernoulli bundle | All others |
| T.18.10 | Conservation law | Finset / partition | All others |

**The unique intra-corpus formalised implication chain**:

```
T.18.6 ⟹ T.18.5    (via T18_5_OOD_failure, which calls T18_6_extrapolation_wall)
```

All other 35 ordered pairs `(T.18.i, T.18.j)` have **no** existing Lean
derivation chain. They are documented in `R3_Agent5_IndependenceMap.lean`
as jointly provable from their individual hypothesis bundles — each
without invoking the other.

Specifically formalised independence pairs (each as a Lean theorem):

- `independence_T18_1_T18_6` — uncomputability ⊥ extrapolation wall.
- `independence_T18_1_T18_2` — uncomputability ⊥ NP-hardness.
- `independence_T18_3_T18_4` — self-model ⊥ Goodhart.
- `independence_T18_7_T18_4` — metric unification ⊥ Goodhart.
- `independence_T18_9_T18_6` — det-gap ⊥ extrapolation wall.
- `independence_T18_10_T18_5` — conservation ⊥ alignment.

**Final meta-summary** (`T18_family_unique_chain`): the unique chain has
the form "OOD hypothesis → both T.18.6 and T.18.5 conclusions".

## What is NOT done (honest dead ends)

- **Full computability transfer of R.108 → R.172.** `ComputablePred` is
  strictly stronger than `IsDecidablePred`. The arrow R.172 → R.108
  exists; R.108 → R.172 does **not** in general (we record this as
  `rice_strictly_stronger` with a comment).
- **Closing T.18.1 ⟺ T.18.6 to full bidirectional uncomputability.**
  We strengthened R2 Agent 9's image-level complementarity to global
  complementarity under bijective `enc`. The next step (a *Lean-formal*
  proof that surjectivity of `enc` is achievable in the MIP signature
  layer) lies beyond the opaque signature layer; we ship it as a
  hypothesis.
- **Tight reverse direction in the NP-hard reduction**
  (`T18_2_T18_5_alignment_reduction_complete`) needs a "tightness"
  hypothesis on the threshold `k = (red n).2.2`. Without it, going
  `AlignmentWitness ⟹ base` is not derivable.

## R-deps chain counts

Each file cites ≥ 2 R-deps:

- `OODReducesToFiniteN`: 3 deps (T.18.1, T.18.6, A.2).
- `AlignmentNPHard`: 3 deps (T.18.2, T.18.5, A.2).
- `RiceIncompleteness`: 2 deps (R.172, R.108).
- `SelfModelGoodhart`: 2 deps (T.18.3, T.18.4).
- `FanoNOFChain`: 2 deps (IT.10, IT.12).
- `HeadlineChain`: **3 deps** (T.18.1, R.173, R.108) — the headline.
- `IndependenceMap`: 9 deps (all T.18.*).

Total: 24 chained-result citations across 7 files.
