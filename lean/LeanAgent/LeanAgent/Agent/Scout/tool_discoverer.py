"""Tool Discoverer — obstruction-keyed dispatch into the discoveries channel.

Spec: workspace/agents_spec/tool_discoverer.md
       §C input contract, §D query strategy, §E output contract,
       §I Erdős-Selfridge worked example.

Pure-Python: no LLM call on the hot path. Bridge invocation (§H) is
optional and routed through `LeanAgent.LeanAgent.Agent.Bridge`.
"""

from __future__ import annotations

import datetime as _dt
import json
import re
from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Any, Iterable

from LeanAgent.LeanAgent.Agent.Scout.hypothesis_tracker import (
    OBSTRUCTION_CLASSES,
)


# ────────────────────────────────────────────────────────────────────────────
# Paths
# ────────────────────────────────────────────────────────────────────────────


_DEFAULT_DISCOVERIES = (
    Path(__file__).resolve().parents[3]
    / "registry" / "discoveries" / "entries.jsonl"
)
_DEFAULT_CATALOG = (
    Path(__file__).resolve().parents[4]
    / "workspace" / "agents_spec" / "obstruction_catalog.md"
)


# ────────────────────────────────────────────────────────────────────────────
# Dataclasses
# ────────────────────────────────────────────────────────────────────────────


@dataclass
class DiscoveryEntry:
    id: str
    category: str
    domain: str
    name: str
    maturity: str  # seed | conjectural | validated_once | validated_multi | promoted_to_playbook
    defuses_obstruction: list[str] = field(default_factory=list)
    failure_modes: list[dict] = field(default_factory=list)
    raw: dict = field(default_factory=dict)


_MATURITY_RANK = {
    "promoted_to_playbook": 1,
    "validated_multi": 3,
    "validated_once": 2,
    "conjectural": 1,
    "seed": 0,
}


@dataclass
class Candidate:
    discovery_id: str | None
    category: str
    rationale: str
    fit_score: float
    prerequisites_met: bool | str  # True | False | "unknown"
    suggested_query: str = ""
    is_synthesis: bool = False
    back_references: dict = field(default_factory=dict)


@dataclass
class ToolDiscovererInput:
    object: str
    domain: str
    current_rep_id: str
    current_technique: str
    obstruction_class: str
    mathematical_property_needed: str
    propagation_path: str
    trigger_reason: str = "ternary_judge"  # | wh_chain_stagnation | operator_override
    tried_discoveries: list[str] = field(default_factory=list)
    wh_at_trigger: str | None = None
    evidence_pointer: str | None = None
    query_kind: str = "tool_discoverer"

    def validate(self) -> None:
        if self.obstruction_class not in OBSTRUCTION_CLASSES:
            raise ValueError(
                f"obstruction_class {self.obstruction_class!r} not in catalog "
                f"vocab {sorted(OBSTRUCTION_CLASSES)}"
            )
        valid_triggers = {
            "ternary_judge", "wh_chain_stagnation", "operator_override"
        }
        if self.trigger_reason not in valid_triggers:
            raise ValueError(
                f"trigger_reason {self.trigger_reason!r} not in {valid_triggers}"
            )


@dataclass
class ToolDiscovererOutput:
    candidates: list[Candidate] = field(default_factory=list)
    obstruction_summary: dict = field(default_factory=dict)
    trigger_reason: str = ""
    registry_snapshot: str = ""
    bridge_result: dict | None = None
    ts: str = ""

    def to_dict(self) -> dict:
        return {
            "candidates": [asdict(c) for c in self.candidates],
            "obstruction_summary": dict(self.obstruction_summary),
            "trigger_reason": self.trigger_reason,
            "registry_snapshot": self.registry_snapshot,
            "bridge_result": self.bridge_result,
            "ts": self.ts,
        }


# ────────────────────────────────────────────────────────────────────────────
# Discoveries loader
# ────────────────────────────────────────────────────────────────────────────


def load_discoveries(path: Path | str | None = None) -> list[DiscoveryEntry]:
    p = Path(path) if path else _DEFAULT_DISCOVERIES
    if not p.exists():
        return []
    out: list[DiscoveryEntry] = []
    for line in p.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
        except json.JSONDecodeError:
            continue
        out.append(DiscoveryEntry(
            id=obj.get("id", ""),
            category=obj.get("category", ""),
            domain=obj.get("domain", ""),
            name=obj.get("name", ""),
            maturity=obj.get("maturity", "seed"),
            defuses_obstruction=list(obj.get("defuses_obstruction") or []),
            failure_modes=list(obj.get("failure_modes") or []),
            raw=obj,
        ))
    return out


# ────────────────────────────────────────────────────────────────────────────
# Obstruction-catalog loader (§D.2)
# ────────────────────────────────────────────────────────────────────────────


def _parse_catalog_table(text: str) -> dict[str, dict]:
    """Parse the §A markdown table from obstruction_catalog.md.

    Returns: {obstruction_class -> {meaning, search_keywords, typical_category}}
    """
    out: dict[str, dict] = {}
    in_table = False
    header_seen = False
    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line:
            in_table = False
            continue
        if line.startswith("|") and "obstruction_class" in line.lower():
            in_table = True
            header_seen = True
            continue
        if in_table and line.startswith("|---"):
            continue
        if in_table and line.startswith("|"):
            cells = [c.strip() for c in line.strip("|").split("|")]
            if len(cells) < 4:
                continue
            cls = cells[0].strip("`").strip()
            if cls not in OBSTRUCTION_CLASSES:
                continue
            meaning = cells[1]
            keywords = [k.strip() for k in cells[2].split(",") if k.strip()]
            category = cells[3].strip("`").strip()
            out[cls] = {
                "meaning": meaning,
                "search_keywords": keywords,
                "typical_category": category,
            }
        elif in_table:
            in_table = False
    if not header_seen:
        return {}
    return out


def load_catalog(path: Path | str | None = None) -> dict[str, dict]:
    p = Path(path) if path else _DEFAULT_CATALOG
    if not p.exists():
        return {}
    return _parse_catalog_table(p.read_text(encoding="utf-8"))


def catalog_fallback(obstruction_class: str, *, catalog: dict[str, dict] | None = None) -> dict:
    """Return the catalog row for `obstruction_class`, or an empty stub."""
    cat = catalog if catalog is not None else load_catalog()
    return cat.get(obstruction_class, {
        "meaning": "",
        "search_keywords": [],
        "typical_category": "",
    })


# ────────────────────────────────────────────────────────────────────────────
# Mode-3 query (§D.1)
# ────────────────────────────────────────────────────────────────────────────


_VALID_MATURITIES_FOR_QUERY = {
    "validated_once",
    "validated_multi",
    "promoted_to_playbook",
}


def _maturity_rank(m: str) -> int:
    return _MATURITY_RANK.get(m, -1)


def _domain_match_score(entry_domain: str, query_domain: str) -> float:
    if entry_domain == query_domain:
        return 1.0
    if entry_domain == "meta" or query_domain == "meta":
        return 0.5
    return 0.0


def _category_match_score(entry_category: str, typical_category: str) -> float:
    if not typical_category:
        return 0.5
    return 1.0 if entry_category == typical_category else 0.0


def _maturity_match_score(maturity: str) -> float:
    if maturity == "validated_multi":
        return 1.0
    if maturity == "validated_once":
        return 0.5
    return 0.0  # promoted_to_playbook ranks below validated_multi for fit_score


def mode3_query(
    obstruction_class: str,
    *,
    domain: str,
    typical_category: str,
    tried_discoveries: Iterable[str] = (),
    entries: list[DiscoveryEntry] | None = None,
    top_k: int = 3,
) -> list[Candidate]:
    """Mode-3 obstruction-keyed query against discoveries/entries.jsonl."""
    if entries is None:
        entries = load_discoveries()
    tried = set(tried_discoveries or [])

    candidates_with_score: list[tuple[float, DiscoveryEntry]] = []
    for entry in entries:
        if entry.id in tried:
            continue
        if obstruction_class not in entry.defuses_obstruction:
            continue
        if entry.maturity not in _VALID_MATURITIES_FOR_QUERY:
            continue

        obstruction_match = 1.0  # already filtered, so always 1.0
        domain_score = _domain_match_score(entry.domain, domain)
        maturity_score = _maturity_match_score(entry.maturity)
        category_score = _category_match_score(entry.category, typical_category)

        # Per §E: fit_score = 0.5 * obstruction_match + 0.3 * domain_match
        #                   + 0.2 * maturity_match
        fit_score = (
            0.5 * obstruction_match
            + 0.3 * domain_score
            + 0.2 * maturity_score
        )
        # Use a tuple sort key; primary maturity (validated_multi > validated_once
        # > promoted_to_playbook), then domain_match, then category, then
        # quaternary "fewer failure_modes" (well-charted preferred).
        sort_key = (
            -_maturity_rank(entry.maturity),
            -domain_score,
            -category_score,
            len(entry.failure_modes),
        )
        candidates_with_score.append((sort_key, fit_score, entry))  # type: ignore

    candidates_with_score.sort(key=lambda t: t[0])

    out: list[Candidate] = []
    for _, fit_score, entry in candidates_with_score[:top_k]:
        rationale = (
            f"defuses {obstruction_class!r}; matures at {entry.maturity!r}; "
            f"domain {entry.domain!r} vs query {domain!r}; "
            f"category {entry.category!r}"
        )
        prereq = "unknown"  # full prereq probe is §D.3 / Phase-2
        out.append(Candidate(
            discovery_id=entry.id,
            category=entry.category,
            rationale=rationale,
            fit_score=round(fit_score, 4),
            prerequisites_met=prereq,
            suggested_query="",
            is_synthesis=False,
            back_references=entry.raw.get("back_references", {}),
        ))
    return out


# ────────────────────────────────────────────────────────────────────────────
# Catalog-fallback synthesis (§D.2)
# ────────────────────────────────────────────────────────────────────────────


def synthesis_from_catalog(
    obstruction_class: str,
    mathematical_property_needed: str,
    *,
    catalog: dict[str, dict] | None = None,
) -> tuple[Candidate | None, dict]:
    row = catalog_fallback(obstruction_class, catalog=catalog)
    keywords = row.get("search_keywords", []) or []
    typical_category = row.get("typical_category", "") or ""

    if not keywords:
        # Truly empty fallback — caller emits `technique_gap_unresolved`.
        return None, row

    suggested_query = (
        f"{mathematical_property_needed} -- "
        f"keywords: {', '.join(keywords)}"
    )
    cand = Candidate(
        discovery_id=None,
        category=typical_category or "proof_technique",
        rationale=(
            f"no Mode-3 match; catalog suggests {typical_category!r} family. "
            f"Keywords: {', '.join(keywords)}"
        ),
        fit_score=0.5,  # baseline obstruction match only
        prerequisites_met="unknown",
        suggested_query=suggested_query,
        is_synthesis=True,
        back_references={},
    )
    return cand, row


# ────────────────────────────────────────────────────────────────────────────
# Top-level driver
# ────────────────────────────────────────────────────────────────────────────


def _now_iso() -> str:
    return _dt.datetime.now(_dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _registry_snapshot(entries: list[DiscoveryEntry]) -> str:
    return f"rows={len(entries)}"


def run_tool_discoverer(
    payload: ToolDiscovererInput | dict,
    *,
    discoveries_path: Path | str | None = None,
    catalog_path: Path | str | None = None,
    invoke_bridge: bool = False,
    bridge_kwargs: dict | None = None,
) -> ToolDiscovererOutput:
    """End-to-end Tool Discoverer call.

    Steps (per spec §D):
      1. Mode-3 query against discoveries/entries.jsonl.
      2. If empty → catalog fallback → synthesis candidate (or empty).
      3. If `invoke_bridge` and there is a synthesis candidate, fire Bridge.
    """
    if isinstance(payload, dict):
        payload = ToolDiscovererInput(
            **{k: v for k, v in payload.items()
               if k in ToolDiscovererInput.__dataclass_fields__}
        )
    payload.validate()

    entries = load_discoveries(discoveries_path)
    catalog = load_catalog(catalog_path)
    catalog_row = catalog.get(payload.obstruction_class, {})
    typical_category = catalog_row.get("typical_category", "")

    candidates = mode3_query(
        payload.obstruction_class,
        domain=payload.domain,
        typical_category=typical_category,
        tried_discoveries=payload.tried_discoveries,
        entries=entries,
    )

    obstruction_summary = {
        "obstruction_class": payload.obstruction_class,
        "mathematical_property_needed": payload.mathematical_property_needed,
        "catalog_keywords": list(catalog_row.get("search_keywords", []) or []),
        "catalog_typical_category": typical_category,
    }

    bridge_result: dict | None = None

    # Mode-3 returned nothing → try catalog fallback.
    if not candidates:
        synth_cand, _ = synthesis_from_catalog(
            payload.obstruction_class,
            payload.mathematical_property_needed,
            catalog=catalog,
        )
        if synth_cand is not None:
            candidates = [synth_cand]
            if invoke_bridge:
                bridge_result = _try_bridge(
                    obstruction_summary,
                    domain=payload.domain,
                    bridge_kwargs=bridge_kwargs or {},
                )

    return ToolDiscovererOutput(
        candidates=candidates,
        obstruction_summary=obstruction_summary,
        trigger_reason=payload.trigger_reason,
        registry_snapshot=_registry_snapshot(entries),
        bridge_result=bridge_result,
        ts=_now_iso(),
    )


def _try_bridge(obstruction_summary: dict, *, domain: str, bridge_kwargs: dict) -> dict | None:
    try:
        from LeanAgent.LeanAgent.Agent.Bridge import literature_search as _ls
    except ImportError:  # pragma: no cover
        return None
    try:
        result = _ls.run_bridge(
            obstruction_summary, domain=domain, **bridge_kwargs
        )
        return result.to_dict()
    except NotImplementedError:
        # Live mode is not wired; degrade silently.
        return None
