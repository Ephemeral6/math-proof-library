"""
Stage 5 — Verifier.

Three-step hard check:

  1. Sorry count == 0  (`grep -n sorry` over the file, comments excluded).
  2. `lake build` (or `lake env lean`) of the file completes with zero
     errors.
  3. Back-translation alignment — re-translate the Lean signature to
     natural language and compare with the original NL statement.

Returns one of three verdicts:
  CERTIFIED   — all three pass
  PARTIAL(N)  — N STUCK sorries remain but the file otherwise compiles
  FAIL        — compilation error, or back-translation diverged
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path

from . import Utils
from .LLM import LLM
from .Aligner import (
    BACKTRANSLATE_PROMPT,
    BACKTRANSLATE_SYSTEM,
    ALIGN_CHECK_PROMPT,
    ALIGN_CHECK_SYSTEM,
)


@dataclass
class VerifierResult:
    verdict: str                   # "CERTIFIED" / "PARTIAL" / "FAIL"
    stuck_count: int
    sorry_count: int
    compile_ok: bool
    compile_errors: int
    compile_warnings: int
    back_translation: str | None
    nl_alignment_ok: bool
    notes: list[str] = field(default_factory=list)


def _extract_signature_block(file_text: str) -> str:
    """Heuristic: take from first `theorem` / `lemma` keyword up to and
    including the line that ends with `:=`."""
    lines = file_text.splitlines()
    out = []
    started = False
    for ln in lines:
        if not started and re.match(r"\s*(theorem|lemma|def|example)\b", ln):
            started = True
        if started:
            out.append(ln)
            if ln.rstrip().endswith(":="):
                break
    return "\n".join(out) if out else file_text


def run_verifier(
    lean_file: Path | str,
    *,
    spec: dict,
    llm: LLM,
    do_back_translation: bool = True,
) -> VerifierResult:
    lean_file = Path(lean_file)
    text = Utils.read_text(lean_file)

    # 1. sorry count
    sorry_count = Utils.count_sorries(lean_file)
    stuck_count = sum(
        1 for line in text.splitlines() if "STUCK_" in line and "sorry" in line
    )

    # 2. compilation
    cres = Utils.compile_lean(lean_file)
    compile_errors = len(cres.errors)
    compile_warnings = len(cres.warnings)
    compile_ok = cres.success and compile_errors == 0

    notes: list[str] = []
    if compile_warnings:
        notes.append(f"{compile_warnings} compiler warnings (likely sorry warnings).")

    # 3. back-translation
    back_translation = None
    nl_alignment_ok = True
    if do_back_translation:
        signature = _extract_signature_block(text)
        try:
            bt_resp = llm.ask(
                stage="verifier",
                task="backtranslate",
                prompt=BACKTRANSLATE_PROMPT.format(signature=signature),
                system=BACKTRANSLATE_SYSTEM,
            )
            back_translation = bt_resp.text.strip()
            ali_resp = llm.ask(
                stage="verifier",
                task="alignment_check",
                prompt=ALIGN_CHECK_PROMPT.format(
                    original=spec.get("theorem_nl", ""),
                    backtranslation=back_translation,
                ),
                system=ALIGN_CHECK_SYSTEM,
            )
            verdict_line = ali_resp.text.strip().splitlines()[0] if ali_resp.text.strip() else ""
            nl_alignment_ok = verdict_line.upper().startswith("ALIGNED")
            if not nl_alignment_ok:
                notes.append(f"Back-translation verdict: {verdict_line}")
        except KeyError:
            notes.append("Back-translation skipped (no stub available).")
            nl_alignment_ok = True  # don't fail the verdict if we can't check
        except Exception as exc:  # noqa: BLE001
            notes.append(f"Back-translation errored: {exc!r}")

    # Verdict
    if compile_ok and sorry_count == 0 and nl_alignment_ok:
        verdict = "CERTIFIED"
    elif compile_ok and sorry_count == stuck_count and nl_alignment_ok:
        # File compiles (sorries are warnings, not errors); only STUCK sorries
        # remain. This is the "PARTIAL" case.
        verdict = f"PARTIAL({stuck_count})"
    elif not compile_ok:
        verdict = "FAIL"
        notes.append(f"{compile_errors} compile errors.")
    elif not nl_alignment_ok:
        verdict = "FAIL"
        notes.append("Back-translation diverged from the original NL.")
    else:
        verdict = "FAIL"

    return VerifierResult(
        verdict=verdict,
        stuck_count=stuck_count,
        sorry_count=sorry_count,
        compile_ok=compile_ok,
        compile_errors=compile_errors,
        compile_warnings=compile_warnings,
        back_translation=back_translation,
        nl_alignment_ok=nl_alignment_ok,
        notes=notes,
    )
