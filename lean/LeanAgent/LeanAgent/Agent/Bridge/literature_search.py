"""Bridge — literature search on Tool Discoverer catalog miss.

Spec: workspace/agents_spec/tool_discoverer.md §H "Relationship with Bridge".

Pipeline:
    obstruction_summary {obstruction_class, mathematical_property_needed,
                         catalog_keywords}
        │
        ▼
    build_search_queries  → list[str]   (3 queries: broad, targeted, frontier)
        │
        ▼
    search_literature     → list[PaperResult]  (top-3 per query, deduped)
        │
        ▼
    evaluate_relevance    → RelevanceVerdict   (LLM judgment per paper)
        │
        ▼
    BridgeResult          {papers_found, relevant_papers, suggested_technique}

Stub mode (`BRIDGE_STUB=1`) returns a fixed Erdős-Selfridge fixture so the
Tool Discoverer can be exercised end-to-end without web access.
"""

from __future__ import annotations

import datetime as _dt
import json
import os
from dataclasses import dataclass, field, asdict
from typing import Any

# ────────────────────────────────────────────────────────────────────────────
# Dataclasses
# ────────────────────────────────────────────────────────────────────────────


@dataclass
class PaperResult:
    title: str
    url: str
    abstract_snippet: str
    year: int | None = None
    relevance_score: float = 0.0
    source: str = "stub"   # "arxiv" | "scholar" | "stub"


@dataclass
class RelevanceVerdict:
    relevant: bool
    technique_summary: str
    applicability_assessment: str
    confidence: float = 0.0


@dataclass
class BridgeResult:
    queries: list[str] = field(default_factory=list)
    papers_found: list[PaperResult] = field(default_factory=list)
    relevant_papers: list[PaperResult] = field(default_factory=list)
    relevance_verdicts: list[RelevanceVerdict] = field(default_factory=list)
    suggested_technique: str | None = None
    ts: str = ""

    def to_dict(self) -> dict:
        return {
            "queries": list(self.queries),
            "papers_found": [asdict(p) for p in self.papers_found],
            "relevant_papers": [asdict(p) for p in self.relevant_papers],
            "relevance_verdicts": [asdict(v) for v in self.relevance_verdicts],
            "suggested_technique": self.suggested_technique,
            "ts": self.ts,
        }


# ────────────────────────────────────────────────────────────────────────────
# Stub fixtures — keyed by obstruction_class
# ────────────────────────────────────────────────────────────────────────────


_STUB_FIXTURES: dict[str, list[PaperResult]] = {
    "combinatorial_blowup": [
        PaperResult(
            title="Solution of the minimum modulus problem for covering systems",
            url="https://arxiv.org/abs/1305.6981",
            abstract_snippet=(
                "We answer the minimum modulus question of Erdős by showing "
                "that every distinct covering system has a modulus not "
                "exceeding 10^16, via the probabilistic method."
            ),
            year=2015,
            source="stub",
        ),
        PaperResult(
            title="Covering systems with restricted divisibility",
            url="https://arxiv.org/abs/2104.04484",
            abstract_snippet=(
                "Probabilistic / expectation-bound techniques on covering "
                "systems extend to restricted divisibility classes."
            ),
            year=2021,
            source="stub",
        ),
        PaperResult(
            title="Lovász local lemma over arithmetic progressions",
            url="https://arxiv.org/abs/2010.00000",
            abstract_snippet=(
                "An LLL-style argument bounds union sizes of AP families "
                "without enumeration."
            ),
            year=2020,
            source="stub",
        ),
    ],
    "missing_lower_bound": [
        PaperResult(
            title="Le Cam's two-point method for stochastic optimization",
            url="https://arxiv.org/abs/1909.02365",
            abstract_snippet=(
                "Le Cam's two-point method combined with KL chain rule "
                "yields tight variance lower bounds for adaptive "
                "stochastic queries."
            ),
            year=2019,
            source="stub",
        ),
    ],
    "intractable_certificate": [
        PaperResult(
            title="Performance Estimation Problems via SDP",
            url="https://arxiv.org/abs/1502.05666",
            abstract_snippet=(
                "Worst-case performance of first-order methods is "
                "computable via semidefinite relaxation."
            ),
            year=2015,
            source="stub",
        ),
    ],
}


def _stub_fixture(obstruction_class: str) -> list[PaperResult]:
    return list(_STUB_FIXTURES.get(obstruction_class, []))


# ────────────────────────────────────────────────────────────────────────────
# Step 1 — query construction
# ────────────────────────────────────────────────────────────────────────────


def build_search_queries(
    obstruction_class: str,
    mathematical_property_needed: str,
    catalog_keywords: list[str],
    *,
    domain: str | None = None,
) -> list[str]:
    """Build 2–3 short queries (3–6 words each) suitable for arXiv / Scholar.

    Strategy:
      Q1 — broad: pair the property with the top-1 catalog keyword.
      Q2 — targeted: stack the top-2 catalog keywords with one property noun.
      Q3 — domain-bounded (if domain is supplied): keyword + domain.
    """
    if not catalog_keywords:
        # Fall back to property text alone; truncate to ~6 words.
        words = mathematical_property_needed.split()[:6]
        return [" ".join(words) or obstruction_class.replace("_", " ")]

    head_kw = catalog_keywords[0]
    second_kw = catalog_keywords[1] if len(catalog_keywords) >= 2 else head_kw

    # extract the first noun-like span of the property text
    property_short = " ".join(
        mathematical_property_needed.replace(",", " ").split()[:4]
    )

    queries: list[str] = []
    queries.append(f"{head_kw} {property_short}".strip())
    queries.append(f"{head_kw} {second_kw}".strip())
    if domain:
        queries.append(f"{head_kw} {domain}".strip())

    # Deduplicate while preserving order.
    seen: set[str] = set()
    out: list[str] = []
    for q in queries:
        key = q.lower().strip()
        if key and key not in seen:
            seen.add(key)
            out.append(q)
    return out


# ────────────────────────────────────────────────────────────────────────────
# Step 2 — literature search
# ────────────────────────────────────────────────────────────────────────────


def _stub_mode() -> bool:
    return os.environ.get("BRIDGE_STUB", "") == "1"


def search_literature(
    queries: list[str],
    *,
    obstruction_class: str | None = None,
    top_k_per_query: int = 3,
) -> list[PaperResult]:
    """Run web / arXiv search.

    Stub mode returns the obstruction-keyed fixture verbatim (ignores
    `queries`). Live mode is left as a placeholder — the Phase-2 plan is
    to wire this to Semantic Scholar / arXiv. Until then, a non-stub call
    raises so callers do not silently degrade to nothing.
    """
    if _stub_mode():
        if obstruction_class is None:
            return []
        return _stub_fixture(obstruction_class)[:top_k_per_query]

    raise NotImplementedError(
        "live literature search not wired yet — set BRIDGE_STUB=1 to use "
        "the canned fixture, or implement the Semantic Scholar / arXiv "
        "client."
    )


# ────────────────────────────────────────────────────────────────────────────
# Step 3 — relevance evaluation
# ────────────────────────────────────────────────────────────────────────────


def evaluate_relevance(
    paper: PaperResult,
    obstruction_class: str,
    mathematical_property_needed: str,
    *,
    llm: Any | None = None,
) -> RelevanceVerdict:
    """Decide whether the paper's technique defuses the obstruction.

    Stub mode short-circuits to a deterministic verdict using simple
    keyword matching. Live mode dispatches a 1-shot LLM call (caller
    passes an `LLM` instance from `Agent_legacy.LLM`).
    """
    if _stub_mode() or llm is None:
        # Heuristic keyword overlap: count obstruction-class tokens that
        # show up in the abstract (case-insensitive).
        abstract = paper.abstract_snippet.lower()
        # tokens drawn from the obstruction class itself
        cls_tokens = obstruction_class.replace("_", " ").lower().split()
        # plus property nouns
        prop_tokens = [
            t.lower()
            for t in mathematical_property_needed.split()
            if len(t) >= 4
        ][:6]
        hits = sum(1 for t in cls_tokens + prop_tokens if t in abstract)
        relevant = hits >= 2
        confidence = min(1.0, 0.4 + 0.15 * hits)
        if relevant:
            tech = (
                f"From abstract: {paper.abstract_snippet[:140]}"
                if paper.abstract_snippet
                else paper.title
            )
            apply = (
                f"Plausibly applies to obstruction_class={obstruction_class}; "
                f"keyword-overlap hits={hits}"
            )
        else:
            tech = paper.title
            apply = (
                f"Low keyword overlap (hits={hits}); flag as uncertain "
                f"rather than relevant."
            )
        return RelevanceVerdict(
            relevant=relevant,
            technique_summary=tech,
            applicability_assessment=apply,
            confidence=confidence,
        )

    # Live LLM path — dispatched via Agent_legacy.LLM.LLM.ask(...).
    prompt = (
        f"Obstruction class: {obstruction_class}\n"
        f"Mathematical property needed: {mathematical_property_needed}\n"
        f"Paper title: {paper.title}\n"
        f"Abstract snippet: {paper.abstract_snippet}\n\n"
        "Respond as JSON with keys "
        "{relevant: bool, technique_summary: str, "
        "applicability_assessment: str, confidence: float}."
    )
    response = llm.ask(
        stage="bridge",
        task="evaluate_relevance",
        prompt=prompt,
        max_tokens=512,
    )
    try:
        data = json.loads(response.text)
        return RelevanceVerdict(
            relevant=bool(data.get("relevant", False)),
            technique_summary=str(data.get("technique_summary", "")),
            applicability_assessment=str(data.get("applicability_assessment", "")),
            confidence=float(data.get("confidence", 0.0)),
        )
    except (json.JSONDecodeError, ValueError, TypeError):
        return RelevanceVerdict(
            relevant=False,
            technique_summary="(LLM response unparseable)",
            applicability_assessment=response.text[:200],
            confidence=0.0,
        )


# ────────────────────────────────────────────────────────────────────────────
# Top-level entry
# ────────────────────────────────────────────────────────────────────────────


def _now_iso() -> str:
    return _dt.datetime.now(_dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def run_bridge(
    obstruction_summary: dict,
    *,
    domain: str | None = None,
    top_k_per_query: int = 3,
    llm: Any | None = None,
) -> BridgeResult:
    """End-to-end bridge call.

    `obstruction_summary` matches the Tool Discoverer output shape:
      {
        obstruction_class           : str (must be in the catalog),
        mathematical_property_needed: str,
        catalog_keywords            : list[str],
        catalog_typical_category    : str
      }
    """
    obstruction_class = obstruction_summary.get("obstruction_class", "")
    property_needed = obstruction_summary.get(
        "mathematical_property_needed", ""
    )
    keywords = obstruction_summary.get("catalog_keywords", []) or []

    queries = build_search_queries(
        obstruction_class,
        property_needed,
        list(keywords),
        domain=domain,
    )
    papers = search_literature(
        queries,
        obstruction_class=obstruction_class,
        top_k_per_query=top_k_per_query,
    )

    verdicts: list[RelevanceVerdict] = []
    relevant: list[PaperResult] = []
    for p in papers:
        v = evaluate_relevance(
            p, obstruction_class, property_needed, llm=llm
        )
        verdicts.append(v)
        if v.relevant:
            # Use the verdict's confidence as the paper's relevance_score.
            p.relevance_score = v.confidence
            relevant.append(p)

    # Pick the top-confidence verdict (if any) as the suggested technique.
    suggested: str | None = None
    if relevant:
        relevant.sort(key=lambda p: p.relevance_score, reverse=True)
        # Pull the matching verdict for that paper.
        top_paper = relevant[0]
        for v in verdicts:
            if v.technique_summary.startswith(top_paper.title) or (
                v.relevant and top_paper.title in v.technique_summary
            ):
                suggested = v.technique_summary
                break
        if suggested is None:
            suggested = relevant[0].title

    return BridgeResult(
        queries=queries,
        papers_found=papers,
        relevant_papers=relevant,
        relevance_verdicts=verdicts,
        suggested_technique=suggested,
        ts=_now_iso(),
    )


# ────────────────────────────────────────────────────────────────────────────
# Gap-2: extended trigger entry point
#   Spec: workspace/agents_spec/tool_discoverer.md §H.2.
#   Three trigger sources: Strategy Proposer (priority 1) > Diagnoser (2)
#   > Tool Discoverer fallback (3). Backward-compatible — does not modify
#   `run_bridge()`.
# ────────────────────────────────────────────────────────────────────────────


def _papers_from_queries(
    queries: list[str],
    *,
    obstruction_class: str = "",
    top_k_per_query: int = 3,
    llm: Any | None = None,
    domain: str | None = None,
    property_needed: str = "",
) -> BridgeResult:
    """Common search-and-evaluate path used by the trigger router."""
    papers = search_literature(
        queries,
        obstruction_class=obstruction_class,
        top_k_per_query=top_k_per_query,
    )
    verdicts: list[RelevanceVerdict] = []
    relevant: list[PaperResult] = []
    for p in papers:
        v = evaluate_relevance(
            p, obstruction_class, property_needed, llm=llm
        )
        verdicts.append(v)
        if v.relevant:
            p.relevance_score = v.confidence
            relevant.append(p)
    suggested: str | None = None
    if relevant:
        relevant.sort(key=lambda p: p.relevance_score, reverse=True)
        suggested = relevant[0].title
        for v in verdicts:
            if v.relevant and (
                v.technique_summary.startswith(relevant[0].title)
                or relevant[0].title in v.technique_summary
            ):
                suggested = v.technique_summary
                break
    return BridgeResult(
        queries=queries,
        papers_found=papers,
        relevant_papers=relevant,
        relevance_verdicts=verdicts,
        suggested_technique=suggested,
        ts=_now_iso(),
    )


def run_bridge_with_triggers(
    *,
    strategy_queries: list[str] | None = None,
    diagnoser_trigger: Any | None = None,                # diagnoser.BridgeTrigger; typed loose to avoid import cycle
    obstruction_summary: dict | None = None,
    domain: str | None = None,
    top_k_per_query: int = 3,
    llm: Any | None = None,
) -> BridgeResult:
    """Three-trigger Bridge entry point per `tool_discoverer.md §H.2`.

    Priority:
      1. `strategy_queries`  — vetted by Strategy Proposer
      2. `diagnoser_trigger` — synthesised from a structural pattern
      3. `obstruction_summary` — Tool Discoverer fallback (delegates to run_bridge)

    Empty input yields an empty BridgeResult (callers should guard).
    """
    # Priority 1 — Strategy Proposer
    if strategy_queries:
        return _papers_from_queries(
            list(strategy_queries),
            obstruction_class=(obstruction_summary or {}).get("obstruction_class", ""),
            top_k_per_query=top_k_per_query,
            llm=llm,
            domain=domain,
            property_needed=(obstruction_summary or {}).get("mathematical_property_needed", ""),
        )

    # Priority 2 — Diagnoser direct
    if diagnoser_trigger is not None:
        # Duck-typed extraction; works whether we get a BridgeTrigger dataclass
        # or a plain dict.
        q = getattr(diagnoser_trigger, "query", None)
        if q is None and isinstance(diagnoser_trigger, dict):
            q = diagnoser_trigger.get("query")
        pattern = getattr(diagnoser_trigger, "pattern", None)
        if pattern is None and isinstance(diagnoser_trigger, dict):
            pattern = diagnoser_trigger.get("pattern")
        if not q:
            return BridgeResult(queries=[], ts=_now_iso())
        queries: list[str] = [q]
        if pattern:
            queries.append(f"{pattern} alternative")
        return _papers_from_queries(
            queries,
            obstruction_class=(obstruction_summary or {}).get("obstruction_class", ""),
            top_k_per_query=top_k_per_query,
            llm=llm,
            domain=domain,
            property_needed=(obstruction_summary or {}).get("mathematical_property_needed", ""),
        )

    # Priority 3 — Tool Discoverer fallback
    if obstruction_summary:
        return run_bridge(
            obstruction_summary,
            domain=domain,
            top_k_per_query=top_k_per_query,
            llm=llm,
        )

    return BridgeResult(queries=[], ts=_now_iso())
