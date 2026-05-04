"""Scan formal-conjectures repo, classify open problems by AMS, emit candidate list.

The repo annotates each theorem with Lean attributes like:
    @[category research open, AMS 5]
    theorem NAME ... := by
      sorry

We extract these and pick low-complexity, priority-AMS problems for the agent to attack.
"""

from __future__ import annotations

import json
import re
from collections import Counter
from pathlib import Path

ATTR_RE = re.compile(r'@\[([^\]]+)\]\s*\n', re.MULTILINE)
THM_RE = re.compile(
    r'@\[([^\]]+)\]\s*(?:/--(?P<doc>.*?)-/\s*)?'
    r'\s*(?P<kind>theorem|conjecture|lemma)\s+(?P<name>\S+)'
    r'(?P<sig>.*?):=\s*by\b(?P<proof>.*?)(?=\n@\[|\nend\b|\Z)',
    re.DOTALL,
)
DOC_BEFORE_RE = re.compile(r'/--(?P<doc>.*?)-/\s*$', re.DOTALL)


AMS_MAP = {
    "3": "Mathematical logic",
    "5": "Combinatorics",
    "6": "Order, lattices",
    "8": "General algebraic systems",
    "11": "Number theory",
    "12": "Field theory",
    "13": "Commutative algebra",
    "14": "Algebraic geometry",
    "15": "Linear algebra",
    "16": "Associative rings",
    "17": "Nonassociative rings",
    "18": "Category theory",
    "19": "K-theory",
    "20": "Group theory",
    "22": "Topological groups",
    "26": "Real analysis",
    "28": "Measure theory",
    "30": "Complex analysis",
    "31": "Potential theory",
    "32": "Several complex variables",
    "33": "Special functions",
    "34": "ODEs",
    "35": "PDEs",
    "37": "Dynamical systems",
    "39": "Difference / functional eqs",
    "40": "Sequences/series",
    "41": "Approximations",
    "42": "Harmonic analysis",
    "43": "Abstract harmonic analysis",
    "44": "Integral transforms",
    "45": "Integral equations",
    "46": "Functional analysis",
    "47": "Operator theory",
    "49": "Calculus of variations",
    "51": "Geometry",
    "52": "Convex / discrete geometry",
    "53": "Differential geometry",
    "54": "General topology",
    "55": "Algebraic topology",
    "57": "Manifolds",
    "58": "Global analysis",
    "60": "Probability",
    "62": "Statistics",
    "65": "Numerical analysis",
    "68": "Computer science",
    "70": "Mechanics of particles",
    "74": "Mechanics of solids",
    "76": "Fluid mechanics",
    "78": "Optics",
    "81": "Quantum theory",
    "82": "Statistical mechanics",
    "83": "Relativity",
    "85": "Astronomy",
    "86": "Geophysics",
    "90": "Operations research",
    "91": "Game theory / econ",
    "92": "Biology / life sci",
    "93": "Systems / control",
    "94": "Information / comm",
    "97": "Mathematics education",
}


def parse_attrs(attr_str: str) -> dict:
    """Parse '@[...]' attribute body into {category, ams}."""
    out = {"category": None, "ams": None, "raw": attr_str.strip()}
    cat_m = re.search(r'category\s+([a-zA-Z_]+(?:\s+[a-zA-Z_]+)?)', attr_str)
    if cat_m:
        out["category"] = cat_m.group(1).strip()
    ams_m = re.search(r'AMS\s+(\d+)', attr_str)
    if ams_m:
        # Normalize "05" -> "5" so codes don't double-count
        out["ams"] = str(int(ams_m.group(1)))
    return out


def extract_theorems(text: str) -> list[dict]:
    """Find every '@[...] ... theorem NAME ... := by PROOF' block."""
    out = []
    # Iterate by finding @[...] anchors, then the next theorem/conjecture/lemma + := by
    for m in re.finditer(r'@\[([^\]]+)\]\s*', text):
        attr_str = m.group(1)
        attrs = parse_attrs(attr_str)
        # Look for docstring between attribute and theorem, OR before the attribute
        tail = text[m.end():]
        # Find next theorem/conjecture/lemma
        head = re.match(
            r'(?:/--(?P<doc1>.*?)-/\s*)?\s*(?P<kind>theorem|conjecture|lemma|abbrev|def)\s+(?P<name>\S+)',
            tail,
            re.DOTALL,
        )
        if not head:
            continue
        kind = head.group("kind")
        if kind in ("abbrev", "def"):
            continue
        name = head.group("name")
        doc = (head.group("doc1") or "").strip()
        if not doc:
            # Try docstring just before the attribute (the LAST /-- ... -/ block,
            # and only if nothing of substance appears between it and the attribute)
            pre = text[:m.start()]
            # Find all /-- ... -/ blocks
            doc_blocks = list(re.finditer(r'/--(?P<d>.*?)-/', pre, re.DOTALL))
            if doc_blocks:
                last = doc_blocks[-1]
                gap = pre[last.end():]
                # Only accept if the gap is just whitespace (and maybe a single newline)
                if re.fullmatch(r'\s*', gap):
                    doc = last.group("d").strip()
        # Find ":= by" then capture proof body up to next attribute or 'end'
        rest = tail[head.end():]
        sig_match = re.search(r':=\s*by\b', rest)
        if not sig_match:
            continue
        sig = rest[:sig_match.start()].rstrip()
        body_start = sig_match.end()
        # End of proof: next '@[' or '\nend ' or '\nnamespace '
        end_m = re.search(r'\n@\[|\nend\b|\nnamespace\b', rest[body_start:])
        if end_m:
            proof_body = rest[body_start:body_start + end_m.start()]
        else:
            proof_body = rest[body_start:]
        full_block = text[m.start():m.end() + head.end() + body_start + (end_m.start() if end_m else len(rest) - body_start)]
        out.append({
            "category": attrs["category"],
            "ams": attrs["ams"],
            "kind": kind,
            "name": name,
            "signature": sig.strip(),
            "proof": proof_body.strip(),
            "docstring": doc,
            "stmt_lines": (sig.count("\n") + 1) if sig else 1,
            "proof_has_sorry": bool(re.search(r'\bsorry\b', proof_body)),
            "sorry_count": len(re.findall(r'\bsorry\b', proof_body)),
            "full_block": full_block.strip(),
        })
    return out


def scan(root: Path) -> list[dict]:
    problems = []
    for lean_file in sorted(root.rglob("*.lean")):
        try:
            text = lean_file.read_text(encoding="utf-8", errors="replace")
        except Exception:
            continue
        thms = extract_theorems(text)
        for t in thms:
            if not t["proof_has_sorry"]:
                continue
            if t["category"] != "research open":
                continue
            t["file"] = str(lean_file.relative_to(root)).replace("\\", "/")
            problems.append(t)
    return problems


def report(problems: list[dict]) -> list[dict]:
    print("=" * 70)
    print(f"Total open problems (category=research open, has sorry): {len(problems)}")
    print("=" * 70)

    ams_counter = Counter(p["ams"] or "unknown" for p in problems)
    print(f"\n{'AMS':<6} {'Count':<8} {'Domain'}")
    print("-" * 60)
    for ams, count in ams_counter.most_common(25):
        domain = AMS_MAP.get(ams, f"AMS {ams}")
        print(f"{ams:<6} {count:<8} {domain}")

    priority_ams = {"5", "11", "15", "60", "52", "90", "91", "26", "40", "68"}

    candidates = [
        p for p in problems
        if (p["ams"] in priority_ams)
        and 1 <= p["stmt_lines"] <= 12
        and p["sorry_count"] <= 2
        and len(p["docstring"]) > 0
    ]
    candidates.sort(key=lambda p: (p["stmt_lines"], len(p["signature"])))

    print(f"\n{'=' * 70}")
    print(f"Filtered candidates (priority AMS, stmt_lines<=12, sorry<=2, has doc): {len(candidates)}")
    print("=" * 70)

    for i, p in enumerate(candidates[:30]):
        doc_short = " ".join(p["docstring"].split())[:120]
        print(f"\n--- Candidate {i + 1} ---")
        print(f"  File: {p['file']}")
        print(f"  Name: {p['name']}")
        print(f"  AMS:  {p['ams']} ({AMS_MAP.get(p['ams'], '?')})")
        print(f"  Stmt lines: {p['stmt_lines']}, Sorry: {p['sorry_count']}, Sig len: {len(p['signature'])}")
        print(f"  Doc: {doc_short}")

    return candidates


if __name__ == "__main__":
    root = Path("lean/vendor/formal-conjectures/FormalConjectures")
    if not root.exists():
        print(f"ERROR: {root} not found. Run git clone first.")
        raise SystemExit(1)

    problems = scan(root)
    candidates = report(problems)

    out = Path("workspace/formal_conjectures_candidates.json")
    out.parent.mkdir(parents=True, exist_ok=True)
    # Drop the heavy 'full_block' field from JSON to keep it lean
    slim = [
        {k: v for k, v in c.items() if k != "full_block"}
        for c in candidates[:50]
    ]
    out.write_text(json.dumps(slim, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"\nSaved top 50 candidates to {out}")

    # Also save all problems for later use
    all_out = Path("workspace/formal_conjectures_all_open.json")
    all_slim = [
        {k: v for k, v in p.items() if k != "full_block"}
        for p in problems
    ]
    all_out.write_text(json.dumps(all_slim, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Saved all {len(problems)} open problems to {all_out}")

    # And the top-10 full blocks for the report
    full_out = Path("workspace/formal_conjectures_top10_full.json")
    full_out.write_text(
        json.dumps(candidates[:10], indent=2, ensure_ascii=False),
        encoding="utf-8",
    )
    print(f"Saved top 10 full Lean blocks to {full_out}")
