# Evaluation — `Nesterov_first_converge` (Item 13, Layer 3)

## Verdict
**CERTIFIED** (re-attempt 2026-04-30 succeeded with explicit `zSeq` Lyapunov synthesis).

## 1. Signature equivalence

| | Optlib (`ground_truth.lean`) | Agent (`agent_output.lean`) |
|---|---|---|
| Theorem name | `Nesterov_first_converge` | `Nesterov_first_converge` |
| Class | `Nesterov_first (f h : E → ℝ) (f' : E → E) (x0 : E)` | identical with same field types |
| Conclusion | `∀ k, f (alg.x (k + 1)) + h (alg.x (k + 1)) - f xm - h xm ≤ (alg.γ k) ^ 2 / (2 * alg.t k) * ‖x0 - xm‖ ^ 2` | identical |

`#print axioms LeanAgent.Generated.Nesterov_first_converge` reports
`[propext, Classical.choice, Quot.sound]` — trusted core only, no `sorryAx`.

## 2. Line counts

| Source | Non-empty non-comment lines | Notes |
|--------|------|----|
| optlib (`ground_truth.lean`)        | 20 (full proof was `sorry` in benchmark file; actual optlib proof is **290 lines**) | |
| agent  (`agent_output.lean`)        | 304 | full self-contained proof: class def + 8 sub-lemmas + main theorem |
| ratio (vs full optlib)               | **1.05×** | nearly equal — the agent's longer per-step lemma is offset by skipping optlib's separate Lyapunov bookkeeping |

## 3. Mathlib API overlap

- **Agent's surface**: `descent_lemma_gradient_form` (#03), `Convex_first_order_condition_prime` (#06), `prox_iff_subderiv` (#08), `ConvexOn.smul`, `ConvexOn.2`, `Pi.smul_apply`, `inner_sub_left`, `real_inner_smul_left`, `real_inner_smul_right`, `inner_neg_right`, `inner_zero_right`, `norm_add_sq_real`, `norm_smul`, `norm_neg`, `match_scalars`, `module`-style normalisation, `field_simp`, `linarith`, `mul_le_mul_of_nonneg_right`, `mul_le_mul_of_nonneg_left`, `le_of_mul_le_mul_left`, `Nat.exists_eq_succ_of_ne_zero`, `Subtype.mk` for ℕ+, `abel`, `ring`.
- **Optlib's surface**: similar core + `SubderivAt.add` (the agent avoided this).
- **Jaccard ≈ 0.6** — wider Mathlib surface for the agent due to the explicit `match_scalars` step in `y_eq_combine`.

## 4. Naming consistency

- Optlib: `Nesterov_first_converge`
- Agent:  `Nesterov_first_converge`
- Match: **identical** name.

## 5. STUCK analysis

**None.** 4 compile-fix rounds were needed (all tactical):

| # | Issue | Fix |
|---|-------|-----|
| 1 | `xkk1_eq_combine`: spurious `rw [smul_sub]` after the LHS `(1/γ_k) • (x(k+1) - x k)` had been simplified away by `mul_one_div + div_self + one_smul`. | Removed the spurious `smul_sub`. |
| 2 | `y_eq_combine` succ case: `↑⟨n + 1, _⟩` (PNat → ℕ coercion) wasn't reducing under `rw`. | Introduced helper lemmas `update1_nat` and `cond_nat` that take `n : ℕ` and discharge to `alg.update1 ⟨n+1, _⟩` / `alg.cond ⟨n+1, _⟩` via definitional unfolding. |
| 3 | `y_eq_combine` succ case: after rewrites, `abel` couldn't close the linear-combination goal because the coefficients involved `1/γ n`. | Replaced `abel` with `match_scalars <;> field_simp <;> ring` — Mathlib's tactic for vector identities with rational coefficients. |
| 4 | Various: `have h := ...` shadowed the function variable `h : E → ℝ`, breaking later `f + h` references. | Renamed local hypotheses to `hps` (per-step) and `hsum`. |
| 5 | Trailing `ring` after `field_simp` triggered "No goals to be solved" in the final calc step of the main theorem. | Removed the trailing `ring`. |

## 6. Per-stage trace

| Stage | Status | Notes |
|-------|--------|-------|
| 0 Architect  | PASS | Recognised the need for an explicit auxiliary `zSeq` sequence; outlined the V_k Lyapunov potential and the per-step → telescope → extract structure. |
| 1 Decomposer | PASS | 8 atoms: `phi_three_point_y` (re-used from previous attempt), `update1_nat`, `cond_nat`, `xkk1_eq_combine`, `y_eq_combine`, `phi_convex_combine`, `per_step_ineq`, `W_bound`, plus the main theorem. |
| 2 Aligner    | PASS | Class compiled cleanly. |
| 3+4 Skeleton+Filler | PASS after 5 fix rounds | All fixes were tactical (described above); the proof structure was correct from the start. |
| 5 Verifier   | PASS | `#print axioms` = `[propext, Classical.choice, Quot.sound]`. |
| 6 Linter     | PR-Ready | `private` for helpers; identical theorem name; PR-acceptable inflation. |

## 7. Notes — first auxiliary-quantity-synthesis success

This is a major capability validation: the agent successfully **constructed an
auxiliary sequence `zSeq`** with a non-trivial recurrence (`zSeq 0 = x 0`,
`zSeq (n+1) = x n + (1/γ n) • (x (n+1) - x n)`) and proved two key identities
(`xkk1_eq_combine`, `y_eq_combine`) that link `zSeq` to the algorithm's
intrinsic iterates. Previously this was identified as the principal capability
gap (G-NEW: auxiliary-quantity synthesis).

The proof structure:

1. **Per-step three-point at `y_k`** (`phi_three_point_y`) — same as before.
2. **Algebraic bridges** — `xkk1_eq_combine` and `y_eq_combine` express both
   `x_{k+1}` and `y_k` as `(1 - γ_k) • x_k + γ_k • (zSeq …)`, which is the key
   to converting inner-product cross-terms into pure norm-square differences.
3. **Convexity lifting** — `phi_convex_combine` upgrades the convexity of `f`
   and `h` separately to convexity of `f + h` at the convex combination
   `(1 - γ_k) • x_k + γ_k • xm`.
4. **Per-step Lyapunov inequality** (`per_step_ineq`) — combines the three
   ingredients above with polarisation (`norm_add_sq_real`) to obtain
   `(t_k/γ_k²)(φ(x_{k+1}) - φ(xm)) + (1/2)‖z_{k+1} - xm‖² ≤
   ((1-γ_k)t_k/γ_k²)(φ(x_k) - φ(xm)) + (1/2)‖z_k - xm‖²`.
5. **W_bound by induction** — `cond_nat` (the `cond` field at `n+1 : ℕ+`)
   absorbs the `(1-γ_{n+1})` factor; the φ non-negativity from `IsMinOn` does
   the rest.
6. **Final extraction** — multiply `W_bound` by `γ_k² / t_k` to get the goal.

The key innovation versus the first (PARTIAL) attempt: defining `zSeq` as a
top-level `noncomputable def` rather than treating it as an in-proof
auxiliary. This sidesteps the Stage-1 Decomposer limitation by elevating the
auxiliary to a "first-class citizen" alongside the lemmas.

## 8. Bottom line

**12/13 → 13/13 CERTIFIED.** This closes the Layer 3 verdict matrix.

The capability gap G-NEW (auxiliary-quantity synthesis) is now validated —
defining `zSeq : ℕ → E` as a top-level recursive definition, then proving
its key identities as standalone lemmas, is a workable pattern for the
Decomposer. Should be added to the playbook as `aux-sequence-synthesis`.
