"""Tests for Diagnoser ternary judge (Phase 2 — P2-E)."""

from __future__ import annotations

import unittest

from LeanAgent.LeanAgent.Agent.Scout.diagnoser import (
    BinaryJudge,
    DispatchDecision,
    apply_stagnation_override,
    detect_chain_stagnation,
    ternary_judge,
)
from LeanAgent.LeanAgent.Agent.Scout.hypothesis_tracker import (
    Obstacle,
    WhyHypothesis,
)


def _wh(idx: int, rep_id: str | None) -> WhyHypothesis:
    return WhyHypothesis(
        id=f"WH-{idx}",
        claim="c",
        candidate_property="p",
        rep_id_at_creation=rep_id,
    )


class TestTernaryJudge(unittest.TestCase):
    def test_conjecture_wrong_no_discoverer(self):
        d = ternary_judge(BinaryJudge.CONJECTURE_WRONG, obstacle=None)
        self.assertEqual(d, DispatchDecision.NO_DISCOVERER)

    def test_rep_too_restrictive_no_obstacle(self):
        d = ternary_judge(BinaryJudge.REP_TOO_RESTRICTIVE, obstacle=None)
        self.assertEqual(d, DispatchDecision.REP_ONLY)

    def test_rep_too_restrictive_with_loose_inequality_and_axis_confirmed(self):
        obs = Obstacle(obstruction_class="loose_inequality")
        d = ternary_judge(
            BinaryJudge.REP_TOO_RESTRICTIVE,
            obstacle=obs,
            diagnoser_axis_uniformity_confirmed=True,
        )
        self.assertEqual(d, DispatchDecision.BOTH)

    def test_rep_too_restrictive_with_loose_but_no_axis_confirmation(self):
        obs = Obstacle(obstruction_class="loose_inequality")
        d = ternary_judge(BinaryJudge.REP_TOO_RESTRICTIVE, obstacle=obs)
        self.assertEqual(d, DispatchDecision.REP_ONLY)

    def test_rep_too_restrictive_with_tool_only_obstacle_stays_rep_only(self):
        # obstruction_class={combinatorial_blowup} is not in REP_PARALLEL set
        obs = Obstacle(obstruction_class="combinatorial_blowup")
        d = ternary_judge(
            BinaryJudge.REP_TOO_RESTRICTIVE,
            obstacle=obs,
            diagnoser_axis_uniformity_confirmed=True,
        )
        self.assertEqual(d, DispatchDecision.REP_ONLY)

    def test_explanation_wrong_with_combinatorial_blowup(self):
        obs = Obstacle(obstruction_class="combinatorial_blowup")
        d = ternary_judge(BinaryJudge.EXPLANATION_WRONG, obstacle=obs)
        self.assertEqual(d, DispatchDecision.TOOL_ONLY)

    def test_explanation_wrong_no_obstacle_no_chain(self):
        d = ternary_judge(BinaryJudge.EXPLANATION_WRONG, obstacle=None)
        self.assertEqual(d, DispatchDecision.SUCCESSOR_WH_ONLY)

    def test_explanation_wrong_no_obstacle_with_chain_stagnation(self):
        whs = [_wh(i, "rep_A") for i in range(1, 5)]  # 4 WHs same rep
        d = ternary_judge(
            BinaryJudge.EXPLANATION_WRONG,
            obstacle=None,
            why_hypotheses=whs,
        )
        self.assertEqual(d, DispatchDecision.TOOL_ONLY)

    def test_invalid_obstruction_class_raises(self):
        obs = Obstacle.__new__(Obstacle)
        obs.obstruction_class = "not_a_class"
        obs.mathematical_property_needed = ""
        obs.propagation_path = ""
        with self.assertRaises(ValueError):
            ternary_judge(BinaryJudge.EXPLANATION_WRONG, obstacle=obs)


class TestStagnation(unittest.TestCase):
    def test_chain_too_short(self):
        whs = [_wh(1, "rep_A"), _wh(2, "rep_A")]
        self.assertFalse(detect_chain_stagnation(whs))

    def test_last_two_same_rep_at_length_4(self):
        whs = [_wh(1, "rep_A"), _wh(2, "rep_B"), _wh(3, "rep_A"), _wh(4, "rep_A")]
        self.assertTrue(detect_chain_stagnation(whs))

    def test_last_two_different_rep(self):
        whs = [_wh(1, "rep_A"), _wh(2, "rep_A"), _wh(3, "rep_A"), _wh(4, "rep_B")]
        self.assertFalse(detect_chain_stagnation(whs))


class TestStagnationOverride(unittest.TestCase):
    def test_successor_only_promoted_to_tool(self):
        whs = [_wh(i, "rep_X") for i in range(1, 5)]
        d = apply_stagnation_override(DispatchDecision.SUCCESSOR_WH_ONLY, whs)
        self.assertEqual(d, DispatchDecision.TOOL_ONLY)

    def test_rep_only_promoted_to_both(self):
        whs = [_wh(i, "rep_X") for i in range(1, 5)]
        d = apply_stagnation_override(DispatchDecision.REP_ONLY, whs)
        self.assertEqual(d, DispatchDecision.BOTH)

    def test_no_change_without_stagnation(self):
        whs = [_wh(1, "rep_A"), _wh(2, "rep_B")]
        d = apply_stagnation_override(DispatchDecision.REP_ONLY, whs)
        self.assertEqual(d, DispatchDecision.REP_ONLY)


if __name__ == "__main__":
    unittest.main()
