"""Tests for Novelty Verifier (Phase 2 — P2-C)."""

from __future__ import annotations

import os
import unittest

from LeanAgent.LeanAgent.Agent.Scout import novelty_verifier as nv
from LeanAgent.LeanAgent.Agent.Scout.hypothesis_tracker import (
    Conjecture,
    CompletionStatus,
    TrackerState,
)


def _state(form: str, status: str) -> TrackerState:
    return TrackerState(
        current_conjecture=Conjecture(
            id="C-1",
            form=form,
            completion_status=status,
        ),
    )


class TestQueryBuilding(unittest.TestCase):
    def test_three_rounds(self):
        qs = nv.build_novelty_queries(
            "any conjecture form",
            domain_keywords=["combinatorics", "number theory"],
            key_objects=["covering system", "arithmetic progression"],
            quantitative_claims=["minimum modulus 10^16", "k=3"],
        )
        self.assertGreaterEqual(len(qs["round1"]), 1)
        self.assertGreaterEqual(len(qs["round2"]), 1)
        self.assertGreaterEqual(len(qs["round3"]), 1)
        # Round 3 should mention frontier markers.
        joined = " ".join(qs["round3"]).lower()
        self.assertTrue(
            "frontier" in joined or "open" in joined or "lower" in joined
        )


class TestNotTriggered(unittest.TestCase):
    def test_pending_status_skips(self):
        state = _state("anything", CompletionStatus.PENDING.value)
        v = nv.run_novelty_check(state)
        self.assertEqual(v.novelty_status, nv.NoveltyStatus.UNCERTAIN.value)
        self.assertEqual(v.recommendation, "not triggered")


class TestStubModeRediscovery(unittest.TestCase):
    def setUp(self):
        os.environ["NOVELTY_STUB"] = "1"

    def tearDown(self):
        os.environ.pop("NOVELTY_STUB", None)

    def test_erdos_selfridge_3prime_odd_returns_rediscovery(self):
        state = _state(
            "no odd covering system exists with three distinct prime moduli",
            CompletionStatus.EMPIRICALLY_VERIFIED.value,
        )
        v = nv.run_novelty_check(state)
        self.assertEqual(
            v.novelty_status,
            nv.NoveltyStatus.REDISCOVERY.value,
            f"got {v.novelty_status} with rationale={v.novelty_rationale}",
        )
        # Subsumer should reference Berger / Felzenbaum / Fraenkel 1986.
        self.assertIsNotNone(v.subsumer)
        self.assertIn("1986", v.subsumer)

    def test_in_scope_paper_excluded_as_subsumer(self):
        state = _state(
            "no odd covering system exists with three distinct prime moduli",
            CompletionStatus.EMPIRICALLY_VERIFIED.value,
        )
        # User declares the BFF1986 paper in literature_in_scope; it
        # should NOT count as "got there first".
        v = nv.run_novelty_check(
            state,
            inputs=nv.NoveltyInputs(
                literature_in_scope=["Selfridge's odd covering problem"],
            ),
        )
        self.assertNotEqual(v.novelty_status, nv.NoveltyStatus.REDISCOVERY.value)


class TestNovelOnNoHits(unittest.TestCase):
    def setUp(self):
        os.environ["NOVELTY_STUB"] = "1"

    def tearDown(self):
        os.environ.pop("NOVELTY_STUB", None)

    def test_no_hits_returns_uncertain(self):
        state = _state(
            "a totally fictional conjecture about widget Lyapunov functions",
            CompletionStatus.FORMALLY_CERTIFIED.value,
        )
        v = nv.run_novelty_check(state)
        self.assertEqual(v.novelty_status, nv.NoveltyStatus.UNCERTAIN.value)
        self.assertGreaterEqual(v.confidence, 0.0)


class TestSerialisation(unittest.TestCase):
    def setUp(self):
        os.environ["NOVELTY_STUB"] = "1"

    def tearDown(self):
        os.environ.pop("NOVELTY_STUB", None)

    def test_to_dict_json_roundtrip(self):
        state = _state(
            "no odd covering system exists with three distinct prime moduli",
            CompletionStatus.EMPIRICALLY_VERIFIED.value,
        )
        v = nv.run_novelty_check(state)
        import json
        json.dumps(v.to_dict())


if __name__ == "__main__":
    unittest.main()
