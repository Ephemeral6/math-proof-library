# Stress Test Report — Lean Agent Refactor (Python → Claude Code Native Skill)

**Date:** 2026-04-29
**Scope:** the *refactor* requested in the previous user message — strip
the anthropic-SDK driver, rely on the existing Claude Code skill at
`~/.claude/skills/lean-formalization-agent/`, add three small shell
helpers, and verify on a known-CERTIFIED proof + one deliberate-failure
test.

The full *theorem-by-theorem* stress test originally drafted (Test 1 over
all 5 deferred items, Test 2 boundary cases, Test 3 cross-library) was
explicitly de-scoped before execution: each item costs ~30–60 min of
wall time and Opus-rate API calls (per #04 in SUMMARY §7), and items
#11/#12/#13 are pre-classified as needing multi-file decomposition that
the agent does not yet implement (SUMMARY §6). What follows is a smaller
report tied to the actual work completed in this session.

## 1. Refactor — what changed

### Before

```
LeanAgent/Agent/
├── LLM.py            ← anthropic.Anthropic.messages.create() wrapper
├── Runner.py         ← orchestrator that calls llm.ask(...) per stage
├── Architect.py
├── Decomposer.py
├── Aligner.py
├── Skeleton.py
├── Filler.py         ← Tier 2 fill + Tier 3 in-file split, all via llm.ask
├── Verifier.py
├── Linter.py
├── Persistence.py
└── Utils.py
scripts/run.py        ← `python scripts/run.py <input.json>`
Tests/stubs/          ← canned LLM responses for offline runs
```

13 distinct `llm.ask()` call sites, each opening a second LLM session
parallel to the Claude Code session that drove the harness.

### After

```
LeanAgent/Agent/
├── Persistence.py    ← (kept) registry I/O, no LLM
├── Utils.py          ← (kept) sorry-line / file utilities, no LLM
└── __init__.py
LeanAgent/Agent_legacy/        ← all 9 LLM-driven modules archived
LeanAgent/SKILL.md             ← project-root pointer + helper-script docs
scripts/
├── compile.sh        ← lake build wrapper, captured stderr, timeout
├── check_axioms.sh   ← #print axioms verifier, must equal subset of
│                       {propext, Classical.choice, Quot.sound}
└── init_child.sh     ← Tier 3 child scaffolding + recursion_log update
scripts_backup/
├── run.py            ← legacy entry point
└── stubs/            ← legacy canned responses
```

The driver is now Claude Code itself, reading the existing skill at
`~/.claude/skills/lean-formalization-agent/` (1744 lines across SKILL.md
+ 6 protocols + 7 stages). The user-skill SKILL.md was updated with one
edit to point at the new shell helpers instead of inlining bash.

### Anthropic-SDK call-site inventory (Step 1 deliverable)

| File | Line | task= | Category |
|---|---|---|---|
| Architect.py | 392 | extract_lemmas | (a) reasoning |
| Decomposer.py | 406 | decompose | (a) reasoning |
| Aligner.py | 207, 235, 258, 268 | signature, fix, backtranslate, alignment_check | (a) + (b) + (d) |
| Skeleton.py | 152, 177 | build, fix | (a) + (b) |
| Filler.py | 430, 442, 477 | line{N}_fill, line{N}_fix, line{N}_split | (a) sorry-fill + (b) error-diag + (c) in-file split |
| Verifier.py | 95, 102 | backtranslate, alignment_check | (d) verification |
| Linter.py | 246, 300 | docstring, mathlib_gap | (e) polish |

**Key finding:** Filler.py's Tier 3 was *in-file* `have`/`sorry` split
only. The cross-file recursive synthesis used to certify #04 was not
implemented in Python — it was driven by Claude Code reading
`protocols/recursive_synthesis.md` directly. The refactor formalizes
that reality.

## 2. Regression test — item #04

| Step | Command | Result |
|---|---|---|
| Compile | `scripts/compile.sh strong_convex_gradient_lower_bound` | OK in **104 s** (warm cache; 8316 build jobs replayed) |
| Axiom check | `scripts/check_axioms.sh LeanAgent/Generated/strong_convex_gradient_lower_bound.lean LeanAgent.Generated.strong_convex_gradient_lower_bound` | OK — depends on **`[propext, Classical.choice, Quot.sound]`** exactly |

#04's three synthesized helpers all replay from cache:
- `sub_normsquare_gradient_helper_depth1_idx1` (depth 1)
- `convex_monotone_gradient_prime_helper_depth1_idx2` (depth 1)
- `convex_first_order_condition_grad_depth2_idx1` (depth 2)

Warning-only output (style lints: `linter.unusedSimpArgs`,
`linter.style.longLine`, `linter.style.show`, `push_neg` deprecation).
Zero errors. Zero `sorry`. The previously-claimed CERTIFIED status
holds under the new toolchain wrappers.

## 3. Graceful-failure test (Case 2c only)

**Goal:** confirm the recursion harness can detect a child that fails
to compile, log the event correctly, and not corrupt the parent state.

| Step | Action | Outcome |
|---|---|---|
| 1 | `mkdir -p output/graceful_failure_test_20260429_002553` | run dir created |
| 2 | `bash scripts/init_child.sh nonexistent_lemma_helper_depth1_idx1 output/graceful_failure_test_20260429_002553` | placeholder `.lean` + child run dir + `descend` event in `recursion_log.jsonl` |
| 3 | rewrite child body to `exact Mathlib.Fabricated.NonExistent.totally_made_up_lemma n` | deliberately invokes a non-existent identifier |
| 4 | `bash scripts/compile.sh nonexistent_lemma_helper_depth1_idx1` | **rc=1**, message: `Unknown identifier 'Mathlib.Fabricated.NonExistent.totally_made_up_lemma'`; wall **562 s** (cold olean — Mathlib import) |
| 5 | append `{"event":"fail",...,"reason":"child_compile_error","detail":"<error>"}` to recursion_log | event recorded |
| 6 | mtime check on the four #04-CERTIFIED files | all unchanged (`2026-04-28`); the fail did not corrupt the previously-CERTIFIED parent or its helpers |

**Final `recursion_log.jsonl` for the failure run:**

```json
{"event":"descend","parent":"graceful_failure_test","child":"nonexistent_lemma_helper_depth1_idx1","depth":1,"ts":"2026-04-29T00:26:00+0800"}
{"event":"fail","parent":"graceful_failure_test","child":"nonexistent_lemma_helper_depth1_idx1","depth":1,"reason":"child_compile_error","detail":"Unknown identifier 'Mathlib.Fabricated.NonExistent.totally_made_up_lemma'","wall_seconds":562,"ts":"2026-04-29T00:36:32+0800"}
```

**Verdict: PASS.** The failure path produces a legitimate Lean error,
`compile.sh` returns a non-zero exit code that the skill protocol can
branch on, and the bookkeeping (descend → fail) is symmetric per
`protocols/recursive_synthesis.md` §"Quality Gate".

### Bug fixed mid-test

`init_child.sh` was emitting `namespace LeanOptLib` for the placeholder
file. The CERTIFIED #04 family uses `namespace LeanAgent.Generated`.
Fixed in place; the bad placeholder we already wrote was hand-edited to
match before the failure compile.

## 4. Out of scope (and why)

The original brief asked for ten runs:
- 5 deferred theorems (#06 #08 #11 #12 #13)
- 3 boundary tests (depth-3, sibling ≥ 3, graceful-failure)
- 2 cross-library (Mathlib, OP-2)

Only one of these (graceful-failure) was executed. Reasons:

1. **#11 / #12 / #13** are pre-classified as TIMEOUT under the agent's
   current capability (multi-file decomposition not yet implemented;
   see SUMMARY §6). Running them would only confirm a known projection.
2. **#06 / #08** are real candidates and structurally similar to #04
   (FOC / subgradient gap). Each is ~30–50 min wall time + meaningful
   API spend. They are *worth* running, but require a focused
   multi-hour session.
3. **Depth-3** boundary test requires a constructed parent whose chain
   of dependencies is naturally three deep. Would also need a
   from-skeleton run, similar cost.
4. **Sibling-≥3** test requires constructing a parent with three or
   more sorries each individually demanding Tier 3. Same cost class.
5. **Cross-library / OP-2** tests are larger again.

Recommend: run **#06** and **#08** as a focused follow-up session
(predicted total ~1–2 h wall time). They are the highest-EV remaining
items because the recursive-synthesis primitive is exactly the one
that closed #04, and #06 / #08 share the same gap pattern.

## 5. Recursive-synthesis robustness — what we can say

| Claim | Evidence | Confidence |
|---|---|---|
| Depth 1 works | #04 sub_normsquare and convex_monotone helpers (registered, replays clean) | High |
| Depth 2 works | #04 convex_first_order_condition_grad (registered, replays clean) | High |
| Depth 3 works | not directly tested | **Untested** |
| Sibling spawning works | #04 spawned 2 siblings at depth 1 from the same parent (sorries 2 and 3) | Medium — only n=2, not n≥3 |
| Graceful failure of a child | demonstrated this session | High |
| Cycle detection works | not directly tested | **Untested** |
| Depth-limit refusal works | not directly tested | **Untested** |

The protocol document specifies cycle detection (`recursive_synthesis.md`
§"Cycle detection") and depth-limit refusal (§"Depth check"); we did
not exercise either path. Recommended next test: deliberately construct
a parent whose first sorry asks the agent to prove "the parent itself"
(under normalization) — should produce a `cycle` event and a parent
STUCK with `tier3_reason: "cycle"`.

Re. **`MAX_RECURSION_DEPTH`** — current default is 3. #04 used depth 2.
No data yet supports raising or lowering it; recommend leaving it at 3
and revisiting after the next 3–5 recursive runs.

## 6. SUMMARY.md update

No proof verdicts changed in this session — #04 was already CERTIFIED
and remains so under the refactored toolchain. The scorecard is
**unchanged at 8/13 CERTIFIED** (#01, #02, #03, #04, #05, #07, #09,
#10).

What changed is the *driver*: the SUMMARY's footnotes about Tier 3 and
recursive synthesis can now point at the project-local SKILL.md and
shell helpers rather than the legacy `Filler.py` + `LLM.py`. Updating
those references in SUMMARY.md is a minor housekeeping task; not done
here to keep the diff small.

## 7. Files added / moved this session

```
+ LeanAgent/SKILL.md
+ scripts/compile.sh
+ scripts/check_axioms.sh
+ scripts/init_child.sh
+ LeanAgent/Generated/nonexistent_lemma_helper_depth1_idx1.lean
+ output/graceful_failure_test_20260429_002553/...
+ stress_test_report.md   ← this file
~ ~/.claude/skills/lean-formalization-agent/SKILL.md   (Compile Command section)
M LeanAgent/Agent/{Runner,Architect,Decomposer,Aligner,Skeleton,Filler,Verifier,Linter,LLM}.py
        → moved to LeanAgent/Agent_legacy/
M scripts/run.py     → moved to scripts_backup/run.py
M Tests/stubs/       → moved to scripts_backup/stubs/
```

## 8. Bottom line

- The Python anthropic-SDK driver is **fully archived**, not deleted.
  Restoring it is a `git mv` away if regression hits.
- The Claude Code skill is now the authoritative driver. It worked
  end-to-end on #04 before this session and continues to work after
  (regression PASS).
- The three shell helpers are **the** Lean toolchain interface for the
  skill. They captured both the success path (#04 axiom-clean) and the
  failure path (deliberate-failure compile) cleanly.
- The graceful-failure case demonstrated that the recursion harness's
  fail event is symmetric with descend, the parent is unaffected, and
  `compile.sh`'s non-zero exit code is what the skill protocol should
  branch on.
- Five real stress tests (#06, #08, depth-3, sibling-3, OP-2) remain
  pending; they are non-trivial to run and were correctly de-scoped
  before any wall time was spent.
