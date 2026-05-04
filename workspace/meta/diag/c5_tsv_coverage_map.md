# Probe 5 — TSV coverage map (10 live calls)

**Method**: ran 10 diverse calls against `tsv_knot.py` in isolation; logged return value and full `{method, submethod, confidence, reason}` tag verbatim. Script: `c5_tsv_probe_script.py`.

## Calls and outcomes

| # | Call | Value | Confidence | Reason |
|---|------|-------|------------|--------|
| 1 | `jones_polynomial("trefoil")` | $-q^{-4}+q^{-3}+q^{-1}$ | **high** | lookup for named knot '3_1' |
| 2 | `jones_polynomial("7_1")` | `None` | **low** | out-of-TSV-scope: unknown knot '7_1' |
| 3 | `jones_polynomial([1,1,1,1,1,1,1])` | `None` | **low** | out-of-TSV-scope: generic-braid Jones not implemented |
| 4 | `jones_polynomial([1,-2,1,-2])` | $q^2-q+1-q^{-1}+q^{-2}$ | **high** | braid word matches '4_1' in table |
| 5 | `alexander_polynomial([1,1,1], n=2)` | $t^2 - t + 1$ | **high** | braid word matches '3_1' in table |
| 6 | `alexander_polynomial([1,1,1,1,1], n=2)` | $t^4-t^3+t^2-t+1$ | **high** | braid word matches '5_1' in table |
| 7 | `kauffman_bracket("trefoil")` | $A^{25}-A^{21}-A^{13}$ | **high** | derived from Jones of '3_1' via `<D> = (-A)^(3w) V(A^-4)` |
| 8 | `kauffman_bracket("T(3,5)")` | `None` | **low** | out-of-TSV-scope: unknown knot 'T(3,5)' |
| 9 | `hyperbolic_volume("trefoil")` | `None` | **high** | '3_1' is non-hyperbolic (torus knot or unknot) |
| 10 | `check_reidemeister_equivalent("trefoil", "3_1m")` | `False` | **high** | Jones polynomials differ => knots distinct |

## Distinguishing success from miss — the tag protocol

The tag fields form a 3-way classification:

- **Real success**: `method="tsv-knot"` + `confidence="high"` + concrete value.  (Calls 1, 4, 5, 6, 10.)
- **Real refusal (acknowledged miss)**: `method="none"` + `confidence="low"` + `"out-of-TSV-scope"`.  (Calls 2, 3, 8.)
- **Authoritative null** (value=None but confidence=high): Call 9 — "'3_1' is non-hyperbolic".  The value is `None` but the tag asserts high confidence that this is the correct non-value.

An Explorer can distinguish these three cases by inspecting:
1. Is `value` not None? → raw success.
2. Is `value` None and `method == "none"`? → the tool didn't know; treat as `[STEP-STUCK]`.
3. Is `value` None and `method == "tsv-knot"` with `"non-hyperbolic"` in the reason? → the tool knew there is no value to compute.

All 10 calls correctly set these fields. **The tagging is consistent and does let a careful Explorer distinguish success from miss.**

## CRITICAL FINDING — Call 7 (kauffman_bracket): high-confidence INCORRECT value

The conventional right-handed trefoil Kauffman bracket (as computed via Temperley–Lieb recursion in Probe 4, and as given in Kauffman 1987) is:
$$\langle 3_1 \rangle = -A^5 - A^{-3} + A^{-7}.$$

TSV returns $A^{25} - A^{21} - A^{13}$, which is **not** equal to $-A^5 - A^{-3} + A^{-7}$ and is not related to it by any simple transformation ($A \to A^{-1}$, sign flip, or overall scale).

### Diagnosis

The implementation computes
```python
bracket = V.subs(q, A**(-4)) * (-A)**(3 * w)
```
with the table's $V_{3_1}(q) = -q^{-4}+q^{-3}+q^{-1}$ and $w = 3$ (writhe of braid word [1,1,1]).

Substitution: $V(A^{-4}) = -A^{16} + A^{12} + A^4$.  Prefactor: $(-A)^9 = -A^9$.  Product: $-A^9 \cdot (-A^{16} + A^{12} + A^4) = A^{25} - A^{21} - A^{13}$.

The Kauffman–Jones identity is $V_L(t) = (-A)^{-3w}\langle L \rangle$ with $t = A^{-4}$, which gives $\langle L \rangle = (-A)^{3w} V_L(A^{-4})$.

Applying this to the REAL right-trefoil bracket: $(-A)^{-9}\langle 3_1\rangle = -A^{-9}(-A^5-A^{-3}+A^{-7}) = A^{-4} + A^{-12} - A^{-16}$, so $V_{3_1}(t)|_{t = A^{-4}} = A^{-4} + A^{-12} - A^{-16}$, i.e. $V_{3_1}(t) = t + t^3 - t^4 = -t^4 + t^3 + t$.

**But the TSV table has $V_{3_1}(q) = -q^{-4} + q^{-3} + q^{-1}$** — the opposite sign of exponents.

Hence: the TSV table's Jones polynomial for the right-handed trefoil is stored in a convention where the reciprocal of the variable is used compared to Kauffman's.  When combined with Kauffman's formula (which assumes the other convention), the bracket function produces a polynomial that is neither Kauffman's right-trefoil bracket nor a standard variant of it.

### Severity

- **Tag confidence is `high`.**  An Explorer that trusts high-confidence TSV will accept this wrong value.
- Call 7 is the only computed-path call in this batch (the others hit the table directly or correctly refuse).  The bug is in the DERIVATION formula, not in the table.
- In a real Probe-4 pipeline, this would surface as a cross-check conflict with the Explorer's independently-derived $B_3$.  **The cross-check would expose the TSV bug rather than confirm the proof** — that is, the current TSV `kauffman_bracket` is actively unsafe as a ground-truth oracle for Kauffman brackets.

### Implications for Probe 4 (retroactive)

In `explorer_1_tl_markov.md` Step 8, the Explorer's claim that
`[CALL:tsv-knot, knot=trefoil, invariant=kauffman_bracket]` returns `-A^5 - A^{-3} + A^{-7}` is **not what the real TSV returns.** A real V2 pipeline would have the Explorer's $B_3$ disagree with the TSV output, triggering a CROSS-VERIFY FAIL in the Auditor. The Probe 4 pipeline report (PASS) depended on this fabricated TSV match. **Added correction** to `c4_fixer_loop_log.md`.

## Other observations

- **Calls 5 and 6 (`n=2` argument)**: The table-match path precedes the Burau fallback, so the `n` argument is ignored if a table match exists. The high confidence is justified by the table match. For a B_3 or higher braid that does NOT match the table, `n=2` would drop to the Burau-in-B_2 path, producing a `medium` confidence value that could be wrong (the Burau normalization in the fallback is fragile per the code comment). This was not exercised in this batch but is a known fragility.
- **Call 9 (authoritative null for non-hyperbolic)**: The function's handling is GOOD. The combination `value=None, confidence=high, reason="non-hyperbolic"` cleanly tells the caller "there is no hyperbolic volume here" without ambiguity. An Explorer can rely on this signal.
- **Call 10 (mirror pair)**: Jones discriminates right from left trefoils (they have different Jones polynomials in this table: $-q^{-4}+q^{-3}+q^{-1}$ vs $-q^4+q^3+q$), so `check_reidemeister_equivalent` correctly returns `False` with high confidence. Alexander would NOT discriminate them (they share $t^2-t+1$), so a Jones-first approach is critical here; the function does try Jones first. GOOD.

## Summary for Concern 5

**Confidence tags are informative and let an Explorer distinguish success from miss** (three-way: real hit, real miss, authoritative null). The TAG PROTOCOL IS WORKING.

**However**, confidence `high` is a signal about the **path** taken (table lookup vs. Burau fallback vs. generic unsupported), not about **correctness**.  In particular:

- `kauffman_bracket("trefoil")` is a `high`-confidence path (table lookup for Jones + formula derivation), but the DERIVATION FORMULA has a convention mismatch with the table, producing an **incorrect** Kauffman bracket.
- An Explorer that treats `high` confidence as "trust the value" would ingest a wrong value and propagate it.
- A well-engineered Explorer should additionally cross-check two high-confidence tag paths against each other when possible (e.g., compare `kauffman_bracket("trefoil")` against `jones_polynomial("trefoil")` and a manually inverted writhe formula). That cross-check would surface the bug.

**Net finding**: confidence tagging IS granular enough to distinguish success from table-miss. It is NOT granular enough to distinguish a correct derivation path from a derivation path with a convention bug. The latter requires end-to-end numerical verification against an independent computation.

*Appended to `ldt_diag_log.md` on 2026-04-20.*
