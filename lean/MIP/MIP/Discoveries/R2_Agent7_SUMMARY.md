# R2 Agent 7 — Generalised H_K + KL identity, Renyi-α to uniform,
                 conditional-entropy and MI vanishing

**Direction.** Generalise Round 1's headline `H_K(d) + KL(d ‖ uniform) =
log |Ω|` to (a) arbitrary positive reference distributions `q`, and (b)
other α-divergences (α ∈ {2, ∞, 0}). Also sharpen the conditional-entropy
and mutual-information chain rule with vanishing equality cases.

**Headline.** Two complementary identities:

1. For any strictly-positive reference `q`:
       `knowledgeEntropy d + klDiv d q  =  crossEntropy d q`
   (i.e. the H_K + KL = constant reading where the "constant" is the
   reference-dependent cross-entropy; when `q = uniform`, the constant
   collapses to the d-independent `log |Ω|`).

2. Mutual information `MI(d, P) = H_K(d) - H_π(P, d) = 0` iff every
   positively-massed part hosts a within-part point-mass.

**Output.** Six files, all compile, zero `sorry`, zero new `axiom`.
All `DISCOVERY`.

| File | Group | Key result(s) |
|---|---|---|
| `R2_Agent7_CrossEntropy_NonuniformRef.lean` | I.14 generalised | `H_K_plus_KL_to_q_eq_crossEntropy`, `crossEntropy_uniform_const`, `H_K_plus_KL_to_uniform_via_crossEntropy`, `klDiv_to_uniform_eq_KL_to_uniform_dist` (cross-check between Agent 10's two formalisations of KL-to-uniform), `crossEntropy_uniform_is_d_independent`, `crossEntropy_sub_entropy_eq_KL`. |
| `R2_Agent7_Renyi2_Reference.lean` | B+ | `Renyi2_to_uniform`, distribution-level `1/|Ω| ≤ ∑ p² ≤ 1` brackets, `Renyi2_to_uniform_nonneg`, `Renyi2_to_uniform_le_log_card`, `Renyi2_to_uniform_bracket`, `Renyi2_to_uniform_eq_zero_iff_collision_inv`. |
| `R2_Agent7_RenyiInf_Reference.lean` | B+ | `Renyi_inf_to_uniform`, `maxMass_ge_inv_card` (pigeonhole), `maxMass_le_one`, `Renyi_inf_to_uniform_nonneg`, `Renyi_inf_to_uniform_le_log_card`, `Renyi_inf_to_uniform_bracket`. |
| `R2_Agent7_RenyiZero_Reference.lean` | B+ | `Renyi_zero_to_uniform := log |Ω| - log |supp d|`, `Renyi_zero_to_uniform_nonneg`, `Renyi_zero_to_uniform_le_log_card`, `Renyi_zero_to_uniform_bracket`, `Renyi_zero_to_uniform_max_iff_point_mass`, `Renyi_zero_to_uniform_zero_iff_full_supp`. |
| `R2_Agent7_CondEntropy_PointMass.lean` | C.7 | `condEntropyTotal`, `condEntropyTotal_eq_MI`, `condEntropyTotal_nonneg`, `condEntropy_total_eq_zero_iff`, `condEntropy_total_eq_zero_iff_part_or_pointmass`, `coarse_graining_lossless_iff_condEntropy_zero`. |
| `R2_Agent7_MI_Zero_Iff.lean` | C.7 / A.2 | `MI_eq_zero_iff_part_or_pointmass`, `MI_eq_zero_iff_HK_eq_Hpi`, `MI_pos_iff_some_part_with_residual`. |

---

## Most paper-novel result

**`R2_Agent7_CrossEntropy_NonuniformRef.klDiv_to_uniform_eq_KL_to_uniform_dist`**

The cross-check between Agent 10's two formalisations of "KL to
uniform":

* the **two-sum form** `klDiv d (uniformDist Ω) = ∑ p ω · log (p ω / (1/|Ω|))`
  (from `Agent10_CrossEntropy.klDiv`), and
* the **algebraic form** `KL_to_uniform_dist d := log |Ω| - H_K(d)`
  (from `Agent10_KLToUniform_Dist`).

These two definitions are *defined differently* in Round 1 — the
two-sum form is operational (suitable for general Gibbs proofs), the
algebraic form is a closed expression (suitable for the headline
identity).  Their equivalence

```lean
theorem klDiv_to_uniform_eq_KL_to_uniform_dist
    [Nonempty Ω] [DecidableEq Ω] (d : ActivationDist Ω) :
    klDiv d (Agent6.uniformDist Ω) = KL_to_uniform_dist d
```

closes the gap between the two formalisations.  Combined with the
non-uniform identity `H_K + klDiv d q = crossEntropy d q`, this
certifies that the H_K-plus-KL = (constant) reading uniquely
distinguishes the uniform reference (when "constant" means "d-
independent"): for any other strictly-positive `q`, the
`crossEntropy d q` depends nontrivially on `d`.

## Most mathematically substantive

**`R2_Agent7_MI_Zero_Iff.MI_pos_iff_some_part_with_residual`**

The full *strict-positivity* characterisation of mutual information in
the partition framing:

```lean
theorem MI_pos_iff_some_part_with_residual
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    0 < mutualInformation d P
      ↔ ∃ S ∈ P.parts,
          0 < ((P.subdomainMass d S : NNReal) : ℝ) ∧ 0 < condEntropy S d
```

Forward direction: from `MI > 0` and the all-nonneg per-summand
analysis, the contrapositive forces some summand to be strictly
positive, i.e. both `π_S > 0` and `condEntropy S d > 0` simultaneously.
This is the "where is the residual information" structural lemma — the
parts of `P` where coarse-graining loses information are exactly those
where both (a) the part carries mass and (b) the within-part
distribution is non-degenerate.

## Correction to the prompt direction

The prompt suggested `MI = 0 ⟺ d is constant on each S`.  This is
**incorrect** in the MIP framing: in this gauge, `MI = H_K - H_π = H(d|P)`
is the *expected within-part entropy*, not a classical `I(X; Y)`
(no joint distribution is formalised here).  Hence `MI = 0` corresponds
to *within-part degeneracy* (each positively-massed part hosts a
point-mass), the **opposite** of "constant within each S" (which is the
within-part uniform = Jensen-saturating case, giving maximal `H(d|P)`,
not zero).

We document this in the file header and prove the correct equivalence.

## Strategy notes / Mathlib bridges

* **`Finset.single_le_sum`** — for the unit-interval bound `(d.p ω : ℝ) ≤ 1`
  on each individual mass, since the sum equals 1.
* **`sq_sum_le_card_mul_sum_sq`** (Chebyshev / Cauchy-Schwarz) — used for
  the distribution-level Renyi-2 lower bound `∑ p² ≥ 1/|Ω|`. Same
  technique as Agent 3's partition-level `Σ π² ≥ 1/m`.
* **`Finset.max'`** — for the Renyi-∞ definition. Combined with
  `Finset.image_nonempty` to handle the nonemptyness side-condition.
* **`Finset.sum_lt_sum_of_nonempty`** — for the pigeonhole `maxMass ≥ 1/|Ω|`:
  if every mass were `< 1/|Ω|`, the sum would be `< 1`, contradicting
  normalisation.
* **`Real.log_eq_zero`** — for the equality cases (`Renyi-0 = log|Ω|` iff
  `|supp d| = 1`, etc.), gives the disjunction `x = 0 ∨ x = 1 ∨ x = -1`.
* **`Finset.sum_eq_zero_iff_of_nonneg`** — for the `H(d|P) = 0 ⟺ each
  summand = 0` step.

## Cross-references with prior agents

* **Agent 10** (`Agent10_KLToUniform_Dist`, `Agent10_CrossEntropy`,
  `Agent10_PartitionEntropyReduction`, `Agent10_EntropyChainRule`,
  `Agent10_KL_TwoDist`) — we **build on** Agent 10's two definitions of
  "KL to uniform" (algebraic and two-sum) and prove their equivalence;
  we extend Agent 10's `crossEntropy_eq_entropy_add_KL` to the H_K+KL
  identity form; we extend Agent 10's `mutualInformation_nonneg` to the
  full strict-positivity characterisation.
* **Agent 6** (`Agent6_HK_LogCard`, `Agent6_HK_Support`) — we use Agent
  6's `uniformDist`, `uniformMass`, `uniformMass_coe`, `supp`, and
  `supp_nonempty` as building blocks.
* **Agent 3** (`Agent3_PiSqBounds`) — partition-level `1/m ≤ Σ π² ≤ 1`
  inspired the distribution-level proof for `1/|Ω| ≤ Σ p² ≤ 1`; the same
  Cauchy-Schwarz / pointwise-`p² ≤ p` techniques port directly.
* **R-SUB.7** (via Agent 10's chain rule) — used through Agent 10's
  packaged `mutualInformation_eq_expected_condEntropy`.

No overlap with R2-Agents 1-6 or 8-10 (different topics, distinct
sub-fields of the entropy/divergence corpus).

## File-naming and compilation

All files match `MIP/Discoveries/R2_Agent7_*.lean`. All compile from
`C:\Users\12729\Desktop\Math\lean\MIP` via:
```
lake env lean MIP/Discoveries/R2_Agent7_<topic>.lean
```
All exit code 0 (only `unusedSectionVars` warnings).

## Theorems proved (concise list)

* `H_K_plus_KL_to_q_eq_crossEntropy` (generalised identity, arbitrary positive q)
* `crossEntropy_uniform_const`        (d-independence at uniform)
* `H_K_plus_KL_to_uniform_via_crossEntropy` (round-trip to Agent 10's headline)
* `klDiv_to_uniform_eq_KL_to_uniform_dist`  (two-formalisation cross-check)
* `crossEntropy_uniform_is_d_independent`
* `crossEntropy_sub_entropy_eq_KL`
* `Renyi2_to_uniform_nonneg`, `Renyi2_to_uniform_le_log_card`
* `sum_p_sq_le_one`, `sum_p_sq_ge_inv_card`  (distribution-level brackets)
* `Renyi2_to_uniform_eq_zero_iff_collision_inv`
* `Renyi_inf_to_uniform_nonneg`, `Renyi_inf_to_uniform_le_log_card`
* `maxMass_ge_inv_card` (pigeonhole), `maxMass_le_one`
* `Renyi_zero_to_uniform_nonneg`, `Renyi_zero_to_uniform_le_log_card`
* `Renyi_zero_to_uniform_max_iff_point_mass`
* `Renyi_zero_to_uniform_zero_iff_full_supp`
* `condEntropyTotal`, `condEntropyTotal_eq_MI`, `condEntropyTotal_nonneg`
* `condEntropy_total_eq_zero_iff`
* `condEntropy_total_eq_zero_iff_part_or_pointmass`
* `coarse_graining_lossless_iff_condEntropy_zero`
* `MI_eq_zero_iff_part_or_pointmass`
* `MI_eq_zero_iff_HK_eq_Hpi`
* `MI_pos_iff_some_part_with_residual`
