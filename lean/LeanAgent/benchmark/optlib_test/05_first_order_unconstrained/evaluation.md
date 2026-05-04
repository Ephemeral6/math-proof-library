# Evaluation — `first_order_unconstrained` (Item 05, Layer 1)

## Verdict
**CERTIFIED**

## 1. Signature equivalence (sanity_check.lean)

- Compile result: **PASS**
- `agent_first_order_unconstrained` has identical signature to optlib's `first_order_unconstrained`. The cross-`example` invokes the agent's lemma on optlib-shape hypotheses successfully.
- `#print axioms` reports `[propext, Classical.choice, Quot.sound]` — no `sorryAx`.
- Note: agent renames `hfc` to `_hfc` to silence the unused-variable warning. The hypothesis is **kept** (so signature matches optlib byte-for-byte modulo the underscore prefix). PR-acceptable.

## 2. Line counts

| Source | Non-empty non-comment lines |
|--------|-----------------------------|
| optlib (`ground_truth.lean`)        | 15 |
| agent  (`agent_output.lean`)        | 19 |
| ratio  | **1.27×** |

## 3. Mathlib API overlap (Jaccard)

- **Optlib proof** uses: optlib helpers `optimal_no_descent_direction`, `DescentDirection`, plus `inner_neg_right`, `Left.neg_neg_iff`, `real_inner_self_eq_norm_sq`. **No** Mathlib lemma is invoked directly for the gradient-at-min step — the heavy lifting is in optlib's helper.
- **Agent proof** uses: `IsMinOn.isLocalMin`, `IsLocalMin.fderiv_eq_zero`, `HasGradientAt.hasFDerivAt`, `HasFDerivAt.fderiv`, `LinearIsometryEquiv.map_eq_zero_iff`, `Filter.univ_mem` — all **Mathlib**.
- Jaccard = |A ∩ B| / |A ∪ B| = 0 / (5 + 5) = **0.0** — completely different proof routes, even though they prove identical theorems.
- This is one of the cleanest demonstrations of **G2 (multi-route exploration)** working in the agent's favor: it discovered a 4-step Mathlib proof of the same theorem that optlib proves via a 50-line helper plus contradiction.

## 4. Naming consistency

- Optlib name: `first_order_unconstrained`
- Agent name:  `first_order_unconstrained`
- Match: **identical**.

## 5. STUCK analysis
**None.** Stage 4 closed the body in a single skeleton+filler pass; 0 STUCK.

## 6. Per-stage trace

| Stage | Status | Wall time | Notes |
|-------|--------|-----------|-------|
| 0 Architect  | PASS | < 1 min | Stage 0 chose **direct Mathlib route** rather than going through optlib's `optimal_no_descent_direction` helper. This is the multi-route exploration that the prior descent-lemma run lacked. |
| 1 Decomposer | PASS | < 1 min | 4 atoms (univ ∈ 𝓝, IsLocalMin, fderiv = 0, Riesz inversion) |
| 2 Aligner    | PASS | 25 s    | Single compile attempt; clean |
| 3+4 Skeleton+Filler | PASS | 25 s | All 4 atoms closed in one compile; **0 STUCK** |
| 5 Verifier   | PASS | (above) | `#print axioms` confirms no `sorryAx` |
| 6 Linter     | PR-Ready | — | snake_case OK; matches optlib name; docstring present; `_hfc` prefix to silence linter; LOC inflation 1.27× |

## 7. Notes

- **Strategic win**: this run validates the SUMMARY's claim that adding multi-route exploration (G2) would convert PARTIALs to CERTIFIEDs. Optlib's proof goes through a helper that itself depends on `expansion`, `HasGradientAt`, neighborhood arguments — perhaps 100+ lines of dependency closure. The agent's 4-line route via `IsLocalMin.fderiv_eq_zero` is what a Mathlib reviewer would want.
- For PR to **optlib**, this proof is dramatically shorter than the original and could legitimately replace it (subject to optlib maintainers' style preference).
- For PR to **Mathlib** itself, this lemma is novel only in its inner-product / gradient form (Mathlib has `IsLocalMin.fderiv_eq_zero` already); could go in `Mathlib.Analysis.Calculus.LocalExtr.Basic` as a corollary.

## 8. Source artifacts

- Run dir: `LeanAgent/output/first_order_unconstrained_20260428_174508/`
- Generated Lean: `LeanAgent/Generated/first_order_unconstrained.lean`
- Sanity check: `benchmark/optlib_test/05_first_order_unconstrained/sanity_check.lean`
