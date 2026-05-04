"""Tests for verifier dispatcher."""

from __future__ import annotations

import os
import sys
import tempfile
import unittest
from pathlib import Path

from LeanAgent.LeanAgent.Agent.Scout.instance_sorter import TestPlanStep
from LeanAgent.LeanAgent.Agent.Scout.verifier import dispatch, VerifierResult


def _step(cmd) -> TestPlanStep:
    return TestPlanStep(step=1, instance="t", verifier_command=cmd)


class TestPythonCli(unittest.TestCase):
    def test_python_script_pass(self):
        with tempfile.TemporaryDirectory() as tmp:
            script = Path(tmp) / "ok.py"
            script.write_text('print("hello scout")\n', encoding="utf-8")
            result = dispatch(_step({"kind": "python_cli",
                                     "argv": ["python", str(script)]}),
                              timeout_s=10)
            self.assertEqual(result.actual_outcome, "pass")
            self.assertIn("hello scout", result.actual_evidence)

    def test_python_script_fail(self):
        with tempfile.TemporaryDirectory() as tmp:
            script = Path(tmp) / "boom.py"
            script.write_text('import sys; sys.exit(7)\n', encoding="utf-8")
            result = dispatch(_step({"kind": "python_cli",
                                     "argv": ["python", str(script)]}),
                              timeout_s=10)
            self.assertEqual(result.actual_outcome, "fail")

    def test_python_script_string_command(self):
        with tempfile.TemporaryDirectory() as tmp:
            script = Path(tmp) / "echo.py"
            script.write_text('print("string-form")\n', encoding="utf-8")
            # NB: paths on Windows have backslashes; use posix-style joined arg.
            result = dispatch(_step(f'python "{script}"'), timeout_s=10)
            self.assertEqual(result.actual_outcome, "pass")
            self.assertIn("string-form", result.actual_evidence)

    def test_timeout(self):
        # Sleep longer than the timeout.
        result = dispatch(_step({"kind": "python_cli",
                                 "argv": ["python", "-c",
                                          "import time; time.sleep(5)"]}),
                          timeout_s=0.5)
        self.assertEqual(result.actual_outcome, "timeout")
        self.assertIn("0.5", result.actual_evidence)

    def test_empty_argv_errors(self):
        result = dispatch(_step({"kind": "python_cli", "argv": []}),
                          timeout_s=5)
        self.assertEqual(result.actual_outcome, "error")
        self.assertIn("empty argv", result.actual_evidence)


class TestEngineCall(unittest.TestCase):
    def test_engine_call_pass(self):
        result = dispatch(_step({"kind": "engine_call",
                                 "engine": "scout_test_engine",
                                 "op": "echo",
                                 "kwargs": {"value": "hi"}}))
        self.assertEqual(result.actual_outcome, "pass")
        self.assertIn("hi", result.actual_evidence)

    def test_engine_call_fail(self):
        result = dispatch(_step({"kind": "engine_call",
                                 "engine": "scout_test_engine",
                                 "op": "boom",
                                 "kwargs": {}}))
        self.assertEqual(result.actual_outcome, "fail")
        self.assertIn("intentional failure", result.actual_evidence)

    def test_engine_call_unknown_engine(self):
        result = dispatch(_step({"kind": "engine_call",
                                 "engine": "no_such_engine",
                                 "op": "x"}))
        self.assertEqual(result.actual_outcome, "error")

    def test_engine_call_unknown_op(self):
        result = dispatch(_step({"kind": "engine_call",
                                 "engine": "scout_test_engine",
                                 "op": "missing_op"}))
        self.assertEqual(result.actual_outcome, "error")

    def test_engine_call_kwargs(self):
        result = dispatch(_step({"kind": "engine_call",
                                 "engine": "scout_test_engine",
                                 "op": "add",
                                 "kwargs": {"a": 3, "b": 4}}))
        self.assertEqual(result.actual_outcome, "pass")
        self.assertIn("7", result.actual_evidence)


class TestUnknownKind(unittest.TestCase):
    def test_unknown_kind(self):
        result = dispatch(_step({"kind": "telepathy"}))
        self.assertEqual(result.actual_outcome, "error")

    def test_bad_command_type(self):
        result = dispatch(_step(42))
        self.assertEqual(result.actual_outcome, "error")


@unittest.skipUnless(sys.platform != "win32" or os.environ.get("SCOUT_RUN_LEAN_TESTS"),
                     "lean_compile dispatch test requires bash; "
                     "set SCOUT_RUN_LEAN_TESTS=1 to enable.")
class TestLeanCompile(unittest.TestCase):
    def test_missing_path_errors(self):
        # The dispatcher should still validate input shape on any platform.
        result = dispatch(_step({"kind": "lean_compile"}), timeout_s=5)
        self.assertEqual(result.actual_outcome, "error")
        self.assertIn("missing", result.actual_evidence)


class TestLeanCompileShape(unittest.TestCase):
    """Platform-independent shape validation (does not invoke compile.sh)."""

    def test_missing_path_errors_immediately(self):
        result = dispatch(_step({"kind": "lean_compile"}), timeout_s=1)
        self.assertEqual(result.actual_outcome, "error")
        self.assertIn("missing", result.actual_evidence)


if __name__ == "__main__":
    unittest.main()
