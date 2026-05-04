"""
Shared utilities for the Lean Formalization Agent pipeline.

Provides:
  * compile_lean         -- run `lake env lean <file>` and parse output
  * lake_build           -- run `lake build <module>` and parse output
  * count_sorries        -- count `sorry` occurrences outside comments
  * extract_errors       -- parse errors/warnings from compiler output
  * insert_at_line / replace_first / replace_block
  * project_root, generated_dir, lean_module_for
"""

from __future__ import annotations

import os
import re
import shlex
import subprocess
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable


# --------------------------------------------------------------------------- #
# Project layout helpers
# --------------------------------------------------------------------------- #

def project_root() -> Path:
    """Return the LeanAgent project root (the dir containing lakefile.toml)."""
    here = Path(__file__).resolve()
    for p in [here, *here.parents]:
        if (p / "lakefile.toml").exists():
            return p
    raise RuntimeError("project root with lakefile.toml not found")


def generated_dir() -> Path:
    return project_root() / "LeanAgent" / "Generated"


def lean_module_for(rel_path: Path | str) -> str:
    """Translate a path under the project root to a dotted Lean module name.

    e.g. LeanAgent/Generated/descent_lemma.lean -> LeanAgent.Generated.descent_lemma
    """
    p = Path(rel_path)
    if p.is_absolute():
        p = p.relative_to(project_root())
    parts = list(p.with_suffix("").parts)
    return ".".join(parts)


# --------------------------------------------------------------------------- #
# Compilation
# --------------------------------------------------------------------------- #

LAKE_BIN = os.environ.get("LAKE_BIN", "lake")
ELAN_BIN_DIR = str(Path(os.environ.get("USERPROFILE", os.environ.get("HOME", "/"))) / ".elan" / "bin")


def _env_with_elan() -> dict:
    env = os.environ.copy()
    sep = ";" if os.name == "nt" else ":"
    if ELAN_BIN_DIR not in env.get("PATH", ""):
        env["PATH"] = ELAN_BIN_DIR + sep + env.get("PATH", "")
    return env


@dataclass
class CompileResult:
    success: bool
    returncode: int
    stdout: str
    stderr: str
    errors: list[dict] = field(default_factory=list)
    warnings: list[dict] = field(default_factory=list)

    @property
    def combined(self) -> str:
        return (self.stdout or "") + (("\n" + self.stderr) if self.stderr else "")


def compile_lean(lean_file: str | Path, *, timeout: int = 600) -> CompileResult:
    """Run `lake env lean <file>` against a single .lean file.

    Returns CompileResult with parsed errors/warnings.
    """
    lean_file = Path(lean_file)
    cwd = project_root()
    cmd = [LAKE_BIN, "env", "lean", str(lean_file.resolve())]
    try:
        proc = subprocess.run(
            cmd,
            cwd=str(cwd),
            env=_env_with_elan(),
            capture_output=True,
            text=True,
            timeout=timeout,
            encoding="utf-8",
            errors="replace",
        )
    except subprocess.TimeoutExpired as exc:
        return CompileResult(
            success=False,
            returncode=-1,
            stdout=exc.stdout or "",
            stderr=(exc.stderr or "") + f"\n[timeout after {timeout}s]",
            errors=[{"file": str(lean_file), "line": 0, "col": 0,
                     "message": f"compile timeout after {timeout}s",
                     "severity": "error"}],
        )
    full = (proc.stdout or "") + ("\n" + proc.stderr if proc.stderr else "")
    errors, warnings = extract_errors(full, str(lean_file))
    return CompileResult(
        success=(proc.returncode == 0 and not errors),
        returncode=proc.returncode,
        stdout=proc.stdout or "",
        stderr=proc.stderr or "",
        errors=errors,
        warnings=warnings,
    )


def lake_build(target: str | None = None, *, timeout: int = 1200) -> CompileResult:
    """Run `lake build [target]`."""
    cwd = project_root()
    cmd = [LAKE_BIN, "build"]
    if target:
        cmd.append(target)
    try:
        proc = subprocess.run(
            cmd,
            cwd=str(cwd),
            env=_env_with_elan(),
            capture_output=True,
            text=True,
            timeout=timeout,
            encoding="utf-8",
            errors="replace",
        )
    except subprocess.TimeoutExpired as exc:
        return CompileResult(
            success=False,
            returncode=-1,
            stdout=exc.stdout or "",
            stderr=(exc.stderr or "") + f"\n[lake build timeout after {timeout}s]",
            errors=[{"file": "", "line": 0, "col": 0,
                     "message": f"lake build timeout after {timeout}s",
                     "severity": "error"}],
        )
    full = (proc.stdout or "") + ("\n" + proc.stderr if proc.stderr else "")
    errors, warnings = extract_errors(full, "")
    return CompileResult(
        success=(proc.returncode == 0 and not errors),
        returncode=proc.returncode,
        stdout=proc.stdout or "",
        stderr=proc.stderr or "",
        errors=errors,
        warnings=warnings,
    )


# --------------------------------------------------------------------------- #
# Output parsing
# --------------------------------------------------------------------------- #

# Lean compiler error line:   <path>:<line>:<col>: error: <msg>   (or warning:)
# `lake build` may also prefix with `error:` without location.
_LOC_RE = re.compile(
    r"^(?P<file>[^:]+(?::[^:]+)?):(?P<line>\d+):(?P<col>\d+):\s*"
    r"(?P<sev>error|warning|info)\s*:\s*(?P<msg>.*)$"
)


def extract_errors(output: str, default_file: str = "") -> tuple[list[dict], list[dict]]:
    """Parse compiler output into (errors, warnings) lists.

    Each item is a dict {file, line, col, message, severity}. Multi-line
    messages are merged onto the most recent diagnostic.
    """
    errors: list[dict] = []
    warnings: list[dict] = []
    current: dict | None = None

    def flush():
        nonlocal current
        if current is None:
            return
        bucket = errors if current["severity"] == "error" else (
            warnings if current["severity"] == "warning" else None)
        if bucket is not None:
            current["message"] = current["message"].rstrip()
            bucket.append(current)
        current = None

    for raw_line in output.splitlines():
        m = _LOC_RE.match(raw_line)
        if m:
            flush()
            current = {
                "file": m.group("file"),
                "line": int(m.group("line")),
                "col": int(m.group("col")),
                "severity": m.group("sev"),
                "message": m.group("msg"),
            }
            continue
        # `lake build` style:  error: <msg>
        m2 = re.match(r"^(error|warning):\s*(.*)$", raw_line)
        if m2 and current is None:
            flush()
            current = {
                "file": default_file,
                "line": 0,
                "col": 0,
                "severity": m2.group(1),
                "message": m2.group(2),
            }
            continue
        # continuation
        if current is not None and raw_line.strip():
            current["message"] += "\n" + raw_line
    flush()
    return errors, warnings


# --------------------------------------------------------------------------- #
# Sorry counting + manipulation
# --------------------------------------------------------------------------- #

def _strip_comments(text: str) -> str:
    """Remove `/- ... -/` block comments and `--` line comments. Best-effort."""
    out = []
    i = 0
    n = len(text)
    while i < n:
        # block comment (handles nesting at depth 1 — Lean allows nesting but we
        # only need an approximation good enough to skip text inside `/- ... -/`).
        if text[i:i+2] == "/-":
            depth = 1
            i += 2
            while i < n and depth > 0:
                if text[i:i+2] == "/-":
                    depth += 1
                    i += 2
                elif text[i:i+2] == "-/":
                    depth -= 1
                    i += 2
                else:
                    i += 1
            continue
        if text[i:i+2] == "--":
            while i < n and text[i] != "\n":
                i += 1
            continue
        if text[i] == '"':
            out.append(text[i])
            i += 1
            while i < n and text[i] != '"':
                if text[i] == "\\" and i + 1 < n:
                    out.append(text[i:i+2])
                    i += 2
                else:
                    out.append(text[i])
                    i += 1
            if i < n:
                out.append(text[i])
                i += 1
            continue
        out.append(text[i])
        i += 1
    return "".join(out)


_SORRY_RE = re.compile(r"\bsorry\b")


def count_sorries(lean_file: str | Path) -> int:
    text = Path(lean_file).read_text(encoding="utf-8")
    stripped = _strip_comments(text)
    return len(_SORRY_RE.findall(stripped))


def _find_sorry_positions(text: str) -> list[tuple[int, int]]:
    """Return list of (1-indexed line, char offset) for each non-comment sorry."""
    in_block = 0
    in_line_comment = False
    in_string = False
    line = 1
    hits: list[tuple[int, int]] = []
    i = 0
    n = len(text)
    while i < n:
        c = text[i]
        if c == "\n":
            line += 1
            in_line_comment = False
            i += 1
            continue
        if in_line_comment:
            i += 1
            continue
        if in_string:
            if c == "\\" and i + 1 < n:
                i += 2; continue
            if c == '"':
                in_string = False
            i += 1
            continue
        if in_block > 0:
            if text[i:i+2] == "/-":
                in_block += 1; i += 2; continue
            if text[i:i+2] == "-/":
                in_block -= 1; i += 2; continue
            i += 1
            continue
        if text[i:i+2] == "/-":
            in_block = 1; i += 2; continue
        if text[i:i+2] == "--":
            in_line_comment = True; i += 2; continue
        if c == '"':
            in_string = True; i += 1; continue
        if (text[i:i+5] == "sorry"
                and (i == 0 or not (text[i-1].isalnum() or text[i-1] == "_"))
                and (i + 5 == n or not (text[i+5].isalnum() or text[i+5] == "_"))):
            hits.append((line, i))
            i += 5
            continue
        i += 1
    return hits


def _line_contains_marker(text: str, line_no: int, markers: list[str]) -> bool:
    """Return True if the 1-indexed line in `text` contains any of `markers`."""
    if not markers:
        return False
    lines = text.splitlines()
    if line_no < 1 or line_no > len(lines):
        return False
    line = lines[line_no - 1]
    return any(m in line for m in markers)


def find_sorry_lines(
    lean_file: str | Path, *, skip_markers: list[str] | None = None
) -> list[int]:
    """Return 1-indexed line numbers of `sorry` occurrences (outside comments).

    If `skip_markers` is given, any sorry on a line containing one of those
    marker strings is omitted (used to skip sorries already classified as
    STUCK so subsequent passes attack the next one).
    """
    text = Path(lean_file).read_text(encoding="utf-8")
    out: list[int] = []
    for line_no, _ in _find_sorry_positions(text):
        if skip_markers and _line_contains_marker(text, line_no, skip_markers):
            continue
        out.append(line_no)
    return out


# --------------------------------------------------------------------------- #
# File editing helpers
# --------------------------------------------------------------------------- #

def read_text(path: str | Path) -> str:
    return Path(path).read_text(encoding="utf-8")


def write_text(path: str | Path, text: str) -> None:
    Path(path).write_text(text, encoding="utf-8")


def replace_first(path: str | Path, needle: str, replacement: str) -> bool:
    """Replace first occurrence of `needle` in file. Returns True if changed."""
    text = read_text(path)
    idx = text.find(needle)
    if idx < 0:
        return False
    new = text[:idx] + replacement + text[idx + len(needle):]
    write_text(path, new)
    return True


def _column_of_offset(text: str, offset: int) -> int:
    """Return the 0-indexed column of `offset` (chars since start of line)."""
    nl = text.rfind("\n", 0, offset)
    return offset - (nl + 1) if nl >= 0 else offset


def _line_indent_of_offset(text: str, offset: int) -> str:
    """Return the leading-whitespace prefix of the line containing offset."""
    nl = text.rfind("\n", 0, offset)
    line_start = nl + 1
    line_end = text.find("\n", offset)
    if line_end < 0:
        line_end = len(text)
    line = text[line_start:line_end]
    return line[: len(line) - len(line.lstrip(" \t"))]


def replace_first_sorry(
    path: str | Path,
    replacement: str,
    *,
    skip_markers: list[str] | None = None,
) -> bool:
    """Replace the first sorry token (outside comments) in file.

    If the replacement is multi-line, subsequent lines are indented to match
    the column where the sorry was found, so the substitution stays inside
    Lean's whitespace-sensitive `by` block. The first line is placed at the
    sorry's exact offset (so `:= by sorry` becomes `:= by <line0>` with the
    rest indented underneath).

    If `skip_markers` is given, sorries on lines containing any marker are
    skipped. Returns True if a replacement was performed.
    """
    text = read_text(path)
    positions = _find_sorry_positions(text)
    for line_no, offset in positions:
        if skip_markers and _line_contains_marker(text, line_no, skip_markers):
            continue
        col = _column_of_offset(text, offset)
        rep_lines = replacement.rstrip("\n").splitlines()
        if len(rep_lines) <= 1:
            new_block = replacement
        else:
            indent = " " * col
            head, *rest = rep_lines
            new_block = head + "\n" + "\n".join(indent + ln for ln in rest)
        new = text[:offset] + new_block + text[offset + 5:]
        write_text(path, new)
        return True
    return False


def mark_first_sorry_stuck(
    path: str | Path,
    *,
    tag: str,
    skip_markers: list[str] | None = None,
) -> bool:
    """Append `-- {tag}` after the first non-skipped sorry on its line.

    This keeps the `sorry` token in the file (so the build still warns) but
    adds an inline marker so subsequent passes can skip it.
    """
    text = read_text(path)
    positions = _find_sorry_positions(text)
    for line_no, offset in positions:
        if skip_markers and _line_contains_marker(text, line_no, skip_markers):
            continue
        # Find end of this line.
        end = text.find("\n", offset)
        if end < 0:
            end = len(text)
        line_segment = text[offset + 5:end]
        # If marker already present, no-op.
        if tag in line_segment:
            return False
        new = text[:end] + f"  -- {tag}" + text[end:]
        write_text(path, new)
        return True
    return False


# --------------------------------------------------------------------------- #
# Goal-state extraction (best effort)
# --------------------------------------------------------------------------- #

def get_goal_state_at_sorry(lean_file: str | Path) -> str | None:
    """Try to extract Lean's "unsolved goals" message at the first sorry.

    Strategy: run `lake env lean` on the file. Lean reports each `sorry` as a
    warning with the goal context. We grab the first such warning.
    """
    res = compile_lean(lean_file)
    for w in res.warnings:
        if "declaration uses 'sorry'" in w["message"] or "unsolved goals" in w["message"]:
            return w["message"]
    for e in res.errors:
        if "unsolved goals" in e["message"]:
            return e["message"]
    return None


def banner(title: str) -> str:
    return f"\n{'=' * 8} {title} {'=' * (max(0, 60 - len(title) - 10))}\n"


def fmt_diags(diags: Iterable[dict], limit: int = 6) -> str:
    items = list(diags)
    out = []
    for d in items[:limit]:
        loc = f"{Path(d['file']).name}:{d['line']}:{d['col']}" if d["file"] else "?"
        first_line = d["message"].splitlines()[0] if d["message"] else ""
        out.append(f"  - {loc} [{d['severity']}] {first_line}")
    if len(items) > limit:
        out.append(f"  ... ({len(items) - limit} more)")
    return "\n".join(out) if out else "  (none)"
