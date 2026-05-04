"""Rep Selector — file-read + filter on representations registry.

Spec: LeanAgent/registry/representations/SCHEMA.md §C — Architect probe.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path


# Default canonical path; tests may override.
_DEFAULT_REGISTRY = (
    Path(__file__).resolve().parents[3]                          # LeanAgent/
    / "registry" / "representations" / "entries.jsonl"
)


# Qualifier ranking (higher is better) per SCHEMA §C.3.
_QUALIFIER_RANK = {
    "EXACT": 3,
    "EXHAUSTIVE_ON_SAMPLE": 2,
    "NUMERICAL": 1,
    "INCOMPLETE": 0,
}

# Cost ranking (lower is cheaper) per SCHEMA §A.2.
_COST_RANK = {"cheap": 0, "moderate": 1, "expensive": 2}


@dataclass
class RepEntry:
    id: str
    object: str
    domain: str
    representation: str
    formal_form: str
    tools_required: list
    tools_status: str
    transport_to: list
    verification_qualifier: str
    source_problem: str
    status: str
    failure_mode: str | None = None
    notes: str = ""
    raw: dict | None = None                          # full original JSON

    @classmethod
    def from_dict(cls, d: dict) -> "RepEntry":
        return cls(
            id=d.get("id", ""),
            object=d.get("object", ""),
            domain=d.get("domain", ""),
            representation=d.get("representation", ""),
            formal_form=d.get("formal_form", ""),
            tools_required=d.get("tools_required", []) or [],
            tools_status=d.get("tools_status", "missing"),
            transport_to=d.get("transport_to", []) or [],
            verification_qualifier=d.get("verification_qualifier", "INCOMPLETE"),
            source_problem=d.get("source_problem", ""),
            status=d.get("status", "conjectural"),
            failure_mode=d.get("failure_mode"),
            notes=d.get("notes", ""),
            raw=d,
        )


def load_representations(path: str | Path | None = None) -> list[RepEntry]:
    """Read registry/representations/entries.jsonl and return non-empty parsed rows."""
    p = Path(path) if path else _DEFAULT_REGISTRY
    if not p.exists():
        return []
    out: list[RepEntry] = []
    for line in p.read_text(encoding="utf-8-sig").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            d = json.loads(line)
        except json.JSONDecodeError:
            continue
        out.append(RepEntry.from_dict(d))
    return out


def _transport_in_degree(rep_id: str, all_reps: list[RepEntry]) -> int:
    n = 0
    for r in all_reps:
        for edge in r.transport_to:
            if edge.get("target_rep_id") == rep_id:
                n += 1
    return n


def _cheapest_outgoing_cost(rep: RepEntry) -> int:
    """Lower is better; default to expensive when no edges."""
    if not rep.transport_to:
        return _COST_RANK["expensive"]
    return min(
        (_COST_RANK.get(e.get("cost", "expensive"), _COST_RANK["expensive"])
         for e in rep.transport_to),
        default=_COST_RANK["expensive"],
    )


def _matches_object(rep: RepEntry, object_keywords: str | list[str]) -> bool:
    """Substring match on object/representation/notes — domain-agnostic.

    The SCHEMA describes this as 'object_keywords match'; we implement
    case-insensitive substring over (object, representation, notes).
    """
    if isinstance(object_keywords, str):
        kw = [object_keywords.lower()] if object_keywords else []
    else:
        kw = [k.lower() for k in object_keywords if k]
    if not kw:
        return True                                  # no keyword → all match
    blob = f"{rep.object} {rep.representation} {rep.notes}".lower()
    return any(k in blob for k in kw)


def select_rep(
    *,
    object: str | list[str],
    domain: str,
    reps: list[RepEntry] | None = None,
) -> dict:
    """Per SCHEMA §C.

    Returns a dict with shape:
      { "preferred_starting_rep": <rep_id> or None,
        "representations": [<RepEntry>, ...],            # ranked candidates
        "warnings": [...] }
    """
    if reps is None:
        reps = load_representations()
    if not reps:
        return {"preferred_starting_rep": None, "representations": [], "warnings": []}

    matches = [
        r for r in reps
        if _matches_object(r, object)
        and (r.domain == domain or r.domain == "meta")
        and r.status != "disproved"
    ]

    if not matches:
        return {
            "preferred_starting_rep": None,
            "representations": [],
            "warnings": [f"no rep matches (object='{object}', domain='{domain}')"],
        }

    # Ranking key per SCHEMA §C.3 — descending sort, so we negate where applicable.
    def _key(r: RepEntry) -> tuple:
        return (
            r.tools_status == "available",                       # primary, True > False
            _transport_in_degree(r.id, reps),                    # secondary
            _QUALIFIER_RANK.get(r.verification_qualifier, 0),    # tertiary
            -_cheapest_outgoing_cost(r),                         # quaternary (cheapest preferred → larger -cost)
        )

    ranked = sorted(matches, key=_key, reverse=True)
    warnings: list[str] = []
    for r in ranked[:3]:
        if r.status == "conjectural":
            warnings.append(f"{r.id} is conjectural (qualifier: {r.verification_qualifier})")
        if r.tools_status != "available":
            warnings.append(f"{r.id} tools_status={r.tools_status}")
    return {
        "preferred_starting_rep": ranked[0].id,
        "representations": ranked,
        "warnings": warnings,
    }
