# Math Agent Architecture v2.2 — Integrator Extension

> Extension document. Does NOT modify the frozen `agent_architecture_v2.md`
> or `agent_architecture_v2.1_ldt_extension.md`.
>
> Created: 2026-04-21. Author: three-tier upgrade, stage P0.
>
> This document records the first non-trivial change to the V2 pipeline
> since the LDT extension (v2.1): introducing an Integrator role between
> Auditor PASS and archival. Triggered by the spiral knots external-review
> finding (verdict B+, 2026-04-21) that the archived `best_proof.md` was
> not self-contained.

---

## 1. What v2.2 adds over v2.1

The v2.1 LDT extension added a new research domain and supporting
infrastructure but did not alter the pipeline skeleton. v2.2 makes the
first structural change: it inserts an Integrator between the converged
Auditor ⇄ Fixer loop and archival.

### Summary of additions

| Component | v2.1 state | v2.2 addition |
|-----------|------------|---------------|
| Pipeline | Scout → Explorer×N → Judge → Auditor ⇄ Fixer → PASS → archive | + Integrator → integration_check ⇄ Integrator (≤1 corrective) → archive |
| `math-proof-agent/prompts/` | scout, explorer, judge, auditor, fixer | + `integrator.md` |
| `math-auditor/` | `ldt_checklist.md` | + `integration_check.md` |
| `math-proof-agent/` | `SKILL.md` | + `orchestrator_update.md` note |

### Summary of non-additions (explicit)

v2.2 does NOT:
- Modify any existing prompt or checklist file. All added files are new.
- Change what Auditor verifies. Auditor still audits the combined
  `best_proof.md + fixer_round_*.md` artifact.
- Change the Fixer's incremental-patch nature.
- Change the TSV verifier or the LDT checklist.
- Alter `judge.md`, `failure_patterns.md`, or archival procedure.

---

## 2. Motivation (spiral knots retrospective)

The LDT-domain stress test on Blackwell et al., "Classical invariants of
spiral knots" (arXiv:2506.17889), completed 2026-04-20 with Auditor PASS
after Fixer Round 2. External review produced verdict B+ with three
architectural findings:

1. **No Integrator role.** Fixer is incremental; nothing rewrites the main
   proof after Auditor PASSes. The final `best_proof.md` retained
   obsolete content:
   - Step 5 used the wrong induction variable ($D_k$ = principal minors of
     $B_\epsilon$ in $B_p$), although Fixer Round 1 had replaced this with
     the intrinsic $F_k = \det(I_k - y A'_k)$ in the smaller group
     $B_{k+1}$.
   - Step 6 cited "By Step 3, $\det(I - B) = \pm t^a \Phi_p(t)$ cancels",
     although Fixer Round 2 had replaced this mechanism with the
     universal scalar recursion $h_k = (1+t)h_{k-1} - t h_{k-2}$.
   - Block Structure Lemma, Lemma Q, and top/bot monomial sub-lemma lived
     only in `fixer_round_{1,2}.md` as external references.
2. **Ad-hoc sympy verification is undocumented and irreproducible.** Addressed
   by v2.2 stage P1 (Verified Sympy Block protocol).
3. **TSV-Simplicial is toy-level.** Addressed by v2.2 stage P2 (roadmap,
   deferred).

v2.2-P0 introduces the Integrator to resolve finding (1).

---

## 3. Pipeline flow (v2.2)

```
Scout → Explorer×N → Judge → Auditor ⇄ Fixer → PASS
      → Integrator → integration_check ⇄ Integrator (max 1 corrective)
      → archive
```

- **Integrator** runs ONCE per proof after Auditor PASS (skip if no Fixer
  round executed). Inputs: all `explorer_*.md`, `fixer_round_*.md`,
  `auditor_round_*.md`. Outputs: rewritten `best_proof.md` plus
  `integrator_report.md`. Before rewriting, the pre-integrator version is
  preserved at `best_proof_pre_integrator.md`.
- **integration_check** is a lightweight integrity sweep (7 items:
  source traceability, cross-references, citation definitions,
  VERIFIED-SYMPY tag validity, definition discipline, conclusion-target
  match, stuck-point bookkeeping). It does not re-prove anything. On
  `INTEGRATION-PASS`, archival proceeds. On `INTEGRATION-FAIL`, Integrator
  runs one corrective pass; if the second check also fails, archive as-is
  with a degradation warning.

---

## 4. Files added (v2.2-P0)

| File | Purpose |
|------|---------|
| `~/.claude/skills/math-proof-agent/prompts/integrator.md` | Integrator role specification |
| `~/.claude/skills/math-auditor/integration_check.md` | Integration check checklist |
| `~/.claude/skills/math-proof-agent/orchestrator_update.md` | Pipeline orchestration update |
| `~/Desktop/Math/workspace/agent_architecture_v2.2_integrator.md` | This architecture doc |

---

## 5. What Integrator does and does NOT do

### Does

- Walk `best_proof.md` section by section and diff against Fixer additions.
- Identify obsolete content (stale induction variable, closed stuck point,
  broken cross-reference).
- Inline Fixer-added lemmas as full statements with proofs in the main body.
- Update the "what closed / what didn't" section to the current state.
- Update the citation ledger (cumulative L1 / L2 / L3 / Independent counts).
- Preserve all verification tags (`[VERIFIED-SYMPY:...]`, `[VERIFIED:...]`,
  `[I]`, `[L1/2/3]`, `[CALL:...]`).
- Write `integrator_report.md` as a merge log with sections
  §0 Target ToC / §1 Obsolete removed / §2 New integrated /
  §3 Citation ledger delta / §4 Cross-ref fixups / §5 Verification roster /
  §6 Residual gaps.

### Does NOT

- Run verification scripts.
- Re-score Axis 5 (Geometric Intuition).
- Generate new mathematics.
- Modify the problem statement, Auditor reports, or Fixer reports.
- Touch `failure_patterns.md`, `judge.md`, or `agent_architecture_v2.md`.
- Archive the proof (the CLAUDE.md auto-archive procedure does that
  afterwards).

---

## 6. Reliability rules (from `integrator.md`)

1. **Do not invent**: every claim in the rewritten proof traces to a
   source location.
2. **Preserve tags**.
3. **Resolve conflicts by recency**: Auditor > later Fixer > earlier
   Fixer > Explorer > Scout.
4. **Update stale cross-references**.
5. **Flag irreconcilable conflicts**: if two Fixer rounds contradict and
   Auditor did not resolve, STOP and write a conflict note — do not ship
   a rewrite.

---

## 7. Hard limits

- One Integrator invocation per proof artifact.
- One corrective Integrator invocation if integration_check FAILs.
- Total cap per artifact: two Integrator invocations.
- On second-failure, archive with `[WARN: INTEGRATION-DEGRADED]`.

---

## 8. Expected effect on the B+ verdict

Applying Integrator to the spiral knots artifact is the P0 test case.
Per the external reviewer's findings, the rewritten `best_proof.md`
should:

- Replace Step 5's wrong induction variable with the corrected $F_k$ /
  $A'_k$ framing.
- Replace Step 6's stale `[Step 3]` citation with the $h_k$ scalar
  recursion mechanism from Fixer Round 2.
- Inline the Block Structure Lemma, Lemma Q, and top/bot monomial
  sub-lemma as full statements with proofs.
- Be readable end-to-end without opening `fixer_round_*.md`.

If Integrator achieves this on the spiral knots test, the B+ architectural
finding for "missing Integrator" is resolved.

---

## 9. What's NOT in v2.2 (explicit)

- **Integrator does not un-freeze V2 architecture.** `agent_architecture_v2.md`
  remains canonical for the pipeline before Integrator. This doc specifies
  the addition.
- **Integrator does not subsume Auditor.** Auditor still verifies
  mathematical correctness across the combined artifact. Integrator
  assumes that verification has happened.
- **Integrator does not subsume Fixer.** Fixer is still the incremental
  patch mechanism inside the Auditor loop. Integrator runs AFTER the loop
  converges.
- **No changes to domain routing.** LDT checklist still runs when the
  LDT keyword is detected.

---

## 10. Next-stage dependencies

- v2.2-P1 (Verified Sympy Block protocol) builds on the Integrator by
  standardizing the `[VERIFIED-SYMPY:...]` tag that Integrator preserves
  and integration_check (item C4) validates.
- v2.2-P2 (TSV-Simplicial upgrade roadmap) is orthogonal to the Integrator
  and is a planning document only; it writes no code.
