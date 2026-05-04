"""
Stage 2 — Aligner.

Input : JSON spec (theorem_name, theorem_nl, assumptions, conclusion).
Output: A `.lean` file with the imports + theorem signature + `sorry` body
        that compiles cleanly.

Pipeline:
  1. Ask the LLM to produce a Lean signature (imports, `theorem ... := by sorry`).
  2. Write the file.
  3. `lake env lean` it.
  4. If errors → feed the error message back, ask for a fix. Up to N rounds.
  5. Once compiling, ask the LLM to back-translate the Lean statement to NL.
  6. Compare back-translation with the original NL. If divergent → fix.

The LLM responses are keyed (stage="aligner", task="signature" / "fix" /
"backtranslate") so the stub registry can serve them in offline mode.

The Aligner returns an `AlignerResult` describing the final file path,
iterations used, and a back-translation comparison.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from . import Utils
from .LLM import LLM


# --------------------------------------------------------------------------- #
# Result types
# --------------------------------------------------------------------------- #

@dataclass
class AlignerResult:
    success: bool
    lean_file: Path
    iterations: int
    final_signature: str
    back_translation: str | None
    nl_alignment_ok: bool
    history: list[dict] = field(default_factory=list)


# --------------------------------------------------------------------------- #
# Prompts
# --------------------------------------------------------------------------- #

SIGNATURE_SYSTEM = """\
You are a Lean 4 / Mathlib expert. Translate natural-language theorem
statements into clean Lean 4 + Mathlib syntax.

Output rules:
  * Output ONE Lean code block fenced with ```lean ... ```.
  * The block must contain: necessary `import` lines, optional `open` lines,
    and exactly ONE `theorem` declaration whose body is `by sorry`.
  * Use the most general typeclass abstractions available in Mathlib.
  * Do NOT prove anything — the body MUST be `by sorry`.
  * Do not include explanations outside the code block.
"""

SIGNATURE_PROMPT = """\
Translate the following theorem into a Lean 4 + Mathlib signature.

Theorem name: {theorem_name}

Assumptions:
{assumptions_block}

Conclusion:
{conclusion}

Natural-language statement (informal):
{theorem_nl}

Produce a single Lean 4 file (imports + signature + `by sorry`).
"""

FIX_SYSTEM = """\
You are a Lean 4 / Mathlib expert. Given a Lean file that fails to compile
plus the compiler error messages, fix the file.

Output rules:
  * Output ONE Lean code block (```lean ... ```).
  * The body of the theorem must remain `by sorry` (we are only fixing the
    signature, not the proof).
  * If imports are missing, add them.
  * Make minimum changes; preserve the theorem name and assumption naming
    where possible.
"""

FIX_PROMPT = """\
The Lean file below does not compile. Fix it.

=== File ({lean_path}) ===
```lean
{file_text}
```

=== Compiler errors ===
{errors_block}

Return the full corrected file in one ```lean``` block.
"""

BACKTRANSLATE_SYSTEM = """\
You are a careful mathematician. Given a Lean 4 theorem signature, write
a one-paragraph natural-language statement that captures EXACTLY what the
Lean theorem says (no more, no less).
"""

BACKTRANSLATE_PROMPT = """\
Lean theorem (signature only):
```lean
{signature}
```

Write a single English paragraph describing the assumptions and conclusion
in mathematical language.
"""

ALIGN_CHECK_SYSTEM = """\
You are comparing two natural-language statements of a theorem. Decide
whether they describe the same mathematical claim.
"""

ALIGN_CHECK_PROMPT = """\
Original informal statement:
{original}

Back-translation from Lean:
{backtranslation}

Answer with one line:
  ALIGNED   — if the two say the same thing
  DIVERGENT — if they differ in any meaningful way
followed by a one-line explanation.
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


def _format_errors(errors: list[dict], limit: int = 10) -> str:
    lines = []
    for e in errors[:limit]:
        loc = f"line {e['line']}, col {e['col']}" if e["line"] else "?"
        lines.append(f"- [{e['severity']}] {loc}: {e['message']}")
    if len(errors) > limit:
        lines.append(f"- (+{len(errors) - limit} more errors)")
    return "\n".join(lines) if lines else "(no errors reported)"


def _format_assumptions(assumptions: list[str]) -> str:
    return "\n".join(f"  - {a}" for a in assumptions) or "  (none)"


# --------------------------------------------------------------------------- #
# Main entry
# --------------------------------------------------------------------------- #

def run_aligner(
    spec: dict,
    *,
    output_dir: Path,
    llm: LLM,
    max_fix_rounds: int = 10,
    max_align_rounds: int = 2,
    lean_file_override: Path | str | None = None,
) -> AlignerResult:
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    theorem_name = spec["theorem_name"]
    if lean_file_override is not None:
        lean_file = Path(lean_file_override)
        if not lean_file.is_absolute():
            lean_file = Utils.project_root() / lean_file
    else:
        lean_file = Utils.generated_dir() / f"{theorem_name}.lean"
    lean_file.parent.mkdir(parents=True, exist_ok=True)

    history: list[dict] = []

    # 1. initial signature
    prompt = SIGNATURE_PROMPT.format(
        theorem_name=theorem_name,
        assumptions_block=_format_assumptions(spec.get("assumptions", [])),
        conclusion=spec.get("conclusion", ""),
        theorem_nl=spec.get("theorem_nl", ""),
    )
    resp = llm.ask(stage="aligner", task="signature", prompt=prompt,
                   system=SIGNATURE_SYSTEM)
    code = _extract_code(resp.text)
    Utils.write_text(lean_file, code)
    history.append({"step": "initial_signature", "provider": resp.provider})

    # 2. compile-fix loop
    iterations = 0
    last_compile = None
    for attempt in range(max_fix_rounds + 1):
        iterations += 1
        last_compile = Utils.compile_lean(lean_file)
        if last_compile.success:
            history.append({"step": f"compile_ok@{iterations}",
                            "warnings": len(last_compile.warnings)})
            break
        history.append({
            "step": f"compile_fail@{iterations}",
            "errors": [e["message"].splitlines()[0] for e in last_compile.errors[:3]],
        })
        if attempt >= max_fix_rounds:
            break
        # ask for a fix
        fix_prompt = FIX_PROMPT.format(
            lean_path=lean_file.name,
            file_text=Utils.read_text(lean_file),
            errors_block=_format_errors(last_compile.errors),
        )
        fix_resp = llm.ask(
            stage="aligner",
            task="fix",
            prompt=fix_prompt,
            system=FIX_SYSTEM,
            attempt=attempt + 1,
        )
        code = _extract_code(fix_resp.text)
        Utils.write_text(lean_file, code)

    if last_compile is None or not last_compile.success:
        return AlignerResult(
            success=False,
            lean_file=lean_file,
            iterations=iterations,
            final_signature=Utils.read_text(lean_file),
            back_translation=None,
            nl_alignment_ok=False,
            history=history,
        )

    # 3. back-translation check
    signature_text = Utils.read_text(lean_file)
    bt_resp = llm.ask(
        stage="aligner",
        task="backtranslate",
        prompt=BACKTRANSLATE_PROMPT.format(signature=signature_text),
        system=BACKTRANSLATE_SYSTEM,
    )
    back_translation = bt_resp.text.strip()
    history.append({"step": "back_translation",
                    "provider": bt_resp.provider})

    align_resp = llm.ask(
        stage="aligner",
        task="alignment_check",
        prompt=ALIGN_CHECK_PROMPT.format(
            original=spec.get("theorem_nl", ""),
            backtranslation=back_translation,
        ),
        system=ALIGN_CHECK_SYSTEM,
    )
    verdict_line = align_resp.text.strip().splitlines()[0] if align_resp.text.strip() else ""
    aligned = verdict_line.upper().startswith("ALIGNED")
    history.append({"step": "alignment_check", "verdict": verdict_line})

    return AlignerResult(
        success=True,
        lean_file=lean_file,
        iterations=iterations,
        final_signature=signature_text,
        back_translation=back_translation,
        nl_alignment_ok=aligned,
        history=history,
    )
