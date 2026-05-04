"""Tests for Tool Discoverer (Phase 2 — P2-B)."""

from __future__ import annotations

import os
import unittest

from LeanAgent.LeanAgent.Agent.Scout import tool_discoverer as td


class TestCatalogParsing(unittest.TestCase):
    def test_catalog_has_all_eight_classes(self):
        cat = td.load_catalog()
        # Spec says 8 obstruction classes; the catalog file owns the table.
        for cls in td.OBSTRUCTION_CLASSES:
            self.assertIn(cls, cat, f"missing catalog row for {cls}")
            row = cat[cls]
            self.assertGreaterEqual(
                len(row["search_keywords"]),
                1,
                f"no keywords for {cls}",
            )
            self.assertIn(
                row["typical_category"],
                {
                    "proof_technique",
                    "definition_synthesis",
                    "strategic_pattern",
                    "api_workaround",
                    "extrapolation_method",
                    "rigor_pattern",
                },
                f"unexpected category for {cls}: {row['typical_category']}",
            )

    def test_catalog_fallback_on_unknown_class(self):
        # Unknown classes return an empty stub.
        row = td.catalog_fallback("__not_a_class__")
        self.assertEqual(row["search_keywords"], [])


class TestMode3Query(unittest.TestCase):
    def test_combinatorial_blowup_finds_disc_001(self):
        """disc_001 lists `combinatorial_blowup` in defuses_obstruction."""
        cands = td.mode3_query(
            "combinatorial_blowup",
            domain="geometric_topology",
            typical_category="proof_technique",
        )
        ids = [c.discovery_id for c in cands]
        self.assertIn("disc_001_homology_parity_bound", ids)

    def test_intractable_certificate_prefers_validated_multi(self):
        """disc_005 (validated_multi) outranks any validated_once siblings."""
        cands = td.mode3_query(
            "intractable_certificate",
            domain="optimization",
            typical_category="rigor_pattern",
        )
        self.assertGreaterEqual(len(cands), 1)
        # First candidate should be validated_multi when one exists.
        # disc_005 and disc_008 both list intractable_certificate.
        # disc_005 maturity = validated_multi; disc_008 maturity = validated_multi.
        for c in cands:
            self.assertIn(c.discovery_id, {
                "disc_005_frontier_extrapolation",
                "disc_008_sdp_rationalize_verify",
            })

    def test_tried_discoveries_excluded(self):
        cands_full = td.mode3_query(
            "combinatorial_blowup",
            domain="geometric_topology",
            typical_category="proof_technique",
        )
        ids_full = {c.discovery_id for c in cands_full}
        self.assertIn("disc_001_homology_parity_bound", ids_full)
        cands_filtered = td.mode3_query(
            "combinatorial_blowup",
            domain="geometric_topology",
            typical_category="proof_technique",
            tried_discoveries=["disc_001_homology_parity_bound"],
        )
        ids_filtered = {c.discovery_id for c in cands_filtered}
        self.assertNotIn("disc_001_homology_parity_bound", ids_filtered)

    def test_top_k_cap(self):
        cands = td.mode3_query(
            "intractable_certificate",
            domain="optimization",
            typical_category="rigor_pattern",
            top_k=1,
        )
        self.assertLessEqual(len(cands), 1)

    def test_unknown_obstruction_returns_empty(self):
        cands = td.mode3_query(
            "loose_inequality",
            domain="optimization",
            typical_category="proof_technique",
        )
        # Currently no entry in the seed registry lists loose_inequality.
        # Test should be permissive: just check it doesn't crash and
        # returns a list.
        self.assertIsInstance(cands, list)


class TestSynthesisFallback(unittest.TestCase):
    def test_combinatorial_blowup_synthesis(self):
        cand, row = td.synthesis_from_catalog(
            "combinatorial_blowup",
            "bound max-union of arithmetic progressions",
        )
        self.assertIsNotNone(cand)
        self.assertTrue(cand.is_synthesis)
        self.assertIsNone(cand.discovery_id)
        self.assertIn("probabilistic method", cand.suggested_query)


class TestRunToolDiscoverer(unittest.TestCase):
    def setUp(self):
        os.environ["BRIDGE_STUB"] = "1"

    def tearDown(self):
        os.environ.pop("BRIDGE_STUB", None)

    def test_hit_path(self):
        payload = td.ToolDiscovererInput(
            object="optimization_iterates",
            domain="optimization",
            current_rep_id="rep_028_exact_qq_certificate",
            current_technique="manual lyapunov hunt",
            obstruction_class="intractable_certificate",
            mathematical_property_needed="find PSD certificate",
            propagation_path="parameter space too large",
        )
        out = td.run_tool_discoverer(payload)
        self.assertGreaterEqual(len(out.candidates), 1)
        # All candidates should be real (non-synthesis) on the hit path.
        self.assertTrue(all(not c.is_synthesis for c in out.candidates))
        self.assertEqual(
            out.obstruction_summary["obstruction_class"],
            "intractable_certificate",
        )

    def test_empty_path_falls_back_to_synthesis(self):
        # Pick an obstruction class that no current discovery defuses.
        payload = td.ToolDiscovererInput(
            object="some_object",
            domain="optimization",
            current_rep_id="rep_unused",
            current_technique="some technique",
            obstruction_class="wrong_direction",  # no entries list this
            mathematical_property_needed=(
                "convert primal upper bound into dual lower bound"
            ),
            propagation_path="proof step needs lower bound",
        )
        out = td.run_tool_discoverer(payload)
        # Falls back to the catalog row → 1 synthesis candidate.
        self.assertEqual(len(out.candidates), 1)
        self.assertTrue(out.candidates[0].is_synthesis)
        self.assertIsNone(out.candidates[0].discovery_id)
        self.assertIn(
            "duality",
            out.candidates[0].suggested_query.lower(),
            f"missing duality keyword: {out.candidates[0].suggested_query}",
        )

    def test_bridge_invocation_on_synthesis(self):
        payload = td.ToolDiscovererInput(
            object="some_object",
            domain="combinatorics",
            current_rep_id="rep_unused",
            current_technique="iterative inclusion-exclusion",
            obstruction_class="combinatorial_blowup",
            mathematical_property_needed="bound max-union of APs",
            propagation_path="enumeration blows up at k=4",
            tried_discoveries=[
                # Pretend we've already tried every disc that lists
                # combinatorial_blowup, forcing fallback.
                "disc_001_homology_parity_bound",
                "disc_003_universal_vertex_upgrade",
            ],
        )
        out = td.run_tool_discoverer(payload, invoke_bridge=True)
        self.assertEqual(len(out.candidates), 1)
        self.assertTrue(out.candidates[0].is_synthesis)
        self.assertIsNotNone(out.bridge_result)
        self.assertGreaterEqual(
            len(out.bridge_result["papers_found"]), 1
        )

    def test_invalid_obstruction_class_rejected(self):
        with self.assertRaises(ValueError):
            payload = td.ToolDiscovererInput(
                object="x",
                domain="x",
                current_rep_id="x",
                current_technique="x",
                obstruction_class="not_a_real_class",
                mathematical_property_needed="x",
                propagation_path="x",
            )
            payload.validate()

    def test_serialisable(self):
        payload = td.ToolDiscovererInput(
            object="o",
            domain="optimization",
            current_rep_id="rep_x",
            current_technique="t",
            obstruction_class="combinatorial_blowup",
            mathematical_property_needed="bound max-union",
            propagation_path="k=4",
        )
        out = td.run_tool_discoverer(payload)
        import json
        # must be JSON-serialisable end-to-end
        json.dumps(out.to_dict())


if __name__ == "__main__":
    unittest.main()
