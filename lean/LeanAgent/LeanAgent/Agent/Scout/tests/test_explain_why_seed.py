"""Tests for explain_why_seed (uses stub LLM)."""

from __future__ import annotations

import json
import os
import unittest
from pathlib import Path

from LeanAgent.LeanAgent.Agent_legacy.LLM import LLM

from LeanAgent.LeanAgent.Agent.Scout.explain_why_seed import (
    _extract_json,
    build_seed_prompt,
    parse_seed_response,
    run_seed,
)


_STUB = Path(__file__).resolve().parents[1] / "stubs" / "explain_why_seed.json"


class TestPromptBuild(unittest.TestCase):
    def test_prompt_contains_anchor_and_evidence(self):
        p = build_seed_prompt(
            conjecture="P holds",
            actual_evidence="3/3 cases pass; max size 5",
            rep_id="rep_001",
            anchor_case="S_{1,1} k=2",
        )
        self.assertIn("S_{1,1} k=2", p)
        self.assertIn("3/3 cases pass", p)
        self.assertIn("rep_001", p)
        self.assertIn("Output JSON ONLY", p)

    def test_prompt_with_failed_attempts(self):
        p = build_seed_prompt(
            conjecture="P holds",
            actual_evidence="ok",
            rep_id="rep_001",
            anchor_case="x",
            failed_attempts=[{"form": "DL has universal vertex"}],
        )
        self.assertIn("universal vertex", p)


class TestJsonExtraction(unittest.TestCase):
    def test_plain_json(self):
        out = _extract_json('{"a": 1, "b": [2, 3]}')
        self.assertEqual(out, {"a": 1, "b": [2, 3]})

    def test_json_in_code_fence(self):
        text = '```json\n{"x": 42}\n```'
        self.assertEqual(_extract_json(text), {"x": 42})

    def test_json_with_prose_around(self):
        text = 'Some preface text.\n\n{"k": "v"}\n\nTrailing junk.'
        self.assertEqual(_extract_json(text), {"k": "v"})

    def test_no_object_raises(self):
        with self.assertRaises(ValueError):
            _extract_json("just prose, no JSON")

    def test_unbalanced_braces_raises(self):
        with self.assertRaises(ValueError):
            _extract_json("{ unbalanced")

    def test_nested_object(self):
        text = '{"outer": {"inner": [1, 2, {"k": "v"}]}}'
        self.assertEqual(_extract_json(text)["outer"]["inner"][2]["k"], "v")


class TestParseSeedResponse(unittest.TestCase):
    def test_valid_response(self):
        text = json.dumps({
            "wh_seed": {"claim": "C", "candidate_property": "P"},
            "candidate_properties": [],
            "top_ranked_id": "P1",
        })
        out = parse_seed_response(text)
        self.assertEqual(out["wh_seed"]["claim"], "C")

    def test_missing_wh_seed_raises(self):
        with self.assertRaises(ValueError):
            parse_seed_response('{"foo": 1}')

    def test_missing_claim_raises(self):
        with self.assertRaises(ValueError):
            parse_seed_response('{"wh_seed": {"candidate_property": "P"}}')

    def test_response_with_prose_prefix(self):
        text = "Here is the JSON:\n" + json.dumps({
            "wh_seed": {"claim": "C", "candidate_property": "P"},
            "candidate_properties": [],
            "top_ranked_id": "P1",
        })
        out = parse_seed_response(text)
        self.assertEqual(out["wh_seed"]["candidate_property"], "P")


class TestRunSeedStub(unittest.TestCase):
    def setUp(self):
        os.environ["SCOUT_STUB"] = "1"

    def tearDown(self):
        os.environ.pop("SCOUT_STUB", None)

    def test_stub_returns_seed(self):
        llm = LLM(provider="stub", stub_path=_STUB)
        out = run_seed(
            conjecture="DL is dismantlable",
            actual_evidence="3/3 dismantlable; max size 5; chordal",
            rep_id="rep_021_dismantlable_graph",
            anchor_case="S_{1,1} k=2",
            llm=llm,
        )
        self.assertIn("wh_seed", out)
        self.assertIn("chordal", out["wh_seed"]["candidate_property"])
        self.assertEqual(out["top_ranked_id"], "P1")
        self.assertEqual(len(out["candidate_properties"]), 3)


if __name__ == "__main__":
    unittest.main()
