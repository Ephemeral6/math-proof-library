"""Tests for end-to-end Runner (Phase 3 — P3-C)."""

from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from LeanAgent.LeanAgent.Agent import runner as r


class TestRunBatchHappy(unittest.TestCase):
    def test_single_problem_pipeline(self):
        problems = [
            {
                "problem_id": "TOY-1",
                "goal": "GD on smooth strongly-convex converges linearly",
                "domain": "optimization",
            },
        ]
        results = r.run_batch(
            problems,
            config=r.RunnerConfig(
                top_k=1,
                stub_mode=True,
                deep_dive_config=r.DeepDiveConfig(max_iterations=2),
            ),
        )
        self.assertEqual(len(results), 1)
        res = results[0]
        self.assertIsNotNone(res.scout_report)
        self.assertIsNotNone(res.deep_dive)
        self.assertIsNotNone(res.novelty)

    def test_top_k_caps_dispatch(self):
        problems = [
            {"problem_id": f"TOY-{i}", "goal": "g", "domain": "optimization"}
            for i in range(5)
        ]
        results = r.run_batch(
            problems,
            config=r.RunnerConfig(top_k=2, stub_mode=True),
        )
        self.assertEqual(len(results), 2)


class TestCLI(unittest.TestCase):
    def test_main_writes_results(self):
        problems = [{
            "problem_id": "CLI-1",
            "goal": "trivial",
            "domain": "optimization",
        }]
        with tempfile.TemporaryDirectory() as tmp:
            in_path = Path(tmp) / "problems.json"
            out_dir = Path(tmp) / "out"
            in_path.write_text(json.dumps(problems), encoding="utf-8")
            rc = r.main([
                "--input", str(in_path),
                "--output", str(out_dir),
                "--top-k", "1",
                "--max-iterations", "2",
                "--stub-mode",
            ])
            self.assertEqual(rc, 0)
            files = list(out_dir.glob("results_*.json"))
            self.assertEqual(len(files), 1)
            data = json.loads(files[0].read_text(encoding="utf-8"))
            self.assertEqual(len(data), 1)
            self.assertEqual(data[0]["problem_id"], "CLI-1")


if __name__ == "__main__":
    unittest.main()
