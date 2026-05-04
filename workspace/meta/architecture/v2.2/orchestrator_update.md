# Orchestrator update — Integrator pipeline stage (v2.2)

> Added: 2026-04-21.
>
> Does NOT modify the frozen `agent_architecture_v2.md` or the base pipeline
> in `SKILL.md`. This note specifies how the orchestrator threads the new
> Integrator role into the loop.

## Pipeline change

```
Old (v2):
  Scout → Explorer×N → Judge → Auditor ⇄ Fixer → PASS → archive

New (v2.2):
  Scout → Explorer×N → Judge → Auditor ⇄ Fixer → PASS
        → Integrator → integration_check ⇄ Integrator (max 1 corrective pass)
        → archive
```

## Rationale

External review of the spiral knots stress test (arXiv:2506.17889) produced
verdict **B+** despite Auditor `PASS`. The reviewer found that the archived
`best_proof.md` was not self-contained: critical new mathematics produced in
Fixer Round 1 (Block Structure Lemma, Lemma Q, corrected induction variable
$F_k = \det(I_k - y A'_k)$) and Fixer Round 2 (universal scalar recursion
$h_k = (1+t)h_{k-1} - t h_{k-2}$, top/bot monomial sub-lemma) lived only
in the Fixer files. `best_proof.md` still referenced the obsolete induction
($D_k$ = principal minors of $B_\epsilon$ in $B_p$) and carried the stale
"By Step 3" reference in the final assembly. Reading the proof end-to-end
required juggling 3+ files.

The Auditor correctly verified the *combined* artifact (proof + all Fixer
rounds), but the *archived* artifact was the un-merged `best_proof.md`.
The Integrator role patches this gap: after Auditor PASSes the combined
artifact, Integrator rewrites `best_proof.md` to match what the Auditor
verified.

## Orchestration steps

1. **After Phase 5 (Fixer) emits PASS from Auditor**, the orchestrator
   checks whether any Fixer round ran. If not, skip Integrator — the proof
   is already self-contained.
2. **Launch Integrator** (Opus) with the prompt at
   `~/.claude/skills/math-proof-agent/prompts/integrator.md`. Inputs:
   full contents of the work directory. Outputs:
   `best_proof.md` (overwritten, with backup at
   `best_proof_pre_integrator.md`) and `integrator_report.md`.
3. **Launch integration_check** (Sonnet or Opus; checklist in
   `~/.claude/skills/math-auditor/integration_check.md`).
   - On `INTEGRATION-PASS`: proceed to archival.
   - On `INTEGRATION-FAIL`: launch Integrator ONE more time with the
     broken-item list as input.
4. **Second integration_check**:
   - On PASS: archival.
   - On FAIL: archive as-is with `[WARN: INTEGRATION-DEGRADED]` in `notes.md`
     listing every unresolved FAIL.
5. **Archival step** (the CLAUDE.md auto-archive procedure) reads the final
   `best_proof.md`, which is now either the Integrator's output or the
   pre-Integrator version with the integration warning.

## Model assignments (v2.2)

| Phase | Role | Model | Notes |
|-------|------|-------|-------|
| Scout | Route analysis | Sonnet | unchanged |
| Explorer | Proof writing | Opus | unchanged |
| Judge | Evaluation | Sonnet | unchanged |
| Auditor | Verification | Opus | unchanged |
| Fixer | Repair | Opus | unchanged |
| **Integrator** | **Rewrite for self-containment** | **Opus** | **new in v2.2** |
| **integration_check** | **Integrity sweep** | **Sonnet** | **new in v2.2; lightweight** |

Integrator uses Opus because the rewrite requires deep understanding of the
mathematical content, even though no new math is generated.
integration_check uses Sonnet because the seven items are mostly mechanical
lookups.

## Trigger conditions (explicit)

Integrator runs iff ALL of:
- Auditor emitted PASS (or PASS-with-reservations).
- At least one Fixer round executed (otherwise nothing to merge).
- `problem.md` exists and a `best_proof.md` exists in `{work_dir}`.

Integrator is SKIPPED (and archival proceeds directly) iff:
- No Fixer round ran.
- Auditor's final verdict was FAIL or PARTIAL (Integrator cannot be useful
  on a failing proof).
- Integrator's output has already been archived once (no re-integration on
  the same artifact).

## Hard limits

- One Integrator invocation per artifact.
- One corrective Integrator invocation if integration_check FAILs the first
  time.
- Total cap: 2 Integrator invocations.

## Failure modes to watch

The Integrator can fail in predictable ways. When evaluating integration_check
output, treat these as signals:

- **C1 FAIL** (source traceability) usually means the Integrator invented
  content. This is a hard stop — do not archive without resolution.
- **C2 FAIL** (cross-references) is the most common failure; expect
  Integrator's second pass to fix it.
- **C5 FAIL** (undefined symbols) usually means the Integrator dropped a
  definition section when rewriting; the second pass should restore it.
- **C6 FAIL** (conclusion mismatch) is rare but critical — halts archival.
- **C7 FAIL** (stuck-point bookkeeping) is cosmetic; archive with a
  warning is acceptable.
