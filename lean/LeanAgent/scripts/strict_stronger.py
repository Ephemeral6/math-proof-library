#!/usr/bin/env python3
"""Strict-stronger filter for the representation registry.

Implements the four-way comparison referenced in five places across the
architecture (representations/SCHEMA.md §C.4 anti-strictly-stronger filter,
agents_spec/explain_why_prompt.md §A.2 step 3 + §E.3, agents_spec/instance_sorter.md §D,
architecture_v2.md §III, architecture_report.md Q1).

Three-tier compare:
  Tier 1 — registry implies_reps graph (cheap, exact)
  Tier 2 — Lean implication probe (when both have formal_form)
  Tier 3 — LLM 4-way classification (fallback)

Spec source of truth:
  - LeanAgent/registry/representations/SCHEMA.md §A (implies_reps field)
  - LeanAgent/registry/representations/SCHEMA.md §C.4 (filter rule)
  - workspace/agents_spec/explain_why_prompt.md §A.2/§E.3 (LLM-side filter)
  - workspace/agents_spec/instance_sorter.md §D (counterfactual claim)

Usage:
    from strict_stronger import compare, load_registry_ctx, Predicate, Verdict
    ctx = load_registry_ctx()
    v = compare(Predicate(rep_id="rep_022_chordal_peo"),
                Predicate(rep_id="rep_021_dismantlable_graph"),
                ctx)
    # v == Verdict.STRICTLY_STRONGER

Self-test:
    python3 LeanAgent/scripts/strict_stronger.py
"""

from __future__ import annotations

import enum
import json
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

REPO_ROOT = Path(__file__).resolve().parents[2]
REPRESENTATIONS_PATH = REPO_ROOT / "LeanAgent" / "registry" / "representations" / "entries.jsonl"


class Verdict(enum.Enum):
    STRICTLY_STRONGER = "STRICTLY_STRONGER"
    STRICTLY_WEAKER = "STRICTLY_WEAKER"
    EQUIVALENT = "EQUIVALENT"
    INCOMPARABLE = "INCOMPARABLE"


@dataclass(frozen=True)
class Predicate:
    """A predicate to be compared against another predicate over the same
    underlying object class. At least one of (rep_id, formal_form, nl)
    must be set; rep_id is preferred (drives the Tier-1 path)."""
    rep_id: Optional[str] = None
    formal_form: Optional[str] = None
    nl: str = ""
    source_iter: Optional[int] = None


@dataclass
class RegistryCtx:
    """Cached registry view for compare()."""
    entries_by_id: dict[str, dict] = field(default_factory=dict)
    implies_graph: dict[str, set[str]] = field(default_factory=dict)
    objects: dict[str, str] = field(default_factory=dict)  # rep_id -> object

    def implies(self, rep_id: str) -> set[str]:
        """Transitive closure of implies_reps from rep_id."""
        if rep_id not in self.implies_graph:
            return set()
        out: set[str] = set()
        stack = [rep_id]
        while stack:
            cur = stack.pop()
            for nxt in self.implies_graph.get(cur, set()):
                if nxt not in out:
                    out.add(nxt)
                    stack.append(nxt)
        return out

    def same_object(self, a: str, b: str) -> bool:
        return self.objects.get(a) == self.objects.get(b)


def load_registry_ctx(path: Path = REPRESENTATIONS_PATH) -> RegistryCtx:
    """Parse entries.jsonl and build the implies graph."""
    ctx = RegistryCtx()
    if not path.exists():
        return ctx
    for line in path.read_text(encoding="utf-8-sig").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            e = json.loads(line)
        except json.JSONDecodeError:
            continue
        rid = e.get("id")
        if not rid:
            continue
        ctx.entries_by_id[rid] = e
        ctx.objects[rid] = e.get("object", "")
        # implies_reps is the new field added by SCHEMA bump; default empty.
        implies = e.get("implies_reps") or []
        ctx.implies_graph[rid] = set(implies)
    return ctx


def _tier1_registry(p_a: Predicate, p_b: Predicate, ctx: RegistryCtx) -> Optional[Verdict]:
    """Cheap registry check via implies_reps graph. Returns None if either
    rep_id is missing or both reps are over different objects (can't compare)."""
    if not (p_a.rep_id and p_b.rep_id):
        return None
    if p_a.rep_id not in ctx.entries_by_id or p_b.rep_id not in ctx.entries_by_id:
        return None
    if not ctx.same_object(p_a.rep_id, p_b.rep_id):
        # Predicates over different objects are not directly comparable in
        # truth-value space; flag INCOMPARABLE so the caller doesn't apply
        # the anti-strictly-stronger filter across object boundaries.
        return Verdict.INCOMPARABLE

    a_implies_b = p_b.rep_id in ctx.implies(p_a.rep_id)
    b_implies_a = p_a.rep_id in ctx.implies(p_b.rep_id)

    if a_implies_b and b_implies_a:
        return Verdict.EQUIVALENT
    if a_implies_b:
        return Verdict.STRICTLY_STRONGER
    if b_implies_a:
        return Verdict.STRICTLY_WEAKER
    # No implication recorded; Tier 1 cannot conclude. Fall through.
    return None


def _tier2_lean_probe(p_a: Predicate, p_b: Predicate) -> Optional[Verdict]:
    """Lean-side implication probe (currently STUBBED — returns None).

    Contract for the eventual implementation:
      Inputs : two Predicates, each with a non-empty `formal_form` that
               parses as a Lean 4 type signature over a shared object class.
      Output : Verdict, by attempting two `∀ x, P x → Q x`-shape goals:
                 forward = `∀ x, p_a x → p_b x`
                 reverse = `∀ x, p_b x → p_a x`
               Result table:
                 (forward closes, reverse closes)        → EQUIVALENT
                 (forward closes, reverse fails/timeout) → STRICTLY_STRONGER
                 (forward fails/timeout, reverse closes) → STRICTLY_WEAKER
                 (both fail/timeout)                     → None  (fallthrough to Tier 3)
      Mechanism: emit a temporary Lean file under `LeanAgent/_tmp/`, run
                 `lake build` with a short timeout (default ~30s per goal),
                 inspect exit code (0 = closes, non-zero = fails) and
                 `#print axioms`-equivalent for axiom-cleanness if needed.
      Timeout : on timeout, treat as "cannot discharge" — return None to
                allow Tier 3 to handle. Do NOT return STRICTLY_STRONGER on
                timeout; that would silently mis-flag candidates.

    Returning None when either `formal_form` is missing or when the probe
    is not yet implemented is the safe behaviour: the caller falls through
    to Tier 3 (LLM) which conservatively returns INCOMPARABLE."""
    if not (p_a.formal_form and p_b.formal_form):
        return None
    # Probe not yet implemented; orchestrator may drop in a real impl.
    # Until then: fall through.
    return None


def _tier3_llm(p_a: Predicate, p_b: Predicate) -> Verdict:
    """LLM 4-way classification fallback (currently STUBBED — returns
    INCOMPARABLE).

    Contract for the eventual implementation:
      Inputs : two Predicates with at least `nl` set on each.
      Output : one of the four Verdicts. The LLM is asked, in a single
               structured prompt, to label `compare(p_a, p_b)`.
      Wiring : the prompt should mirror `workspace/agents_spec/explain_why_prompt.md
               §A.2 step 3` — same anti-strictly-stronger language so the LLM's
               output is consistent with the prompt-level filter the
               orchestrator already applies inside the discovery loop.

    Default behaviour: INCOMPARABLE.
      Rationale: Tier 3 is reached ONLY when Tiers 1 and 2 cannot conclude.
      Returning STRICTLY_STRONGER here without evidence would cause
      `reject_against_failed` to silently reject the candidate — a
      false-positive in the anti-strictly-stronger filter. Returning
      INCOMPARABLE lets the candidate through; the LLM-side filter at
      `explain_why_prompt.md §A.2 step 3` then handles it inside the
      prompt, where the model has full context (anchor case, evidence,
      WH lineage). This two-layer design is documented in
      `representations/SCHEMA.md §C.4`.

    A real implementation should:
      1. Build the prompt with the full registry context (passed as
         `Predicate.formal_form` or registry lookup of `Predicate.rep_id`).
      2. Require the LLM to emit exactly one of the four Verdict strings.
      3. On malformed output, retry once; second failure → INCOMPARABLE."""
    return Verdict.INCOMPARABLE


def compare(p_a: Predicate, p_b: Predicate, ctx: RegistryCtx) -> Verdict:
    """Three-tier compare. Returns the most specific verdict that can be
    discharged. Tier 1 (registry) is cheap and exact; Tier 2 (Lean probe)
    is expensive but exact; Tier 3 (LLM) is a fallback used only when
    neither structured tier resolves."""
    v = _tier1_registry(p_a, p_b, ctx)
    if v is not None:
        return v
    v = _tier2_lean_probe(p_a, p_b)
    if v is not None:
        return v
    return _tier3_llm(p_a, p_b)


def is_strictly_stronger(p_a: Predicate, p_b: Predicate, ctx: RegistryCtx) -> bool:
    """Convenience for the anti-strictly-stronger filter callsites:
    SCHEMA.md §C.4, explain_why_prompt.md §A.2/§E.3, instance_sorter.md §D.
    Returns True iff `compare(p_a, p_b) == STRICTLY_STRONGER`."""
    return compare(p_a, p_b, ctx) is Verdict.STRICTLY_STRONGER


def reject_against_failed(candidate: Predicate,
                          failed_attempts: list[Predicate],
                          ctx: RegistryCtx) -> Optional[Predicate]:
    """The anti-strictly-stronger filter primitive used by the Proposer
    (architecture_report.md Q1) and the Tracker successor-filter
    (explain_why_prompt.md §E.3). Returns the failed predicate that the
    candidate is strictly stronger than, or None if the candidate passes."""
    for fa in failed_attempts:
        if compare(candidate, fa, ctx) is Verdict.STRICTLY_STRONGER:
            return fa
    return None


# ----------------------------------------------------------------------------
# Self-test
# ----------------------------------------------------------------------------

def _self_test() -> int:
    """Anchor on the OP-1 known relation chain (chordal → dismantlable;
    universal_vertex → dismantlable; chordal_or_cone → dismantlable).
    These relations live in the seeded `implies_reps` field."""
    ctx = load_registry_ctx()

    cases = [
        # (p_a, p_b, expected)
        # OP-1 chain
        ("rep_022_chordal_peo", "rep_021_dismantlable_graph", Verdict.STRICTLY_STRONGER),
        ("rep_021_dismantlable_graph", "rep_022_chordal_peo", Verdict.STRICTLY_WEAKER),
        ("rep_019_universal_vertex", "rep_021_dismantlable_graph", Verdict.STRICTLY_STRONGER),
        ("rep_023_iterative_max_level", "rep_021_dismantlable_graph", Verdict.STRICTLY_STRONGER),
        ("rep_032_chordal_or_cone", "rep_021_dismantlable_graph", Verdict.STRICTLY_STRONGER),
        ("rep_024_w4_metric_chepoi", "rep_021_dismantlable_graph", Verdict.STRICTLY_STRONGER),
        # Equivalent forms in optimization
        ("rep_001_descent_fderiv", "rep_002_descent_gradient", Verdict.EQUIVALENT),
        ("rep_002_descent_gradient", "rep_001_descent_fderiv", Verdict.EQUIVALENT),
        ("rep_010_zseq_lyapunov", "rep_011_trajectory_xt_yt", Verdict.EQUIVALENT),
        ("rep_012_match_scalars_vector", "rep_013_abel_normalisation", Verdict.EQUIVALENT),
        # Incomparable: chordal and universal_vertex are both subsumed by
        # the dichotomy but neither implies the other.
        ("rep_019_universal_vertex", "rep_022_chordal_peo", Verdict.INCOMPARABLE),
        ("rep_022_chordal_peo", "rep_019_universal_vertex", Verdict.INCOMPARABLE),
        # Cross-object (different `object` field) → INCOMPARABLE.
        ("rep_001_descent_fderiv", "rep_021_dismantlable_graph", Verdict.INCOMPARABLE),
        # SHB-rate qualifier upgrade: EXACT-QQ implies the pure-numerical LMI claim.
        ("rep_028_exact_qq_certificate", "rep_026_2step_lyapunov_lmi", Verdict.STRICTLY_STRONGER),
        ("rep_028_exact_qq_certificate", "rep_027_lookahead_lmi", Verdict.STRICTLY_STRONGER),
        ("rep_026_2step_lyapunov_lmi", "rep_028_exact_qq_certificate", Verdict.STRICTLY_WEAKER),
    ]

    failures: list[str] = []
    for a, b, expected in cases:
        if a not in ctx.entries_by_id or b not in ctx.entries_by_id:
            failures.append(f"missing rep entry: {a} or {b}")
            continue
        actual = compare(Predicate(rep_id=a), Predicate(rep_id=b), ctx)
        if actual is not expected:
            failures.append(
                f"compare({a}, {b}) = {actual.value}; expected {expected.value}"
            )

    # Anti-strictly-stronger primitive
    failed = [Predicate(rep_id="rep_019_universal_vertex"),
              Predicate(rep_id="rep_022_chordal_peo")]
    chordal = Predicate(rep_id="rep_022_chordal_peo")
    rejected = reject_against_failed(chordal, failed, ctx)
    if rejected is None or rejected.rep_id != "rep_022_chordal_peo":
        # chordal is EQUIVALENT to itself → not STRICTLY_STRONGER
        # but the candidate is the same object, so reject_against_failed
        # should match chordal-vs-universal_vertex first (INCOMPARABLE) and
        # then chordal-vs-chordal (EQUIVALENT). Neither is STRICTLY_STRONGER,
        # so the function should return None. That is the correct behaviour.
        if rejected is not None:
            failures.append(
                f"reject_against_failed returned {rejected.rep_id}; expected None"
            )

    # A rep that IS strictly stronger than a known-failed form should be flagged.
    new_candidate = Predicate(rep_id="rep_023_iterative_max_level")
    failed_dismantlable = [Predicate(rep_id="rep_021_dismantlable_graph")]
    rej = reject_against_failed(new_candidate, failed_dismantlable, ctx)
    if rej is None or rej.rep_id != "rep_021_dismantlable_graph":
        failures.append(
            "reject_against_failed: expected rep_023 to be strictly stronger "
            f"than rep_021, got rej={rej}"
        )

    if failures:
        print(f"FAIL: {len(failures)} test(s) failed")
        for f in failures:
            print(f"  {f}")
        return 1
    print(f"OK: {len(cases)} compare cases + 2 reject_against_failed cases passed")
    return 0


if __name__ == "__main__":
    sys.exit(_self_test())
