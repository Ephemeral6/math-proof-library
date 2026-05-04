"""
Stage 6 — Linter.

Lightweight code-quality pass over a CERTIFIED Lean file. Runs after Stage 5
and before persistence. Two kinds of issues:

  * `auto_fix`   — corrected in place (currently: missing docstring; LLM
                   generates one from the theorem statement).
  * `suggestion` — reported only (e.g. snake_case naming, @[simp] candidate,
                   unused imports).

The output also includes a PR-readiness verdict:

  * Zero `sorry`
  * Has a docstring directly above the theorem
  * snake_case theorem name
  * No lemma uses project-internal definitions (i.e. only `import Mathlib.…`
    or `import Init`)
  * (Optional) LLM judges this as a non-duplicate Mathlib-gap filler.

LLM stub keys:
  linter::docstring        — text-only docstring body (no /-- … -/)
  linter::mathlib_gap      — "yes <reason>" / "no <reason>" (optional)
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path

from . import Utils
from .LLM import LLM


# --------------------------------------------------------------------------- #
# Result types
# --------------------------------------------------------------------------- #


@dataclass
class LintIssue:
    type: str            # "missing_docstring" / "naming" / "unused_import" / ...
    severity: str        # "auto_fix" / "suggestion" / "info"
    line: int = 0
    message: str = ""


@dataclass
class LintResult:
    lean_file: Path
    issues: list[LintIssue] = field(default_factory=list)
    auto_fixed: list[str] = field(default_factory=list)
    pr_ready: bool = False
    pr_blockers: list[str] = field(default_factory=list)
    notes: list[str] = field(default_factory=list)


# --------------------------------------------------------------------------- #
# Prompts
# --------------------------------------------------------------------------- #

DOCSTRING_SYSTEM = """\
You are writing a single Lean 4 docstring for a theorem. Produce ONE short
paragraph that explains the assumptions and conclusion. No code fences, no
markdown, no "/--" or "-/" delimiters — only the inner text. Keep under 240
characters.
"""

DOCSTRING_PROMPT = """\
Lean theorem signature:
```lean
{signature}
```

Write the docstring body.
"""

GAP_SYSTEM = """\
You are evaluating whether a Lean theorem fills a real gap in Mathlib (vs.
duplicating an existing lemma). Answer with one line:
  YES <one-sentence reason>
  NO  <one-sentence reason>
"""

GAP_PROMPT = """\
Lean theorem:
```lean
{signature}
```

Does this fill a Mathlib gap? Reply YES/NO + reason.
"""


# --------------------------------------------------------------------------- #
# Helpers
# --------------------------------------------------------------------------- #

_THEOREM_RE = re.compile(
    r"^(?P<indent>\s*)(?P<kw>theorem|lemma|def)\s+(?P<name>[A-Za-z_][\w']*)",
    re.MULTILINE,
)
_DOCSTRING_PREFIX_RE = re.compile(r"/--[\s\S]*?-/\s*$")
_FENCE_RE = re.compile(r"```(?:lean|lean4)?\s*\n(.*?)```", re.DOTALL)
_IMPORT_RE = re.compile(r"^\s*import\s+(.+)$", re.MULTILINE)


def _extract_block(text: str) -> str:
    m = _FENCE_RE.search(text)
    return (m.group(1).strip() if m else text.strip())


def _is_snake_case(name: str) -> bool:
    return bool(re.match(r"^[a-z][a-z0-9_]*$", name))


def _signature_block(file_text: str) -> str:
    """Return text from the `theorem`/`lemma` keyword up to the `:=`."""
    out = []
    started = False
    for line in file_text.splitlines():
        if not started and re.match(r"\s*(theorem|lemma|def|example)\b", line):
            started = True
        if started:
            out.append(line)
            if line.rstrip().endswith(":="):
                break
    return "\n".join(out)


def _docstring_present_above(text: str, decl_line_idx: int) -> bool:
    """Walk upwards from decl_line_idx-1 over blank lines and find `-/`."""
    lines = text.splitlines()
    i = decl_line_idx - 1
    while i >= 0 and lines[i].strip() == "":
        i -= 1
    if i < 0:
        return False
    return lines[i].rstrip().endswith("-/")


def _find_decl(text: str) -> tuple[str, str, int] | None:
    """Return (kw, name, line_index_0based) for the first theorem-like decl."""
    m = _THEOREM_RE.search(text)
    if not m:
        return None
    line_idx = text[: m.start()].count("\n")
    return m.group("kw"), m.group("name"), line_idx


def _insert_docstring(text: str, decl_line_idx: int, body: str) -> str:
    body = body.strip().splitlines()
    if not body:
        return text
    lines = text.splitlines()
    block = ["/-- " + body[0]] + ["    " + b for b in body[1:]] + ["-/"]
    new_lines = lines[:decl_line_idx] + block + lines[decl_line_idx:]
    return "\n".join(new_lines) + ("\n" if text.endswith("\n") else "")


# --------------------------------------------------------------------------- #
# Individual checks
# --------------------------------------------------------------------------- #


def _check_sorry(text: str, file: Path) -> list[LintIssue]:
    n = Utils.count_sorries(file)
    if n == 0:
        return []
    return [
        LintIssue(
            type="sorry_remaining",
            severity="suggestion",
            message=f"{n} sorry token(s) remain (Verifier should have caught this).",
        )
    ]


def _check_naming(name: str) -> list[LintIssue]:
    if _is_snake_case(name):
        return []
    return [
        LintIssue(
            type="naming",
            severity="suggestion",
            message=f"theorem name '{name}' is not snake_case (Mathlib convention).",
        )
    ]


def _check_simp_candidate(signature: str) -> list[LintIssue]:
    body = signature.split(":=")[0]
    body_after_colon = body.split(":", 1)[-1]
    if re.search(r"=\s*[^\n=]+$", body_after_colon) or "↔" in body_after_colon:
        return [
            LintIssue(
                type="simp_candidate",
                severity="info",
                message="Equation/iff conclusion — consider tagging `@[simp]`.",
            )
        ]
    return []


def _check_unused_imports(text: str) -> list[LintIssue]:
    """Heuristic only: flag any non-Mathlib/Init import as worth verifying."""
    out: list[LintIssue] = []
    for m in _IMPORT_RE.finditer(text):
        mod = m.group(1).strip()
        if not mod.startswith(("Mathlib.", "Init.")):
            out.append(
                LintIssue(
                    type="unused_import_candidate",
                    severity="info",
                    line=text[: m.start()].count("\n") + 1,
                    message=(
                        f"non-Mathlib import `{mod}` — verify it's actually used."
                    ),
                )
            )
    return out


def _check_project_internal_imports(text: str) -> list[str]:
    """Return imports that look project-internal (block PR readiness)."""
    bad: list[str] = []
    for m in _IMPORT_RE.finditer(text):
        mod = m.group(1).strip()
        if mod.startswith("LeanAgent."):
            bad.append(mod)
    return bad


# --------------------------------------------------------------------------- #
# Auto-fix: docstring
# --------------------------------------------------------------------------- #


def _autofix_missing_docstring(
    file: Path, text: str, decl_line_idx: int, llm: LLM
) -> tuple[str | None, str]:
    """Returns (new_text, note). new_text is None if we couldn't fix."""
    sig = _signature_block(text)
    try:
        resp = llm.ask(
            stage="linter",
            task="docstring",
            prompt=DOCSTRING_PROMPT.format(signature=sig),
            system=DOCSTRING_SYSTEM,
        )
    except KeyError:
        return None, "docstring auto-fix skipped (no stub available)"
    body = _extract_block(resp.text).strip()
    body = re.sub(r"^/--\s*", "", body)
    body = re.sub(r"\s*-/\s*$", "", body)
    if not body:
        return None, "docstring auto-fix produced empty text"
    new_text = _insert_docstring(text, decl_line_idx, body)
    Utils.write_text(file, new_text)
    return new_text, f"inserted docstring ({len(body)} chars)"


# --------------------------------------------------------------------------- #
# PR-ready evaluation
# --------------------------------------------------------------------------- #


def _evaluate_pr_ready(
    *,
    text: str,
    name: str | None,
    has_docstring: bool,
    sorry_count: int,
    project_imports: list[str],
    llm: LLM,
) -> tuple[bool, list[str], list[str]]:
    blockers: list[str] = []
    notes: list[str] = []

    if sorry_count != 0:
        blockers.append(f"{sorry_count} sorry token(s) remain.")
    if not has_docstring:
        blockers.append("no docstring on the main declaration.")
    if name is None:
        blockers.append("could not locate a theorem/lemma declaration.")
    elif not _is_snake_case(name):
        blockers.append(f"name '{name}' is not snake_case.")
    if project_imports:
        blockers.append(
            "depends on project-internal imports: "
            + ", ".join(f"`{m}`" for m in project_imports)
        )

    # Only ask for the gap-filling judgment if everything else passes —
    # otherwise it's wasted budget.
    if not blockers:
        sig = _signature_block(text)
        try:
            resp = llm.ask(
                stage="linter",
                task="mathlib_gap",
                prompt=GAP_PROMPT.format(signature=sig),
                system=GAP_SYSTEM,
            )
            line0 = (resp.text.strip().splitlines() or [""])[0]
            notes.append(f"mathlib_gap: {line0}")
            if line0.upper().startswith("NO"):
                blockers.append("LLM judges this duplicates an existing Mathlib lemma.")
        except KeyError:
            notes.append("mathlib_gap check skipped (no stub).")

    return (not blockers), blockers, notes


# --------------------------------------------------------------------------- #
# Main entry
# --------------------------------------------------------------------------- #


def run_linter(lean_file: Path | str, *, llm: LLM) -> LintResult:
    lean_file = Path(lean_file)
    text = Utils.read_text(lean_file)
    issues: list[LintIssue] = []
    auto_fixed: list[str] = []
    notes: list[str] = []

    decl = _find_decl(text)
    name = decl[1] if decl else None

    # 1. sorry remaining
    issues.extend(_check_sorry(text, lean_file))

    # 2. docstring (auto-fix)
    has_docstring = decl is not None and _docstring_present_above(text, decl[2])
    if not has_docstring and decl is not None:
        issues.append(
            LintIssue(
                type="missing_docstring",
                severity="auto_fix",
                line=decl[2] + 1,
                message="no `/-- ... -/` docstring above the declaration.",
            )
        )
        new_text, note = _autofix_missing_docstring(lean_file, text, decl[2], llm)
        notes.append(note)
        if new_text is not None:
            auto_fixed.append("missing_docstring")
            text = new_text
            # decl_line_idx may have shifted — refresh.
            decl = _find_decl(text)
            has_docstring = decl is not None and _docstring_present_above(text, decl[2])

    # 3. naming (suggestion only — renames affect downstream imports).
    if name is not None:
        issues.extend(_check_naming(name))

    # 4. simp candidate
    issues.extend(_check_simp_candidate(_signature_block(text)))

    # 5. unused import suggestion
    issues.extend(_check_unused_imports(text))

    # 6. PR-ready
    project_imports = _check_project_internal_imports(text)
    sorry_count = Utils.count_sorries(lean_file)
    pr_ready, pr_blockers, pr_notes = _evaluate_pr_ready(
        text=text,
        name=name,
        has_docstring=has_docstring,
        sorry_count=sorry_count,
        project_imports=project_imports,
        llm=llm,
    )
    notes.extend(pr_notes)

    return LintResult(
        lean_file=lean_file,
        issues=issues,
        auto_fixed=auto_fixed,
        pr_ready=pr_ready,
        pr_blockers=pr_blockers,
        notes=notes,
    )
