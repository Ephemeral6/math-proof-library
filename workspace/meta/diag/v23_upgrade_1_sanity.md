# Sanity check — Upgrade 1 (Dynamic Fixer round limit)

**Date.** 2026-04-21.
**Target.** Confirm the updated Auditor F4 prompt produces `FIXER-STALLED`
on a mock Fixer output that closes a routine SP but introduces a new
HIGH/STRUCTURAL SP.

## Mock Fixer Round-3 output (input)

```
## Progress ledger
- SPs closed this round:
  - SP-5 (LOW, ROUTINE) — Birman citation added for braid-group relation
- SPs introduced this round:
  - SP-7 (HIGH, STRUCTURAL) — new induction variable k_j introduced but
    the recurrence for k_j at step j=0 is not defined
- Net HIGH/STRUCTURAL delta: +1 (regress)

## Fix Report
### Issue 1 Fix (SP-5)
- Original: "Birman relation cited but no page number"
- Fix: added "[Birman 1974, p. 38, relation (3)]"
- Fixed step: step 7 now reads "...by [Birman 1974, p. 38, relation (3)]..."

## Complete Fixed Proof
[... (proof body omitted from mock) ...]

## Summary
- Fixed: 1 issue
- Sympy scripts: 0 added, 0 updated
- Confidence: LOW (introduced new structural concern)
```

## Simulated Auditor F4 execution

Reading `~/.claude/skills/math-auditor/ldt_checklist.md` §F4 procedure:

1. **Ledger present?** YES. (The block is at the top of the Fixer output.)
2. **Cross-reference closed SPs.** Claim: SP-5 closed. Previous audit's
   SP-5 was "Birman relation cited but no page number" (routine, LOW).
   The fixed proof step 7 contains the cited page number. Verified close.
   **FALSE-CLOSE count:** 0.
3. **Cross-reference introduced SPs.** Claim: SP-7 (HIGH, STRUCTURAL)
   introduced. Fixer acknowledged this itself. Auditor reads the fixed
   proof: step with new induction variable k_j lacks j=0 case definition.
   Confirmed. Auditor's independently-detected-new-gap count matches
   Fixer's ledger. No additional unreported gaps.
4. **Honest Net HIGH/STRUCTURAL delta:**
   - HIGH/STRUCTURAL closed this round: 0 (SP-5 was LOW, ROUTINE).
   - HIGH/STRUCTURAL introduced this round: 1 (SP-7).
   - Net: 0 - 1 = -1? **Wait — re-read the rule.** The rule is
     `(# HIGH/STRUCTURAL closed) - (# HIGH/STRUCTURAL introduced)`. Here
     `closed = 0` and `introduced = 1`, so Net = -1. But the rule says
     `negative = progress`. That would be wrong for this case.
   - **Re-read fixer.md carefully.** The prompt in `fixer.md` says:
     "Net HIGH/STRUCTURAL delta: <integer> (negative = progress, zero = stall,
     positive = regress)". So negative MUST mean more closed than introduced.
     The sign convention is `(closed - introduced)` negative = introduced
     exceeds closed = REGRESS, not progress. **Fixer's prompt sign
     convention is inverted!**
   - **Correction needed in fixer.md.** The Fixer mock correctly wrote
     "Net: +1 (regress)" because it interpreted +1 as "introduced exceeds
     closed". To make the semantics match: either (a) flip the sign
     convention in fixer.md to `(closed - introduced)` with
     `negative = regress`, or (b) keep the current literal text
     `negative = progress` and define Net as
     `(introduced - closed)` so that closing more gives Net < 0.

**Option (b) is consistent with the Fixer mock.** The mock wrote
"Net HIGH/STRUCTURAL delta: +1 (regress)" meaning 1 introduced, 0 closed,
so `introduced - closed = +1`. This matches "positive = regress".

**Prompt clarification to apply:** fixer.md's formula should be stated
explicitly as `Net = (# introduced HIGH/STRUCTURAL) - (# closed HIGH/STRUCTURAL)`.
Applying the fix (see next block).

5. **Gate outcome (using Net = introduced - closed = +1):**
   - Net > 0 ⇒ regress.
   - At least one HIGH/STRUCTURAL SP remains open (SP-7 itself, and any
     HIGH/STRUCTURAL SPs from prior rounds not closed this round).
   - Outcome: **FIXER-STALLED.**

## Auditor F4 output (simulated)

```
### F4 Fixer progress check
- Ledger present: YES
- Claimed closed: 1 (SP-5, LOW/ROUTINE) — of which FALSE-CLOSE: 0
- Claimed introduced: 1 (SP-7, HIGH/STRUCTURAL)
- Auditor-detected new gaps: 1 (matches ledger; 0 unreported)
- Honest Net HIGH/STRUCTURAL delta: +1 (regress: 0 closed, 1 introduced)
- Gate outcome: FIXER-STALLED
```

## Result

**PASS (with prompt clarification).** The updated F4 rule produces the
expected `FIXER-STALLED` outcome on a mock round that closes 1 routine
SP while introducing 1 HIGH/STRUCTURAL SP.

**Clarification applied to fixer.md**: Net delta formula is now
explicitly `Net = (# HIGH/STRUCTURAL introduced) - (# HIGH/STRUCTURAL
closed)` with `positive = regress, zero = stall, negative = progress`.
This is consistent with the mock Fixer output's own reporting.

See fixer.md for the updated language.
