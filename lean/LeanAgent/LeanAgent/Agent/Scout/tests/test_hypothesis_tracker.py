"""Tests for hypothesis_tracker."""

from __future__ import annotations

import unittest

from LeanAgent.LeanAgent.Agent.Scout.hypothesis_tracker import (
    CompletionStatus,
    Conjecture,
    Obstacle,
    OBSTRUCTION_CLASSES,
    Prediction,
    TrackerState,
    WhVerdict,
    WhyHypothesis,
    can_emit_summary,
    create_seed_wh,
    maybe_transition_to_verified,
    update_completion_status,
)


def _make_state(intent: str = "scout") -> TrackerState:
    c = Conjecture(id="C1", form="P holds", rep_id="rep_001", test_plan=None)
    return TrackerState(current_conjecture=c, intent=intent)


def _seed() -> dict:
    return {
        "wh_seed": {
            "claim": "DL is dismantlable because it is chordal",
            "candidate_property": "DL is chordal (every induced cycle ≥ 4 has a chord)",
        },
        "candidate_properties": [
            {"id": "P1", "feature": "chordal", "informativeness_rank": 1},
        ],
        "top_ranked_id": "P1",
    }


class TestCreateSeedWh(unittest.TestCase):
    def test_basic_creation(self):
        wh = create_seed_wh(_seed(), intent="scout", rep_id="rep_001",
                            anchor_case="S_{1,1} k=2")
        self.assertEqual(wh.id, "WH-1")
        self.assertEqual(wh.verdict, WhVerdict.ACTIVE.value)
        self.assertEqual(wh.rep_id_at_creation, "rep_001")
        self.assertEqual(wh.anchor_case, "S_{1,1} k=2")
        self.assertIsNone(wh.successor_id)
        self.assertEqual(wh.predictions, [])

    def test_missing_seed_fields_raises(self):
        with self.assertRaises(ValueError):
            create_seed_wh({"wh_seed": {"claim": "x"}}, intent="scout")
        with self.assertRaises(ValueError):
            create_seed_wh({}, intent="scout")


class TestScoutGuard(unittest.TestCase):
    def test_scout_wh_does_not_transition_to_verified(self):
        wh = create_seed_wh(_seed(), intent="scout")
        wh.predictions = [Prediction(next_complexity="x", status="verified")]
        maybe_transition_to_verified(wh, intent="scout")
        # Must stay ACTIVE despite "all verified" — scout guard.
        self.assertEqual(wh.verdict, WhVerdict.ACTIVE.value)

    def test_deep_dive_wh_transitions_when_all_verified(self):
        wh = create_seed_wh(_seed(), intent="deep_dive")
        wh.predictions = [
            Prediction(next_complexity="a", status="verified"),
            Prediction(next_complexity="b", status="verified"),
        ]
        maybe_transition_to_verified(wh, intent="deep_dive")
        self.assertEqual(wh.verdict, WhVerdict.VERIFIED.value)

    def test_deep_dive_wh_does_not_transition_when_pending(self):
        wh = create_seed_wh(_seed(), intent="deep_dive")
        wh.predictions = [
            Prediction(next_complexity="a", status="verified"),
            Prediction(next_complexity="b", status="pending"),
        ]
        maybe_transition_to_verified(wh, intent="deep_dive")
        self.assertEqual(wh.verdict, WhVerdict.ACTIVE.value)


class TestCompletionStatus(unittest.TestCase):
    def test_scout_always_pending(self):
        state = _make_state(intent="scout")
        self.assertEqual(update_completion_status(state),
                         CompletionStatus.PENDING.value)
        self.assertIn("scout mode", state.current_conjecture.completion_rationale)

    def test_deep_dive_with_no_plan_is_pending(self):
        state = _make_state(intent="deep_dive")
        # No test_plan → all-passes vacuously and qualifier=INCOMPLETE → INCONCLUSIVE_OPEN.
        v = update_completion_status(state)
        self.assertIn(v, {CompletionStatus.INCONCLUSIVE_OPEN.value,
                          CompletionStatus.PENDING.value})

    def test_deep_dive_step_level_fail(self):
        state = _make_state(intent="deep_dive")
        state.current_conjecture.test_plan = {
            "steps": [{"actual_outcome": "fail"}, {"actual_outcome": "pass"}]
        }
        self.assertEqual(update_completion_status(state),
                         CompletionStatus.FALSIFIED.value)

    def test_deep_dive_pending_step_returns_pending(self):
        state = _make_state(intent="deep_dive")
        state.current_conjecture.test_plan = {
            "steps": [{"actual_outcome": "pass"}, {"actual_outcome": None}]
        }
        self.assertEqual(update_completion_status(state),
                         CompletionStatus.PENDING.value)

    def test_deep_dive_empirically_verified(self):
        state = _make_state(intent="deep_dive")
        state.current_conjecture.test_plan = {
            "steps": [{"actual_outcome": "pass"}, {"actual_outcome": "pass"}]
        }
        state.current_conjecture.verification_qualifier = "EXHAUSTIVE_ON_SAMPLE"
        # All WH settled (vacuously — no WHs).
        self.assertEqual(update_completion_status(state),
                         CompletionStatus.EMPIRICALLY_VERIFIED.value)

    def test_deep_dive_formally_certified(self):
        state = _make_state(intent="deep_dive")
        state.current_conjecture.test_plan = {
            "steps": [{"actual_outcome": "pass"}]
        }
        state.current_conjecture.verification_qualifier = "EXACT"
        self.assertEqual(update_completion_status(state),
                         CompletionStatus.FORMALLY_CERTIFIED.value)


class TestArchiveGate(unittest.TestCase):
    def test_can_emit_summary_only_on_positive_terminal(self):
        state = _make_state(intent="deep_dive")
        for s, expected in [
            (CompletionStatus.PENDING, False),
            (CompletionStatus.FALSIFIED, False),
            (CompletionStatus.INCONCLUSIVE_OPEN, False),
            (CompletionStatus.ERROR, False),
            (CompletionStatus.EMPIRICALLY_VERIFIED, True),
            (CompletionStatus.FORMALLY_CERTIFIED, True),
        ]:
            state.current_conjecture.completion_status = s.value
            self.assertEqual(can_emit_summary(state), expected, msg=str(s))


class TestObstacleValidation(unittest.TestCase):
    def test_valid_class_passes(self):
        for cls in OBSTRUCTION_CLASSES:
            Obstacle(obstruction_class=cls).validate()

    def test_invalid_class_raises(self):
        with self.assertRaises(ValueError):
            Obstacle(obstruction_class="bogus_class").validate()


class TestSerialisation(unittest.TestCase):
    def test_state_to_json_roundtrip_keys(self):
        state = _make_state(intent="scout")
        wh = create_seed_wh(_seed(), intent="scout", rep_id="rep_001")
        state.why_hypotheses.append(wh)
        state.log("WH-1 created from anchor S_{1,1} k=2")
        s = state.to_json()
        # Parse back as plain dict; check shape.
        import json as _json
        d = _json.loads(s)
        self.assertEqual(d["intent"], "scout")
        self.assertEqual(len(d["why_hypotheses"]), 1)
        self.assertEqual(d["why_hypotheses"][0]["id"], "WH-1")
        self.assertEqual(d["current_conjecture"]["id"], "C1")
        self.assertEqual(len(d["tracker_log"]), 1)


if __name__ == "__main__":
    unittest.main()
