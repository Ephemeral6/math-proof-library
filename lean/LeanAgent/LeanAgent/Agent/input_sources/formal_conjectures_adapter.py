"""Adapter for the `formal-conjectures` repository (or any directory of
.lean files containing `theorem` / `conjecture` declarations).

We do a structural parse — no Lean elaboration — pulling out:
  - the docstring before the theorem (becomes `goal` NL),
  - the `theorem`/`conjecture` head + signature (becomes `lean_statement`),
  - the AMS code from the docstring's `AMS:` line if present.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Iterable


_DECL_HEADER = re.compile(
    r"""^[ \t]*
    (theorem|conjecture|lemma)
    [ \t]+([A-Za-z_][A-Za-z0-9_'.]*)
    """,
    re.VERBOSE,
)

# A loose "AMS code" matcher — works inside docstrings ("AMS: 11") AND inside
# the Lean attribute syntax used by formal-conjectures ("@[category research open, AMS 11]").
_AMS_LINE = re.compile(r"\bAMS\s*:?\s*([0-9A-Za-z\-, ]+)", re.IGNORECASE)

# Category attribute, e.g. "@[category research open, AMS 5]" or "@[category API, AMS 5]".
_CATEGORY_RE = re.compile(r"category\s+([a-zA-Z_]+(?:\s+[a-zA-Z_]+)?)")


def _domain_from_ams(ams: str) -> str:
    """Map an AMS field (possibly multiple space-separated codes) to a coarse domain."""
    if not ams:
        return "general"
    # Pull every standalone integer; first one wins for routing.
    codes = [int(x) for x in re.findall(r"\b\d+\b", ams)]
    if not codes:
        return "general"
    code = codes[0]
    if code in (49, 65, 90):
        return "optimization"
    if code in (60, 62):
        return "statistics"
    if code in (5, 11):
        return "combinatorics"
    if code in (53, 57):
        return "geometric_topology"
    if code in (68,):
        return "computer_science"
    if code in (15, 16):
        return "linear_algebra"
    if code in (51, 52):
        return "geometry"
    return "general"


def _split_blocks(text: str) -> list[tuple[str, str, str]]:
    """Yield (decl_kind, decl_name, full_block) tuples."""
    lines = text.splitlines(keepends=False)
    blocks: list[tuple[str, str, str]] = []
    i = 0
    while i < len(lines):
        m = _DECL_HEADER.match(lines[i])
        if not m:
            i += 1
            continue
        decl_kind, decl_name = m.group(1), m.group(2)

        # Walk back to collect the preceding `@[...]` attribute(s), line comments,
        # blank lines, and doc-comment.
        doc_start = i
        j = i - 1
        while j >= 0 and (
            lines[j].strip().startswith("--")
            or lines[j].strip().startswith("@[")
            or lines[j].strip() == ""
        ):
            doc_start = j
            j -= 1
        if j >= 0 and lines[j].strip().endswith("-/"):
            # Multiline doc comment; walk back to its `/-` (or `/--`) opening.
            while j >= 0 and not lines[j].strip().startswith("/-"):
                j -= 1
            if j >= 0:
                doc_start = j

        # Walk forward to the end of the declaration: blank line or
        # next top-level keyword.
        k = i + 1
        while k < len(lines):
            l = lines[k].strip()
            if l == "" or _DECL_HEADER.match(lines[k]):
                break
            k += 1
        full_block = "\n".join(lines[doc_start:k])
        blocks.append((decl_kind, decl_name, full_block))
        i = k
    return blocks


def _parse_block(block: str) -> dict:
    # Pull the docstring NL — accept both `/-- ... -/` and `/- ... -/` forms.
    nl = ""
    m_doc = re.match(r"\s*/-(?:-)?(.*?)-/", block, re.DOTALL)
    if m_doc:
        nl = m_doc.group(1).strip()
    else:
        line_doc = re.findall(r"^--+\s*(.*)$", block, re.MULTILINE)
        nl = "\n".join(line_doc).strip()

    # AMS: prefer the Lean attribute (@[category ..., AMS N]); fall back to docstring.
    ams = ""
    m_attr = re.search(r"@\[([^\]]*\bAMS\b[^\]]*)\]", block)
    if m_attr:
        m_ams = re.search(r"\bAMS\s+([0-9 ]+)", m_attr.group(1))
        if m_ams:
            ams = m_ams.group(1).strip()
    if not ams:
        ams_match = _AMS_LINE.search(nl)
        if ams_match:
            ams = ams_match.group(1).strip()

    # Category, e.g. "research open" / "research solved" / "API".
    category = ""
    if m_attr:
        m_cat = _CATEGORY_RE.search(m_attr.group(1))
        if m_cat:
            category = m_cat.group(1).strip()

    return {"nl": nl, "ams": ams, "category": category}


def parse_formal_conjectures(
    root: Path | str,
    *,
    limit: int | None = None,
) -> list[dict]:
    """Walk a directory tree and emit unified problem dicts."""
    root = Path(root)
    out: list[dict] = []
    if not root.exists():
        return out

    files = sorted(root.rglob("*.lean")) if root.is_dir() else [root]
    for f in files:
        try:
            text = f.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError):
            continue
        for kind, name, block in _split_blocks(text):
            meta = _parse_block(block)
            problem_id = f"FC-{f.stem}-{name}"
            out.append({
                "problem_id": problem_id,
                "goal": meta["nl"] or f"{kind} {name}",
                "domain": _domain_from_ams(meta["ams"]),
                "lean_statement": block.strip(),
                "source": "formal_conjectures",
                "literature_in_scope": [],
                "decl_kind": kind,
                "decl_name": name,
                "ams": meta["ams"],
                "category": meta["category"],
                "is_open": ("sorry" in block) and (meta["category"] == "research open"),
                "file": str(f.relative_to(root) if f != root else f.name),
            })
            if limit is not None and len(out) >= limit:
                return out
    return out
