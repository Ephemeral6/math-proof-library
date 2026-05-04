"""Tests for Deep Dive Orchestrator (Phase 3 — P3-A)."""

from __future__ import annotations

import os
import unittest

from LeanAgent.LeanAgent.Agent.DeepDive import orchestrator as do
from LeanAgent.LeanAgent.Agent.Scout.diagnoser import BinaryJudge
from LeanAgent.LeanAgent.Agent.Scout.hypothesis_tracker import (
    CompletionStatus,
    Obstacle,
)


class TestSeedFromScout(unittest.TestCase):
    def test_seeds_wh1_from_scout(self):
        scout = {
            "scout_outcome": "pass",
            "scout_evidence": "step 1 pass",
            "scout_rep_id": "rep_028_exact_qq_certificate",
            "scout_wh": {
                "claim": "the rate is O(1/T)",
                "candidate_property": "single-step Lyapunov decreases",
            },
        }
        problem = {"problem_id": "TOY-1", "goal": "convergence at O(1/T)",
                   "domain": "optimization"}
        state = do._seed_state_from_scout(scout, problem)
        self.assertEqual(state.why_hypotheses[0].id, "WH-1")
        self.assertEqual(
            state.why_hypotheses[0].rep_id_at_creation,
            "rep_028_exact_qq_certificate",
        )
        steps = state.current_conjecture.test_plan["steps"]
        self.assertEqual(len(steps), 1)
        self.assertEqual(steps[0]["actual_outcome"], "pass")


class TestStubLoopHappyPath(unittest.TestCase):
    """In stub mode (default hooks), all steps pass and the loop
    terminates with EMPIRICALLY_VERIFIED after a few iterations."""

    def setUp(self):
        os.environ["BRIDGE_STUB"] = "1"

    def tearDown(self):
        os.environ.pop("BRIDGE_STUB", None)

    def test_terminates_empirically_verified(self):
        problem = {
            "problem_id": "TOY-CONVERGENCE",
            "goal": "GD on smooth strongly convex converges at linear rate",
            "domain": "optimization",
        }
        scout = {
            "scout_outcome": "pass",
            "scout_evidence": "k=1 case checks",
            "scout_rep_id": "rep_test",
            "scout_wh": {
                "claim": "linear convergence",
                "candidate_property": "L-smooth + μ-SC",
            },
        }
        result = do.deep_dive(
            problem,
            scout_result=scout,
            config=do.DeepDiveConfig(max_iterations=4),
        )
        self.assertEqual(
            result.completion_status,
            CompletionStatus.EMPIRICALLY_VERIFIED.value,
            f"halt={result.halt_reason}, log={[e['event'] for e in result.state.tracker_log]}",
        )
        # Loop should run ≥ 1 iteration on top of the inherited scout step.
        self.assertGreaterEqual(result.iterations_run, 1)


class TestStubLoopFailsCleanly(unittest.TestCase):
    def setUp(self):
        os.environ["BRIDGE_STUB"] = "1"

    def tearDown(self):
        os.environ.pop("BRIDGE_STUB", None)

    def test_verifier_fail_halts_with_falsified(self):
        def _v(state, idx):
            return {"actual_outcome": "fail",
                    "actual_evidence": "counter-example at instance N=3"}
        problem = {"problem_id": "TOY-BAD", "goal": "wrong claim",
                   "domain": "optimization"}
        result = do.deep_dive(
            problem,
            verifier_hook=_v,
            config=do.DeepDiveConfig(max_iterations=2),
        )
        self.assertEqual(
            result.completion_status,
            CompletionStatus.FALSIFIED.value,
        )


class TestDiscovererInvocation(unittest.TestCase):
    """When explain-why returns an obstacle with combinatorial_blowup,
    the orchestrator should invoke the Tool Discoverer."""

    def setUp(self):
        os.environ["BRIDGE_STUB"] = "1"

    def tearDown(self):
        os.environ.pop("BRIDGE_STUB", None)

    def test_tool_discoverer_called(self):
        def _v(state, idx):
            return {"actual_outcome": "pass",
                    "actual_evidence": f"step {idx} of probing"}

        explain_calls = {"n": 0}

        def _ew(state):
            # On the first iteration only, return an obstacle (forces the
            # discoverer to fire).  Then degrade to pass on subsequent
            # iterations so the loop terminates.
            explain_calls["n"] += 1
            if explain_calls["n"] == 1:
                return {
                    "binary_judge": BinaryJudge.EXPLANATION_WRONG,
                    "obstacle": Obstacle(
                        obstruction_class="combinatorial_blowup",
                        mathematical_property_needed=(
                            "bound max-union of arithmetic progressions"
                        ),
                        propagation_path="enumeration blew up at k=4",
                    ),
                    "wh_seed": {
                        "claim": "second-stage hypothesis",
                        "candidate_property": "use probabilistic method",
                    },
                }
            return None

        problem = {
            "problem_id": "TOY-COMBI",
            "goal": "combinatorial bound",
            "domain": "combinatorics",
        }
        result = do.deep_dive(
            problem,
            verifier_hook=_v,
            explain_why_hook=_ew,
            config=do.DeepDiveConfig(max_iterations=4),
        )
        # At least one Tool Discoverer call should have been logged.
        kinds = [c["kind"] for c in result.discoverer_calls]
        self.assertIn("tool_discoverer", kinds,
                      f"no tool discoverer call; kinds={kinds}, "
                      f"halt={result.halt_reason}")
        # WH chain should have grown (successor created).
        self.assertGreaterEqual(len(result.state.why_hypotheses), 2)


class TestSerialisable(unittest.TestCase):
    def setUp(self):
        os.environ["BRIDGE_STUB"] = "1"

    def tearDown(self):
        os.environ.pop("BRIDGE_STUB", None)

    def test_to_dict_json_roundtrip(self):
        problem = {"problem_id": "TOY", "goal": "ok", "domain": "optimization"}
        result = do.deep_dive(problem, config=do.DeepDiveConfig(max_iterations=2))
        import json
        json.dumps(result.to_dict())


if __name__ == "__main__":
    unittest.main()
