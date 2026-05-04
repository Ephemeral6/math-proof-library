"""
Stage 3 — Skeleton Builder.

Input : a `.lean` file from Stage 2 with `theorem ... := by sorry`,
        plus the JSON `steps` list describing the atomic proof plan.
Output: same file rewritten so the `by sorry` body is replaced by a chain
        of `have h{id} : <type> := by sorry` lines (one per step) and a
        final `exact?-style` conclusion that compiles (with sorry warnings).

The intermediate goal types are produced by the LLM. Each `have` line is
prefixed by a `-- step {id}: {description}` comment so a human reviewer can
trace which natural-language step corresponds to which Lean fragment.

We iterate: compile, if there are type errors on a `have` line, ask the LLM
to fix the type. Up to N rounds.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from . import Utils
from .LLM import LLM


@dataclass
class SkeletonResult:
    success: bool
    lean_file: Path
    iterations: int
    sorry_count: int
    history: list[dict] = field(default_factory=list)


# --------------------------------------------------------------------------- #
# Prompts
# --------------------------------------------------------------------------- #

SKELETON_SYSTEM = """\
You are a Lean 4 / Mathlib expert. You will be given a Lean theorem
signature and a sequence of natural-language proof steps. Your job is to
produce a `have`-chain skeleton: one `have h{id} : <Lean type> := by sorry`
per step, finishing with a single tactic line that combines them to close
the goal.

Output rules:
  * Output ONE Lean code block.
  * Keep all imports / opens / variable declarations / namespace from the
    input file unchanged.
  * Replace the existing `by sorry` body with `by` followed by the
    `have`-chain.
  * Each `have` line should be preceded by a comment of the form
    `-- step {id}: {description}` (truncate description if too long).
  * Use `sorry` (NOT `by exact?`) as the body of every `have`.
  * After all `have`s, write a single `exact ?` style closing line. If
    unsure, just write `sorry` as the very last line — that's allowed.
  * Use Mathlib idioms; reference imported names exactly. Do NOT introduce
    new imports unless necessary; if you must, add them at the top.
  * The intermediate types should match the natural-language description;
    pick reasonable Lean encodings (Set.Icc, ∫ in Mathlib, etc.).
"""

SKELETON_PROMPT = """\
=== Existing Lean file ===
```lean
{file_text}
```

=== Proof steps ===
{steps_block}

Produce the rewritten Lean file with the `have`-chain skeleton.
"""

FIX_SKELETON_SYSTEM = """\
You are a Lean 4 / Mathlib expert. The Lean skeleton below fails to compile.
Fix the file. Each `have` body must remain `by sorry`; you may only adjust
the *types* of the `have`s, the imports, or the closing line.
"""

FIX_SKELETON_PROMPT = """\
=== File ===
```lean
{file_text}
```

=== Compiler errors ===
{errors_block}

Return the corrected file.
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


def _format_steps(steps: list[dict]) -> str:
    out = []
    for s in steps:
        uses = ", ".join(f"h{u}" for u in s.get("uses", [])) or "—"
        ext = s.get("external_theorem")
        ext_str = f" [external: {ext}]" if ext else ""
        out.append(
            f"step {s['id']}  (method={s['method']}, uses={uses}){ext_str}\n"
            f"    {s['description']}"
        )
    return "\n".join(out)


def _format_errors(errors: list[dict], limit: int = 10) -> str:
    lines = []
    for e in errors[:limit]:
        lines.append(f"- line {e['line']}, col {e['col']} [{e['severity']}]: {e['message']}")
    if len(errors) > limit:
        lines.append(f"- (+{len(errors) - limit} more)")
    return "\n".join(lines) if lines else "(none)"


# --------------------------------------------------------------------------- #
# Entry
# --------------------------------------------------------------------------- #

def run_skeleton(
    lean_file: Path | str,
    *,
    steps: list[dict],
    llm: LLM,
    max_fix_rounds: int = 10,
) -> SkeletonResult:
    lean_file = Path(lean_file)
    history: list[dict] = []

    file_text = Utils.read_text(lean_file)
    prompt = SKELETON_PROMPT.format(
        file_text=file_text,
        steps_block=_format_steps(steps),
    )
    resp = llm.ask(stage="skeleton", task="build", prompt=prompt,
                   system=SKELETON_SYSTEM)
    code = _extract_code(resp.text)
    Utils.write_text(lean_file, code)
    history.append({"step": "build", "provider": resp.provider})

    iterations = 0
    last = None
    for attempt in range(max_fix_rounds + 1):
        iterations += 1
        last = Utils.compile_lean(lean_file)
        if last.success:
            history.append({"step": f"compile_ok@{iterations}",
                            "warnings": len(last.warnings)})
            break
        history.append({
            "step": f"compile_fail@{iterations}",
            "errors": [e["message"].splitlines()[0] for e in last.errors[:3]],
        })
        if attempt >= max_fix_rounds:
            break
        fix_prompt = FIX_SKELETON_PROMPT.format(
            file_text=Utils.read_text(lean_file),
            errors_block=_format_errors(last.errors),
        )
        fix_resp = llm.ask(
            stage="skeleton",
            task="fix",
            prompt=fix_prompt,
            system=FIX_SKELETON_SYSTEM,
            attempt=attempt + 1,
        )
        code = _extract_code(fix_resp.text)
        Utils.write_text(lean_file, code)

    success = last is not None and last.success
    return SkeletonResult(
        success=success,
        lean_file=lean_file,
        iterations=iterations,
        sorry_count=Utils.count_sorries(lean_file) if lean_file.exists() else -1,
        history=history,
    )
