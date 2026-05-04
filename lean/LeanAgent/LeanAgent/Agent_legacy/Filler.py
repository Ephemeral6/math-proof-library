"""
Stage 4 — Tactic Filler.

For each `sorry` in the skeleton file (in source order), try four tiers of
strategies:

  1. Auto-search tactics      — `exact?`, `apply?`, `simp`, `linarith`,
                                `ring`, `norm_num`, `omega`, `positivity`,
                                etc.
  2. LLM-generated tactic seq — given the goal state + the natural-language
                                step description, produce a tactic block.
                                Iterate up to 5 times on compile feedback.
  3. Recursive split          — split the current sorry into 2 have/sorry
                                sub-goals; the new sorries are picked up by
                                the next iteration of the outer loop.
                                Tracked recursion depth ≤ 3 per branch.
  4. STUCK                    — record the goal state + all attempts.
                                The sorry is annotated `-- STUCK_<n>` and
                                skipped on subsequent iterations so the
                                loop advances to the next sorry.

Each successful sorry replacement is rewritten in-place and the file is
recompiled before moving to the next sorry.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from . import Utils
from .LLM import LLM
from .Persistence import PersistenceManager


SKIP_MARKER = "STUCK_"


@dataclass
class SorryReport:
    line: int                       # line of this sorry at the moment of attempt
    description: str                # NL description from the step (if matched)
    closed: bool
    method: str                     # "auto:exact?" / "llm" / "split" / "stuck"
    tactic: str | None              # the tactic that closed it (if any)
    attempts: list[dict] = field(default_factory=list)
    goal_state: str | None = None
    depth: int = 0                  # recursion depth from a split


@dataclass
class FillerResult:
    success: bool                  # zero remaining (non-stuck) sorries
    lean_file: Path
    initial_sorry_count: int
    final_sorry_count: int
    closed: int
    stuck: int
    reports: list[SorryReport] = field(default_factory=list)


# --------------------------------------------------------------------------- #
# Auto-tactics catalog
# --------------------------------------------------------------------------- #

AUTO_TACTICS: list[tuple[str, str]] = [
    ("trivial",    "trivial"),
    ("rfl",        "rfl"),
    ("exact?",     "exact?"),
    ("apply?",     "apply?"),
    ("simp",       "simp"),
    ("simp_all",   "simp_all"),
    ("aesop",      "aesop"),
    ("linarith",   "linarith"),
    ("nlinarith",  "nlinarith"),
    ("ring",       "ring"),
    ("ring_nf",    "ring_nf"),
    ("norm_num",   "norm_num"),
    ("omega",      "omega"),
    ("positivity", "positivity"),
    ("field_simp", "field_simp"),
    ("decide",     "decide"),
]


# --------------------------------------------------------------------------- #
# Prompts
# --------------------------------------------------------------------------- #

LLM_FILL_SYSTEM = """\
You are a Lean 4 / Mathlib expert closing a single `sorry` in a proof.
You will be given the full current Lean file and the natural-language
description of the step you must prove.

Output rules:
  * Output ONE Lean code block fenced ```lean ... ```.
  * The block must contain ONLY the tactic sequence that replaces `sorry`,
    NOT the whole file.
  * The tactic sequence may be a single tactic (`linarith`) or a multi-line
    tactic block — but it must close exactly the current goal.
  * Prefer concise, idiomatic Mathlib tactics. Do not introduce `sorry`.
  * Do not output explanations.
"""

LLM_FILL_PROMPT = """\
Current Lean file:
```lean
{file_text}
```

The next `sorry` to close is on line {line}. Its informal description is:

    {description}

Goal state at that point (compiler output):
{goal_state}

Provide the tactic block that replaces `sorry` (only the tactic, no `by`).
"""

LLM_FIX_FILL_SYSTEM = """\
You are debugging a Lean tactic. The previous attempt failed to compile.
Provide a corrected tactic block that replaces the SAME `sorry`. Output
only the tactic block in a ```lean``` fence; no explanations.
"""

LLM_FIX_FILL_PROMPT = """\
Current Lean file:
```lean
{file_text}
```

The previous attempt to fill the `sorry` on line {line} produced these
errors:

{errors_block}

The informal step description is: {description}

Provide a corrected tactic block.
"""

LLM_SPLIT_SYSTEM = """\
You are a Lean 4 expert. You cannot close the current goal directly, so
split it into two intermediate `have` lemmas and reduce the original goal
to a combination of them.

Output rules:
  * Output ONE Lean code block.
  * The block contains exactly two `have` lines:
        have h_left  : <type> := by sorry
        have h_right : <type> := by sorry
    followed by ONE closing tactic that finishes the goal using h_left and
    h_right (e.g. `linarith`, `exact ...`, `calc ...`).
  * Do not include `by` at the start; this snippet replaces a `sorry`
    inside an existing `by` block.
"""

LLM_SPLIT_PROMPT = """\
Current Lean file:
```lean
{file_text}
```

The `sorry` on line {line} cannot be closed directly. Goal state:
{goal_state}

Informal description: {description}

Split it into two `have` lemmas + a closing tactic.
"""


# --------------------------------------------------------------------------- #
# Helpers
# --------------------------------------------------------------------------- #

_CODE_FENCE_RE = re.compile(r"```(?:lean|lean4)?\s*\n(.*?)```", re.DOTALL)


def _extract_code(text: str) -> str:
    m = _CODE_FENCE_RE.search(text)
    if m:
        return m.group(1).strip() + "\n"
    return text.strip() + "\n"


def _format_errors(errors: list[dict], limit: int = 6) -> str:
    if not errors:
        return "(none)"
    return "\n".join(
        f"- line {e['line']}, col {e['col']}: {e['message'].splitlines()[0]}"
        for e in errors[:limit]
    )


def _goal_state_for_line(lean_file: Path, target_line: int) -> str | None:
    res = Utils.compile_lean(lean_file)
    candidates = [d for d in (res.warnings + res.errors)
                  if d["line"] == target_line]
    if candidates:
        return candidates[0]["message"]
    for d in res.warnings + res.errors:
        if "unsolved goals" in d["message"] or "declaration uses 'sorry'" in d["message"]:
            return d["message"]
    return None


def _step_for_line(lean_file: Path, line: int) -> str:
    """Read the `-- step N: ...` comment immediately preceding the line."""
    text = Utils.read_text(lean_file).splitlines()
    idx = max(0, line - 1)
    for k in range(idx, max(-1, idx - 5), -1):
        line_text = text[k] if 0 <= k < len(text) else ""
        m = re.match(r"\s*--\s*step\s+\d+\s*:\s*(.*)", line_text)
        if m:
            return m.group(1).strip()
    return text[idx].strip() if 0 <= idx < len(text) else ""


def _has_search_suggestion(res) -> bool:
    """Detect `apply?`/`exact?`/`hint`-style "Try this:" output that signals
    the tactic was a search that didn't actually close the goal."""
    haystack = (res.stdout or "") + "\n" + (res.stderr or "")
    return "Try this:" in haystack or "found a partial proof" in haystack


def _has_implicit_sorry_warning(res) -> bool:
    """Detect Lean's `declaration uses 'sorry'` warning."""
    return any(
        "declaration uses 'sorry'" in (w.get("message") or "")
        for w in res.warnings
    )


def _try_replace_first_active_sorry(
    lean_file: Path,
    replacement_tactic: str,
    *,
    expect_no_new_sorry: bool = True,
) -> tuple[bool, Any]:
    """Backup, replace first non-skipped sorry, recompile. Restore on failure.

    A replacement is accepted only when ALL of these hold:
      * The file compiles with returncode 0 and no errors.
      * The text-sorry count strictly dropped (unless the caller asked us to
        permit new sorries via `expect_no_new_sorry=False`, used by the
        split tier).
      * No "Try this:" / "found a partial proof" is in the compiler output
        (those indicate `apply?` / `exact?` failed to close).
      * If after substitution the text-sorry count is 0, then the
        "declaration uses 'sorry'" warning must also be gone — otherwise
        the tactic introduced an implicit sorry.
    """
    original = Utils.read_text(lean_file)
    sorries_before = len(Utils.find_sorry_lines(lean_file, skip_markers=[SKIP_MARKER]))
    if not Utils.replace_first_sorry(
        lean_file, replacement_tactic, skip_markers=[SKIP_MARKER]
    ):
        return False, None
    res = Utils.compile_lean(lean_file)
    sorries_after = len(Utils.find_sorry_lines(lean_file, skip_markers=[SKIP_MARKER]))

    rejected = False
    reason = ""
    if not res.success:
        rejected, reason = True, "compile_failed"
    elif expect_no_new_sorry and sorries_after >= sorries_before:
        rejected, reason = True, "did_not_drop_sorry"
    elif _has_search_suggestion(res):
        rejected, reason = True, "search_suggestion_only"
    elif sorries_after == 0 and _has_implicit_sorry_warning(res):
        rejected, reason = True, "implicit_sorry_remains"

    if rejected:
        # restore
        Utils.write_text(lean_file, original)
        if res is not None:
            # annotate the compile result with the reject reason for the report
            res.errors = list(res.errors) + [{
                "file": str(lean_file), "line": 0, "col": 0,
                "severity": "error",
                "message": f"[Filler reject: {reason}]",
            }]
        return False, res
    return True, res


# --------------------------------------------------------------------------- #
# Top-level loop
# --------------------------------------------------------------------------- #

def run_filler(
    lean_file: Path | str,
    *,
    steps: list[dict],
    llm: LLM,
    max_llm_rounds: int = 5,
    max_split_depth: int = 3,
    max_iterations: int = 64,
    persistence: PersistenceManager | None = None,
) -> FillerResult:
    lean_file = Path(lean_file)
    initial_count = Utils.count_sorries(lean_file)
    reports: list[SorryReport] = []

    # Track recursion depth per "branch" of split. We approximate by tagging
    # newly-introduced sorries via the depth of the closure that produced them.
    # In practice the simple counter on STUCK markers + the iteration cap is
    # enough for the MVP.
    iteration = 0
    stuck_count = 0
    while iteration < max_iterations:
        iteration += 1
        active = Utils.find_sorry_lines(lean_file, skip_markers=[SKIP_MARKER])
        if not active:
            break
        line = active[0]
        description = _step_for_line(lean_file, line)
        goal_state = _goal_state_for_line(lean_file, line)
        rep = SorryReport(
            line=line,
            description=description,
            closed=False,
            method="stuck",
            tactic=None,
            goal_state=goal_state,
        )

        closed = _close_one_sorry(
            lean_file,
            description=description,
            goal_state=goal_state,
            llm=llm,
            max_llm_rounds=max_llm_rounds,
            max_split_depth=max_split_depth,
            report=rep,
            persistence=persistence,
        )

        if not closed:
            stuck_count += 1
            tag = f"{SKIP_MARKER}{stuck_count}"
            Utils.mark_first_sorry_stuck(
                lean_file, tag=tag, skip_markers=[SKIP_MARKER]
            )
            rep.method = "stuck"

        reports.append(rep)

    # Final stats
    closed_count = sum(1 for r in reports if r.closed)
    stuck_total = sum(1 for r in reports if not r.closed)
    final_count = Utils.count_sorries(lean_file)
    return FillerResult(
        success=(stuck_total == 0 and final_count == 0),
        lean_file=lean_file,
        initial_sorry_count=initial_count,
        final_sorry_count=final_count,
        closed=closed_count,
        stuck=stuck_total,
        reports=reports,
    )


def _close_one_sorry(
    lean_file: Path,
    *,
    description: str,
    goal_state: str | None,
    llm: LLM,
    max_llm_rounds: int,
    max_split_depth: int,
    report: SorryReport,
    persistence: PersistenceManager | None = None,
) -> bool:
    # Tier 0: playbook lookup — replay tactics that closed similar goals.
    if persistence is not None and goal_state:
        for hit in persistence.search_playbook(goal_state, top_k=3):
            tac = hit.get("tactic")
            if not tac:
                continue
            ok, res = _try_replace_first_active_sorry(lean_file, tac)
            attempt = {
                "tier": "playbook",
                "tactic": tac[:120],
                "ok": ok,
                "domain": hit.get("domain"),
            }
            if res and not ok:
                attempt["errors"] = [
                    e["message"].splitlines()[0] for e in res.errors[:2]
                ]
            report.attempts.append(attempt)
            if ok:
                report.closed = True
                report.method = f"playbook:{hit.get('domain', '?')}"
                report.tactic = tac
                return True

    # Tier 1: auto-tactics
    for name, tactic in AUTO_TACTICS:
        ok, res = _try_replace_first_active_sorry(lean_file, tactic)
        attempt = {
            "tier": "auto",
            "tactic": name,
            "ok": ok,
        }
        if res and not ok:
            attempt["errors"] = [
                e["message"].splitlines()[0] for e in res.errors[:2]
            ]
        report.attempts.append(attempt)
        if ok:
            report.closed = True
            report.method = f"auto:{name}"
            report.tactic = tactic
            return True

    # Tier 2: LLM tactic
    sorry_lines = Utils.find_sorry_lines(lean_file, skip_markers=[SKIP_MARKER])
    line = sorry_lines[0] if sorry_lines else 0

    last_errors: list[dict] = []
    for round_idx in range(max_llm_rounds):
        try:
            if round_idx == 0:
                resp = llm.ask(
                    stage="filler",
                    task=f"line{line}_fill",
                    prompt=LLM_FILL_PROMPT.format(
                        file_text=Utils.read_text(lean_file),
                        line=line,
                        description=description,
                        goal_state=goal_state or "(unavailable)",
                    ),
                    system=LLM_FILL_SYSTEM,
                )
            else:
                resp = llm.ask(
                    stage="filler",
                    task=f"line{line}_fix",
                    prompt=LLM_FIX_FILL_PROMPT.format(
                        file_text=Utils.read_text(lean_file),
                        line=line,
                        description=description,
                        errors_block=_format_errors(last_errors),
                    ),
                    system=LLM_FIX_FILL_SYSTEM,
                    attempt=round_idx,
                )
        except KeyError:
            report.attempts.append({"tier": "llm", "round": round_idx,
                                    "skipped": "no_stub"})
            break
        tactic = _extract_code(resp.text).strip()
        ok, res = _try_replace_first_active_sorry(lean_file, tactic)
        report.attempts.append({
            "tier": "llm",
            "round": round_idx,
            "ok": ok,
            "tactic": tactic[:200],
            "errors": [e["message"].splitlines()[0] for e in (res.errors if res else [])][:3],
        })
        if ok:
            report.closed = True
            report.method = "llm"
            report.tactic = tactic
            return True
        last_errors = res.errors if res else []

    # Tier 3: split
    if max_split_depth > 0:
        try:
            split_resp = llm.ask(
                stage="filler",
                task=f"line{line}_split",
                prompt=LLM_SPLIT_PROMPT.format(
                    file_text=Utils.read_text(lean_file),
                    line=line,
                    goal_state=goal_state or "(unavailable)",
                    description=description,
                ),
                system=LLM_SPLIT_SYSTEM,
            )
        except KeyError:
            report.attempts.append({"tier": "split", "skipped": "no_stub"})
            split_resp = None
        if split_resp is not None:
            split_block = _extract_code(split_resp.text).strip()
            ok, res = _try_replace_first_active_sorry(
                lean_file, split_block, expect_no_new_sorry=False
            )
            report.attempts.append({
                "tier": "split",
                "ok": ok,
                "block": split_block[:200],
                "errors": [e["message"].splitlines()[0] for e in (res.errors if res else [])][:3],
            })
            if ok:
                report.closed = True
                report.method = "split"
                report.tactic = split_block
                return True

    # Tier 4: stuck
    report.method = "stuck"
    return False
