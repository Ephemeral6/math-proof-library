# Agent 6 — Knowledge Entropy `H_K` Extremes

**Direction.** Extreme values of the unpartitioned activation entropy
`H_K(d) := -∑_ω p(ω) log p(ω)` (`MIP.knowledgeEntropy`), complementary
to Agent 3's work on partition masses `π_i`.

**Headline.** `H_K(d) = log |Ω| ↔ d` is uniform. The full iff form of
Jensen's saturating equality, executed via Mathlib's
`Real.strictConcaveOn_negMulLog` + `StrictConcaveOn.eq_of_map_sum_eq`.

**Output.** Seven compile-clean files, zero `sorry`, zero new axiom.

| File | Status | Group | Key result |
|---|---|---|---|
| `Agent6_HK_Nonneg.lean` | DISCOVERY | 1.1 | `H_K_nonneg : 0 ≤ knowledgeEntropy d` |
| `Agent6_HK_Zero_PointMass.lean` | DISCOVERY | 1.2 | `H_K_eq_zero_iff_point_mass` (the iff) |
| `Agent6_HK_LogCard.lean` | DISCOVERY | 2.3 | `H_K_le_log_card`, `H_K_uniform_eq_log_card` |
| `Agent6_HK_Uniform_Saturation.lean` | DISCOVERY | 2.4 | `H_K_eq_log_card_iff_uniform` (the hard iff, equality case of Jensen) |
| `Agent6_HK_Support.lean` | DISCOVERY | 3.5, 3.6 | `knowledgeEntropy_eq_H_supp_supp`, `H_K_le_log_supp_card` (sharper than 2.3) |
| `Agent6_HK_StrictBound.lean` | DISCOVERY | bonus | `H_K_lt_log_card_iff_not_uniform`, `H_K_eq_zero_iff_supp_card_one` |
| `Agent6_HK_Extremes_T8.lean` | OBSERVATION | 4 | `Phi0_mul_Z_eq_zero`: no formal counterpart of NL "T.8 simplifies at H_K extremes" at this model level |

## Notes on reuse

* `Agent6_HK_LogCard` and `Agent6_HK_Uniform_Saturation` lift
  `CjNEW13_entropy_le_log` (already proved for arbitrary probability
  vectors in `MIP/Conjectures/CjNEW13_HpiMaxAtTStar.lean`) and the strict
  Jensen equality case from Mathlib.
* `Agent6_HK_Support` provides a sharper bound `H_K ≤ log (supp d).card`
  via reindexing through the support subtype with `Finset.sum_coe_sort`.
* `Agent6_HK_Zero_PointMass` establishes `negMulLog x = 0 ↔ x ∈ {0, 1}`
  on `[0, 1]` as a standalone lemma — this is not in Mathlib at the
  granularity used here.

## Most fertile group

Group 2 (`H_K ≤ log |Ω|` and the *equality case* iff). Mathlib's
`strictConcaveOn_negMulLog` + `eq_of_map_sum_eq` packaged the
equality-case of Jensen cleanly. Group 1.2 (zero iff point mass) was
the second-most-productive — it produced both an iff and the corollary
`H_K = 0 ↔ |supp d| = 1` for free.

## Group 4 — explicit non-result

Recorded as `OBSERVATION`: in the concrete state-sequence model
(`MIP/Defs/StateSequence.lean`) `Z = 0`, so `Φ₀ · Z = 0` identically,
independent of any activation distribution. The NL claim "T.8 simplifies
at the `H_K` extremes" has *no formal predictive content* at this layer;
the relation `Φ₀ · Z` is independent of any `ActivationDist Ω` data
because `H_K` is not coupled to `Phi0`/`Z` in any axiom. Future agents
should not chase a formal version of this NL claim at the current model
depth — they need richer coupling axioms first.
