# Benchmark Runner Protocol

This document describes how to execute one pipeline run for any of the 13 theorems.

## Per-theorem run procedure

For directory `<NN>_<name>/`:

1. **Invoke the skill.** Read `~/.claude/skills/lean-formalization-agent/SKILL.md`. Hand it the path `benchmark/optlib_test/<NN>_<name>/input.json`.
2. **Pipeline executes.** Stages 0–6 produce intermediate artifacts under `LeanAgent/output/<theorem_name>_<timestamp>/`. The final Lean file is copied to `LeanAgent/Generated/`.
3. **Capture outputs.** Copy the run artifacts back into `benchmark/optlib_test/<NN>_<name>/`:
   - `agent_output.lean` ← final Generated file
   - `run_summary.md` ← `output/<run>/run_summary.md`
   - `verdicts/` ← all `verdict_*.json` files
   - failed routes (if any) → `failed_attempts/`
4. **Build sanity_check.** Use the template in `<NN>_<name>/sanity_check.lean` — fill in the agent's exact signature, leave the body as `<original optlib theorem name> <hypotheses>`. Compile:
   ```
   export PATH="$HOME/.elan/bin:$PATH" && cd ~/Desktop/Math/LeanAgent && lake env lean benchmark/optlib_test/<NN>_<name>/sanity_check.lean
   ```
   Compile success → signature equivalent. Compile failure → record diff in evaluation.md.
5. **Evaluate.** Fill in `<NN>_<name>/evaluation.md` per the template.

## Time budget reality

- Single Mathlib import compile: ~2 min from cold cache, ~5 s after the project's `.olean` files are warm.
- A full pipeline run touches 5–15 distinct compile cycles (skeleton + per-sorry filler + verifier). Expect 15–60 min wall time per Layer 1 / Layer 2 theorem, 60+ min per Layer 3 theorem.
- 30-minute timeout per theorem, as user specified, will likely TIMEOUT all of Layer 3 and possibly the harder Layer 2 items.

## Sequence

Run order: 01 → 02 → … → 13. **Do not parallelize** — `lake env lean` shares a build directory.

## What evaluation.md must contain

1. **Verdict**: CERTIFIED / PARTIAL(N stuck) / FAIL / TIMEOUT
2. **Signature equivalence**: did `sanity_check.lean` compile? If not, paste the type-mismatch error.
3. **Lines**: agent / optlib non-empty non-comment line count (use `grep -cv '^[[:space:]]*\($\|--\)' <file>`)
4. **Mathlib API overlap**: list lemma names referenced (`exact`, `apply`, `rw [...]`, `simp only [...]`) on both sides, then |A∩B| / |A∪B|.
5. **Naming**: agent's theorem name vs optlib's. Identical / kebab-snake variant / unrelated.
6. **STUCK analysis**: per STUCK entry, paste goal state at point of failure and classify cause: 
   - `mathlib-lookup` (couldn't find a Mathlib lemma it needed)
   - `chain-rule` (calculus differentiability composition)
   - `integral` (measure-theoretic obstruction)
   - `pp-display` (term elaboration / implicit instance resolution)
   - `algebra` (ring/field rewriting failure)
   - `other` (specify)
