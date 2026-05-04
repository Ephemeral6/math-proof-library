"""End-to-end stub test for the orchestrator."""

from __future__ import annotations

import json
import os
import tempfile
import unittest
from pathlib import Path

from LeanAgent.LeanAgent.Agent.Scout import scout_batch, scout_one, ScoutConfig


_REPO_ROOT = Path(__file__).resolve().parents[5]


def _problem(pid: str = "OP-test", goal: str = "prove DL is dismantlable") -> dict:
    return {
        "problem_id": pid,
        "goal": goal,
        "domain": "combinatorial_topology",
        "object_keywords": "DL",
        "literature_in_scope": [],
    }


class TestScoutOne(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.cfg = ScoutConfig(
            output_dir=Path(self.tmp.name),
            stub_mode=True,
            timeout_s=10.0,
            batch_id="test_one",
        )

    def tearDown(self):
        self.tmp.cleanup()

    def test_end_to_end_scout(self):
        rpt = scout_one(_problem(), self.cfg)
        # Verifier returns "pass" on stub-engine echo → scout_outcome == pass.
        self.assertEqual(rpt.scout_outcome, "pass")
        self.assertIn(rpt.estimated_difficulty,
                      {"shallow", "medium", "deep", "intractable"})
        self.assertEqual(rpt.scout_wh.get("id"), "WH-1")
        self.assertIn("chordal", rpt.scout_wh.get("candidate_property", "").lower())
        # Output file written.
        out = Path(self.tmp.name) / "test_one" / "OP-test.json"
        self.assertTrue(out.exists())

    def test_missing_goal_raises(self):
        with self.assertRaises(ValueError):
            scout_one({"problem_id": "x"}, self.cfg)


class TestScoutBatch(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.cfg = ScoutConfig(
            output_dir=Path(self.tmp.name),
            stub_mode=True,
            timeout_s=10.0,
            batch_id="test_batch",
        )

    def tearDown(self):
        self.tmp.cleanup()

    def test_batch_runs_all(self):
        problems = [
            _problem("OP-A", "goal A"),
            _problem("OP-B", "goal B"),
            _problem("OP-C", "goal C"),
        ]
        batch = scout_batch(problems, self.cfg)
        self.assertEqual(len(batch["reports"]), 3)
        self.assertEqual(len(batch["ranking"]), 3)
        # Batch report file exists.
        f = Path(self.tmp.name) / "test_batch" / "_batch_report.json"
        self.assertTrue(f.exists())
        data = json.loads(f.read_text(encoding="utf-8"))
        self.assertEqual(data["batch_id"], "test_batch")

    def test_failure_report_when_problem_invalid(self):
        problems = [
            _problem("OP-Good"),
            {"problem_id": "OP-Bad"},          # no goal → scout_one raises
        ]
        batch = scout_batch(problems, self.cfg)
        self.assertEqual(len(batch["reports"]), 2)
        bad = next(r for r in batch["reports"] if r["problem_id"] == "OP-Bad")
        self.assertEqual(bad["scout_outcome"], "error")
        self.assertEqual(bad["recommended_action"], "needs_tool_first")


class TestRanking(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.cfg = ScoutConfig(
            output_dir=Path(self.tmp.name),
            stub_mode=True,
            timeout_s=10.0,
            batch_id="rank_test",
        )

    def tearDown(self):
        self.tmp.cleanup()

    def test_pass_outcomes_ranked_above_failures(self):
        # 3 valid + 1 invalid → invalid should be ranked last.
        problems = [
            _problem("OP-1"),
            _problem("OP-2"),
            {"problem_id": "OP-broken"},   # error
        ]
        batch = scout_batch(problems, self.cfg)
        ranks = {r["problem_id"]: r["rank"] for r in batch["ranking"]}
        # OP-broken is "error", scout_outcome != "pass" → ranked below pass cases.
        self.assertGreater(ranks["OP-broken"], ranks["OP-1"])
        self.assertGreater(ranks["OP-broken"], ranks["OP-2"])


if __name__ == "__main__":
    unittest.main()
