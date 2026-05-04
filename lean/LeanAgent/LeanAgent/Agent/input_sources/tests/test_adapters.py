"""Tests for input source adapters (Phase 3 — P3-D)."""

from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from LeanAgent.LeanAgent.Agent.input_sources import (
    formal_conjectures_adapter as fca,
    ranked_problems_adapter as rpa,
)


_RANKED_FIXTURE = """\
# Proposer Output

## Top 15 Candidate Problems

### Rank 1: SHB blow-up rate
**Source**: Mode A
**Score**: 108

**Problem Statement**:
For deterministic SHB with momentum β = 1 - O(1/√κ) we have ratio = κ².

**Motivation**: ...

**Estimated Difficulty**: research

---

### Rank 2: Adam dimension explosion on quadratic
**Source**: Mode B

**Problem Statement**:
Adam achieves Ω(d) gap on random PSD quadratic.

**Estimated Difficulty**: research [KEEP-WITH-CAVEAT — partial overlap]

---
"""

_FC_FIXTURE = """\
import Mathlib.Tactic

/-- A toy conjecture about widget convergence.

AMS: 90C25 (Convex programming)
-/
theorem widget_conv (x : ℝ) (h : x > 0) : x ^ 2 > 0 := by
  positivity

/--
Another open problem.

AMS: 11N25
-/
conjecture covering_density (n : ℕ) : True
"""


class TestRankedProblemsAdapter(unittest.TestCase):
    def test_two_blocks_parsed(self):
        with tempfile.TemporaryDirectory() as tmp:
            f = Path(tmp) / "ranked.md"
            f.write_text(_RANKED_FIXTURE, encoding="utf-8")
            problems = rpa.parse_ranked_problems(f)
        self.assertEqual(len(problems), 2)
        p0, p1 = problems
        self.assertEqual(p0["rank"], 1)
        self.assertIn("SHB", p0["title"])
        self.assertIn("κ²", p0["goal"])
        self.assertEqual(p0["domain"], "optimization")
        self.assertEqual(p0["source"], "ranked_problems")
        self.assertEqual(p1["rank"], 2)
        self.assertIn("Adam", p1["title"])

    def test_real_file_parses_some_blocks(self):
        # Smoke-test against the actual ranked_problems.md if present.
        repo_root = Path(__file__).resolve().parents[5]
        cand = repo_root / "workspace" / "projects" / "proposer" / "ranked_problems.md"
        if not cand.exists():
            self.skipTest(f"no real ranked_problems.md at {cand}")
        problems = rpa.parse_ranked_problems(cand, limit=5)
        self.assertGreaterEqual(len(problems), 1)
        for p in problems:
            for k in ("problem_id", "goal", "domain", "source"):
                self.assertIn(k, p)

    def test_limit_caps_output(self):
        with tempfile.TemporaryDirectory() as tmp:
            f = Path(tmp) / "ranked.md"
            f.write_text(_RANKED_FIXTURE, encoding="utf-8")
            problems = rpa.parse_ranked_problems(f, limit=1)
        self.assertEqual(len(problems), 1)


class TestFormalConjecturesAdapter(unittest.TestCase):
    def test_two_decls_parsed(self):
        with tempfile.TemporaryDirectory() as tmp:
            f = Path(tmp) / "Toy.lean"
            f.write_text(_FC_FIXTURE, encoding="utf-8")
            problems = fca.parse_formal_conjectures(Path(tmp))
        names = [p["decl_name"] for p in problems]
        self.assertIn("widget_conv", names)
        # The `conjecture` keyword should also be picked up if Lean
        # accepts it; tolerate either.
        for p in problems:
            self.assertIn(p["domain"], {"optimization", "general", "combinatorics", "statistics", "geometric_topology", "computer_science"})

    def test_ams_routing(self):
        with tempfile.TemporaryDirectory() as tmp:
            f = Path(tmp) / "Toy.lean"
            f.write_text(_FC_FIXTURE, encoding="utf-8")
            problems = fca.parse_formal_conjectures(Path(tmp))
        # widget_conv was tagged AMS 90C25 → optimization.
        widget = next(p for p in problems if p["decl_name"] == "widget_conv")
        self.assertEqual(widget["domain"], "optimization")
        self.assertEqual(widget["ams"].strip().split()[0], "90C25")

    def test_limit(self):
        with tempfile.TemporaryDirectory() as tmp:
            f = Path(tmp) / "Toy.lean"
            f.write_text(_FC_FIXTURE, encoding="utf-8")
            problems = fca.parse_formal_conjectures(Path(tmp), limit=1)
        self.assertEqual(len(problems), 1)

    def test_missing_dir_returns_empty(self):
        problems = fca.parse_formal_conjectures(
            Path("/__definitely_not_a_real_path__/")
        )
        self.assertEqual(problems, [])


if __name__ == "__main__":
    unittest.main()
