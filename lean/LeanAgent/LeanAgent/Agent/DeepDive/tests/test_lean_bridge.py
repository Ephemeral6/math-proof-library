"""Tests for Lean Bridge (Phase 3 — P3-B)."""

from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from LeanAgent.LeanAgent.Agent.DeepDive import lean_bridge as lb
from LeanAgent.LeanAgent.Agent.Scout.hypothesis_tracker import (
    CompletionStatus,
    Conjecture,
    TrackerState,
    WhyHypothesis,
)


def _make_state(status: str) -> TrackerState:
    return TrackerState(
        current_conjecture=Conjecture(
            id="toy_descent",
            form="f(y) ≤ f(x) + ⟨∇f(x), y-x⟩ + (L/2)‖y-x‖²",
            completion_status=status,
            verification_qualifier="EXACT",
        ),
        why_hypotheses=[
            WhyHypothesis(
                id="WH-1",
                claim="L-smooth gives Lipschitz gradient",
                candidate_property="apply Cauchy-Schwarz on the integral form",
            ),
            WhyHypothesis(
                id="WH-2",
                claim="γ(t) = x + t(y-x) parametrises the segment",
                candidate_property="define γ and apply the FTC",
            ),
        ],
        intent="deep_dive",
    )


class TestExtractProofTarget(unittest.TestCase):
    def test_steps_count_matches_wh_chain(self):
        s = _make_state(CompletionStatus.EMPIRICALLY_VERIFIED.value)
        target = lb.extract_proof_target(s)
        self.assertEqual(len(target.steps), len(s.why_hypotheses))
        self.assertEqual(target.theorem_name, "toy_descent")

    def test_target_dict_serialisable(self):
        s = _make_state(CompletionStatus.FORMALLY_CERTIFIED.value)
        target = lb.extract_proof_target(s)
        d = target.to_dict()
        json.dumps(d)


class TestPrepareLeanInput(unittest.TestCase):
    def test_writes_input_json(self):
        s = _make_state(CompletionStatus.EMPIRICALLY_VERIFIED.value)
        target = lb.extract_proof_target(s)
        with tempfile.TemporaryDirectory() as tmp:
            path = lb.prepare_lean_input(target, output_dir=tmp)
            self.assertTrue(path.exists())
            data = json.loads(path.read_text(encoding="utf-8"))
            # Must match the test JSON shape used by Agent_legacy.Runner.
            for k in ("theorem_name", "theorem_nl",
                      "assumptions", "conclusion", "steps"):
                self.assertIn(k, data, f"missing key {k}")


class TestRunLeanPipeline(unittest.TestCase):
    def test_invoke_false_returns_not_run(self):
        with tempfile.TemporaryDirectory() as tmp:
            input_path = Path(tmp) / "x.json"
            input_path.write_text("{}", encoding="utf-8")
            r = lb.run_lean_pipeline(input_path, invoke=False)
        self.assertEqual(r.status, "NOT_RUN")


class TestAttemptFormalCertification(unittest.TestCase):
    def test_pending_status_yields_not_triggered(self):
        s = _make_state(CompletionStatus.PENDING.value)
        with tempfile.TemporaryDirectory() as tmp:
            r = lb.attempt_formal_certification(s, output_dir=tmp)
        self.assertEqual(r["status"], "NOT_TRIGGERED")

    def test_triggered_status_writes_input_and_returns_not_run(self):
        s = _make_state(CompletionStatus.EMPIRICALLY_VERIFIED.value)
        with tempfile.TemporaryDirectory() as tmp:
            r = lb.attempt_formal_certification(
                s, output_dir=tmp, invoke=False,
            )
            self.assertEqual(r["status"], "NOT_RUN")
            self.assertTrue(Path(r["input_json"]).exists())


if __name__ == "__main__":
    unittest.main()
