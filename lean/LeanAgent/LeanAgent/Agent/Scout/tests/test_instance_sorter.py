"""Tests for instance_sorter."""

from __future__ import annotations

import unittest

from LeanAgent.LeanAgent.Agent.Scout.instance_sorter import (
    TestPlan,
    TestPlanStep,
    validate_test_plan,
)


class TestInstanceSorter(unittest.TestCase):
    def _scout_step(self) -> TestPlanStep:
        return TestPlanStep(
            step=1,
            instance="S_{1,1} k=2",
            verifier_command="python /tmp/v.py",
            predicted_outcome="pass",
        )

    def test_scout_plan_accepts_single_step(self):
        plan = TestPlan(steps=[self._scout_step()], max_steps=1)
        self.assertTrue(validate_test_plan(plan, intent="scout"))

    def test_scout_plan_rejects_two_steps(self):
        s1 = self._scout_step()
        s2 = TestPlanStep(step=2, instance="x", verifier_command="y")
        plan = TestPlan(steps=[s1, s2], max_steps=1)
        with self.assertRaises(ValueError) as ctx:
            validate_test_plan(plan, intent="scout")
        self.assertIn("scout caps at 1 step", str(ctx.exception))

    def test_scout_plan_rejects_zero_steps(self):
        with self.assertRaises(ValueError):
            validate_test_plan(TestPlan(steps=[]), intent="scout")

    def test_deep_dive_accepts_multi_step(self):
        plan = TestPlan(
            steps=[
                TestPlanStep(step=1, instance="x1", verifier_command="a"),
                TestPlanStep(step=2, instance="x2", verifier_command="b"),
                TestPlanStep(step=3, instance="x3", verifier_command="c"),
            ],
            max_steps=10,
        )
        self.assertTrue(validate_test_plan(plan, intent="deep_dive"))

    def test_deep_dive_rejects_misnumbered_steps(self):
        plan = TestPlan(
            steps=[
                TestPlanStep(step=1, instance="x", verifier_command="a"),
                TestPlanStep(step=3, instance="y", verifier_command="b"),  # gap
            ]
        )
        with self.assertRaises(ValueError):
            validate_test_plan(plan, intent="deep_dive")

    def test_unknown_intent_raises(self):
        plan = TestPlan(steps=[self._scout_step()])
        with self.assertRaises(ValueError):
            validate_test_plan(plan, intent="bogus")

    def test_round_trip_json(self):
        plan = TestPlan(steps=[self._scout_step()], max_steps=1)
        plan.steps[0].actual_outcome = "pass"
        plan.steps[0].actual_evidence = "all 3 cases pass"
        plan.steps[0].runtime_s = 0.42
        s = plan.to_json()
        plan2 = TestPlan.from_json(s)
        self.assertEqual(plan2.max_steps, 1)
        self.assertEqual(len(plan2.steps), 1)
        self.assertEqual(plan2.steps[0].instance, "S_{1,1} k=2")
        self.assertEqual(plan2.steps[0].actual_outcome, "pass")
        self.assertAlmostEqual(plan2.steps[0].runtime_s or 0, 0.42)

    def test_engine_call_verifier_command(self):
        step = TestPlanStep(
            step=1,
            instance="cut_glue_alpha",
            verifier_command={"kind": "engine_call", "engine": "surface_geo",
                              "op": "cut_glue", "kwargs": {"obj": "alpha"}},
        )
        plan = TestPlan(steps=[step])
        validate_test_plan(plan, intent="scout")
        plan2 = TestPlan.from_json(plan.to_json())
        self.assertEqual(plan2.steps[0].verifier_command["op"], "cut_glue")


if __name__ == "__main__":
    unittest.main()
