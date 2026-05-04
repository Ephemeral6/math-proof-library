# Math Proof Library

A research workspace for accumulating rigorous proofs from optimization and ML theory papers.

## Project structure

```
Math/
├── proofs/
│   ├── research/    A-class proofs (research-level, 2015+ papers)
│   └── library/     B/C-class proofs (foundational lemmas, toolbox)
├── workspace/
│   ├── active/      Current proof agent working directories
│   └── archive/     Old working directories
├── papers/          Source paper PDFs, by topic
├── INDEX.md         Top-level pointer to the two index files
├── RESEARCH_INDEX.md  A-class proof catalog
├── LIBRARY_INDEX.md   B/C-class proof catalog
└── CLAUDE.md        This file
```

## Proof workflow

### Starting a proof

When I give you a math problem or theorem to prove:

1. Create a working directory: `workspace/active/proof_work_YYYYMMDD_HHMMSS/`
2. Save the problem statement as `problem.md` inside that directory
3. Trigger the math-proof-agent skill and run the protocol below
4. All intermediate files go into the working directory

### Pipeline stages

The proof agent runs the following stages in order. (As of 2026-04-29 the pipeline has six stages, up from the original five — the new stage is **Tightness Pre-Audit**, between Explorer and Judge.)

```
Proposer → Scout → Explorer ×N → Tightness Pre-Audit → Judge → Auditor → Fixer → Archive
```

- **Proposer / Scout**: route generation and library lookup. (Unchanged.)
- **Explorer**: parallel route execution. Emits one proof markdown per frame. (Unchanged.)
- **Tightness Pre-Audit** (new, 2026-04-29): for each Explorer frame, runs five checks (T1 rate preservation, T2 metric consistency, T3 constant tracking, T4 triangle/CS alert, T5 stochastic vs deterministic) and emits `tightness_report.md` plus a verdict in `{PROCEED, FIX_BEFORE_JUDGE, REJECT_FRAME}`. Full spec at `workspace/agents_spec/tightness_preaudit.md`. Frames marked REJECT_FRAME are pulled from Judge's candidate set unless every frame is rejected (in which case the orchestrator triggers an extra Explorer round with the failure modes injected as anti-hints).
- **Judge**: existing 4 criteria (rigor, constant tightness, agreement, readability) plus criterion (5) Tightness Pre-Audit verdict — prefer PROCEED frames over FIX_BEFORE_JUDGE over REJECT_FRAME, then break ties by CRITICAL count, then WARNING count.
- **Auditor**: existing rules unchanged, plus **Rule A-NEW**: every Pre-Audit WARNING must be explicitly checked for rate impact. If the warning's loose constant is dominated by a different term in the leading constant, PASS with annotation `[T{n}-WARNING-DOMINATED]`. If it propagates into the rate, FAIL with annotation `[T{n}-WARNING-PROPAGATED]`. Pre-Audit CRITICALs that somehow leak past Judge fail immediately with `[T{n}-CRITICAL-LEAKED-FROM-PREAUDIT]`.
- **Fixer**: when verdict is FIX_BEFORE_JUDGE, Fixer's first task is to apply the Pre-Audit's suggested replacements (T4 alternatives are listed inline in the report); the orchestrator re-runs Pre-Audit on the fixed proof before re-entering Auditor.

### After proof completion - AUTO ARCHIVE

After every successful proof (audit passed), automatically do the following without asking:

**Step A: Classify the proof (A/B/C)**

Determine the proof class based on:
- **A-class**: 2015+ research paper, novel proof technique, non-textbook → goes to `proofs/research/`
- **B-class**: Classic paper with non-trivial proof, important infrastructure theorem → goes to `proofs/library/`
- **C-class**: Undergraduate textbook standard result → goes to `proofs/library/`

If unclear, ask me.

**Step A2: Determine the branch**

Based on the problem content, classify it into one of these branches:
- optimization/convergence - SGD, GD, momentum convergence rates
- optimization/adaptive-methods - Adam, AdaGrad, RMSProp analysis
- optimization/lower-bounds - complexity lower bounds, oracle complexity
- optimization/stochastic - variance reduction, SVRG, SAGA
- optimization/mirror-descent - mirror descent, Bregman divergence
- learning-theory/generalization - generalization bounds, uniform convergence
- learning-theory/pac - PAC learning, VC dimension
- learning-theory/rademacher - Rademacher complexity bounds
- learning-theory/stability - algorithmic stability, leave-one-out
- convex-analysis/duality - Fenchel, Lagrangian, strong/weak duality
- convex-analysis/kkt - KKT conditions, constraint qualification
- convex-analysis/subgradient - subgradient methods, proximal operators
- statistics/concentration - Hoeffding, Bernstein, sub-Gaussian, sub-exponential
- statistics/high-dimensional - high-dim estimation, random matrices
- linear-algebra - matrix analysis, spectral theory, matrix inequalities
- probability - martingales, coupling, large deviations

**Step B: Create proof folder**

Based on classification:
- A-class: `proofs/research/{branch}/{name}/`
- B/C-class: `proofs/library/{branch}/{name}/`

Example: `proofs/research/optimization/convergence/sam-convergence-flat-minima/`
Example: `proofs/library/statistics/concentration/hoeffding-inequality/`

Inside this folder, create:

1. `problem.md` - Clean theorem statement with source info:
   ```
   # [Theorem name]
   
   ## Source
   - Paper: [title if known]
   - Context: [brief description]
   
   ## Statement
   [LaTeX theorem statement]
   
   ## Difficulty
   [standard/advanced/research/conjecture]
   ```

2. `proof.md` - The final verified proof (clean version, not the full report)

3. `report.md` - The full five-phase report (copy of final_report.md)

4. `notes.md` - Auto-generated proof notes:
   ```
   # Notes: [theorem name]
   
   ## Proof technique
   [Which route won and why]
   
   ## Key steps
   [The critical steps that made the proof work]
   
   ## Audit result
   [Summary of what the auditor found]
   
   ## Related results
   [If you can identify connections to other theorems]
   ```

5. `failed_attempts/` - Directory containing any failed route proofs (for learning)

**Step C: Update the appropriate INDEX file**

- A-class → add row to `RESEARCH_INDEX.md`
- B/C-class → add row to `LIBRARY_INDEX.md`

Row format:
```
| [theorem name] | [source] | [difficulty] | [YYYY-MM-DD] | [relative path] |
```

Update the total count and last-updated date at the bottom of the index file.
Also update the totals in `INDEX.md`.

**Step D: Clean up workspace**

Move the working directory from `workspace/active/` to `workspace/archive/`.

**Step E: Confirm**

Print a summary:
```
Proof archived:
  Class: [A/B/C]
  Branch: [branch]
  Path: proofs/[research|library]/[branch]/[folder-name]/
  Files: problem.md, proof.md, report.md, notes.md
  [RESEARCH|LIBRARY]_INDEX.md updated (total: N proofs)
  Working dir moved to workspace/archive/
```

### Failed proofs

If a proof fails (all routes failed after retry):
- Still move the working directory to workspace/archive/ with prefix `failed_`
- Do NOT create anything under proofs/
- Print what was attempted and why it failed
- Suggest what might work differently

## Conventions

- File names: kebab-case English
- File content: Chinese or English, whatever is natural
- Encoding: UTF-8 always
- Paths: use forward slashes in documentation, Claude Code handles OS differences
- Working directory names: proof_work_YYYYMMDD_HHMMSS format

## When I say...

- "prove [theorem]" or "证明 [定理]" → Start full proof workflow
- "archive this" → Manually trigger archiving of the most recent proof
- "show index" or "看看目录" → Display INDEX.md contents
- "what have we proved about [topic]" → Search proofs/ for related theorems
- "clean up" → Move any stale workspace/active/ dirs to archive/
