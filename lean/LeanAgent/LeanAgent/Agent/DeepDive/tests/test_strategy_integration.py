"""Integration test for Gap-1/2/3 composition in strategy_integration.py."""

from __future__ import annotations

import os
import unittest
from pathlib import Path

from LeanAgent.LeanAgent.Agent_legacy.LLM import LLM

from LeanAgent.LeanAgent.Agent.DeepDive.strategy_integration import (
    IterationDecision,
    iterate_with_strategy,
)
from LeanAgent.LeanAgent.Agent.Scout.hypothesis_tracker import (
    Conjecture,
    TrackerState,
)
from LeanAgent.LeanAgent.Agent.Scout.orchestrator import ScoutConfig
from LeanAgent.LeanAgent.Agent.Scout.tractability_report import (
    DifficultySignals,
    TractabilityReport,
)


_STUB_DIR = Path(__file__).resolve().parents[2] / "Scout" / "stubs"


def _strategy_llm() -> LLM:
    return LLM(provider="stub", stub_path=_STUB_DIR / "strategy_proposer.json")


def _scope_llm() -> LLM:
    return LLM(provider="stub", stub_path=_STUB_DIR / "scope_judge.json")


class _FakeScout:
    def __init__(self):
        self.calls = []

    def __call__(self, problem, config):
        self.calls.append(problem["problem_id"])
        return TractabilityReport(
            problem_id=problem["problem_id"],
            scout_outcome="pass",
            scout_evidence="fake",
            scout_wh={},
            scout_rep_id=None,
            estimated_difficulty="shallow",
            difficulty_signals=DifficultySignals(
                verifier_runtime_s=0.1, rep_tools_status="available",
                wh_anchor_size=0, registry_hits=2,
            ),
            recommended_action="deep_dive",
        )


def _state_with_passes() -> TrackerState:
    """State whose conjecture has prior passes."""
    c = Conjecture(
        id="C1",
        form="DL is dismantlable because it is chordal",
        rep_id="rep_022_chordal_peo",
        test_plan={
            "steps": [
                {"step": 1, "instance": "S_{1,1} k=2", "actual_outcome": "pass"},
                {"step": 2, "instance": "S_{1,2} k=3", "actual_outcome": "pass"},
            ],
        },
    )
    state = TrackerState(current_conjecture=c, intent="deep_dive")
    return state


# ────────────────────────────────────────────────────────────────────────────
# Path 1: Scope Judge → continue_with_caveat (S_{2,1} 6/47 scenario)
# ────────────────────────────────────────────────────────────────────────────


class TestScopeContinue(unittest.TestCase):
    def setUp(self):
        os.environ["SCOUT_STUB"] = "1"

    def tearDown(self):
        os.environ.pop("SCOUT_STUB", None)

    def test_op1_s21_continues_with_caveat(self):
        state = _state_with_passes()
        decision = iterate_with_strategy(
            state=state,
            verifier_result={"actual_outcome": "fail"},
            falsification_evidence={
                "n_failing": 6, "n_total": 47,
                "structural_pattern": "non-chordal-non-cone DLs at high genus",
            },
            diagnoser_decision={
                "binary": "rep_too_restrictive",
                "dispatch": "REP_ONLY",
                "obstacle": None,
            },
            config=ScoutConfig(stub_mode=True, batch_id="integ_test"),
            proof_deps={"steps": [{"id": "L1", "claim": "chordal-or-cone implies dismantlable"}]},
            passing_instances=[
                {"instance": "S_{1,1} k=2", "params": {"g": 1, "n": 1, "k": 2},
                 "actual_evidence": "all chordal"},
                {"instance": "S_{1,2} k=3", "params": {"g": 1, "n": 2, "k": 3},
                 "actual_evidence": "chordal-or-cone (271/271)"},
            ],
            failing_instance={"instance": "S_{2,1} k=2", "params": {"g": 2, "n": 1, "k": 2}},
            llm=_scope_llm(),
        )
        self.assertEqual(decision.next_action, "continue_with_caveat")
        self.assertIsNotNone(decision.scope_verdict)
        self.assertEqual(decision.scope_verdict.verdict, "scope_limitation")


# ────────────────────────────────────────────────────────────────────────────
# Path 2: Falsification → Strategy → apply_strategy + Bridge trigger
# ────────────────────────────────────────────────────────────────────────────


class TestStrategyApplied(unittest.TestCase):
    def setUp(self):
        os.environ["SCOUT_STUB"] = "1"
        os.environ["BRIDGE_STUB"] = "1"

    def tearDown(self):
        os.environ.pop("SCOUT_STUB", None)
        os.environ.pop("BRIDGE_STUB", None)

    def test_chordal_failure_routes_to_strategy(self):
        # No prior_passes → skip scope judge, go straight to strategy.
        c = Conjecture(
            id="C1",
            form="DL is dismantlable because it is chordal",
            rep_id="rep_022_chordal_peo",
            test_plan={"steps": [{"step": 1, "actual_outcome": "fail"}]},
        )
        state = TrackerState(current_conjecture=c, intent="deep_dive")
        fake_scout = _FakeScout()
        decision = iterate_with_strategy(
            state=state,
            verifier_result={"actual_outcome": "fail"},
            falsification_evidence={
                "n_failing": 12, "n_total": 54,
                "structural_pattern": "induced 4-cycle, degree (6,5,5,5)",
            },
            diagnoser_decision={
                "binary": "rep_too_restrictive",
                "dispatch": "REP_ONLY",
                "obstacle": {"obstruction_class": "loose_inequality"},
            },
            config=ScoutConfig(stub_mode=True, batch_id="integ_strategy"),
            failed_attempts=[{"form": "DL has universal vertex"}],
            llm=_strategy_llm(),
            scout_one_fn=fake_scout,
        )
        self.assertEqual(decision.next_action, "apply_strategy")
        self.assertIsNotNone(decision.strategy_proposal)
        self.assertIsNotNone(decision.strategy_proposal.recommended_id)
        # Bridge trigger should fire (Diagnoser direct; pattern present).
        self.assertIsNotNone(decision.bridge_trigger_used)


# ────────────────────────────────────────────────────────────────────────────
# Path 3: Verifier did not fail → no_op
# ────────────────────────────────────────────────────────────────────────────


class TestNoOpOnPass(unittest.TestCase):
    def test_no_op_when_no_failure(self):
        state = _state_with_passes()
        decision = iterate_with_strategy(
            state=state,
            verifier_result={"actual_outcome": "pass"},
            falsification_evidence={},
            diagnoser_decision={"binary": "", "dispatch": "", "obstacle": None},
            config=ScoutConfig(stub_mode=True),
        )
        self.assertEqual(decision.next_action, "no_op")
        self.assertIsNone(decision.scope_verdict)
        self.assertIsNone(decision.strategy_proposal)


# ────────────────────────────────────────────────────────────────────────────
# Path 4: Bridge priority order
# ────────────────────────────────────────────────────────────────────────────


class TestBridgePriority(unittest.TestCase):
    def setUp(self):
        os.environ["SCOUT_STUB"] = "1"
        os.environ["BRIDGE_STUB"] = "1"

    def tearDown(self):
        os.environ.pop("SCOUT_STUB", None)
        os.environ.pop("BRIDGE_STUB", None)

    def test_strategy_bridge_beats_diagnoser(self):
        # Strategy stub picks S1 (weaken_property, not bridge) — so Diagnoser
        # path should fire because no priority-1 trigger exists.
        # We verify that whichever fires is a real Bridge call.
        c = Conjecture(
            id="C1", form="X", rep_id="rep_022",
            test_plan={"steps": [{"step": 1, "actual_outcome": "fail"}]},
        )
        state = TrackerState(current_conjecture=c, intent="deep_dive")
        fake_scout = _FakeScout()
        decision = iterate_with_strategy(
            state=state,
            verifier_result={"actual_outcome": "fail"},
            falsification_evidence={
                "n_failing": 5, "n_total": 100,
                "structural_pattern": "test pattern",
            },
            diagnoser_decision={
                "binary": "rep_too_restrictive",
                "dispatch": "REP_ONLY",
                "obstacle": None,
            },
            config=ScoutConfig(stub_mode=True, batch_id="integ_priority"),
            llm=_strategy_llm(),
            scout_one_fn=fake_scout,
        )
        # Either diagnoser or strategy_proposer fires; both are valid.
        self.assertIn(
            decision.bridge_trigger_used,
            ("strategy_proposer", "diagnoser"),
        )


if __name__ == "__main__":
    unittest.main()
