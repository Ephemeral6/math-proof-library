"""Tests for tractability_report."""

from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from LeanAgent.LeanAgent.Agent.Scout.hypothesis_tracker import (
    Conjecture, TrackerState, create_seed_wh
)
from LeanAgent.LeanAgent.Agent.Scout.tractability_report import (
    estimate_difficulty,
    generate_report,
    recommend_action,
    TractabilityReport,
    write_report,
)


def _state_with_seed_wh() -> TrackerState:
    state = TrackerState(
        current_conjecture=Conjecture(id="C1", form="P", rep_id="rep_001"),
        intent="scout",
    )
    seed = {
        "wh_seed": {"claim": "C", "candidate_property": "P"},
        "candidate_properties": [],
        "top_ranked_id": "P1",
    }
    state.why_hypotheses.append(create_seed_wh(seed, intent="scout", rep_id="rep_001"))
    return state


class TestDifficulty(unittest.TestCase):
    def test_pass_shallow(self):
        d = estimate_difficulty(scout_outcome="pass", runtime_s=2.0,
                                rep_tools_status="available",
                                wh_anchor_size=3, registry_hits=2)
        self.assertEqual(d, "shallow")

    def test_pass_medium(self):
        d = estimate_difficulty(scout_outcome="pass", runtime_s=20.0,
                                rep_tools_status="available",
                                wh_anchor_size=10, registry_hits=0)
        self.assertEqual(d, "medium")

    def test_pass_deep_due_to_partial_tools(self):
        d = estimate_difficulty(scout_outcome="pass", runtime_s=10.0,
                                rep_tools_status="partial",
                                wh_anchor_size=10, registry_hits=0)
        self.assertEqual(d, "deep")

    def test_pass_deep_due_to_size(self):
        d = estimate_difficulty(scout_outcome="pass", runtime_s=10.0,
                                rep_tools_status="available",
                                wh_anchor_size=200)
        self.assertEqual(d, "deep")

    def test_intractable_when_tools_missing(self):
        d = estimate_difficulty(scout_outcome="pass", runtime_s=1.0,
                                rep_tools_status="missing")
        self.assertEqual(d, "intractable")

    def test_timeout_is_intractable(self):
        d = estimate_difficulty(scout_outcome="timeout", runtime_s=120.0,
                                rep_tools_status="available")
        self.assertEqual(d, "intractable")

    def test_fail_is_deep(self):
        d = estimate_difficulty(scout_outcome="fail", runtime_s=1.0,
                                rep_tools_status="available")
        self.assertEqual(d, "deep")


class TestRecommendAction(unittest.TestCase):
    def test_pass_shallow_means_deep_dive(self):
        self.assertEqual(
            recommend_action(scout_outcome="pass", estimated_difficulty="shallow"),
            "deep_dive",
        )

    def test_pass_deep_with_hits_means_deep_dive(self):
        self.assertEqual(
            recommend_action(scout_outcome="pass", estimated_difficulty="deep",
                             registry_hits=2),
            "deep_dive",
        )

    def test_pass_deep_no_hits_means_defer(self):
        self.assertEqual(
            recommend_action(scout_outcome="pass", estimated_difficulty="deep",
                             registry_hits=0),
            "defer",
        )

    def test_fail_with_no_axis_means_discard(self):
        self.assertEqual(
            recommend_action(scout_outcome="fail", estimated_difficulty="deep"),
            "discard",
        )

    def test_fail_with_axis_means_defer(self):
        self.assertEqual(
            recommend_action(scout_outcome="fail", estimated_difficulty="deep",
                             refinement_axis_identified=True),
            "defer",
        )

    def test_inconclusive_means_defer(self):
        self.assertEqual(
            recommend_action(scout_outcome="inconclusive", estimated_difficulty="medium"),
            "defer",
        )

    def test_error_means_needs_tool_first(self):
        self.assertEqual(
            recommend_action(scout_outcome="error", estimated_difficulty="deep"),
            "needs_tool_first",
        )

    def test_intractable_means_needs_tool_first(self):
        self.assertEqual(
            recommend_action(scout_outcome="pass", estimated_difficulty="intractable"),
            "needs_tool_first",
        )


class TestGenerateReport(unittest.TestCase):
    def test_basic_pass_report(self):
        state = _state_with_seed_wh()
        rpt = generate_report(
            problem_id="OP-X",
            state=state,
            verifier_outcome="pass",
            verifier_evidence="3/3 cases pass",
            runtime_s=1.5,
            rep_id="rep_001",
            rep_tools_status="available",
            wh_anchor_size=3,
            registry_hits=2,
        )
        self.assertEqual(rpt.problem_id, "OP-X")
        self.assertEqual(rpt.scout_outcome, "pass")
        self.assertEqual(rpt.estimated_difficulty, "shallow")
        self.assertEqual(rpt.recommended_action, "deep_dive")
        self.assertEqual(rpt.scout_wh["id"], "WH-1")
        self.assertEqual(rpt.scout_rep_id, "rep_001")

    def test_verifier_mixed_becomes_inconclusive(self):
        state = _state_with_seed_wh()
        rpt = generate_report(
            problem_id="OP-Y",
            state=state,
            verifier_outcome="mixed",
            verifier_evidence="some cases differ",
            runtime_s=1.0,
            rep_id="rep_002",
        )
        self.assertEqual(rpt.scout_outcome, "inconclusive")
        self.assertEqual(rpt.recommended_action, "defer")

    def test_verifier_timeout_routed(self):
        state = _state_with_seed_wh()
        rpt = generate_report(
            problem_id="OP-Z",
            state=state,
            verifier_outcome="timeout",
            verifier_evidence="timed out after 60s",
            runtime_s=60.0,
            rep_id="rep_003",
        )
        self.assertEqual(rpt.scout_outcome, "timeout")
        self.assertEqual(rpt.estimated_difficulty, "intractable")
        self.assertEqual(rpt.recommended_action, "needs_tool_first")


class TestWriteReport(unittest.TestCase):
    def test_writes_json(self):
        state = _state_with_seed_wh()
        rpt = generate_report(
            problem_id="OP-W/special chars*",
            state=state,
            verifier_outcome="pass",
            verifier_evidence="ok",
            runtime_s=0.5,
            rep_id="rep_001",
            rep_tools_status="available",
            wh_anchor_size=3,
            registry_hits=2,
        )
        with tempfile.TemporaryDirectory() as tmp:
            p = write_report(rpt, Path(tmp))
            self.assertTrue(p.exists())
            data = json.loads(p.read_text(encoding="utf-8"))
            self.assertEqual(data["scout_outcome"], "pass")
            # filename sanitised: '/' and '*' replaced with '_'
            self.assertNotIn("/", p.name)
            self.assertNotIn("*", p.name)


if __name__ == "__main__":
    unittest.main()
