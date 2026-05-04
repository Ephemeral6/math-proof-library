"""Tests for rep_selector — exercises the real entries.jsonl file."""

from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from LeanAgent.LeanAgent.Agent.Scout.rep_selector import (
    RepEntry,
    load_representations,
    select_rep,
)


class TestLoadRepresentations(unittest.TestCase):
    def test_default_registry_loads(self):
        reps = load_representations()
        # Phase-1: 35 entries seeded.
        self.assertGreater(len(reps), 30)
        self.assertTrue(all(r.id.startswith("rep_") for r in reps))

    def test_missing_file_returns_empty(self):
        out = load_representations(path="/nonexistent/path.jsonl")
        self.assertEqual(out, [])

    def test_loads_explicit_path(self):
        # Write a temp jsonl with two entries.
        e = [
            {
                "id": "rep_test_a",
                "object": "thing",
                "domain": "optimization",
                "representation": "form A",
                "formal_form": "x : Foo",
                "tools_required": [],
                "tools_status": "available",
                "transport_to": [],
                "verification_qualifier": "EXACT",
                "source_problem": "test",
                "status": "validated",
                "failure_mode": None,
                "notes": "",
            },
            {
                "id": "rep_test_b",
                "object": "thing",
                "domain": "optimization",
                "representation": "form B",
                "formal_form": "y : Bar",
                "tools_required": [],
                "tools_status": "missing",
                "transport_to": [],
                "verification_qualifier": "INCOMPLETE",
                "source_problem": "test",
                "status": "conjectural",
            },
        ]
        with tempfile.TemporaryDirectory() as tmp:
            p = Path(tmp) / "entries.jsonl"
            p.write_text("\n".join(json.dumps(x) for x in e) + "\n", encoding="utf-8")
            reps = load_representations(p)
            self.assertEqual(len(reps), 2)
            self.assertEqual(reps[0].id, "rep_test_a")


class TestSelectRep(unittest.TestCase):
    def setUp(self):
        self.reps = [
            RepEntry.from_dict({
                "id": "rep_001", "object": "descent",
                "domain": "optimization", "representation": "FDeriv form",
                "formal_form": "...", "tools_required": [], "tools_status": "available",
                "transport_to": [{"target_rep_id": "rep_002", "cost": "moderate"}],
                "verification_qualifier": "EXACT",
                "source_problem": "OptLib2 #03", "status": "validated",
            }),
            RepEntry.from_dict({
                "id": "rep_002", "object": "descent",
                "domain": "optimization", "representation": "gradient form",
                "formal_form": "...", "tools_required": [], "tools_status": "available",
                "transport_to": [{"target_rep_id": "rep_001", "cost": "moderate"}],
                "verification_qualifier": "EXACT",
                "source_problem": "OptLib2 #03", "status": "validated",
            }),
            RepEntry.from_dict({
                "id": "rep_900", "object": "DL",
                "domain": "geometric_topology", "representation": "universal vertex",
                "formal_form": "...", "tools_required": [], "tools_status": "available",
                "transport_to": [],
                "verification_qualifier": "EXHAUSTIVE_ON_SAMPLE",
                "source_problem": "OP-1 R1", "status": "disproved",  # excluded
                "failure_mode": "K_4 core",
            }),
            RepEntry.from_dict({
                "id": "rep_910", "object": "DL",
                "domain": "geometric_topology", "representation": "(W4) wheel",
                "formal_form": "...", "tools_required": ["curver"], "tools_status": "partial",
                "transport_to": [],
                "verification_qualifier": "EXHAUSTIVE_ON_SAMPLE",
                "source_problem": "OP-1 R6", "status": "validated",
            }),
        ]

    def test_disproved_excluded(self):
        result = select_rep(object="DL", domain="geometric_topology", reps=self.reps)
        ids = [r.id for r in result["representations"]]
        self.assertNotIn("rep_900", ids)

    def test_domain_filter(self):
        result = select_rep(object="descent", domain="optimization", reps=self.reps)
        ids = [r.id for r in result["representations"]]
        self.assertIn("rep_001", ids)
        self.assertIn("rep_002", ids)
        self.assertNotIn("rep_900", ids)
        self.assertNotIn("rep_910", ids)

    def test_picks_validated_available_first(self):
        result = select_rep(object="DL", domain="geometric_topology", reps=self.reps)
        # rep_910 is the only non-disproved DL match.
        self.assertEqual(result["preferred_starting_rep"], "rep_910")
        # warning emitted because tools_status=partial.
        self.assertTrue(any("partial" in w for w in result["warnings"]))

    def test_no_match_returns_none(self):
        result = select_rep(object="bogus", domain="optimization", reps=self.reps)
        self.assertIsNone(result["preferred_starting_rep"])
        self.assertTrue(any("no rep matches" in w for w in result["warnings"]))

    def test_meta_domain_passes_through(self):
        meta = RepEntry.from_dict({
            "id": "rep_meta", "object": "recursive synthesis",
            "domain": "meta", "representation": "auxiliary sequence",
            "formal_form": "...", "tools_required": [], "tools_status": "available",
            "transport_to": [],
            "verification_qualifier": "EXHAUSTIVE_ON_SAMPLE",
            "source_problem": "OptLib2 #04", "status": "validated",
        })
        # Match on a query that includes "recursive" and any domain.
        result = select_rep(object="recursive synthesis", domain="optimization",
                            reps=[meta] + self.reps)
        ids = [r.id for r in result["representations"]]
        self.assertIn("rep_meta", ids)


class TestRanking(unittest.TestCase):
    def test_in_degree_used_as_secondary(self):
        # Two same-domain, same-qualifier reps; the one with more incoming
        # transport edges should win.
        reps = [
            RepEntry.from_dict({
                "id": "rep_hub", "object": "x", "domain": "optimization",
                "representation": "hub form", "formal_form": "...",
                "tools_required": [], "tools_status": "available",
                "transport_to": [], "verification_qualifier": "EXACT",
                "source_problem": "test", "status": "validated",
            }),
            RepEntry.from_dict({
                "id": "rep_leaf", "object": "x", "domain": "optimization",
                "representation": "leaf form", "formal_form": "...",
                "tools_required": [], "tools_status": "available",
                "transport_to": [{"target_rep_id": "rep_hub", "cost": "cheap"}],
                "verification_qualifier": "EXACT",
                "source_problem": "test", "status": "validated",
            }),
            RepEntry.from_dict({
                "id": "rep_other", "object": "x", "domain": "optimization",
                "representation": "other form", "formal_form": "...",
                "tools_required": [], "tools_status": "available",
                "transport_to": [{"target_rep_id": "rep_hub", "cost": "moderate"}],
                "verification_qualifier": "EXACT",
                "source_problem": "test", "status": "validated",
            }),
        ]
        result = select_rep(object="x", domain="optimization", reps=reps)
        # rep_hub has 2 incoming edges → preferred over rep_leaf / rep_other.
        self.assertEqual(result["preferred_starting_rep"], "rep_hub")


if __name__ == "__main__":
    unittest.main()
