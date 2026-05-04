"""Tests for Bridge-trigger expansion (Gap-2):
   - diagnoser.extract_bridge_trigger
   - diagnoser.select_highest_priority_trigger
   - Bridge.run_bridge_with_triggers
"""

from __future__ import annotations

import os
import unittest

from LeanAgent.LeanAgent.Agent.Bridge.literature_search import (
    BridgeResult,
    run_bridge_with_triggers,
)
from LeanAgent.LeanAgent.Agent.Scout.diagnoser import (
    BinaryJudge,
    BridgeTrigger,
    extract_bridge_trigger,
    select_highest_priority_trigger,
)
from LeanAgent.LeanAgent.Agent.Scout.hypothesis_tracker import Obstacle


# ────────────────────────────────────────────────────────────────────────────
# extract_bridge_trigger
# ────────────────────────────────────────────────────────────────────────────


class TestExtractBridgeTrigger(unittest.TestCase):
    def test_rep_too_restrictive_with_pattern_triggers(self):
        t = extract_bridge_trigger(
            "rep_too_restrictive",
            falsification_evidence={
                "structural_pattern": "induced 4-cycle, degree (6,5,5,5)",
            },
            current_property="DL is chordal",
            target_property="DL is dismantlable",
        )
        self.assertIsNotNone(t)
        self.assertEqual(t.source, "diagnoser")
        self.assertEqual(t.priority, 2)
        self.assertIn("DL is chordal", t.query)
        self.assertIn("DL is dismantlable", t.query)
        self.assertIn("induced 4-cycle", t.pattern)

    def test_no_pattern_no_trigger(self):
        t = extract_bridge_trigger(
            "rep_too_restrictive",
            falsification_evidence={},
            current_property="x",
            target_property="y",
        )
        self.assertIsNone(t)

    def test_empty_pattern_no_trigger(self):
        t = extract_bridge_trigger(
            "rep_too_restrictive",
            falsification_evidence={"structural_pattern": ""},
            current_property="x",
            target_property="y",
        )
        self.assertIsNone(t)

    def test_conjecture_wrong_no_trigger(self):
        t = extract_bridge_trigger(
            "conjecture_wrong",
            falsification_evidence={"structural_pattern": "anything"},
            current_property="x",
            target_property="y",
        )
        self.assertIsNone(t)

    def test_explanation_wrong_with_pattern_triggers(self):
        # explanation_wrong + pattern is also acceptable per the implementation note.
        t = extract_bridge_trigger(
            "explanation_wrong",
            falsification_evidence={"structural_pattern": "some pattern"},
            current_property="A",
            target_property="B",
        )
        self.assertIsNotNone(t)
        self.assertEqual(t.priority, 2)

    def test_default_property_strings(self):
        t = extract_bridge_trigger(
            "rep_too_restrictive",
            falsification_evidence={"structural_pattern": "x"},
        )
        self.assertIn("<current property>", t.query)
        self.assertIn("<target property>", t.query)

    def test_binary_judge_enum_input_works(self):
        t = extract_bridge_trigger(
            BinaryJudge.REP_TOO_RESTRICTIVE,
            falsification_evidence={"structural_pattern": "x"},
            current_property="a", target_property="b",
        )
        self.assertIsNotNone(t)


# ────────────────────────────────────────────────────────────────────────────
# select_highest_priority_trigger
# ────────────────────────────────────────────────────────────────────────────


class TestPrioritySelection(unittest.TestCase):
    def test_strategy_beats_diagnoser(self):
        s = BridgeTrigger(source="strategy_proposer", priority=1, queries=["q1"])
        d = BridgeTrigger(source="diagnoser", priority=2, query="q2")
        chosen = select_highest_priority_trigger([s, d])
        self.assertIs(chosen, s)

    def test_diagnoser_beats_tool_discoverer(self):
        d = BridgeTrigger(source="diagnoser", priority=2, query="q")
        td = BridgeTrigger(source="tool_discoverer", priority=3,
                           obstruction_summary={"obstruction_class": "x"})
        chosen = select_highest_priority_trigger([td, d])
        self.assertIs(chosen, d)

    def test_strategy_beats_all(self):
        s = BridgeTrigger(source="strategy_proposer", priority=1, queries=["q"])
        d = BridgeTrigger(source="diagnoser", priority=2, query="q")
        td = BridgeTrigger(source="tool_discoverer", priority=3, obstruction_summary={})
        chosen = select_highest_priority_trigger([td, d, s])
        self.assertIs(chosen, s)

    def test_only_one_present(self):
        d = BridgeTrigger(source="diagnoser", priority=2, query="q")
        chosen = select_highest_priority_trigger([None, d, None])
        self.assertIs(chosen, d)

    def test_all_none(self):
        self.assertIsNone(select_highest_priority_trigger([None, None]))

    def test_empty(self):
        self.assertIsNone(select_highest_priority_trigger([]))


# ────────────────────────────────────────────────────────────────────────────
# run_bridge_with_triggers — priority routing (uses BRIDGE_STUB)
# ────────────────────────────────────────────────────────────────────────────


class TestRunBridgeWithTriggers(unittest.TestCase):
    def setUp(self):
        os.environ["BRIDGE_STUB"] = "1"

    def tearDown(self):
        os.environ.pop("BRIDGE_STUB", None)

    def test_strategy_queries_take_priority(self):
        r = run_bridge_with_triggers(
            strategy_queries=["weakly modular graph dismantlable"],
            diagnoser_trigger=BridgeTrigger(source="diagnoser", priority=2, query="OTHER"),
            obstruction_summary={"obstruction_class": "loose_inequality",
                                 "mathematical_property_needed": "x",
                                 "catalog_keywords": []},
        )
        self.assertIsInstance(r, BridgeResult)
        # The chosen queries are the strategy ones.
        self.assertEqual(r.queries, ["weakly modular graph dismantlable"])

    def test_diagnoser_trigger_when_no_strategy(self):
        d = BridgeTrigger(
            source="diagnoser", priority=2,
            query="weaker than chordal implies dismantlable",
            pattern="induced 4-cycle",
        )
        r = run_bridge_with_triggers(diagnoser_trigger=d)
        self.assertIn("weaker than chordal implies dismantlable", r.queries)
        # Pattern-derived secondary query also added.
        self.assertTrue(any("induced 4-cycle" in q for q in r.queries))

    def test_diagnoser_trigger_dict_form(self):
        # Duck-typing: dict instead of dataclass.
        r = run_bridge_with_triggers(
            diagnoser_trigger={"query": "Q", "pattern": "P"}
        )
        self.assertIn("Q", r.queries)
        self.assertTrue(any("P" in q for q in r.queries))

    def test_obstruction_summary_fallback(self):
        r = run_bridge_with_triggers(
            obstruction_summary={
                "obstruction_class": "combinatorial_blowup",
                "mathematical_property_needed": "bound max-union without enumeration",
                "catalog_keywords": ["probabilistic method"],
                "catalog_typical_category": "proof_technique",
            },
        )
        # Stub fallback path runs; result should have queries.
        self.assertTrue(len(r.queries) > 0)

    def test_empty_input_returns_empty_result(self):
        r = run_bridge_with_triggers()
        self.assertEqual(r.queries, [])
        self.assertEqual(r.papers_found, [])

    def test_diagnoser_trigger_no_query_returns_empty(self):
        d = BridgeTrigger(source="diagnoser", priority=2, query=None)
        r = run_bridge_with_triggers(diagnoser_trigger=d)
        self.assertEqual(r.queries, [])


if __name__ == "__main__":
    unittest.main()
