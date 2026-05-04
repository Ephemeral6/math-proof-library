"""Sorry Replacer — inject agent-produced tactic proofs into formal-conjectures .lean files.

Workflow:
1. read_sorry_locations(lean_path)        -> list[SorryLocation]
2. replace_sorry(location, tactic_proof)  -> rewrites the file in place (with .bak)
3. verify(lean_path, lake_root)           -> runs `lake build`, returns ReplaceResult
4. rollback(lean_path)                    -> restores from .bak
5. attempt_fill_sorry(...)                -> end-to-end: locate -> replace -> verify -> rollback on failure
"""

from __future__ import annotations

import re
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Optional


THEOREM_KW = re.compile(r'^(theorem|conjecture|lemma)\s+(\S+)', re.MULTILINE)


@dataclass
class SorryLocation:
    """Position of a sorry inside a `theorem ... := by sorry` block."""
    file_path: Path
    theorem_name: str
    sorry_line: int          # 1-indexed
    sorry_col: int           # 0-indexed
    theorem_start_line: int  # 1-indexed
    theorem_end_line: int    # 1-indexed (sorry's line)
    full_statement: str      # `theorem ... := by` text
    original_content: str    # whole-file backup


@dataclass
class ReplaceResult:
    success: bool
    file_path: Path
    theorem_name: str
    tactic_proof: str
    lake_stdout: Optional[str] = None
    lake_stderr: Optional[str] = None
    error_message: Optional[str] = None


def read_sorry_locations(lean_path: Path) -> list[SorryLocation]:
    """Find every theorem/conjecture/lemma block whose body contains `sorry`."""
    content = lean_path.read_text(encoding="utf-8")
    lines = content.split("\n")

    locations: list[SorryLocation] = []

    matches = list(THEOREM_KW.finditer(content))
    for idx, match in enumerate(matches):
        thm_name = match.group(2)
        thm_start_offset = match.start()
        thm_start_line0 = content[:thm_start_offset].count("\n")  # 0-indexed

        # The body of this theorem ends where the next theorem starts (or EOF).
        body_end = matches[idx + 1].start() if idx + 1 < len(matches) else len(content)
        body = content[thm_start_offset:body_end]

        sorry_match = re.search(r'\bsorry\b', body)
        if not sorry_match:
            continue

        sorry_offset = thm_start_offset + sorry_match.start()
        sorry_line0 = content[:sorry_offset].count("\n")
        line_start = content.rfind("\n", 0, sorry_offset) + 1
        sorry_col = sorry_offset - line_start

        stmt_lines = lines[thm_start_line0:sorry_line0 + 1]
        full_statement = "\n".join(stmt_lines)

        locations.append(SorryLocation(
            file_path=lean_path,
            theorem_name=thm_name,
            sorry_line=sorry_line0 + 1,
            sorry_col=sorry_col,
            theorem_start_line=thm_start_line0 + 1,
            theorem_end_line=sorry_line0 + 1,
            full_statement=full_statement,
            original_content=content,
        ))

    return locations


def replace_sorry(
    location: SorryLocation,
    tactic_proof: str,
    backup: bool = True,
) -> Path:
    """Replace the `sorry` belonging to `location.theorem_name` with `tactic_proof`.

    `tactic_proof` is the body that goes after `by` (no leading `by`).
    """
    lean_path = location.file_path

    if backup:
        backup_path = lean_path.with_suffix(".lean.bak")
        shutil.copy2(lean_path, backup_path)

    content = lean_path.read_text(encoding="utf-8")

    # Locate the target theorem and the FIRST sorry inside its body.
    name_re = re.escape(location.theorem_name)
    pattern = re.compile(
        rf'((?:theorem|conjecture|lemma)\s+{name_re}\b.*?:=\s*by\s*?\n?[ \t]*)\bsorry\b',
        re.DOTALL,
    )

    indent = "  "
    formatted = "\n".join(
        f"{indent}{line.rstrip()}" if line.strip() else ""
        for line in tactic_proof.strip().split("\n")
    )

    new_content, count = pattern.subn(rf'\1{formatted.lstrip()}', content, count=1)
    if count == 0:
        # Fallback: try matching with the theorem name token-suffixed (handles dotted names).
        raise ValueError(
            f"Could not locate sorry for {location.theorem_name} in {lean_path}"
        )

    lean_path.write_text(new_content, encoding="utf-8")
    return lean_path


def _find_lake_root(lean_path: Path) -> Optional[Path]:
    p = lean_path.resolve().parent
    while p != p.parent:
        if (p / "lakefile.lean").exists() or (p / "lakefile.toml").exists():
            return p
        p = p.parent
    return None


def verify(
    lean_path: Path,
    lake_root: Optional[Path] = None,
    timeout: int = 300,
) -> ReplaceResult:
    """Run `lake build <module>`; success requires zero errors and no sorry warnings."""
    if lake_root is None:
        lake_root = _find_lake_root(lean_path)
        if lake_root is None:
            return ReplaceResult(
                success=False,
                file_path=lean_path,
                theorem_name="?",
                tactic_proof="",
                error_message="Could not find lakefile.lean / lakefile.toml",
            )

    try:
        rel = lean_path.resolve().relative_to(lake_root.resolve())
        module_name = ".".join(rel.with_suffix("").parts)
    except ValueError:
        module_name = lean_path.stem

    try:
        result = subprocess.run(
            ["lake", "build", module_name],
            cwd=str(lake_root),
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        stdout = result.stdout or ""
        stderr = result.stderr or ""
        success = (
            result.returncode == 0
            and "error" not in stderr.lower()
            and "sorry" not in stderr.lower()
            and "sorry" not in stdout.lower()
        )
        return ReplaceResult(
            success=success,
            file_path=lean_path,
            theorem_name=module_name,
            tactic_proof="",
            lake_stdout=stdout[-2000:],
            lake_stderr=stderr[-2000:],
            error_message=None if success else (stderr[-500:] or stdout[-500:]),
        )
    except subprocess.TimeoutExpired:
        return ReplaceResult(
            success=False,
            file_path=lean_path,
            theorem_name=module_name,
            tactic_proof="",
            error_message=f"lake build timed out after {timeout}s",
        )
    except FileNotFoundError:
        return ReplaceResult(
            success=False,
            file_path=lean_path,
            theorem_name=module_name,
            tactic_proof="",
            error_message="lake not found in PATH",
        )


def rollback(lean_path: Path) -> bool:
    """Restore from `<file>.lean.bak`. Returns True iff a backup existed."""
    backup_path = lean_path.with_suffix(".lean.bak")
    if backup_path.exists():
        shutil.copy2(backup_path, lean_path)
        backup_path.unlink()
        return True
    return False


def attempt_fill_sorry(
    lean_path: Path,
    theorem_name: str,
    tactic_proof: str,
    lake_root: Optional[Path] = None,
    timeout: int = 300,
) -> ReplaceResult:
    """Locate -> replace -> verify -> commit-or-rollback."""
    locations = read_sorry_locations(lean_path)

    target = next((loc for loc in locations if loc.theorem_name == theorem_name), None)
    if target is None:
        return ReplaceResult(
            success=False,
            file_path=lean_path,
            theorem_name=theorem_name,
            tactic_proof=tactic_proof,
            error_message=f"No sorry found for theorem '{theorem_name}' in {lean_path}",
        )

    try:
        replace_sorry(target, tactic_proof, backup=True)
    except ValueError as e:
        return ReplaceResult(
            success=False,
            file_path=lean_path,
            theorem_name=theorem_name,
            tactic_proof=tactic_proof,
            error_message=str(e),
        )

    result = verify(lean_path, lake_root, timeout)
    result.theorem_name = theorem_name
    result.tactic_proof = tactic_proof

    if not result.success:
        rollback(lean_path)
        result.error_message = (
            f"lake build failed, rolled back. Error: {result.error_message}"
        )
    else:
        # Success — drop the backup.
        backup_path = lean_path.with_suffix(".lean.bak")
        if backup_path.exists():
            backup_path.unlink()

    return result
