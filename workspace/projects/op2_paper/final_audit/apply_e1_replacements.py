"""
E1: Global find-replace for Pedregosa/GPT23 hallucinations.
Generates a per-file change log; outputs counts.

EXCLUDES:
  - workspace/op2_li_review/D5_nesterov/gpt23.txt (cached arXiv PDF text — Pedregosa appears
    legitimately there as a *cited reference* in the actual paper's bibliography)
  - workspace/active/op2_final_audit/ (the audit reports themselves which name Pedregosa as the bug)
  - *.aux, *.toc (auto-generated LaTeX files; will regenerate on recompile)
"""
import re
from pathlib import Path

MATH_ROOT = Path(r"C:\Users\12729\Desktop\Math")

# Files to process (.md, .py, .json, .tex)
EXTENSIONS = {".md", ".py", ".json", ".tex"}

# Hard exclusions
EXCLUDE_PATHS = [
    r"workspace\op2_li_review\D5_nesterov\gpt23.txt",
    r"workspace\active\op2_final_audit",   # all audit reports - they report the bug
]

# Replacement table (longest-match first to avoid clobbering)
# Order matters: do the longer patterns first
REPLACEMENTS = [
    # === Three-author forms (longest first) ===
    ("Goujaud--Pedregosa--Taylor","Goujaud--Taylor--Dieuleveut"),  # LaTeX double-hyphen
    ("Goujaud–Pedregosa–Taylor",  "Goujaud–Taylor–Dieuleveut"),    # en-dashes
    ("Goujaud-Pedregosa-Taylor",  "Goujaud-Taylor-Dieuleveut"),    # hyphens
    ("Goujaud, Pedregosa, Taylor","Goujaud, Taylor, Dieuleveut"),
    ("Goujaud, Pedregosa & Taylor","Goujaud, Taylor & Dieuleveut"),
    ("Goujaud and Pedregosa and Taylor","Goujaud, Taylor, and Dieuleveut"),
    # === Year-typo variants (3-author with year) ===
    ("Goujaud–Pedregosa 2022", "Goujaud–Taylor–Dieuleveut 2023"),
    ("Goujaud-Pedregosa 2022", "Goujaud-Taylor-Dieuleveut 2023"),
    ("Goujaud, Pedregosa 2022","Goujaud, Taylor, Dieuleveut 2023"),
    ("Goujaud-Pedregosa 2023", "Goujaud-Taylor-Dieuleveut 2023"),
    ("Goujaud–Pedregosa 2023", "Goujaud–Taylor–Dieuleveut 2023"),
    # === Two-author forms (must come AFTER 3-author) ===
    ("Goujaud--Pedregosa", "Goujaud--Taylor--Dieuleveut"),  # LaTeX
    ("Goujaud–Pedregosa",  "Goujaud–Taylor–Dieuleveut"),    # en-dash
    ("Goujaud-Pedregosa",  "Goujaud-Taylor-Dieuleveut"),    # hyphen
    ("Goujaud/Pedregosa",  "Goujaud/Taylor/Dieuleveut"),    # slash
    ("Goujaud, Pedregosa", "Goujaud, Taylor, Dieuleveut"),
    ("Goujaud or Pedregosa","Goujaud or Taylor"),           # informal
    ("Goujaud and Pedregosa","Goujaud and Taylor"),
    # === Pedregosa-Taylor (without Goujaud) ===
    ("Pedregosa–Taylor 2023", "Taylor–Dieuleveut 2023"),
    ("Pedregosa-Taylor 2023", "Taylor-Dieuleveut 2023"),
    ("Pedregosa-Taylor",      "Taylor-Dieuleveut"),
    # === Acronyms ===
    ("GPT23",    "GTD23"),
    ("GPT 23",   "GTD 23"),
    ("GPT-23",   "GTD-23"),
    ("GPT-cyc",  "GTD-cyc"),
    ("GPT (cyc)","GTD (cyc)"),
]

# Regex for any remaining standalone "Pedregosa" — but ONLY if in plausible Goujaud context.
# We use word boundaries to avoid mid-token replacements.
# For safety we list this as a SEPARATE second-pass regex that the script flags but doesn't
# auto-apply (the user can review).

PEDREGOSA_REGEX = re.compile(r"\bPedregosa\b")

def should_process(path: Path) -> bool:
    """Return True if file should be processed."""
    rel = path.relative_to(MATH_ROOT).as_posix()
    if path.suffix not in EXTENSIONS:
        return False
    for excl in EXCLUDE_PATHS:
        excl_norm = excl.replace("\\", "/")
        if rel.startswith(excl_norm):
            return False
    return True

def apply_replacements(text: str) -> tuple[str, int]:
    """Apply all REPLACEMENTS, return (new_text, total_count)."""
    total = 0
    for old, new in REPLACEMENTS:
        count = text.count(old)
        if count > 0:
            text = text.replace(old, new)
            total += count
    return text, total

def main():
    log = []
    total_files_changed = 0
    total_replacements = 0
    pedregosa_residual = []  # (path, line_number, line_content)
    files_processed = 0

    # Walk everything under workspace/ and proofs/
    targets = []
    for sub in ["workspace", "proofs"]:
        root = MATH_ROOT / sub
        for path in root.rglob("*"):
            if path.is_file() and should_process(path):
                targets.append(path)
    # Also include RESEARCH_INDEX.md in project root
    rin = MATH_ROOT / "RESEARCH_INDEX.md"
    if rin.exists():
        targets.append(rin)
    inx = MATH_ROOT / "INDEX.md"
    if inx.exists():
        targets.append(inx)
    libidx = MATH_ROOT / "LIBRARY_INDEX.md"
    if libidx.exists():
        targets.append(libidx)

    for path in sorted(set(targets)):
        files_processed += 1
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            try:
                text = path.read_text(encoding="utf-8", errors="replace")
            except Exception as e:
                log.append(f"SKIP (encoding error): {path}: {e}")
                continue

        original = text
        new_text, count = apply_replacements(text)

        if count > 0:
            path.write_text(new_text, encoding="utf-8")
            total_files_changed += 1
            total_replacements += count
            rel = path.relative_to(MATH_ROOT).as_posix()
            log.append(f"  {rel}: {count} replacement(s)")

        # Check for residual standalone "Pedregosa"
        for line_num, line in enumerate(new_text.splitlines(), 1):
            if PEDREGOSA_REGEX.search(line):
                rel = path.relative_to(MATH_ROOT).as_posix()
                pedregosa_residual.append((rel, line_num, line.strip()[:200]))

    print("=" * 70)
    print(f"E1 GLOBAL REPLACEMENT REPORT")
    print("=" * 70)
    print(f"Files processed: {files_processed}")
    print(f"Files changed:   {total_files_changed}")
    print(f"Total replacements: {total_replacements}")
    print()
    print("Per-file changes:")
    for line in log:
        print(line)
    print()
    print("=" * 70)
    print(f"RESIDUAL 'Pedregosa' OCCURRENCES (after replacement)")
    print("=" * 70)
    if pedregosa_residual:
        for rel, ln, content in pedregosa_residual:
            print(f"  {rel}:{ln}: {content}")
    else:
        print("  NONE — clean!")

if __name__ == "__main__":
    main()
