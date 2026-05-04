"""Tests for Bridge literature search (Phase 2 — P2-A).

Run under stub mode (`BRIDGE_STUB=1`); no network access required.
"""

from __future__ import annotations

import os
import unittest

from LeanAgent.LeanAgent.Agent.Bridge import literature_search as ls


def _enable_stub():
    os.environ["BRIDGE_STUB"] = "1"


def _disable_stub():
    os.environ.pop("BRIDGE_STUB", None)


class TestBuildSearchQueries(unittest.TestCase):
    def test_empty_keywords_falls_back_to_property(self):
        qs = ls.build_search_queries(
            "combinatorial_blowup",
            "bound max-union of arithmetic progressions",
            [],
        )
        self.assertEqual(len(qs), 1)
        self.assertIn("max-union", qs[0])

    def test_three_queries_with_domain(self):
        qs = ls.build_search_queries(
            "combinatorial_blowup",
            "bound max-union of arithmetic progressions",
            ["probabilistic method", "expectation bound", "LP relaxation"],
            domain="combinatorics",
        )
        self.assertEqual(len(qs), 3)
        self.assertTrue(qs[0].startswith("probabilistic method"))
        self.assertIn("expectation bound", qs[1])
        self.assertIn("combinatorics", qs[2])

    def test_dedup_when_keywords_collide(self):
        qs = ls.build_search_queries(
            "combinatorial_blowup",
            "max-union",
            ["probabilistic method", "probabilistic method"],
        )
        # Q2 collapses into Q1, so we should get a single unique query.
        self.assertEqual(len(set(q.lower().strip() for q in qs)), len(qs))


class TestSearchLiterature(unittest.TestCase):
    def setUp(self):
        _enable_stub()

    def tearDown(self):
        _disable_stub()

    def test_stub_returns_combinatorial_blowup_fixture(self):
        papers = ls.search_literature(
            ["probabilistic method covering"],
            obstruction_class="combinatorial_blowup",
        )
        self.assertGreaterEqual(len(papers), 2)
        # The first stub fixture is the Erdős minimum-modulus paper.
        self.assertIn("modulus", papers[0].title.lower())

    def test_stub_unknown_class_returns_empty(self):
        papers = ls.search_literature(
            ["some query"],
            obstruction_class="not_a_real_class",
        )
        self.assertEqual(papers, [])

    def test_live_mode_raises(self):
        _disable_stub()
        with self.assertRaises(NotImplementedError):
            ls.search_literature(["x"], obstruction_class="combinatorial_blowup")


class TestEvaluateRelevance(unittest.TestCase):
    def setUp(self):
        _enable_stub()

    def tearDown(self):
        _disable_stub()

    def test_high_overlap_marked_relevant(self):
        paper = ls.PaperResult(
            title="Probabilistic method on covering systems",
            url="https://arxiv.org/abs/0",
            abstract_snippet=(
                "We use the probabilistic method to bound covering systems "
                "of arithmetic progressions; expectation arguments avoid "
                "enumeration."
            ),
        )
        v = ls.evaluate_relevance(
            paper,
            obstruction_class="combinatorial_blowup",
            mathematical_property_needed=(
                "bound max-union of arithmetic progressions without "
                "enumerating residue tuples"
            ),
        )
        self.assertTrue(v.relevant)
        self.assertGreater(v.confidence, 0.4)

    def test_low_overlap_marked_irrelevant(self):
        paper = ls.PaperResult(
            title="A history of zoological taxonomy",
            url="https://example.org",
            abstract_snippet="This paper surveys the development of taxonomic naming.",
        )
        v = ls.evaluate_relevance(
            paper,
            obstruction_class="combinatorial_blowup",
            mathematical_property_needed="bound max-union of arithmetic progressions",
        )
        self.assertFalse(v.relevant)


class TestRunBridge(unittest.TestCase):
    def setUp(self):
        _enable_stub()

    def tearDown(self):
        _disable_stub()

    def test_full_pipeline_combinatorial_blowup(self):
        obstruction_summary = {
            "obstruction_class": "combinatorial_blowup",
            "mathematical_property_needed": (
                "bound max-union of arithmetic progressions without "
                "enumerating residue tuples"
            ),
            "catalog_keywords": [
                "probabilistic method",
                "expectation bound",
                "LP relaxation",
            ],
            "catalog_typical_category": "proof_technique",
        }
        result = ls.run_bridge(obstruction_summary, domain="combinatorics")
        self.assertGreaterEqual(len(result.queries), 1)
        self.assertGreaterEqual(len(result.papers_found), 1)
        # At least one of the three stub papers should pass the keyword filter.
        self.assertGreaterEqual(len(result.relevant_papers), 1)
        self.assertIsNotNone(result.suggested_technique)
        self.assertTrue(result.ts)

    def test_serializable(self):
        obstruction_summary = {
            "obstruction_class": "combinatorial_blowup",
            "mathematical_property_needed": "x",
            "catalog_keywords": ["probabilistic method"],
            "catalog_typical_category": "proof_technique",
        }
        result = ls.run_bridge(obstruction_summary)
        d = result.to_dict()
        # Round-trip through JSON.
        import json
        json.dumps(d)


if __name__ == "__main__":
    unittest.main()
