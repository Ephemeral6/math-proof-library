#!/usr/bin/env python3
"""Validator for LeanAgent/registry/discoveries/entries.jsonl.

Enforces the rules in discoveries/SCHEMA.md §H:
  1. JSON parse + required-field check
  2. controlled-vocab check (category, domain, maturity)
  3. referential integrity (back_references must point at existing IDs)
  4. acyclic supersede chain
  5. ID uniqueness
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
DISCOVERIES_PATH = REPO_ROOT / "LeanAgent" / "registry" / "discoveries" / "entries.jsonl"
REPRESENTATIONS_PATH = REPO_ROOT / "LeanAgent" / "registry" / "representations" / "entries.jsonl"
PLAYBOOK_PATH = REPO_ROOT / "LeanAgent" / "registry" / "playbook" / "entries.jsonl"
FAILURES_PATH = REPO_ROOT / "LeanAgent" / "registry" / "failures" / "entries.jsonl"
LEMMAS_DIR = REPO_ROOT / "LeanAgent" / "registry" / "lemmas"

CATEGORY_VOCAB = {
    "proof_technique", "definition_synthesis", "strategic_pattern",
    "api_workaround", "extrapolation_method", "rigor_pattern",
}
DOMAIN_VOCAB = {
    "optimization", "convex_analysis", "geometric_topology",
    "combinatorial_topology", "learning_theory", "statistics",
    "linear_algebra", "probability", "lean_formalization", "meta",
}
MATURITY_VOCAB = {
    "seed", "conjectural", "validated_once",
    "validated_multi", "promoted_to_playbook", "disproved",
}
REQUIRED_FIELDS = [
    "id", "category", "domain", "name", "abstract_shape", "signature",
    "when_to_query", "prerequisites", "anti_patterns", "failure_modes",
    "known_instantiations", "back_references", "maturity",
    "discovered_via", "notes", "ts",
]


def load_jsonl(path: Path, strict: bool = True) -> list[dict]:
    if not path.exists():
        return []
    out = []
    for i, line in enumerate(path.read_text(encoding="utf-8-sig").splitlines(), 1):
        line = line.strip()
        if not line:
            continue
        try:
            out.append(json.loads(line))
        except json.JSONDecodeError as e:
            if strict:
                raise SystemExit(f"{path}:{i}  JSON parse error: {e}")
            # tolerant mode: skip bad lines in sibling registries
            continue
    return out


def known_rep_ids() -> set[str]:
    return {e["id"] for e in load_jsonl(REPRESENTATIONS_PATH, strict=False) if "id" in e}


def known_playbook_names() -> set[str]:
    return {e.get("name") or e.get("lemma_name") for e in load_jsonl(PLAYBOOK_PATH, strict=False)}


def known_lemma_files() -> set[str]:
    if not LEMMAS_DIR.exists():
        return set()
    return {p.stem for p in LEMMAS_DIR.iterdir() if p.suffix == ".json"}


def known_failure_keys() -> set[str]:
    return {
        f"{e.get('lemma_name')} {e.get('stuck_id', '')}".strip()
        for e in load_jsonl(FAILURES_PATH, strict=False)
    }


def check_entry(e: dict, idx: int, errors: list[str]) -> None:
    where = f"entry #{idx} ({e.get('id', '<no-id>')})"
    for f in REQUIRED_FIELDS:
        if f not in e:
            errors.append(f"{where}: missing field {f!r}")
    cat = e.get("category")
    if cat not in CATEGORY_VOCAB:
        errors.append(f"{where}: bad category {cat!r}")
    dom = e.get("domain")
    if dom not in DOMAIN_VOCAB:
        errors.append(f"{where}: bad domain {dom!r}")
    mat = e.get("maturity")
    if mat not in MATURITY_VOCAB:
        errors.append(f"{where}: bad maturity {mat!r}")


def check_refs(entries: list[dict], errors: list[str]) -> None:
    rep_ids = known_rep_ids()
    pb_names = known_playbook_names()
    lemma_names = known_lemma_files()
    fail_keys = known_failure_keys()
    for i, e in enumerate(entries):
        where = f"entry #{i} ({e.get('id', '<no-id>')})"
        br = e.get("back_references") or {}
        for r in br.get("representations", []):
            if r not in rep_ids:
                errors.append(f"{where}: back_reference rep {r!r} not in registry/representations/")
        for p in br.get("playbook", []):
            if p not in pb_names:
                errors.append(f"{where}: back_reference playbook {p!r} not in registry/playbook/")
        for L in br.get("lemmas", []):
            if L not in lemma_names:
                # lemma names may also live inside the file; accept if file contains it
                if not any(L in (le.get("lemma_name") or "")
                           for path in [PLAYBOOK_PATH] for le in load_jsonl(path)):
                    errors.append(f"{where}: back_reference lemma {L!r} not found")
        for f in br.get("failures", []):
            # failures key is "lemma_name STUCK_id"; also accept just lemma_name
            if not any(f == k or f in k for k in fail_keys):
                errors.append(f"{where}: back_reference failure {f!r} not in registry/failures/")


def check_unique_ids(entries: list[dict], errors: list[str]) -> None:
    seen: dict[str, int] = {}
    for i, e in enumerate(entries):
        eid = e.get("id")
        if not eid:
            continue
        if eid in seen:
            errors.append(f"duplicate id {eid!r}: entries #{seen[eid]} and #{i}")
        else:
            seen[eid] = i


def check_supersede_acyclic(entries: list[dict], errors: list[str]) -> None:
    by_id = {e["id"]: e for e in entries if "id" in e}
    for eid in by_id:
        seen = set()
        cur = eid
        while True:
            if cur in seen:
                errors.append(f"supersede cycle detected through {eid!r}")
                break
            seen.add(cur)
            nxt = by_id.get(cur, {}).get("superseded_by")
            if not nxt:
                break
            cur = nxt


def main() -> int:
    if not DISCOVERIES_PATH.exists():
        print(f"NO_FILE: {DISCOVERIES_PATH}")
        return 1
    entries = load_jsonl(DISCOVERIES_PATH)
    errors: list[str] = []
    for i, e in enumerate(entries):
        check_entry(e, i, errors)
    check_refs(entries, errors)
    check_unique_ids(entries, errors)
    check_supersede_acyclic(entries, errors)
    if errors:
        print(f"FAIL: {len(errors)} error(s) in {len(entries)} entries")
        for er in errors:
            print(f"  {er}")
        return 1
    print(f"OK: {len(entries)} entries valid")
    return 0


if __name__ == "__main__":
    sys.exit(main())
