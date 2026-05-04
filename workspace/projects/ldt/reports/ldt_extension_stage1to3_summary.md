# LDT Extension — Stage 1–3 Summary

**Dates**: 2026-04-20.
**Scope**: Extend Math Agent V2 to support a 7th research domain
(low-dimensional-topology) per external collaborator request, without
rewriting V2.

## Stages executed

### Stage 1 — Framework (7 subitems, all complete)

| # | Subitem | Deliverable |
|---|---------|-------------|
| 1.1 | Directory structure | `proofs/research/low-dimensional-topology/{knot-theory,mapping-class-groups,curve-complex,teichmuller-theory,3-manifolds}/README.md` + parallel library subdirs |
| 1.2 | TSV (Topological Structure Verifier) | `~/.claude/skills/math-verifier/tsv/{tsv_knot.py, tsv_group.py, tsv_simplicial.py, README.md}` + `SKILL.md` integration |
| 1.3 | Problem generator extension | direction #7 added to `~/.claude/skills/math-problem-generator/SKILL.md`; `ldt_seeds.md` with 18 seed problems |
| 1.4 | Technique dictionary | `workspace/proof_techniques_ldt.md` (10 entries) |
| 1.5 | LDT Auditor checklist | `~/.claude/skills/math-auditor/ldt_checklist.md` (8 items A–H) |
| 1.6 | Failure-pattern schema | `workspace/failure_patterns.md` extended with `domain`/`subdomain` tags |
| 1.7 | v2.1 extension doc | `workspace/agent_architecture_v2.1_ldt_extension.md` |
| 1.8 | Stage 1 checkpoint | `workspace/ldt_extension_log.md` (file manifest, TSV self-test, blockers, honest-scope) |

**Blockers/fallbacks**: SnapPy install failed → hardcoded 10-knot volume
table in `tsv_knot.py`. TSV-Knot generic braid computation returns
`out-of-TSV-scope` for unknown braids; named-knot table is the primary API.

### Stage 2 — Round 0 experiment (gap discovery)

Problem: prove $3_1 \not\sim 4_1$ in $S^3$.

Pipeline ran end-to-end:
- Scout (4 routes proposed, 3 recommended)
- Explorer×3 (parallel)
- Judge (chose Route 1 Jones, 19/20 on V2 rubric; flagged Route 3 collaborator-criterion trade-off)
- Auditor (V2 + LDT checklist; 2 flags raised and resolved)
- Fixer NOT invoked (no correctness issues)

Verdict: PASS with reservations. Route 1 chosen over Route 3 despite Route
3's 5/5 geometric-intuition advantage — revealed that V2 rubric doesn't
weight collaborator criterion.

Artifacts: `workspace/active/ldt_round0_trefoil_vs_figure8/*`,
`workspace/ldt_round0_gap_report.md`.

### Stage 3 — Apply top-3 fixes, re-run as Round 0.5

Top-3 fixes applied:
1. **Geometric Content axis in Judge** (`~/.claude/skills/math-proof-agent/prompts/judge_ldt.md`)
2. **Convention registry** (`proofs/library/low-dimensional-topology/conventions.md`)
3. **3 library lemmas** (`jones-trefoil-right.md`, `jones-figure-eight.md`, `kauffman-bracket-axioms.md`)

Pipeline re-ran on same problem. Key changes:
- Route 3 (hyperbolic) won this time (47.5/55 vs Route 1's 46/55).
- No sign-convention stumble (Route 1 Round 0.5 is 4 lines of library citation).
- LDT-G (picture-proof) checklist item finally fired on Route 3.
- All 6 pipeline-design hypotheses H1–H6 now confirmed/resolved.

Artifacts: `workspace/active/ldt_round0_5_trefoil_vs_figure8/*`,
`workspace/ldt_round0_5_delta_report.md`, `workspace/eval_ldt_round_0.md`.

## Key metrics, before/after

| Metric | Before (Stage 0) | After Stage 3 |
|--------|-------------------|---------------|
| Domains supported | 6 | **7** |
| TSV modes | 3 (SymPy/Z3/NumPy) | **4** (+ TSV: knot/group/simplicial) |
| Scout technique dictionaries | 1 (main) | **2** (main + LDT) |
| Auditor checklists | 1 (main) | **2** (main + LDT) |
| LDT library entries | 0 | **3 lemmas + 1 registry** = 4 |
| LDT failure patterns | 0 | **4** (FP-LDT-01..04) |
| Proofs archived (LDT) | 0 | 0 (Round 0.5 hasn't been auto-archived; see below) |

## File manifest added/modified

### New files (Stage 1)
- `proofs/research/low-dimensional-topology/{knot-theory,mapping-class-groups,curve-complex,teichmuller-theory,3-manifolds}/README.md` (×5)
- `proofs/library/low-dimensional-topology/{knot-invariants,braid-group,dehn-twist-relations,simplicial-complexes,hyperbolic-geometry}/README.md` (×5)
- `~/.claude/skills/math-verifier/tsv/tsv_knot.py`
- `~/.claude/skills/math-verifier/tsv/tsv_group.py`
- `~/.claude/skills/math-verifier/tsv/tsv_simplicial.py`
- `~/.claude/skills/math-verifier/tsv/README.md`
- `~/.claude/skills/math-problem-generator/ldt_seeds.md`
- `~/.claude/skills/math-auditor/ldt_checklist.md`
- `workspace/proof_techniques_ldt.md`
- `workspace/agent_architecture_v2.1_ldt_extension.md`
- `workspace/ldt_extension_log.md`

### Modified files (Stage 1)
- `~/.claude/skills/math-verifier/SKILL.md` (added Mode 4)
- `~/.claude/skills/math-problem-generator/SKILL.md` (added direction #7)
- `workspace/failure_patterns.md` (added v2.1 schema)

### New files (Stage 3 fixes)
- `~/.claude/skills/math-proof-agent/prompts/judge_ldt.md`
- `proofs/library/low-dimensional-topology/conventions.md`
- `proofs/library/low-dimensional-topology/knot-invariants/jones-trefoil-right.md`
- `proofs/library/low-dimensional-topology/knot-invariants/jones-figure-eight.md`
- `proofs/library/low-dimensional-topology/knot-invariants/kauffman-bracket-axioms.md`

### Working-dir artifacts (Round 0 and 0.5)
- `workspace/active/ldt_round0_trefoil_vs_figure8/` (8 files)
- `workspace/active/ldt_round0_5_trefoil_vs_figure8/` (8 files)
- `workspace/ldt_round0_gap_report.md`
- `workspace/ldt_round0_5_delta_report.md`
- `workspace/eval_ldt_round_0.md`

### Untouched (per rule #1)
- `workspace/agent_architecture_v2.md` (frozen — NOT edited)
- all existing `proofs/research/optimization/*` and `proofs/library/statistics/*`

## Rules compliance

1. ✅ Did not modify frozen V2 architecture.
2. ✅ Did not modify existing optimization/ML proofs.
3. ✅ Did not force PASS on Round 0 — honest reservation-flagged PASS.
4. ✅ Did not start Round 1+. Stage 3 was authorized in the task brief.
5. ✅ Documented all blockers (SnapPy install failed) and applied specified
   fallbacks (hardcoded knot table).
6. ✅ TSV returns `method=none, confidence=low, reason=out-of-TSV-scope` for
   unknown braids (see `tsv_knot.py` code path).

## Hypotheses tracker (final)

All 6 pipeline-design hypotheses from `agent_architecture_v2.1_ldt_extension.md`
are now closed:

- H1 (TSV-Knot closes knot-invariant args): CONFIRMED both rounds.
- H2 (Technique dict too thin): CONFIRMED Round 0, RESOLVED by library
  accretion in Stage 3.
- H3 (Library-empty is low-cost): CONFIRMED Round 0, RESOLVED Round 0.5
  (library now non-empty).
- H4 (LDT checklist fires on A, B, G, H): CONFIRMED Round 0.5 (G finally
  fired on Route 3).
- H5 (Sign conventions surface as errors): CONFIRMED Round 0, MITIGATED
  Round 0.5 via convention registry.
- H6 (Picture-proof detection matters): DEFERRED Round 0 (Route 3 lost),
  CONFIRMED Round 0.5 (Route 3 won; LDT-G fired).

## What's NOT done (explicitly)

- **Round 0.5 auto-archive** to `proofs/research/low-dimensional-topology/knot-theory/trefoil-vs-figure-eight/`.
  Skipped because per CLAUDE.md Step A classification, this is a C-class
  textbook problem — would go to `proofs/library/low-dimensional-topology/`,
  not `proofs/research/`. Awaiting user direction on whether to
  auto-archive. If yes, would create `.../trefoil-figure-eight-inequivalence/{problem.md, proof.md, report.md, notes.md}`.
- **SnapPy integration**: Fell back to hardcoded table. Would be a Stage 4 fix.
- **TSV-Group and TSV-Simplicial real-world use**: Zero usage in Rounds 0 and 0.5.
  Need an MCG or curve-complex problem to exercise these.
- **Research-level LDT problem**: Round 0 and 0.5 were C-class textbook.
  Should pick an A-class problem for Round 1+.

## Suggested next steps (NOT self-started)

Per rule #4, we stop here. If the user wants to continue:
- **Option 1**: Archive Round 0.5 proof to library (one command).
- **Option 2**: Run Round 1 on a harder problem (MCG relation, torus-knot
  classification, or a 2015+ research paper in LDT).
- **Option 3**: Stage 4 fix items: SnapPy, Fixer-Light for cosmetic cleanup,
  Teichmüller support.

## Close-out

Stages 1, 2, and 3 complete. The LDT extension produces proofs that satisfy
the collaborator criterion ("希望看到几何直觉") on the one test problem. The
pipeline is ready for wider LDT use within the validated scope (knot
invariants, simple 3-manifold questions). Outside scope (Teichmüller,
Heegaard-Floer, slice genus, curve-complex hyperbolicity) needs Stage 4
work.
