# Lean Agent — Current Status (read-only inventory, 2026-04-30)

**Note on paths.** The original prompt's `ls` paths (`lean/LeanAgent/Agent/…`, `scripts/`, `benchmark/`, `output/`) did not exist at the repo root. The actual project root is `lean/LeanAgent/` and everything lives one level deeper: `lean/LeanAgent/LeanAgent/Agent/`, `lean/LeanAgent/scripts/`, `lean/LeanAgent/benchmark/`, `lean/LeanAgent/output/`. All paths below are relative to the repo root `~/Desktop/Math/`.

---

## 1. Directory structure

```
lean/LeanAgent/
├── lakefile.toml, lake-manifest.json, lean-toolchain         (Lean 4 project)
├── lean_formalization_agent_architecture_v2.md               (design doc)
├── stress_test_report.md                                     (2026-04-29 refactor report)
├── SKILL.md                                                  (project-root pointer)
├── LeanAgent.lean                                            (umbrella import)
│
├── lean/LeanAgent/                                                (Lean source tree)
│   ├── Basic.lean
│   ├── Agent/                                                (Python helpers, NO LLM)
│   │   ├── Persistence.py     registry I/O
│   │   └── Utils.py           compile/sorry/file utilities
│   ├── Agent_legacy/                                         (9 archived LLM-driver modules)
│   │   └── Architect / Decomposer / Aligner / Skeleton /
│   │      Filler / Verifier / Linter / LLM / Runner.py
│   ├── Generated/                                            (all agent-produced .lean files)
│   │   ├── (15 top-level .lean files — see §2)
│   │   ├── DescentLemma/      (5 identical stub frames, see §2 caveat)
│   │   └── SHB/               (Defs / Basic / Descent — out-of-benchmark)
│   └── templates/             (only README.md)
│
├── scripts/                                                  (3 shell helpers — see §5)
│   ├── compile.sh
│   ├── check_axioms.sh
│   └── init_child.sh
├── scripts_backup/                                           (legacy run.py + stubs)
│
├── benchmark/optlib_test/                                    (13-item benchmark — see §3)
├── output/                                                   (12 per-run working dirs + _axiom_probe)
├── registry/                                                 (persistence layer)
│   ├── lemmas/      8 JSON files, one per CERTIFIED lemma
│   ├── playbook/    entries.jsonl  (6 successful goal-pattern → tactic pairs)
│   ├── failures/    entries.jsonl  (5 STUCK records)
│   └── pairs/       entries.jsonl  (14 NL ↔ Lean translation pairs)
└── Tests/test_descent_lemma.json                             (single legacy test fixture)

~/.claude/skills/lean-formalization-agent/
├── SKILL.md                                                  (the orchestrator)
├── protocols/   compile_fix_loop, mathlib_search,
│                per_lemma_loop, persistence,
│                quality_gates, recursive_synthesis           (6 protocols)
├── stages/      stage0_architect → stage6_linter             (7 stage specs)
└── templates/
```

---

## 2. Generated `.lean` files — sorry status & line counts

### Top-level `lean/LeanAgent/Generated/`

| File | Lines | Sorries | Role |
|---|---:|---:|---|
| `lipschitz_continuous_upper_bound.lean` | 104 | 0 | Benchmark **#01** final |
| `strongly_convex_on_def.lean` | 34 | 0 | Benchmark **#02** final |
| `descent_lemma_v3.lean` | 130 | 0 | Benchmark **#03** final (gradient-form wrapper, derivative-comparison route) |
| `strong_convex_gradient_lower_bound.lean` | 37 | 0 | Benchmark **#04** final (parent) |
| `first_order_unconstrained.lean` | 28 | 0 | Benchmark **#05** final |
| `gd_sufficient_decrease.lean` | 158 | 0 | Benchmark **#07** final |
| `proximal_shift.lean` | 101 | 0 | Benchmark **#09** final |
| `proximal_add_sq.lean` | 83 | 0 | Benchmark **#10** final |
| `sub_normsquare_gradient_helper_depth1_idx1.lean` | 42 | 0 | Child helper for #04 (recursive synthesis, depth 1) |
| `convex_monotone_gradient_prime_helper_depth1_idx2.lean` | 32 | 0 | Child helper for #04 (depth 1) |
| `convex_first_order_condition_grad_depth2_idx1.lean` | 130 | 0 | Child helper for #04 (depth 2) |
| `descent_lemma.lean` | 29 | **1** | **Abandoned v1**, superseded by v3 |
| `descent_lemma_v2.lean` | 73 | **4** | **Abandoned v2**, superseded by v3 |
| `nonexistent_lemma_helper_depth1_idx1.lean` | 16 | 0 | `graceful_failure_test_20260429_002553` artifact (toy lemma `n + 0 = n`) |

### `lean/LeanAgent/Generated/DescentLemma/` — caveat

5 files (`Main.lean`, `CauchySchwarzInner.lean`, `FtcLineIntegral.lean`, `IntegralTHalf.lean`, `LipschitzPathBound.lean`) all have **identical md5** (`2ff3d9b06ce…`). Each is a 29-line skeleton with the descent-lemma signature and 7 step-comments whose bodies are `have h_n : True := by trivial`. This is a multi-route exploration scaffold from an earlier session that was **never filled in** — they have 0 sorries only because the holes are `True` stubs, not real proofs. They should be ignored when counting CERTIFIED content; the real descent-lemma proof is `descent_lemma_v3.lean`.

### `lean/LeanAgent/Generated/SHB/` — out-of-benchmark Stochastic Heavy-Ball foundations

| File | Lines | Sorries | Role |
|---|---:|---:|---|
| `SHB.lean` (re-export) | 11 | 0 | Imports the three modules below |
| `SHB/Defs.lean` | 147 | 0 | Iteration + feasibility-region defs |
| `SHB/Basic.lean` | 115 | 0 | Layer-1 structural lemmas |
| `SHB/Descent.lean` | 98 | 0 | Layer-2 single-step descent inequality |

These are unrelated to the optlib benchmark and live under their own multi-file structure.

---

## 3. Optlib benchmark — 13-item progress table

| # | Theorem | Files in benchmark dir | `evaluation.md` verdict | Status |
|---:|---|---|---|---|
| 01 | `lipschitz_continuous_upper_bound` | gt + agent_output + evaluation | **CERTIFIED** | ✅ CERTIFIED |
| 02 | `stronglyConvexOn_def` | gt + agent_output + evaluation + sanity_check | **CERTIFIED** | ✅ CERTIFIED |
| 03 | `lipschitz_continuos_upper_bound'` | gt + agent_output + evaluation | **CERTIFIED** | ✅ CERTIFIED |
| 04 | `Strong_Convex_lower` | gt only — **no agent_output.lean, no evaluation.md** | (none in folder) | ⚠️ CERTIFIED per `SUMMARY.md` & registry, but the benchmark folder was not back-filled. Proof lives at `Generated/strong_convex_gradient_lower_bound.lean` + 3 helpers |
| 05 | `first_order_unconstrained` | gt + agent_output + evaluation + sanity_check | **CERTIFIED** | ✅ CERTIFIED |
| 06 | `Convex_first_order_condition'` | gt only | — | ❌ DEFERRED (Mathlib gap: FDeriv form) |
| 07 | `convex_lipschitz` (GD descent step) | gt + agent_output + evaluation | **CERTIFIED** | ✅ CERTIFIED |
| 08 | `prox_iff_subderiv` | gt only | — | ❌ DEFERRED (needs `SubderivAt.add`, optlib-only) |
| 09 | `proximal_shift` | gt + agent_output + evaluation | **CERTIFIED** | ✅ CERTIFIED |
| 10 | `proximal_add_sq` | gt + agent_output + evaluation | **CERTIFIED** | ✅ CERTIFIED |
| 11 | `gradient_method` (GD O(1/T)) | gt only | — | ❌ DEFERRED (multi-helper telescope) |
| 12 | `proximal_gradient_method_converge` | gt only | — | ❌ DEFERRED (single-file budget) |
| 13 | `Nesterov_first_converge` | gt only | — | ❌ DEFERRED (Lyapunov + extrapolation) |

**Counts:** 7 CERTIFIED with full benchmark artefacts (01, 02, 03, 05, 07, 09, 10); 1 CERTIFIED-claimed-but-not-back-filled (04); 5 DEFERRED (06, 08, 11, 12, 13). `SUMMARY.md` reports 8/13 CERTIFIED.

---

## 4. Skill, protocols, stages — one-line summaries

**`SKILL.md`** (50-line head): "the orchestrator. Claude Code reads this document and drives the seven-stage pipeline directly using its own tools (Read/Write/Edit/Bash/Grep). No subprocess calls, no separate Python runner." Trigger keywords: *formalize, Lean, Mathlib, 形式化*. Working dir contract: outputs go to `lean/LeanAgent/Generated/` and `output/<theorem>_<timestamp>/`.

**Protocols (6):**

| File | Title |
|---|---|
| `compile_fix_loop.md` | Protocol — Compile-Fix Loop |
| `mathlib_search.md` | Protocol — Mathlib Search |
| `per_lemma_loop.md` | Protocol — Per-Lemma Runner Loop |
| `persistence.md` | Protocol — Persistence (Registry Layer) |
| `quality_gates.md` | Protocol — Quality Gates Summary |
| `recursive_synthesis.md` | Protocol — Recursive Dependency Synthesis (Tier 3) |

**Stages (7):**

| File | Title |
|---|---|
| `stage0_architect.md` | Stage 0 — Architect |
| `stage1_decomposer.md` | Stage 1 — Decomposer |
| `stage2_aligner.md` | Stage 2 — Aligner |
| `stage3_skeleton.md` | Stage 3 — Skeleton Builder |
| `stage4_filler.md` | Stage 4 — Tactic Filler |
| `stage5_verifier.md` | Stage 5 — Verifier |
| `stage6_linter.md` | Stage 6 — Linter |

---

## 5. Shell helpers

| Script | Purpose | Exit codes |
|---|---|---|
| `compile.sh <module>` or `-f <relpath>` | Wrap `lake env lean` / `lake build` for a single Generated module; captures stderr to stdout with `[stderr]` prefix; respects `COMPILE_TIMEOUT` (default 600 s) | 0=clean, 1=compile error, 2=usage, 124=timeout |
| `check_axioms.sh <relpath> <thm>` | Build module, write a temp file `#print axioms <thm>`, fail unless the printed axioms are a subset of `{propext, Classical.choice, Quot.sound}` (catches `sorryAx`, `Lean.ofReduceBool`, etc.) | 0=axiom-clean, 1=fail, 2=usage |
| `init_child.sh <child> <parent-run-dir>` | Tier-3 recursive-synthesis scaffold: create `Generated/<child>.lean` with placeholder header + `sorry`; create `<parent>/children/<child>/`; append `{"event":"descend",…}` to `<parent>/recursion_log.jsonl` | 0=ok, 1=usage/IO |

All three live in `lean/LeanAgent/scripts/` and prepend `~/.elan/bin` to `PATH`.

---

## 6. Honest capability assessment

### What the agent demonstrably can do (measured)

- **End-to-end formalize Layer-1 / Layer-2 single-file optlib theorems.** 7 of 8 attempted benchmark items reached `#print axioms` cleanliness (only `propext, Classical.choice, Quot.sound`). Mean line-count inflation vs optlib ≈ 1.48×.
- **Recover from mid-proof Mathlib gaps via Tier-3 recursive synthesis.** Item #04 was lifted from DEFERRED → CERTIFIED by spawning 3 child lemmas (depths 1, 1, 2). `recursion_log.jsonl` shows 3 descend / 3 certify, max depth 2, zero cycle/depth-limit refusals.
- **Reuse foundations across runs.** Item #07 was CERTIFIED in 25 lines because items #01 and #03 had been registered first — registry hit, not re-derivation.
- **Catch tactic-shape errors quickly.** Across 7 measured runs, 13 compile-fix rounds total; **all** were tactic-shape problems (wrong arg name, `simp` over-eager, `ring` on vector goal needing `abel`, etc.) — **zero** were proof-strategy failures.
- **Multi-route exploration pays off.** Item #03 via integral-FTC route → PARTIAL(4 STUCKs) in a prior session; same theorem via derivative-comparison route → CERTIFIED in this session. Same theorem, different route, different verdict.
- **Persist learning.** 8 lemma JSON files, 6 playbook entries, 5 failure entries, 14 NL↔Lean pairs accumulated and queryable.

### What it cannot do yet (also measured)

- **Multi-file decomposition.** Items 11, 12, 13 are pre-classified as needing a multi-file split (telescope sums, Lyapunov + extrapolation, 165–290 LOC bodies). The agent has no current implementation for this — `SUMMARY.md` calls this out as gap **G5** and the `DescentLemma/` directory's 5 identical un-filled-in stubs are the literal evidence: a multi-frame split was scaffolded once and abandoned.
- **Bridge optlib-only API surface.** Items 06 and 08 require lemmas that exist in optlib but not in Mathlib (`Convex_first_order_condition` in FDeriv form, `SubderivAt.add`, `convex_of_norm_sq`). The agent does not currently depend on optlib, and Mathlib-PR'ing the gaps is out of scope for the benchmark loop.
- **Discover non-obvious Mathlib chains autonomously.** Item #05 needed `IsMinOn.isLocalMin` → `IsLocalMin.fderiv_eq_zero`. `exact?` / `aesop` did not surface this directly; goal-pattern → API-surface indexing (gap **G1**) is not yet built.
- **Long `calc` chains.** Untested by the 7 measured runs; remains a known unknown.
- **Reach Layer 3 (`O(1/T)` rates).** 0/3 attempts. Blocked by multi-file decomposition above.

### Loose ends visible in the working tree

- `descent_lemma.lean` (1 sorry) and `descent_lemma_v2.lean` (4 sorries) are **abandoned** drafts — `descent_lemma_v3.lean` superseded them but the older files were never deleted.
- `DescentLemma/{Main,CauchySchwarzInner,FtcLineIntegral,IntegralTHalf,LipschitzPathBound}.lean` are 5 byte-identical stub files with `True`-placeholder bodies — the abandoned multi-route scaffold; they currently inflate the "0-sorry file" count without containing real proofs.
- Item #04's benchmark folder (`benchmark/optlib_test/04_strong_convex_lower/`) lacks `agent_output.lean` and `evaluation.md` even though `SUMMARY.md` and the registry both call it CERTIFIED. The proof artefacts exist (in `Generated/`), but the benchmark folder was not back-filled.
- `Generated/nonexistent_lemma_helper_depth1_idx1.lean` is a `n + 0 = n` toy from the 2026-04-29 graceful-failure test, not a real artefact.
