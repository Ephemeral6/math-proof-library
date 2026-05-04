"""Tests for strategy_proposer."""

from __future__ import annotations

import os
import unittest
from pathlib import Path

from LeanAgent.LeanAgent.Agent_legacy.LLM import LLM

from LeanAgent.LeanAgent.Agent.Scout.orchestrator import ScoutConfig
from LeanAgent.LeanAgent.Agent.Scout.strategy_proposer import (
    CANDIDATE_TYPES,
    StrategyCandidate,
    StrategyProposal,
    _is_dup_of_failed,
    _jaccard_token_overlap,
    generate_candidates,
    probe_candidates,
    rank_candidates,
    run_strategy_proposer,
)
from LeanAgent.LeanAgent.Agent.Scout.tractability_report import (
    DifficultySignals,
    TractabilityReport,
)


_STUB = Path(__file__).resolve().parents[1] / "stubs" / "strategy_proposer.json"


# ────────────────────────────────────────────────────────────────────────────
# Test fixtures: chordal-failure scenario from OP-1 R4→R5
# ────────────────────────────────────────────────────────────────────────────


def _chordal_inputs():
    return {
        "current_conjecture": {
            "id": "DL_dismantlability",
            "form": "DL is dismantlable because it is chordal",
            "rep_id": "rep_022_chordal_peo",
            "domain": "combinatorial_topology",
            "object": "DL",
        },
        "falsification_evidence": {
            "n_failing": 12,
            "n_total": 54,
            "structural_pattern": "induced 4-cycle, degree (6,5,5,5)",
            "axis_uniformity": True,
            "anchor_instances": [{"instance": "S_{1,2} k=4"}],
        },
        "diagnoser_output": {
            "binary": "rep_too_restrictive",
            "dispatch": "REP_ONLY",
            "obstacle": {
                "obstruction_class": "loose_inequality",
                "mathematical_property_needed": "weaker than chordal but still implies dismantlable",
                "propagation_path": "chordality fails on 12 DLs",
            },
        },
        "failed_attempts": [
            {"form": "DL has universal vertex"},
            {"form": "DL has size <= 5"},
        ],
    }


def _stub_llm() -> LLM:
    return LLM(provider="stub", stub_path=_STUB)


# ────────────────────────────────────────────────────────────────────────────
# Generate
# ────────────────────────────────────────────────────────────────────────────


class TestGenerateCandidates(unittest.TestCase):
    def setUp(self):
        os.environ["SCOUT_STUB"] = "1"

    def tearDown(self):
        os.environ.pop("SCOUT_STUB", None)

    def test_generate_candidates_from_chordal_failure(self):
        x = _chordal_inputs()
        cands = generate_candidates(
            current_conjecture=x["current_conjecture"],
            falsification_evidence=x["falsification_evidence"],
            diagnoser_output=x["diagnoser_output"],
            failed_attempts=x["failed_attempts"],
            llm=_stub_llm(),
        )
        # Stub returns 4 candidates.
        self.assertEqual(len(cands), 4)
        self.assertTrue(all(c.type in CANDIDATE_TYPES for c in cands))

    def test_weaken_property_type_present(self):
        cands = generate_candidates(
            **{k: v for k, v in _chordal_inputs().items()
               if k in ("current_conjecture", "falsification_evidence",
                        "diagnoser_output", "failed_attempts")},
            llm=_stub_llm(),
        )
        types = {c.type for c in cands}
        self.assertIn("weaken_property", types)

    def test_bridge_type_has_search_queries(self):
        cands = generate_candidates(
            **{k: v for k, v in _chordal_inputs().items()
               if k in ("current_conjecture", "falsification_evidence",
                        "diagnoser_output", "failed_attempts")},
            llm=_stub_llm(),
        )
        bridges = [c for c in cands if c.type == "bridge_to_literature"]
        self.assertTrue(bridges)
        self.assertTrue(all(c.search_queries for c in bridges))

    def test_invalid_type_filtered(self):
        # Pass a stub that has a bogus type — feed it directly to the parser.
        from LeanAgent.LeanAgent.Agent.Scout.strategy_proposer import _parse_candidates
        text = """{
          "candidates": [
            {"id": "S1", "description": "x", "type": "telepathy", "estimated_tractability": 0.5},
            {"id": "S2", "description": "y", "type": "weaken_property", "estimated_tractability": 0.5}
          ]
        }"""
        out = _parse_candidates(text)
        self.assertEqual(len(out), 1)
        self.assertEqual(out[0].id, "S2")


# ────────────────────────────────────────────────────────────────────────────
# Probe
# ────────────────────────────────────────────────────────────────────────────


class _FakeScout:
    """Replays a deterministic scout response per candidate description."""

    def __init__(self, mapping=None):
        self.mapping = mapping or {}
        self.calls = []

    def __call__(self, problem, config):
        self.calls.append(problem["problem_id"])
        # Default: return shallow + pass + 2 hits.
        report_kw = self.mapping.get(problem["problem_id"], {})
        return TractabilityReport(
            problem_id=problem["problem_id"],
            scout_outcome=report_kw.get("outcome", "pass"),
            scout_evidence=report_kw.get("evidence", "stub-fake"),
            scout_wh={},
            scout_rep_id=None,
            estimated_difficulty=report_kw.get("difficulty", "shallow"),
            difficulty_signals=DifficultySignals(
                verifier_runtime_s=0.1,
                rep_tools_status="available",
                wh_anchor_size=0,
                registry_hits=report_kw.get("hits", 2),
            ),
            recommended_action=report_kw.get("action", "deep_dive"),
        )


class TestProbeCandidates(unittest.TestCase):
    def test_probe_fills_probe_result(self):
        cands = [
            StrategyCandidate(id="S1", description="weaken chordal", type="weaken_property"),
            StrategyCandidate(id="S2", description="bridge stuff", type="bridge_to_literature",
                              search_queries=["q1"]),
        ]
        fake = _FakeScout()
        cfg = ScoutConfig(stub_mode=True, batch_id="t")
        out = probe_candidates(
            cands,
            current_conjecture={"domain": "combinatorial_topology"},
            config=cfg,
            scout_one_fn=fake,
        )
        # weaken_property got probed; bridge_to_literature did not.
        self.assertIsNotNone(out[0].probe_result)
        self.assertIsNone(out[1].probe_result)
        # Only 1 scout call (S1). S2 is bridge → skipped.
        self.assertEqual(len(fake.calls), 1)

    def test_probe_handles_scout_exception(self):
        def _raise(p, c):
            raise RuntimeError("simulated")

        cands = [StrategyCandidate(id="S1", description="x", type="weaken_property")]
        out = probe_candidates(
            cands,
            current_conjecture={"domain": "x"},
            config=ScoutConfig(stub_mode=True),
            scout_one_fn=_raise,
        )
        self.assertIn("error", out[0].probe_result)


# ────────────────────────────────────────────────────────────────────────────
# Rank
# ────────────────────────────────────────────────────────────────────────────


def _candidate(id_, type_, descr="x", tract=0.5, probe=None):
    c = StrategyCandidate(id=id_, description=descr, type=type_,
                          estimated_tractability=tract)
    c.probe_result = probe
    return c


def _probe(outcome="pass", difficulty="shallow"):
    return {"scout_outcome": outcome, "estimated_difficulty": difficulty}


class TestRank(unittest.TestCase):
    def test_rank_prefers_pass_over_fail(self):
        a = _candidate("A", "weaken_property", probe=_probe("pass", "medium"), tract=0.4)
        b = _candidate("B", "weaken_property", probe=_probe("fail", "medium"), tract=0.9)
        prop = rank_candidates([b, a])
        self.assertEqual(prop.recommended_id, "A")

    def test_rank_prefers_higher_tractability_when_probe_equal(self):
        a = _candidate("A", "weaken_property", probe=_probe("pass", "shallow"), tract=0.7)
        b = _candidate("B", "split_cases",     probe=_probe("pass", "shallow"), tract=0.4)
        prop = rank_candidates([b, a])
        self.assertEqual(prop.recommended_id, "A")

    def test_rank_demotes_duplicates_of_failed_attempts(self):
        a = _candidate("A", "weaken_property",
                       descr="DL has universal vertex (weaker form)",
                       probe=_probe("pass", "shallow"), tract=0.9)
        b = _candidate("B", "weaken_property",
                       descr="weaken chordal to (W4)+(M)",
                       probe=_probe("pass", "shallow"), tract=0.5)
        failed = [{"form": "DL has universal vertex"}]
        prop = rank_candidates([a, b], failed_attempts=failed)
        # B should beat A despite lower tractability because A is dup.
        self.assertEqual(prop.recommended_id, "B")
        self.assertTrue(any(c.is_dup_of_failed for c in prop.candidates if c.id == "A"))

    def test_recommendation_rationale_built(self):
        a = _candidate("A", "weaken_property",
                       descr="(W4)", probe=_probe("pass", "shallow"), tract=0.7)
        prop = rank_candidates([a])
        self.assertIn("A", prop.recommendation_rationale)
        self.assertIn("probe=pass", prop.recommendation_rationale)


# ────────────────────────────────────────────────────────────────────────────
# Helpers
# ────────────────────────────────────────────────────────────────────────────


class TestDedupHelpers(unittest.TestCase):
    def test_jaccard_overlap(self):
        self.assertGreater(
            _jaccard_token_overlap("DL is chordal", "DL is chordal"),
            0.99,
        )
        self.assertEqual(_jaccard_token_overlap("", "x"), 0.0)
        self.assertLess(
            _jaccard_token_overlap("a totally different thing", "DL is chordal"),
            0.2,
        )

    def test_dup_detection(self):
        c = StrategyCandidate(
            id="X",
            description="weaken the DL is chordal hypothesis",
            type="weaken_property",
        )
        self.assertTrue(_is_dup_of_failed(c, [{"form": "DL is chordal"}]))

    def test_no_dup_when_different(self):
        c = StrategyCandidate(
            id="X",
            description="bridge to weakly modular graph theory",
            type="bridge_to_literature",
        )
        self.assertFalse(_is_dup_of_failed(c, [{"form": "DL is chordal"}]))


# ────────────────────────────────────────────────────────────────────────────
# End-to-end stub
# ────────────────────────────────────────────────────────────────────────────


class TestEndToEndStub(unittest.TestCase):
    def setUp(self):
        os.environ["SCOUT_STUB"] = "1"

    def tearDown(self):
        os.environ.pop("SCOUT_STUB", None)

    def test_chordal_failure_produces_recommendation(self):
        x = _chordal_inputs()
        # Inject a fake scout that gives weaken_property a strong probe and split_cases medium.
        fake = _FakeScout(mapping={
            "strategy_S1": {"outcome": "pass", "difficulty": "shallow", "hits": 3},
            "strategy_S2": {"outcome": "pass", "difficulty": "medium", "hits": 1},
            "strategy_S3": {"outcome": "pass", "difficulty": "medium", "hits": 1},
            # S4 is bridge_to_literature — not probed.
        })
        cfg = ScoutConfig(stub_mode=True, batch_id="strategy_test")
        prop = run_strategy_proposer(
            current_conjecture=x["current_conjecture"],
            falsification_evidence=x["falsification_evidence"],
            diagnoser_output=x["diagnoser_output"],
            failed_attempts=x["failed_attempts"],
            registry_context={},
            config=cfg,
            llm=_stub_llm(),
            scout_one_fn=fake,
        )
        # Top recommendation should be the (W4) weaken_property candidate (S1).
        self.assertEqual(prop.recommended_id, "S1")
        self.assertGreaterEqual(len(prop.candidates), 3)
        self.assertIn("weaken_property", {c.type for c in prop.candidates})
        self.assertIn("bridge_to_literature", {c.type for c in prop.candidates})


if __name__ == "__main__":
    unittest.main()
