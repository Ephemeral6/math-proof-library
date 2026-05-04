/-
Graceful-failure test child.
Deliberately references a Mathlib lemma that does not exist; lake build
must fail with an "unknown identifier" / "unknown constant" error so the
recursion harness can record `event: fail` cleanly.
-/
import Mathlib

namespace LeanAgent.Generated

theorem nonexistent_lemma_helper_depth1_idx1 (n : ℕ) : n + 0 = n := by
  -- This identifier is fabricated and is NOT in Mathlib.  The compile
  -- error here is the whole point of the test.
  exact Mathlib.Fabricated.NonExistent.totally_made_up_lemma n

end LeanAgent.Generated
