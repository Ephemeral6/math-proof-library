"""Tests for Sorry Replacer."""

from __future__ import annotations

import os
import tempfile
import unittest
from pathlib import Path

from LeanAgent.LeanAgent.Agent.input_sources import sorry_replacer as sr


SAMPLE_LEAN = '''import Mathlib

/-- A test conjecture.
    AMS: 05
    Category: research open
-/
theorem test_theorem (n : ℕ) (h : n > 0) : n ≥ 1 := by
  sorry

/-- Another one. -/
theorem test_theorem_2 (a b : ℕ) : a + b = b + a := by
  sorry
'''


def _write_temp_lean(text: str) -> Path:
    fd, name = tempfile.mkstemp(suffix=".lean", text=True)
    os.close(fd)
    p = Path(name)
    p.write_text(text, encoding="utf-8")
    return p


def _cleanup(p: Path) -> None:
    for q in (p, p.with_suffix(".lean.bak")):
        if q.exists():
            q.unlink()


class TestReadSorryLocations(unittest.TestCase):
    def test_finds_two_sorries(self):
        p = _write_temp_lean(SAMPLE_LEAN)
        try:
            locs = sr.read_sorry_locations(p)
            self.assertEqual(len(locs), 2)
            self.assertEqual(locs[0].theorem_name, "test_theorem")
            self.assertEqual(locs[1].theorem_name, "test_theorem_2")
            # Sorry lines must point at the actual sorry, not the theorem header
            self.assertGreater(locs[0].sorry_line, locs[0].theorem_start_line)
        finally:
            _cleanup(p)

    def test_no_sorry(self):
        p = _write_temp_lean("-- no theorems here\ndef foo := 42\n")
        try:
            self.assertEqual(sr.read_sorry_locations(p), [])
        finally:
            _cleanup(p)

    def test_skips_theorem_without_sorry(self):
        text = (
            "theorem proven_one : 1 + 1 = 2 := by\n  rfl\n\n"
            "theorem unproven : 2 + 2 = 4 := by\n  sorry\n"
        )
        p = _write_temp_lean(text)
        try:
            locs = sr.read_sorry_locations(p)
            self.assertEqual(len(locs), 1)
            self.assertEqual(locs[0].theorem_name, "unproven")
        finally:
            _cleanup(p)


class TestReplaceSorry(unittest.TestCase):
    def test_replace_first_sorry(self):
        p = _write_temp_lean(SAMPLE_LEAN)
        try:
            locs = sr.read_sorry_locations(p)
            sr.replace_sorry(locs[0], "omega", backup=True)
            new_content = p.read_text(encoding="utf-8")
            self.assertIn("omega", new_content)
            # The second sorry must remain.
            self.assertEqual(new_content.count("sorry"), 1)
            # Backup must exist.
            self.assertTrue(p.with_suffix(".lean.bak").exists())
        finally:
            _cleanup(p)

    def test_replace_multiline_proof(self):
        p = _write_temp_lean(SAMPLE_LEAN)
        try:
            locs = sr.read_sorry_locations(p)
            proof = "intro h\nlinarith"
            sr.replace_sorry(locs[1], proof, backup=False)
            new_content = p.read_text(encoding="utf-8")
            self.assertIn("intro h", new_content)
            self.assertIn("linarith", new_content)
            # Original first sorry untouched.
            self.assertEqual(new_content.count("sorry"), 1)
        finally:
            _cleanup(p)

    def test_replace_unknown_theorem_raises(self):
        p = _write_temp_lean(SAMPLE_LEAN)
        try:
            locs = sr.read_sorry_locations(p)
            fake = sr.SorryLocation(
                file_path=p,
                theorem_name="nonexistent_theorem",
                sorry_line=1,
                sorry_col=0,
                theorem_start_line=1,
                theorem_end_line=1,
                full_statement="",
                original_content="",
            )
            with self.assertRaises(ValueError):
                sr.replace_sorry(fake, "rfl", backup=False)
        finally:
            _cleanup(p)


class TestRollback(unittest.TestCase):
    def test_rollback_restores(self):
        p = _write_temp_lean(SAMPLE_LEAN)
        try:
            locs = sr.read_sorry_locations(p)
            sr.replace_sorry(locs[0], "omega", backup=True)
            self.assertTrue(sr.rollback(p))
            restored = p.read_text(encoding="utf-8")
            self.assertEqual(restored.count("sorry"), 2)
            self.assertFalse(p.with_suffix(".lean.bak").exists())
        finally:
            _cleanup(p)

    def test_rollback_no_backup(self):
        p = _write_temp_lean("x")
        try:
            self.assertFalse(sr.rollback(p))
        finally:
            _cleanup(p)


class TestAttemptFillSorryDryRun(unittest.TestCase):
    """attempt_fill_sorry without lake — verifies the rollback path on missing tooling."""

    def test_missing_lakefile_rolls_back(self):
        # Use a temp file with no lakefile anywhere up the tree.
        with tempfile.TemporaryDirectory() as td:
            p = Path(td) / "Standalone.lean"
            p.write_text(SAMPLE_LEAN, encoding="utf-8")
            result = sr.attempt_fill_sorry(p, "test_theorem", "omega")
            self.assertFalse(result.success)
            # File should be back to original (rollback restored).
            self.assertEqual(p.read_text(encoding="utf-8").count("sorry"), 2)


if __name__ == "__main__":
    unittest.main()
