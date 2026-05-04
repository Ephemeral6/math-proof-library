"""Tests for proposer_scout (stub mode)."""

from __future__ import annotations

import json
import os
import unittest
from pathlib import Path

from LeanAgent.LeanAgent.Agent_legacy.LLM import LLM

from LeanAgent.LeanAgent.Agent.Scout.proposer_scout import (
    build_proposer_prompt,
    parse_proposer_response,
    run_proposer_scout,
    validate_scout_output,
)


_STUB = Path(__file__).resolve().parents[1] / "stubs" / "proposer_scout.json"


class TestPromptBuild(unittest.TestCase):
    def test_includes_goal_and_domain(self):
        p = build_proposer_prompt(
            goal="Prove DL is contractible.",
            rep_id="rep_021",
            domain="combinatorial_topology",
            object_keywords="DL dismantlable",
            literature_in_scope=[{"title": "Bestvina-Brady 1997"}],
        )
        self.assertIn("Prove DL is contractible.", p)
        self.assertIn("rep_021", p)
        self.assertIn("combinatorial_topology", p)
        self.assertIn("Bestvina-Brady", p)
        self.assertIn("EXACTLY 1 step", p)


class TestParse(unittest.TestCase):
    def test_valid_response(self):
        text = json.dumps({
            "conjecture": {"form": "x", "object": "y", "domain": "meta"},
            "test_plan": {"max_steps": 1, "steps": [
                {"step": 1, "instance": "smol", "verifier_command": "x"}
            ]},
            "object_for_rep_select": "y",
        })
        out = parse_proposer_response(text)
        self.assertEqual(out["conjecture"]["form"], "x")

    def test_missing_conjecture(self):
        with self.assertRaises(ValueError):
            parse_proposer_response('{"test_plan": {}}')

    def test_missing_test_plan(self):
        with self.assertRaises(ValueError):
            parse_proposer_response('{"conjecture": {}}')


class TestValidation(unittest.TestCase):
    def _good(self):
        return {
            "conjecture": {"form": "x", "object": "y", "domain": "meta"},
            "test_plan": {"max_steps": 1, "steps": [
                {"step": 1, "instance": "smol", "verifier_command": "x"}
            ]},
            "object_for_rep_select": "y",
        }

    def test_good_passes(self):
        self.assertTrue(validate_scout_output(self._good()))

    def test_two_steps_fails(self):
        bad = self._good()
        bad["test_plan"]["steps"].append(
            {"step": 2, "instance": "next", "verifier_command": "y"}
        )
        with self.assertRaises(ValueError) as ctx:
            validate_scout_output(bad)
        self.assertIn("scout caps at 1 step", str(ctx.exception))

    def test_zero_steps_fails(self):
        bad = self._good()
        bad["test_plan"]["steps"] = []
        with self.assertRaises(ValueError):
            validate_scout_output(bad)

    def test_wrong_step_index_fails(self):
        bad = self._good()
        bad["test_plan"]["steps"][0]["step"] = 2
        with self.assertRaises(ValueError):
            validate_scout_output(bad)

    def test_missing_instance_fails(self):
        bad = self._good()
        bad["test_plan"]["steps"][0].pop("instance")
        with self.assertRaises(ValueError):
            validate_scout_output(bad)


class TestRunStub(unittest.TestCase):
    def setUp(self):
        os.environ["SCOUT_STUB"] = "1"

    def tearDown(self):
        os.environ.pop("SCOUT_STUB", None)

    def test_stub_round_trip(self):
        llm = LLM(provider="stub", stub_path=_STUB)
        out = run_proposer_scout(
            goal="prove DL dismantlable",
            domain="combinatorial_topology",
            object_keywords="DL",
            llm=llm,
        )
        self.assertIn("descending link", out["conjecture"]["form"])
        self.assertEqual(len(out["test_plan"]["steps"]), 1)
        step = out["test_plan"]["steps"][0]
        self.assertEqual(step["step"], 1)
        self.assertEqual(step["verifier_command"]["kind"], "engine_call")


if __name__ == "__main__":
    unittest.main()
