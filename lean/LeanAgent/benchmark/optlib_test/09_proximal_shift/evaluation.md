# Evaluation — `proximal_shift` (Item 09, Layer 2)

## Verdict
**CERTIFIED**

## 1. Signature equivalence
- Agent's signature is byte-equivalent to optlib's modulo `prox_prop` definition (which is inlined: `prox_prop f x z := ∀ y, f z + ‖z - x‖^2/2 ≤ f y + ‖y - x‖^2/2`).
- `#print axioms` shows `[propext, Classical.choice, Quot.sound]` — no `sorryAx`.

## 2. Line counts
| Source | Non-empty non-comment lines | Notes |
|--------|------|----|
| optlib (`ground_truth.lean`)        | 32 | uses `IsMinOn` / `isMinOn_univ_iff` machinery |
| agent  (`agent_output.lean`)        | ~70 | uses inlined `prox_prop` and explicit norm/scalar manipulations |
| ratio  | **2.2×** | the inflation comes from the `lhs_eq` and `rhs_eq` algebraic identities being made explicit |

## 3. Mathlib API overlap (Jaccard)
- **Both** use: `smul_smul`, `mul_inv_cancel₀`, `one_smul`, `smul_sub`, `norm_smul`, `Real.norm_eq_abs`, `sq_abs`, `mul_pow`, `Pi.smul_apply`, `smul_eq_mul`, `mul_le_mul_of_nonneg_left`, `le_of_mul_le_mul_left`.
- **Optlib** additionally uses `mul_le_mul_left` with `sq_pos_iff` for the multiplicative cancellation.
- **Agent** uses `abel` for vector subtraction reorderings (where optlib uses `field_simp` + `ring_nf`).
- Jaccard ≈ 0.85 — same Mathlib core, slight tactic-dialect difference.

## 4. Naming consistency
- Optlib: `proximal_shift`
- Agent:  `proximal_shift`
- Match: **identical**.

## 5. STUCK analysis
**None.** **5 compile-fix rounds** for tactic-shape issues (none strategic):
- (i) `simp [..., sq_abs]` left `|t|^2` instead of `t^2` because the `^2` matched before `sq_abs` rewrote — fixed by `simp only [..., mul_pow, sq_abs]; ring`.
- (ii) `rw [hyw] at hz` failed because `hz` had unreduced beta `(fun u => f (t • u + a)) (t⁻¹ • (w - a))` — fixed by `simp only [] at hz` then `rw [hyw]`. Eventually used a cleaner `simpa [hbeta] using hz`.
- (iii) `show ... = ... from by ring` for vector subtraction — `ring` doesn't apply to vectors → swapped to `abel`.
- (iv) Same vector `ring` issue, second occurrence.
- (v) `t * (t⁻¹ • ...)` parsed as `HMul ℝ E` (no instance) — fixed to `t • (t⁻¹ • ...)`.

All five issues are **detectable by a pre-emit linter**: classify `ring` calls on vector goals as errors; flag `rw` after lambda specialization without beta-reduce. No proof restructuring needed.

## 6. Per-stage trace
| Stage | Status | Notes |
|-------|--------|-------|
| 0 Architect  | PASS | 1 NEW lemma; defined `prox_prop` inline (since Mathlib lacks proximal operator API) |
| 1 Decomposer | PASS | 4 atoms (forward direction algebraic identity, backward symmetric, two `lhs_eq`/`rhs_eq` helpers) |
| 2 Aligner    | PASS | First compile clean |
| 3+4 Skeleton+Filler | PASS after 5 fix rounds | All STUCK-free at proof level |
| 5 Verifier   | PASS | `#print axioms` = standard |
| 6 Linter     | PR-Ready (modulo optlib's `prox_prop` source) | snake_case OK; matches optlib name |

## 7. Notes
- **6/13 CERTIFIED** so far. This is the second Layer-2 success.
- The proof is essentially the same algebraic gymnastics as optlib's, structurally. Inflation came mostly from making implicit type coercions explicit.
- For PR to optlib: the proof works as a drop-in replacement except that `prox_prop` is optlib's. PR-acceptable if accompanied by removal of the `prox_prop` definition (i.e., merge with optlib's existing).
- Major confidence boost on the "tactic-shape errors are linter-fixable" claim — five rounds of fix were each one-line edits that a goal-state-aware tactic linter could automate.
