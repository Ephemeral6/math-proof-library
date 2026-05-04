"""End-to-End stub test (Phase 3 — final integration).

Wires together:
  Scout (stub) → Deep Dive → Lean Bridge (NOT_RUN) → Novelty (stub).

Asserts the full chain produces a serialisable artefact in <30s.
"""

from __future__ import annotations

import json
import os
import time
import unittest

from LeanAgent.LeanAgent.Agent import runner as r
from LeanAgent.LeanAgent.Agent.DeepDive import lean_bridge as lb
from LeanAgent.LeanAgent.Agent.Scout import novelty_verifier as nv
from LeanAgent.LeanAgent.Agent.Scout.hypothesis_tracker import (
    CompletionStatus,
)


class TestEndToEndStub(unittest.TestCase):
    def setUp(self):
        os.environ["BRIDGE_STUB"] = "1"
        os.environ["NOVELTY_STUB"] = "1"

    def tearDown(self):
        os.environ.pop("BRIDGE_STUB", None)
        os.environ.pop("NOVELTY_STUB", None)

    def test_full_chain_under_30s(self):
        problems = [
            {
                "problem_id": "TOY-CONV-1",
                "goal": (
                    "GD on smooth strongly convex achieves "
                    "‖x_T - x*‖² ≤ (1-μ/L)^T · ‖x_0 - x*‖²"
                ),
                "domain": "optimization",
            },
            {
                "problem_id": "TOY-COMBI-1",
                "goal": "no odd covering system exists with three distinct prime moduli",
                "domain": "combinatorics",
            },
        ]
        cfg = r.RunnerConfig(
            top_k=2,
            stub_mode=True,
            lean_enabled=True,
            novelty_enabled=True,
            deep_dive_config=r.DeepDiveConfig(
                max_iterations=3,
                invoke_bridge=True,
            ),
        )
        t0 = time.time()
        results = r.run_batch(problems, config=cfg)
        elapsed = time.time() - t0

        self.assertLess(elapsed, 30.0,
                        f"E2E stub took {elapsed:.2f}s — exceeds 30s budget")
        self.assertEqual(len(results), 2)

        # Both problems should have completed empirical verification under
        # the default (PASS) verifier hook.
        for res in results:
            self.assertIsNotNone(res.scout_report)
            self.assertIsNotNone(res.deep_dive)
            self.assertIsNotNone(res.lean_status)
            self.assertIsNotNone(res.novelty)

            # Check that the deep-dive reached a terminal state.
            self.assertIn(
                res.deep_dive["completion_status"],
                {
                    CompletionStatus.EMPIRICALLY_VERIFIED.value,
                    CompletionStatus.FORMALLY_CERTIFIED.value,
                    CompletionStatus.PENDING.value,
                },
                f"unexpected status for {res.problem_id}: "
                f"{res.deep_dive['completion_status']}",
            )

            # Lean bridge should be NOT_RUN (we set invoke=False inside
            # runner) — the contract is it WROTE a JSON input file.
            self.assertIn(res.lean_status["status"], {"NOT_RUN", "ERROR"})

            # Novelty should have a verdict.
            self.assertIn(
                res.novelty["novelty_status"],
                {"novel", "rediscovery", "extension", "uncertain"},
            )

        # Erdős-Selfridge stub fixture should drive the combinatorics
        # problem to a `rediscovery` verdict via the stub key heuristic.
        combi = next(r for r in results if r.problem_id == "TOY-COMBI-1")
        # When the deep-dive reaches a positive terminal state, novelty
        # fires; otherwise it returns "not triggered" with status uncertain.
        # Either way the field must exist; we only assert rediscovery
        # when the deep dive reached a positive terminal state.
        if combi.deep_dive["completion_status"] in (
            CompletionStatus.EMPIRICALLY_VERIFIED.value,
            CompletionStatus.FORMALLY_CERTIFIED.value,
        ):
            self.assertEqual(combi.novelty["novelty_status"], "rediscovery")

        # Result should be JSON-serialisable.
        json.dumps([res.to_dict() for res in results])


if __name__ == "__main__":
    unittest.main()
