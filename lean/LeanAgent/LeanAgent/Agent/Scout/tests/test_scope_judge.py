"""Tests for scope_judge."""

from __future__ import annotations

import os
import unittest
from pathlib import Path

from LeanAgent.LeanAgent.Agent_legacy.LLM import LLM

from LeanAgent.LeanAgent.Agent.Scout.hypothesis_tracker import (
    Conjecture, TrackerState
)
from LeanAgent.LeanAgent.Agent.Scout.scope_judge import (
    ScopeSignals,
    ScopeVerdict,
    Workaround,
    check_failure_severity,
    check_parameter_boundary,
    check_proof_dependency,
    check_structural_consistency,
    has_prior_passes,
    llm_scope_tiebreak,
    run_scope_judge,
)


_STUB = Path(__file__).resolve().parents[1] / "stubs" / "scope_judge.json"


def _stub_llm() -> LLM:
    return LLM(provider="stub", stub_path=_STUB)


# ────────────────────────────────────────────────────────────────────────────
# Signal 1: parameter boundary
# ────────────────────────────────────────────────────────────────────────────


class TestParameterBoundary(unittest.TestCase):
    def test_outside_convex_hull_high_signal(self):
        passing = [
            {"params": {"g": 1, "n": 1, "k": 2}},
            {"params": {"g": 1, "n": 2, "k": 3}},
        ]
        failing = {"params": {"g": 2, "n": 1, "k": 5}}
        s = check_parameter_boundary(failing, passing)
        # g=2 outside [1,1]; k=5 outside [2,3]; n=1 inside → 2/3.
        self.assertGreater(s, 0.6)
        self.assertLess(s, 0.7)

    def test_inside_convex_hull_zero_signal(self):
        passing = [
            {"params": {"k": 2}},
            {"params": {"k": 5}},
        ]
        failing = {"params": {"k": 3}}
        self.assertEqual(check_parameter_boundary(failing, passing), 0.0)

    def test_no_passing_returns_zero(self):
        self.assertEqual(check_parameter_boundary({"params": {"k": 5}}, []), 0.0)

    def test_no_numeric_params_returns_zero(self):
        self.assertEqual(
            check_parameter_boundary({"params": {"name": "x"}}, [{"params": {"name": "y"}}]),
            0.0,
        )


# ────────────────────────────────────────────────────────────────────────────
# Signal 2: structural consistency
# ────────────────────────────────────────────────────────────────────────────


class TestStructuralConsistency(unittest.TestCase):
    def test_novel_pattern_high_signal(self):
        passing = [{"actual_evidence": "all chordal; no induced 4-cycles"}]
        failing = {"structural_pattern": "induced 4-cycle, degree (6,5,5,5)"}
        s = check_structural_consistency(failing, passing)
        self.assertGreater(s, 0.6)

    def test_same_pattern_low_signal(self):
        passing = [{"actual_evidence": "all chordal; no induced 4-cycles"}]
        failing = {"structural_pattern": "induced 4-cycles found"}
        # token overlap is high → score lowered toward falsification.
        s = check_structural_consistency(failing, passing)
        self.assertLess(s, 0.6)

    def test_empty_pattern_returns_neutral(self):
        s = check_structural_consistency({}, [{"actual_evidence": "ok"}])
        self.assertEqual(s, 0.5)


# ────────────────────────────────────────────────────────────────────────────
# Signal 3: severity
# ────────────────────────────────────────────────────────────────────────────


class TestFailureSeverity(unittest.TestCase):
    def test_low_ratio_high_signal(self):
        # 5% failures
        self.assertGreater(check_failure_severity(5, 100), 0.85)

    def test_high_ratio_low_signal(self):
        # 60% failures
        self.assertEqual(check_failure_severity(60, 100), 0.0)

    def test_zero_total_returns_zero(self):
        self.assertEqual(check_failure_severity(5, 0), 0.0)


# ────────────────────────────────────────────────────────────────────────────
# Signal 4: workaround search (LLM stub)
# ────────────────────────────────────────────────────────────────────────────


class TestProofDependency(unittest.TestCase):
    def setUp(self):
        os.environ["SCOUT_STUB"] = "1"

    def tearDown(self):
        os.environ.pop("SCOUT_STUB", None)

    def test_workaround_found_via_stub(self):
        w = check_proof_dependency(
            conjecture={"form": "DL is dismantlable via chordal-or-cone"},
            failing_instance={"instance": "S_{2,1} k=2"},
            falsification_evidence={"structural_pattern": "non-chordal-non-cone"},
            proof_deps={"steps": [{"id": "L1", "claim": "..."}]},
            llm=_stub_llm(),
        )
        self.assertTrue(w.exists)
        self.assertIn("Lemma 7.1", w.description)

    def test_no_proof_deps_no_llm_call(self):
        # Even without stub_llm, should not crash.
        w = check_proof_dependency(
            conjecture={}, failing_instance={}, falsification_evidence={},
            proof_deps=None,
        )
        self.assertFalse(w.exists)


# ────────────────────────────────────────────────────────────────────────────
# has_prior_passes helper
# ────────────────────────────────────────────────────────────────────────────


class TestHasPriorPasses(unittest.TestCase):
    def test_dict_state_with_pass(self):
        state = {
            "current_conjecture": {
                "test_plan": {"steps": [{"actual_outcome": "pass"},
                                         {"actual_outcome": "fail"}]}
            }
        }
        self.assertTrue(has_prior_passes(state))

    def test_dict_state_without_pass(self):
        state = {
            "current_conjecture": {
                "test_plan": {"steps": [{"actual_outcome": "fail"}]}
            }
        }
        self.assertFalse(has_prior_passes(state))

    def test_empty_state(self):
        self.assertFalse(has_prior_passes({}))
        self.assertFalse(has_prior_passes(None))

    def test_dataclass_state(self):
        c = Conjecture(id="C", form="x", rep_id="r",
                       test_plan={"steps": [{"actual_outcome": "pass"}]})
        state = TrackerState(current_conjecture=c)
        self.assertTrue(has_prior_passes(state))


# ────────────────────────────────────────────────────────────────────────────
# End-to-end run_scope_judge
# ────────────────────────────────────────────────────────────────────────────


class TestRunScopeJudge(unittest.TestCase):
    def setUp(self):
        os.environ["SCOUT_STUB"] = "1"

    def tearDown(self):
        os.environ.pop("SCOUT_STUB", None)

    def test_op1_s21_scenario_yields_scope_limitation(self):
        # OP-1 §11.7: 6 non-chordal-non-cone on S_{2,1} k=2 out of 47.
        v = run_scope_judge(
            conjecture={"form": "DL is dismantlable via chordal-or-cone dichotomy"},
            passing_instances=[
                {"instance": "S_{1,1} k=2", "params": {"g": 1, "n": 1, "k": 2},
                 "actual_evidence": "all chordal", "structural_pattern": "chordal"},
                {"instance": "S_{1,1} k=3", "params": {"g": 1, "n": 1, "k": 3},
                 "actual_evidence": "all chordal", "structural_pattern": "chordal"},
                {"instance": "S_{1,2} k=3", "params": {"g": 1, "n": 2, "k": 3},
                 "actual_evidence": "chordal-or-cone holds (271/271)",
                 "structural_pattern": "chordal-or-cone"},
            ],
            failing_instance={"instance": "S_{2,1} k=2",
                              "params": {"g": 2, "n": 1, "k": 2}},
            falsification_evidence={
                "n_failing": 6, "n_total": 47,
                "structural_pattern": "non-chordal-non-cone DLs at high genus",
            },
            proof_deps={"steps": [{"id": "L1", "claim": "chordal-or-cone implies dismantlable"}]},
            llm=_stub_llm(),
        )
        self.assertEqual(v.verdict, "scope_limitation")
        self.assertEqual(v.recommendation, "continue_with_scope_caveat")
        self.assertTrue(v.workaround.exists)
        self.assertIn("Lemma 7.1", v.workaround.description)

    def test_high_severity_yields_falsification(self):
        # Severity = 0 (60% fail), boundary = 0 (param inside range),
        # structure ≈ 0.3 (pattern exactly seen in passing).
        # → scope_score ≈ 0.09 ≤ 0.3 → falsification (no tiebreak needed).
        v = run_scope_judge(
            conjecture={"form": "X holds"},
            passing_instances=[
                {"instance": "P1", "params": {"k": 2},
                 "actual_evidence": "induced 4-cycle still seen",
                 "structural_pattern": "induced 4-cycle still seen"},
                {"instance": "P2", "params": {"k": 4},
                 "actual_evidence": "induced 4-cycle still seen",
                 "structural_pattern": "induced 4-cycle still seen"},
            ],
            failing_instance={"instance": "P3", "params": {"k": 3}},     # inside [2,4]
            falsification_evidence={
                "n_failing": 60, "n_total": 100,
                "structural_pattern": "induced 4-cycle still seen",
            },
            proof_deps=None,
            llm=_stub_llm(),
        )
        self.assertEqual(v.verdict, "falsification")
        self.assertEqual(v.recommendation, "abandon")

    def test_uncertain_routes_to_human_review(self):
        # Force middle-band scope_score by skipping workaround.
        # Using stub fixture that returns uncertain via the explicit prompt key.
        # We bypass the tiebreak fixture by providing a plain `any` stub
        # that returns low confidence.
        from pathlib import Path
        import tempfile, json
        with tempfile.TemporaryDirectory() as tmp:
            stub = Path(tmp) / "uncertain_stub.json"
            stub.write_text(json.dumps({
                "scope_judge::workaround": '{"exists": false, "description": "", "cost": "medium"}',
                "scope_judge::tiebreak":
                    '{"verdict": "uncertain", "confidence": 0.45, "rationale": "ambiguous"}',
            }))
            llm = LLM(provider="stub", stub_path=stub)
            v = run_scope_judge(
                conjecture={"form": "X"},
                passing_instances=[{"instance": "P", "params": {"k": 2},
                                    "actual_evidence": "weird"}],
                failing_instance={"instance": "Q", "params": {"k": 3}},
                falsification_evidence={
                    "n_failing": 30, "n_total": 100,
                    "structural_pattern": "ambiguous",
                },
                proof_deps={"steps": []},
                llm=llm,
            )
            self.assertEqual(v.verdict, "uncertain")
            self.assertEqual(v.recommendation, "human_review")
            self.assertLess(v.confidence, 0.6)

    def test_signals_attached_to_verdict(self):
        v = run_scope_judge(
            conjecture={"form": "X"},
            passing_instances=[{"instance": "P", "params": {"k": 2},
                                "actual_evidence": "chordal"}],
            failing_instance={"instance": "Q", "params": {"k": 5}},
            falsification_evidence={"n_failing": 5, "n_total": 100,
                                    "structural_pattern": "non-chordal"},
            proof_deps=None,
            llm=_stub_llm(),
        )
        self.assertIsInstance(v.signals, ScopeSignals)
        self.assertGreater(v.signals.scope_score, 0)


# ────────────────────────────────────────────────────────────────────────────
# Completion-status interaction (§F)
# ────────────────────────────────────────────────────────────────────────────


def _apply_scope_to_completion(verdict: ScopeVerdict, prior: str) -> str:
    """The mapping enforced by orchestrator (§F). Local copy for testing."""
    if verdict.verdict == "scope_limitation" and verdict.workaround.exists:
        return prior
    if verdict.verdict == "scope_limitation":
        return "inconclusive_open"
    if verdict.verdict == "falsification":
        return "falsified"
    return prior


class TestCompletionStatusMapping(unittest.TestCase):
    def test_scope_with_workaround_keeps_status(self):
        v = ScopeVerdict(verdict="scope_limitation", confidence=0.8, rationale="",
                         affected_scope="x", unaffected_scope="y",
                         workaround=Workaround(exists=True, description="L7.1"),
                         recommendation="continue_with_scope_caveat")
        self.assertEqual(_apply_scope_to_completion(v, "empirically_verified"),
                         "empirically_verified")

    def test_scope_without_workaround_becomes_inconclusive(self):
        v = ScopeVerdict(verdict="scope_limitation", confidence=0.8, rationale="",
                         affected_scope="x", unaffected_scope="y",
                         workaround=Workaround(exists=False),
                         recommendation="continue_with_scope_caveat")
        self.assertEqual(_apply_scope_to_completion(v, "empirically_verified"),
                         "inconclusive_open")

    def test_falsification_becomes_falsified(self):
        v = ScopeVerdict(verdict="falsification", confidence=0.9, rationale="",
                         affected_scope="x", unaffected_scope="y",
                         workaround=Workaround(exists=False),
                         recommendation="abandon")
        self.assertEqual(_apply_scope_to_completion(v, "empirically_verified"),
                         "falsified")


if __name__ == "__main__":
    unittest.main()
