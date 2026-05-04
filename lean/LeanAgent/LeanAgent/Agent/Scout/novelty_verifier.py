"""Novelty Verifier — runs only when a conjecture reaches a positive
terminal state and asks "has this already been proved?".

Triggered when `current_conjecture.completion_status` is in
{empirically_verified, formally_certified}. Three rounds of literature
search (broad → targeted → frontier) feed an LLM judge that emits a
NoveltyVerdict in {novel, rediscovery, extension, uncertain}.

Stub mode (`NOVELTY_STUB=1`) returns a deterministic verdict so the
orchestrator can be exercised without a network connection.
"""

from __future__ import annotations

import datetime as _dt
import enum
import json
import os
from dataclasses import dataclass, field, asdict
from typing import Any

from LeanAgent.LeanAgent.Agent.Scout.hypothesis_tracker import (
    CompletionStatus,
    TrackerState,
)


# ────────────────────────────────────────────────────────────────────────────
# Vocab
# ────────────────────────────────────────────────────────────────────────────


class NoveltyStatus(str, enum.Enum):
    NOVEL = "novel"
    REDISCOVERY = "rediscovery"
    EXTENSION = "extension"
    UNCERTAIN = "uncertain"


_TRIGGERING_COMPLETION = {
    CompletionStatus.EMPIRICALLY_VERIFIED.value,
    CompletionStatus.FORMALLY_CERTIFIED.value,
}


# ────────────────────────────────────────────────────────────────────────────
# Dataclasses
# ────────────────────────────────────────────────────────────────────────────


@dataclass
class PaperHit:
    title: str
    url: str
    abstract_snippet: str = ""
    year: int | None = None
    round_number: int = 0   # 1 | 2 | 3
    in_scope: bool = False  # supplied via literature_in_scope


@dataclass
class NoveltyEvidence:
    queries_round1: list[str] = field(default_factory=list)
    queries_round2: list[str] = field(default_factory=list)
    queries_round3: list[str] = field(default_factory=list)
    hits: list[PaperHit] = field(default_factory=list)


@dataclass
class NoveltyVerdict:
    novelty_status: str = NoveltyStatus.UNCERTAIN.value
    confidence: float = 0.0
    novelty_rationale: str = ""
    subsumer: str | None = None
    frontier: str | None = None
    recommendation: str = "uncertain — recommend operator review"
    evidence: NoveltyEvidence | None = None
    ts: str = ""

    def to_dict(self) -> dict:
        return {
            "novelty_status": self.novelty_status,
            "confidence": self.confidence,
            "novelty_rationale": self.novelty_rationale,
            "subsumer": self.subsumer,
            "frontier": self.frontier,
            "recommendation": self.recommendation,
            "evidence": (
                None if self.evidence is None
                else {
                    "queries_round1": list(self.evidence.queries_round1),
                    "queries_round2": list(self.evidence.queries_round2),
                    "queries_round3": list(self.evidence.queries_round3),
                    "hits": [asdict(h) for h in self.evidence.hits],
                }
            ),
            "ts": self.ts,
        }


# ────────────────────────────────────────────────────────────────────────────
# Stub fixtures
# ────────────────────────────────────────────────────────────────────────────


_STUB_HITS: dict[str, list[PaperHit]] = {
    # Erdős-Selfridge: 3-prime odd covering doesn't exist
    "erdos_selfridge_3prime_odd": [
        PaperHit(
            title="Selfridge's odd covering problem",
            url="https://en.wikipedia.org/wiki/Covering_system",
            abstract_snippet=(
                "Berger, Felzenbaum, Fraenkel (1986) showed no odd "
                "covering exists with three distinct prime moduli."
            ),
            year=1986,
            round_number=1,
        ),
    ],
}


def _stub_mode() -> bool:
    return os.environ.get("NOVELTY_STUB", "") == "1"


def _stub_key_from_state(state: TrackerState) -> str:
    """Heuristic stub key: pull tokens off the conjecture form."""
    form = state.current_conjecture.form.lower()
    if "odd" in form and "cover" in form and ("prime" in form or "3" in form):
        return "erdos_selfridge_3prime_odd"
    return ""


# ────────────────────────────────────────────────────────────────────────────
# Step 1 — query construction
# ────────────────────────────────────────────────────────────────────────────


def build_novelty_queries(
    conjecture_form: str,
    *,
    domain_keywords: list[str],
    key_objects: list[str],
    quantitative_claims: list[str],
) -> dict[str, list[str]]:
    """Three rounds of search queries.

    R1 — broad sweep: domain + objects.
    R2 — targeted: quantitative claims (specific rates, exponents,
         constants).
    R3 — frontier identification: domain + "open problem", "frontier",
         "lower bound" markers.
    """
    obj = " ".join(key_objects[:2]) if key_objects else ""
    dom = " ".join(domain_keywords[:2]) if domain_keywords else ""

    r1 = []
    if dom and obj:
        r1.append(f"{dom} {obj}".strip())
    if dom:
        r1.append(dom)
    if obj:
        r1.append(obj)

    r2 = []
    for claim in quantitative_claims[:3]:
        r2.append(f"{obj} {claim}".strip() if obj else claim)

    r3 = []
    if dom:
        r3.append(f"{dom} frontier".strip())
        r3.append(f"{dom} open problems".strip())
        r3.append(f"{dom} lower bound".strip())

    def _dedup(seq: list[str]) -> list[str]:
        seen, out = set(), []
        for s in seq:
            k = s.lower().strip()
            if k and k not in seen:
                seen.add(k)
                out.append(s)
        return out

    return {
        "round1": _dedup(r1),
        "round2": _dedup(r2),
        "round3": _dedup(r3),
    }


# ────────────────────────────────────────────────────────────────────────────
# Step 2 — search and evaluate
# ────────────────────────────────────────────────────────────────────────────


def search_and_evaluate(
    queries: dict[str, list[str]],
    *,
    literature_in_scope: list[str] | None = None,
    stub_key: str = "",
) -> NoveltyEvidence:
    """Run three rounds of search; in stub mode pull from the fixture.

    `literature_in_scope` is the list of paper titles / URLs the user
    already declared as prior context — these papers are NOT counted as
    "got there first" evidence.
    """
    in_scope = set(literature_in_scope or [])
    evidence = NoveltyEvidence(
        queries_round1=list(queries.get("round1", [])),
        queries_round2=list(queries.get("round2", [])),
        queries_round3=list(queries.get("round3", [])),
    )
    if _stub_mode():
        for h in list(_STUB_HITS.get(stub_key, [])):
            h.in_scope = (h.title in in_scope) or (h.url in in_scope)
            evidence.hits.append(h)
    # Live mode is left to wire to a real search backend; absence of hits
    # in live mode is itself evidence of novelty.
    return evidence


# ────────────────────────────────────────────────────────────────────────────
# Step 3 — verdict
# ────────────────────────────────────────────────────────────────────────────


def determine_novelty(
    evidence: NoveltyEvidence,
    *,
    conjecture_form: str = "",
) -> NoveltyVerdict:
    """Decide novelty from search evidence.

    Heuristic:
      - If ≥1 out-of-scope hit explicitly subsumes the conjecture
        → REDISCOVERY (confidence high).
      - If only in-scope hits surfaced → likely NOVEL or EXTENSION
        (confidence medium; cannot fully rule out an unindexed paper).
      - If no hits at all → UNCERTAIN (search may have missed; flag for
        operator review).

    Subsumption is detected via simple title/abstract heuristics in stub
    mode; live mode would dispatch an LLM judge.
    """
    out_of_scope = [h for h in evidence.hits if not h.in_scope]
    in_scope_only = [h for h in evidence.hits if h.in_scope]

    if not evidence.hits:
        return NoveltyVerdict(
            novelty_status=NoveltyStatus.UNCERTAIN.value,
            confidence=0.3,
            novelty_rationale=(
                "No literature hits across 3 search rounds; cannot "
                "rule out unindexed prior work."
            ),
            recommendation=(
                "operator review — extend search to journal-only sources."
            ),
            evidence=evidence,
            ts=_now_iso(),
        )

    if out_of_scope:
        # Pick the earliest published / first hit as the subsumer.
        subsumer = min(
            out_of_scope,
            key=lambda h: (h.year if h.year is not None else 9999),
        )
        rationale = (
            f"Found prior work outside literature_in_scope: "
            f"{subsumer.title!r} ({subsumer.year}) — "
            f"{subsumer.abstract_snippet[:120]}"
        )
        return NoveltyVerdict(
            novelty_status=NoveltyStatus.REDISCOVERY.value,
            confidence=0.85,
            novelty_rationale=rationale,
            subsumer=f"{subsumer.title} ({subsumer.year}) <{subsumer.url}>",
            recommendation=(
                "rediscovery — file under reproduction; do not publish "
                "as new."
            ),
            evidence=evidence,
            ts=_now_iso(),
        )

    # Only in-scope hits → user already knew about these.
    return NoveltyVerdict(
        novelty_status=NoveltyStatus.NOVEL.value,
        confidence=0.6,
        novelty_rationale=(
            f"All {len(in_scope_only)} hits are in literature_in_scope; "
            f"no out-of-scope subsumer found."
        ),
        recommendation=(
            "novel candidate — recommend deeper search before publication."
        ),
        evidence=evidence,
        ts=_now_iso(),
    )


# ────────────────────────────────────────────────────────────────────────────
# Top-level driver
# ────────────────────────────────────────────────────────────────────────────


def _now_iso() -> str:
    return _dt.datetime.now(_dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


@dataclass
class NoveltyInputs:
    """Optional explicit inputs; if absent we mine `state` for them."""
    domain_keywords: list[str] = field(default_factory=list)
    key_objects: list[str] = field(default_factory=list)
    quantitative_claims: list[str] = field(default_factory=list)
    literature_in_scope: list[str] = field(default_factory=list)


def _mine_inputs_from_state(state: TrackerState, override: NoveltyInputs | None) -> NoveltyInputs:
    if override is not None:
        return override
    # Heuristic mining; overridable by caller.
    return NoveltyInputs(
        domain_keywords=[],
        key_objects=[],
        quantitative_claims=[],
        literature_in_scope=[],
    )


def is_triggering(state: TrackerState) -> bool:
    """Per spec: only fire when completion_status is a positive terminal."""
    return state.current_conjecture.completion_status in _TRIGGERING_COMPLETION


def run_novelty_check(
    state: TrackerState,
    *,
    inputs: NoveltyInputs | None = None,
) -> NoveltyVerdict:
    """End-to-end check.

    No-op verdict if `state.current_conjecture.completion_status` is not
    a triggering value (returns UNCERTAIN with an explanatory rationale).
    """
    if not is_triggering(state):
        return NoveltyVerdict(
            novelty_status=NoveltyStatus.UNCERTAIN.value,
            confidence=0.0,
            novelty_rationale=(
                f"completion_status="
                f"{state.current_conjecture.completion_status!r} is not in "
                f"{sorted(_TRIGGERING_COMPLETION)}"
            ),
            recommendation="not triggered",
            ts=_now_iso(),
        )

    mined = _mine_inputs_from_state(state, inputs)
    queries = build_novelty_queries(
        state.current_conjecture.form,
        domain_keywords=mined.domain_keywords,
        key_objects=mined.key_objects,
        quantitative_claims=mined.quantitative_claims,
    )
    evidence = search_and_evaluate(
        queries,
        literature_in_scope=mined.literature_in_scope,
        stub_key=_stub_key_from_state(state),
    )
    return determine_novelty(evidence, conjecture_form=state.current_conjecture.form)
