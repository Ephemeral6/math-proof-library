# Lean Formalization Agent — Project README / Skill Pointer

This project is the working directory for the `lean-formalization-agent`
Claude Code skill.  The agent is **Claude Code itself** — there is no
external LLM driver any more.  The Python pipeline that used to live in
`LeanAgent/Agent/{Architect,Decomposer,Aligner,Skeleton,Filler,Verifier,Linter,LLM,Runner}.py`
has been archived under `LeanAgent/Agent_legacy/`; the legacy `scripts/run.py`
and `Tests/stubs/` are under `scripts_backup/`.

## Where the skill lives

`~/.claude/skills/lean-formalization-agent/` (user-skills directory):

```
SKILL.md                                      ← orchestrator
protocols/{compile_fix_loop,                  ← reusable sub-procedures
           mathlib_search,
           per_lemma_loop,
           persistence,
           quality_gates,
           recursive_synthesis}.md
stages/{stage0_architect, stage1_decomposer,  ← per-stage instructions
        stage2_aligner,   stage3_skeleton,
        stage4_filler,    stage5_verifier,
        stage6_linter}.md
templates/                                    ← input-spec / feedback formats
```

When the user asks for Lean formalization, Claude Code reads those files
**at run time** (not from training memory) and follows the documented
flow.  The skill calls the helper scripts in `scripts/` (this directory)
for every Lean compile and axiom check — it does **not** invoke any LLM
of its own.

## Helper scripts (all under `scripts/`)

| Script | Purpose | Exit codes |
|---|---|---|
| `compile.sh <module>` (or `-f <path>`) | Build a `LeanAgent.Generated.*` module via `lake build`, or a single file via `lake env lean`. Captures stderr to stdout. Honors `COMPILE_TIMEOUT` (default 600s). | 0 ok / 1 fail / 2 usage / 124 timeout |
| `check_axioms.sh <lean-path> <theorem>` | Build the module, then run `#print axioms` in a probe file and verify the printed list is a subset of `{propext, Classical.choice, Quot.sound}`. | 0 clean / 1 fail / 2 usage |
| `init_child.sh <child-name> <parent-run-dir>` | For Tier 3 recursive synthesis: scaffold `LeanAgent/Generated/<child>.lean` (placeholder signature + `sorry`), create `<parent-run-dir>/children/<child>/input.json`, and append a `{"event":"descend",...}` line to the parent's `recursion_log.jsonl`. | 0 ok / 1 usage or IO error |

The scripts are deliberately small and have no Python / LLM dependency.
They read no config; everything is positional.

## The remaining Python (kept on purpose)

Two non-LLM modules in `LeanAgent/Agent/` are still useful as utilities and
were **not** archived:

- `Persistence.py` — manages `registry/` (lemmas, playbook, failures, pairs).
  The skill's `protocols/persistence.md` documents the same on-disk schema;
  Claude Code can write directly to those files OR `import` this module from
  a one-off Python helper if a batch operation is faster.
- `Utils.py` — `find_sorry_lines`, `read_text`, etc.  Pure file/text
  helpers; the skill mostly reaches for `Read`/`Edit`/`Grep` instead, but
  these are kept for any future scripted use.

If you want to reuse them, run `python -c "from LeanAgent.Agent import Utils; …"`
from the project root.

## Working directories

```
~/Desktop/Math/lean/LeanAgent/
├── lakefile.toml                 ← Mathlib v4.30.0-rc2
├── lean-toolchain                ← leanprover/lean4:v4.30.0-rc2
├── scripts/                      ← compile.sh, check_axioms.sh, init_child.sh
├── scripts_backup/               ← legacy run.py, Tests/stubs/
├── LeanAgent/
│   ├── Agent/                    ← Persistence.py, Utils.py only
│   ├── Agent_legacy/             ← Runner.py, Architect.py, … (anthropic-SDK callers)
│   └── Generated/                ← certified Lean files, one lemma per file
├── benchmark/optlib_test/        ← 13-item benchmark + SUMMARY.md
├── output/<theorem>_<ts>/        ← per-run artifacts (blueprint, child run dirs,
│                                   recursion_log.jsonl, …)
└── registry/                     ← lemmas/, playbook/, failures/, pairs/
```

## Quick verification

To confirm the toolchain is alive without spending an LLM call:

```bash
scripts/compile.sh strong_convex_gradient_lower_bound
scripts/check_axioms.sh \
    LeanAgent/Generated/strong_convex_gradient_lower_bound.lean \
    LeanOptLib.strong_convex_gradient_lower_bound
```

Both should exit 0; the second prints the axiom list from the
already-CERTIFIED #04 proof.

## Why the rewrite

`LeanAgent/Agent_legacy/LLM.py` opened a second LLM session via the
`anthropic` SDK in addition to the Claude Code session that drove the
agent — two LLM workers with no shared context.  The skill formulation
folds the second worker into the first: the same Claude Code session that
reads `SKILL.md` also reads the sorry skeleton, reasons about tactics,
and edits the Lean files.  Recursive synthesis works the same way — the
skill protocol tells Claude Code when to descend, and `init_child.sh`
provides the bookkeeping.
