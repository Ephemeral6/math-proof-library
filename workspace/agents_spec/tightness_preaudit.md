# Tightness Pre-Audit — Stage Specification

**Version**: 1.0
**Created**: 2026-04-29
**Position in pipeline**: Explorer → **Tightness Pre-Audit** → Judge → Auditor → Fixer → Archive
**Trigger**: math-proof-agent orchestrator after Explorer frames are emitted, before Judge selects a Winner.
**Model**: Sonnet (cheap, structured table generation; defers symbolic checks to math-verifier via CALL markers).

---

## 0. Why this stage exists

Across OP-2 (Math.Prog. submission, v3–v5) the pipeline produced proofs that **closed but with a wrong rate**:

| Failure | Symptom |
|---|---|
| v5 §4.2.1 | Quoted GFJ2015 *Cesàro-average* upper bound as a tightness witness against an OP-2 *last-iterate* lower bound. UB and LB attached to different metrics — comparison vacuous. |
| Theorem 3 Step 2–3 | Bounded a signed inner-product sum $\sum_t \langle b_t, z_t-z^\star\rangle$ by Cauchy–Schwarz, replacing a $\Theta(T^0)$ telescoping cancellation with a $\Theta(T^{0.2})$ absolute bound. End-to-end rate dropped from $T^{-1/2}$ to $T^{-0.3}$. |
| v4 tightness claim | Claimed leading constant $\kappa/10$. Re-tracking through the binding step at $t=4$ revealed the actual achievable constant was $\kappa/23$. Bottleneck step had a $>2.3\times$ slack and was never flagged. |

Each was a **bound that closed but was too loose**, and the agent had no mechanism to notice. Tightness Pre-Audit's job is to produce that mechanism: every inequality in the proof is checked numerically *and* asymptotically against the headline rate before the proof goes to Judge.

This stage **does not rewrite the proof**; it produces a structured report that Judge and Auditor consume.

---

## 1. Input contract

The orchestrator passes Tightness Pre-Audit:

1. `frames/`: directory containing one subdir per Explorer route, e.g. `frames/route_1/proof.md`, `frames/route_2/proof.md`, …
2. `target_rate.txt`: a one-line statement of the headline rate the proof claims, in the form `<metric> = O(<expression-in-T>)` or `<metric> = Ω(<expression-in-T>)`. Example: `E[f(x_T)-f*] = O(T^{-1/2})`.
3. `target_metric.txt`: one of `last-iterate | cesaro-average | best-iterate | weighted-average | minimum-iterate`. Used by T2.
4. `setting.txt`: one line, `deterministic | stochastic`. Used by T5.

If any input is missing the stage emits `[INPUT-MISSING]` in the report header and proceeds with whatever is available.

---

## 2. Per-frame protocol

For each `frames/route_N/proof.md`:

### Step 1 — Inequality extraction

Parse the proof, building a list of inequalities. An "inequality" is any line of the form $A \leq B$, $A \geq B$, $A = B$ where the equality is a lossy bookkeeping step (e.g. invoking $|x| = \sqrt{x^2}$ then bounding $\sqrt{x^2}$ by something larger).

For each inequality record:

```
step_id   : N.M   (Step number from the proof)
LHS       : symbolic expression
RHS       : symbolic expression
technique : {triangle | cauchy-schwarz | young | jensen | descent-lemma | ...}
free_vars : set of free parameters (T, η, σ, β, μ, L, …)
```

If the proof lacks numbered steps, number them sequentially as encountered.

### Step 2 — Run the five checks

Apply T1–T5 (defined in §3) to the extracted inequalities. Each check produces zero or more rows in the report.

### Step 3 — Emit `frames/route_N/tightness_report.md`

Use the format in §4.

### Step 4 — Compute frame verdict

```
verdict = REJECT_FRAME      if any T1, T2, or T5 row is CRITICAL
        = FIX_BEFORE_JUDGE  if T3 or T4 has WARNING but no CRITICAL anywhere
        = PROCEED           otherwise
```

The verdict is written to the frame's report header and to a top-level `frames/preaudit_summary.md`.

---

## 3. The five checks

### T1 — Rate preservation

**Goal**: Catch inequalities that lower the asymptotic rate.

**For each inequality $A \leq B$ in the proof** with $T$ as a free variable:

1. Pick three test scales: $T \in \{10^2, 10^4, 10^6\}$. For other free variables (η, σ, β, μ, L, …) substitute the values stated in the theorem hypothesis or, failing that, the canonical defaults `η = 1/L`, `σ = 1`, `β = 0.9`, `μ = 0`, `L = 1`.
2. Evaluate $A(T)$ and $B(T)$ numerically. (Use `[CALL:math-verifier]` mode `numpy` if symbolic evaluation is non-trivial.)
3. Compute $\text{ratio}(T) = B(T)/|A(T)|$ at each $T$. (Take absolute value to handle signed sums; if $A$ changes sign, evaluate $\sum |A|$ vs $|\sum A|$ separately — see T4.)
4. Estimate the *rate exponent* of $A$ and $B$:
   $$\hat\alpha = \frac{\log B(10^6) - \log B(10^2)}{\log 10^6 - \log 10^2}, \qquad \hat\alpha_A \text{ analogously.}$$
5. Classify:

| Condition | Severity |
|---|---|
| $\hat\alpha_B - \hat\alpha_A > 0.05$ (rate strictly worse on RHS) | **CRITICAL** |
| $\hat\alpha_B - \hat\alpha_A \in [-0.05, 0.05]$ but $\text{ratio}(10^6) > 10$ | WARNING |
| Otherwise | OK |

The CRITICAL bar is a *rate* drop, not a constant drop. A $1000\times$ constant blow-up at fixed $T$ is a T3 issue, not T1.

**Cross-check**: if the proof's headline rate (from `target_rate.txt`) is $T^{-\alpha}$ but the cumulative product of all OK-and-WARNING inequalities yields rate $T^{-\beta}$ with $\beta < \alpha$, emit a synthetic CRITICAL row labelled `END-TO-END-RATE-DROP`. This catches cases where each individual step is "only a little loose" but they compound.

### T2 — Metric consistency

**Goal**: Catch UB-vs-LB comparisons across mismatched metrics.

For every external citation in the proof (`[REF:...]` or any inline citation of a published bound):

1. Identify whether the cited bound is on **last iterate** $f(x_T)-f^\star$, **Cesàro average** $f(\bar x_T)-f^\star$, **best iterate** $\min_{t\le T} f(x_t)-f^\star$, **weighted average**, or **minimum-gradient** $\min_{t\le T}\|\nabla f(x_t)\|^2$. Read this from the cited source's theorem statement; if ambiguous, mark `[METRIC-AMBIGUOUS]`.
2. Compare with `target_metric.txt`.

| Condition | Severity |
|---|---|
| Cited metric and target metric differ AND the proof uses the citation as a *tightness witness* (UB matching the proof's LB or vice versa) | **CRITICAL** |
| Cited metric and target metric differ but the citation is used only for context (e.g., "for comparison, ..."), not for tightness | WARNING |
| Same metric type but different sub-flavour (e.g. expectation vs almost-sure) | WARNING |
| Match | OK |

Additionally, if the proof produces a UB on $f(x_T)-f^\star$ but quotes a LB on $\|\nabla f(x_T)\|^2$ (or vice versa), emit WARNING `metric-type-mismatch` — these are not directly comparable without smoothness/PL conversion, which is itself a lossy step.

**Required output**: explicit "metric chain" table showing every UB/LB used and its metric, even if all consistent.

### T3 — Constant tracking

**Goal**: Identify the bottleneck step in the leading-constant derivation.

1. Read the proof's final constant $C$ (the prefactor in the headline bound).
2. Trace backwards: every inequality contributes a multiplicative factor $c_i \geq 1$ (with $c_i = 1$ meaning no slack). Build the chain $C = \prod_i c_i$.
3. Numerically evaluate each $c_i$ at the canonical parameter values (or at the binding instance the proof identifies — if the proof claims tightness at a specific $t^\star$, use that).
4. Identify the *bottleneck step* = $\arg\max_i c_i$.
5. Classify:

| Condition | Severity |
|---|---|
| Bottleneck $c_i > 100$ AND no published lower bound certifies this slack is unavoidable | WARNING |
| Bottleneck $c_i > 100$ AND a published LB certifies the slack | OK (annotated `unavoidable-slack`) |
| Bottleneck $c_i \in [10, 100]$ | NOTE |
| Bottleneck $c_i < 10$ | OK |

If the proof claims the leading constant is $C^\star$ but the bottleneck step alone produces $c_i > C^\star$, emit CRITICAL `tightness-claim-violated`. (This is the v4 $\kappa/10$ vs $\kappa/23$ case.)

### T4 — Triangle inequality / Cauchy–Schwarz alert

**Goal**: Catch every place a *signed* sum is bounded by an *unsigned* sum, and quantify the loss.

Search the proof for the following techniques (regex-class match):

- `triangle inequality`, `\\Vert.*\\Vert\\,?\\le.*\\Vert.*\\Vert\\,?\\+`, `|a+b|\\le|a|+|b|`
- `cauchy[- ]?schwarz`, `Cauchy.{0,5}Schwarz`, `\\langle.*\\rangle.*\\le.*\\Vert.*\\Vert.*\\Vert.*\\Vert`
- `young.{0,5}inequality`, `ab\\le.*a^2.*b^2`
- `\\sum.*\\le.*\\sum.*|.*|` (sum of absolute values)

For each occurrence:

1. Identify the LHS (signed object) and RHS (unsigned bound).
2. Numerically evaluate both at the canonical parameter values, sampling random sign patterns / noise realizations (≥1000 samples; via `[CALL:math-verifier]` mode `numpy`).
3. Compute $r = \mathbb{E}[\text{RHS}] / \mathbb{E}[|\text{LHS}|]$.
4. Classify:

| Condition | Severity |
|---|---|
| $r > 10$ AND LHS contains a noise/martingale/oscillatory term that LHS-without-bound has expected cancellation | **WARNING** with `signed-structure-lost` |
| $r > 10$ but LHS has no cancellation structure (e.g. all-positive) | NOTE only |
| $r \le 10$ | OK |

**Suggestion field** (mandatory when WARNING fires): name at least one alternative bookkeeping that preserves the signed structure. Default suggestions:

- "Replace with telescoping identity: $\\sum_t \\langle b_t, z_t-z^\\star\\rangle = \\langle B_T, z_T-z^\\star\\rangle - \\sum_t \\langle B_t, z_{t+1}-z_t\\rangle$ where $B_t=\\sum_{s\\le t}b_s$."
- "Replace with Young's inequality with optimal constant: $\\langle a,b\\rangle \\le \\frac{\\lambda}{2}\\|a\\|^2 + \\frac{1}{2\\lambda}\\|b\\|^2$, then choose $\\lambda$ to balance against the sister term."
- "Replace with Doob/Burkholder for martingale increments: $\\mathbb{E}[\\sum_t \\xi_t]^2 = \\sum_t \\mathbb{E}\\xi_t^2$ when $\\xi_t$ is a martingale-difference sequence."
- "Replace with Abel summation if one factor is monotone."

T4 is the direct lesson from OP-2 Theorem 3: that proof should never have lost the signed structure of $\sum\langle b_t, z_t-z^\star\rangle$ to Cauchy–Schwarz.

### T5 — Stochastic vs deterministic consistency

**Goal**: Catch deterministic-style arguments quietly applied in a stochastic setting.

Triggered only when `setting.txt = stochastic`.

For each step in the proof:

1. Check whether the step relies on any of:
   - $x_T \to x^\star$ (almost-sure or in-expectation pointwise convergence)
   - $\nabla f(x_T) \to 0$
   - Telescoping that sums to $f(x_0)-f(x^\star)$ exactly
   - $\eta_t \to 0$ summability arguments without a noise floor
2. Verify the step survives stochastic perturbation: under bounded variance $\sigma^2 > 0$, does $\mathbb{E}\|x_T-x^\star\|^2$ have a noise floor $\Omega(\sigma^2/T)$ or $\Omega(\sigma^2)$ that contradicts the deterministic claim?

| Condition | Severity |
|---|---|
| Step would force $x_T \to x^\star$ or $\nabla f(x_T)\to 0$ as $T\to\infty$ in stochastic setting with $\sigma>0$ | **CRITICAL** `stochastic-floor-violated` |
| Step requires square-summable $\sum\eta_t^2 < \infty$ that the actual schedule does not satisfy | WARNING |
| Step is "deterministic in spirit" but algebraically survives (e.g. uses smoothness only) | OK |

T5 is the ADAGRAD-COORDWISE-OFUL-AMGM-EXPONENT-MISMATCH lesson generalized: a deterministic AM-GM balance has fewer terms than a stochastic one because the noise floor adds a third term. Any deterministic argument transferred wholesale into a stochastic proof is suspect.

---

## 4. Output format — `tightness_report.md`

```markdown
# Tightness Pre-Audit — Frame {N}
Generated: {YYYY-MM-DD HH:MM}
Target rate: {string from target_rate.txt}
Target metric: {string from target_metric.txt}
Setting: {deterministic|stochastic}

## T1 — Rate preservation
| Step | Inequality (LHS ≤ RHS) | LHS rate | RHS rate | ratio @ T=1e6 | Status |
|---|---|---|---|---|---|
| 2.3 | Σ⟨b_t, z_t-z*⟩ ≤ √(Σ‖b_t‖²) · √(Σ‖z_t-z*‖²) | T^0 | T^{0.2} | 320 | **CRITICAL** |
| ... | ... | ... | ... | ... | ... |

End-to-end rate check: target T^{-1/2}, derived T^{-0.3} — **CRITICAL: END-TO-END-RATE-DROP**

## T2 — Metric consistency
| Citation | Cited metric | Target metric | Used as | Status |
|---|---|---|---|---|
| GFJ2015 Thm 3 | Cesàro average | last iterate | tightness witness | **CRITICAL** |
| ... | ... | ... | ... | ... |

## T3 — Constant tracking
| Final constant | Bottleneck step | Bottleneck factor | Published LB? | Status |
|---|---|---|---|---|
| C = κ/10 (claimed) | Step 5: descent-lemma slack at t=4 | 23 | none | **CRITICAL: tightness-claim-violated** (κ/23 > κ/10) |

## T4 — Triangle / Cauchy–Schwarz alerts
| Step | Technique | E[|LHS|] | E[RHS] | r | Suggested replacement | Status |
|---|---|---|---|---|---|---|
| 2.3 | Cauchy–Schwarz on signed inner-product sum | 0.04·T^0 | 12·T^{0.2} | 320 | telescoping via $B_t=\sum_{s\le t}b_s$ | **WARNING** signed-structure-lost |

## T5 — Stochastic consistency
| Step | Deterministic claim | Stochastic counter | Status |
|---|---|---|---|
| 4.7 | $\nabla f(x_T) \to 0$ as $T\to\infty$ | bounded variance σ²>0 forces $\|\nabla f(x_T)\|^2 \ge c\sigma^2/T$ | OK (rate matches floor) |

## Summary
- CRITICAL: 3
- WARNING: 1
- NOTE: 0
- Verdict: **REJECT_FRAME**
- Recommendation to Fixer (if FIX_BEFORE_JUDGE): replace step 2.3 Cauchy–Schwarz with telescoping; recompute end-to-end rate.
```

If a check produces no rows, write `(no findings)` under that section heading — never omit a section.

---

## 5. Integration with downstream stages

### 5.1 Judge (modified selection criterion)

Judge's existing criteria (mathematical rigor, constant tightness, agreement with prior work, readability) are unchanged. The new criterion (5) **Tightness Pre-Audit score** is appended:

1. Frames with `verdict = PROCEED` are preferred over `FIX_BEFORE_JUDGE` over `REJECT_FRAME`.
2. Among frames with the same verdict, prefer fewer CRITICAL issues, then fewer WARNINGs.
3. Only when *every* frame has `verdict = REJECT_FRAME` does Judge select among rejected frames; in that case Judge picks the one with the fewest CRITICALs and emits `[ALL-REJECTED]` so the orchestrator triggers an extra Explorer round (one new frame, with the failure modes from the existing CRITICALs injected as anti-hints).

Judge's output format gains one line:
```
Pre-Audit verdict for Winner: {PROCEED | FIX_BEFORE_JUDGE | REJECT_FRAME}
Outstanding issues: T1-CRITICAL: {count}, T2-CRITICAL: {count}, ..., T4-WARNING: {count}, T5-CRITICAL: {count}
```

### 5.2 Auditor (Rule A-NEW)

Existing rules unchanged. New rule appended:

> **Rule A-NEW (Tightness Pre-Audit follow-through)**. For every WARNING in the Pre-Audit report, Auditor must explicitly check whether the warning's *rate impact* materializes in the final bound:
>
> - If the WARNING is a constant blow-up that does not change the rate (e.g. a $50\times$ slack on a step whose contribution to the leading constant is dominated by a different term), Auditor PASSes the step with annotation `[T{n}-WARNING-DOMINATED]`.
> - If the WARNING affects the rate (e.g. a Cauchy–Schwarz that downstream steps amplify), Auditor FAILs the step with annotation `[T{n}-WARNING-PROPAGATED]` and references the Pre-Audit row that flagged it.
> - Auditor must not silently ignore any WARNING. If unsure, query `[CALL:math-verifier]` to compute the end-to-end constant under both the original step and the Pre-Audit's suggested replacement, and report the ratio.

Auditor's CRITICAL-handling is unaffected: any CRITICAL in Pre-Audit should already have caused REJECT_FRAME upstream; if Auditor is somehow seeing a frame with an outstanding CRITICAL, Auditor FAILs immediately with `[T{n}-CRITICAL-LEAKED-FROM-PREAUDIT]` for the orchestrator to debug.

### 5.3 Fixer

Fixer receives `tightness_report.md` alongside the audit report. For `FIX_BEFORE_JUDGE` frames the Fixer's first task is to apply the Pre-Audit's suggested replacements (T4 alternatives). After applying fixes the orchestrator re-runs Tightness Pre-Audit on the fixed proof; only when the new verdict is PROCEED does the proof re-enter Auditor.

---

## 6. Failure modes Pre-Audit itself can have

This stage is not infallible. Known limitations:

1. **Free-variable substitution can mask asymptotic behaviour.** If the canonical defaults happen to land in a region where the inequality is tight but other regions are loose, T1 will report OK falsely. Mitigation: always evaluate at three different $T$ scales, and if the proof's hypothesis specifies parameter ranges (e.g. $\kappa > 1000$), prefer those over canonical defaults.
2. **Symbolic LHS extraction is fragile** when the proof uses heavy notation. If LHS extraction fails for a step, emit `[T1-EXTRACTION-FAILED step={N}]` and skip; the human must back-stop.
3. **T4 false positives** on identities where the bound is genuinely tight (e.g. $|a|+|b|$ when $a,b$ have the same sign). Acceptable: the Auditor's Rule A-NEW will downgrade these to PASS-with-annotation if they don't propagate.
4. **T5 cannot run in deterministic settings**, by design.

---

## 7. Calling conventions

When run by the orchestrator, Tightness Pre-Audit accepts the following CALL markers in its output for orchestrator post-processing:

- `[CALL:math-verifier] {numpy: <script>}` — when numerical evaluation of an inequality requires Monte-Carlo (T1, T4).
- `[CALL:math-verifier] {sympy: <expr>}` — when symbolic rate extraction is needed.
- `[ATTENTION: human]` — when the stage has insufficient information to classify a step (e.g. the cited paper's theorem statement is not in the project workspace and `target_metric.txt` was not provided).

---

## 8. Provenance

This stage was created in response to OP-2 (`workspace/op2_proof_v5.tex`) failures documented in:

- `workspace/op2_audit_final.md` (v5 §4.2.1 Cesàro/last-iterate mismatch)
- `workspace/op2_audit_round3.md` (Theorem 3 Cauchy–Schwarz rate drop)
- `workspace/op2_li_review/` (v4 tightness-constant audit)

Failure patterns recorded:
- FP-METRIC-MISMATCH
- FP-SIGNED-STRUCTURE-LOST
- FP-CONSTANT-BLOWUP
- FP-STOCHASTIC-FLOOR

Test case: `workspace/agents_spec/tests/test_tightness_preaudit.md`.
