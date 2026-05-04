# Test — Tightness Pre-Audit on OP-2 known failures

**Created**: 2026-04-29
**Purpose**: Regression test that Tightness Pre-Audit catches the three documented OP-2 tightness failures. If a future change to `workspace/agents_spec/tightness_preaudit.md` causes any expected CRITICAL or WARNING to disappear, the change has regressed the catch rate.

This file is self-contained: input proof excerpts, the inputs to Pre-Audit (target rate, metric, setting), the expected report, and the dry-run trace.

---

## Test fixtures

Three frames, each a real OP-2 failure reduced to a minimal reproducer.

```
test_input/
├── frames/
│   ├── route_thm3/      # OP-2 Theorem 3 Step 2-3 — Cauchy-Schwarz on signed sum
│   │   └── proof.md
│   ├── route_v5_421/    # OP-2 v5 §4.2.1 — Cesàro vs last-iterate metric mismatch
│   │   └── proof.md
│   └── route_v4_const/  # OP-2 v4 — claimed κ/10 constant, actual κ/23
│       └── proof.md
├── target_rate.txt      # E[f(x_T)-f*] = Ω(L D^2 / T + σ D / sqrt(T))
├── target_metric.txt    # last-iterate
└── setting.txt          # stochastic
```

---

## Frame 1 — `route_thm3/proof.md` (Theorem 3, bias bound)

Minimal reproducer of the Cauchy-Schwarz step that lost the rate:

```
Step 1 (setup). Let z_t := x_t - x*, b_t := η_t (g_t - ∇f(x_t)), so b_t is a
mean-zero martingale-difference sequence with E[‖b_t‖²] ≤ η_t² σ². With
η_t = 1/√t we have E[‖b_t‖²] = σ²/t.

Step 2 (bias decomposition). The bias term is
    B_T := Σ_{t=1}^{T} ⟨b_t, z_t - x*⟩.
Since (b_t) is a martingale-difference sequence and (z_t - x*) is predictable
w.r.t. the natural filtration,
    E[B_T] = 0    and    Var(B_T) = Σ_t E[‖b_t‖²] · E[‖z_t-x*‖²].

Under bounded iterates ‖z_t - x*‖ ≤ D, Var(B_T) ≤ D² Σ_t σ²/t = D² σ² log T.
Hence E[|B_T|] = O(D σ √(log T)) = O(T^0).

Step 3 (CRITICAL: replace B_T's signed structure with absolute Cauchy-Schwarz).
We bound
    |B_T| = |Σ_t ⟨b_t, z_t-x*⟩|
          ≤ (Σ_t ‖b_t‖²)^{1/2} · (Σ_t ‖z_t-x*‖²)^{1/2}                    (★)
          ≤ (Σ_t σ²/t)^{1/2} · (T D²)^{1/2}
          = O((σ √log T) · D √T) = O(σ D T^{0.5} √log T).

Therefore the bias term contributes Ω(σ D T^{0.5}) to the lower bound, and
combined with the algorithm's drift the headline rate becomes Ω(T^{-0.3}).
```

The fault is at step (★): bounding a martingale-difference sum (LHS rate
$\Theta(T^0)$) by Cauchy-Schwarz absolute envelopes (RHS rate $\Theta(T^{0.5})$
in the leading term and $\Theta(T^{0.2})$ in the surviving asymptotics after
parameter optimization).

---

## Frame 2 — `route_v5_421/proof.md` (v5 §4.2.1, metric mismatch)

```
Step 1. We have shown E[f(x_T) - f*] ≥ c · L D² / T for the OP-2 last-iterate.

Step 2 (CRITICAL: claim tightness via GFJ2015 upper bound).
By Ghadimi-Feyzmahdavian-Johansson (2015, Theorem 3), deterministic Heavy Ball
satisfies
    f(\bar x_T) - f* ≤ C · L D² / T           [REF: GFJ2015 Thm 3]
where \bar x_T = (1/T) Σ_{t=1}^{T} x_t is the Cesàro average iterate.

Combined with our Step 1 lower bound, this matches up to constants, proving
the rate Ω(L D²/T) is tight for SHB on this function class.
```

The fault: Step 1's lower bound is on $f(x_T)-f^\star$ (last iterate), GFJ's
upper bound is on $f(\bar x_T)-f^\star$ (Cesàro average). They are not the
same metric, so the comparison cannot establish tightness.

---

## Frame 3 — `route_v4_const/proof.md` (v4, leading-constant violation)

```
Theorem (claimed). For all β ∈ (0, 1), the bias-term lower bound has
leading constant
    C* = κ / 10
where κ = L/μ is the condition number.

Proof.
Step 5 (binding instance at t=4). By the descent-lemma applied to the
auxiliary objective, the bias contribution at t=4 satisfies
    bias(t=4) ≥ (1 - 23/κ) · D².
Step 6. Combining with the upstream factor 1/η = L from Step 4 and the
contraction constant (1-1/κ) from Step 3, we obtain
    bias(T) ≥ (κ/10) · (L D² / T)           [claimed leading constant]
which establishes the κ/10 rate.
```

The fault: Step 5 alone produces a multiplicative factor $\approx 23$ at
$\kappa$ scale. The chain product of step factors cannot be smaller than its
largest term. Therefore the headline claim "$\kappa/10$" is internally
inconsistent — the true achievable constant from this proof is at most
$\kappa/23$.

---

## Inputs to Pre-Audit

```
target_rate.txt:
  E[f(x_T) - f*] = Ω(L D^2 / T + sigma D / sqrt(T))

target_metric.txt:
  last-iterate

setting.txt:
  stochastic
```

---

## Expected `tightness_report.md` per frame

### `frames/route_thm3/tightness_report.md` (expected)

```markdown
# Tightness Pre-Audit — Frame route_thm3
Target rate: E[f(x_T) - f*] = Ω(L D^2 / T + σ D / √T)
Target metric: last-iterate
Setting: stochastic

## T1 — Rate preservation
| Step | Inequality | LHS rate | RHS rate | ratio @ T=1e6 | Status |
|---|---|---|---|---|---|
| 3 (★) | |Σ⟨b_t, z_t-x*⟩| ≤ (Σ‖b_t‖²)^{1/2}(Σ‖z_t-x*‖²)^{1/2} | T^0 (with √log T) | T^{0.5} (with √log T) | ≈ 1000 | **CRITICAL** |

End-to-end rate check: target T^{-1/2}, derived T^{-0.3} — **CRITICAL: END-TO-END-RATE-DROP**

## T2 — Metric consistency
(no findings — no external citations on this frame)

## T3 — Constant tracking
| Final constant | Bottleneck step | Bottleneck factor | Status |
|---|---|---|---|
| derived implicitly via T^0.5 | Step 3 | dominates the rate | NOTE (covered by T1 CRITICAL) |

## T4 — Triangle / Cauchy-Schwarz alerts
| Step | Technique | E[|LHS|] | E[RHS] | r | Suggested replacement | Status |
|---|---|---|---|---|---|---|
| 3 (★) | Cauchy-Schwarz on signed inner-product sum | Θ(σ D √log T) ≈ 3.7 at T=1e6 | Θ(σ D √(T log T)) ≈ 3700 at T=1e6 | ≈ 1000 | Telescoping via partial sums B_t = Σ_{s≤t} b_s, then Doob/Burkholder on the martingale | **WARNING** signed-structure-lost |

## T5 — Stochastic consistency
(no findings — proof correctly accounts for noise floor)

## Summary
- CRITICAL: 2 (T1 step-3, T1 END-TO-END-RATE-DROP)
- WARNING: 1 (T4 step-3)
- Verdict: **REJECT_FRAME**
- Recommendation: replace step 3 Cauchy-Schwarz with telescoping/Doob; the corrected bias bound should be Θ(σ D √log T), preserving the headline rate.
```

### `frames/route_v5_421/tightness_report.md` (expected)

```markdown
# Tightness Pre-Audit — Frame route_v5_421
Target rate: E[f(x_T) - f*] = Ω(L D^2 / T + σ D / √T)
Target metric: last-iterate
Setting: stochastic

## T1 — Rate preservation
(no findings — no inequality manipulation in this frame)

## T2 — Metric consistency
| Citation | Cited metric | Target metric | Used as | Status |
|---|---|---|---|---|
| GFJ2015 Thm 3 | Cesàro average | last iterate | tightness witness | **CRITICAL** metric-mismatch |

## T3 — Constant tracking
(no findings — no constant claim)

## T4 — Triangle / Cauchy-Schwarz alerts
(no findings)

## T5 — Stochastic consistency
| Step | Deterministic claim | Stochastic counter | Status |
|---|---|---|---|
| 2 | GFJ2015's UB is for the deterministic setting (σ=0); cited inside a stochastic proof without a stochastic UB | last-iterate has noise floor σ²/T which the deterministic UB does not bound | WARNING `deterministic-UB-cited-stochastic` |

## Summary
- CRITICAL: 1 (T2 metric-mismatch)
- WARNING: 1 (T5)
- Verdict: **REJECT_FRAME**
- Recommendation: either re-derive the lower bound for the Cesàro average so the metric matches, or find a last-iterate UB for the same function class (e.g., Sebbouh-Gower-Defazio 2021 weighted-average UB has a last-iterate analogue under bounded iterates). The current cross-metric comparison does not establish tightness.
```

### `frames/route_v4_const/tightness_report.md` (expected)

```markdown
# Tightness Pre-Audit — Frame route_v4_const
Target rate: E[f(x_T) - f*] = Ω(L D^2 / T + σ D / √T)
Target metric: last-iterate
Setting: stochastic

## T1 — Rate preservation
(no findings — rate is correct, claim is on the constant)

## T2 — Metric consistency
(no findings)

## T3 — Constant tracking
| Final constant | Bottleneck step | Bottleneck factor | Status |
|---|---|---|---|
| C* = κ/10 (claimed) | Step 5: descent-lemma slack at t=4 | 23 | **CRITICAL: tightness-claim-violated** (κ/23 > κ/10) |

## T4 — Triangle / Cauchy-Schwarz alerts
(no findings)

## T5 — Stochastic consistency
(no findings)

## Summary
- CRITICAL: 1 (T3)
- WARNING: 0
- Verdict: **REJECT_FRAME**
- Recommendation: weaken the claimed constant to C* ≤ κ/23 (matching the bottleneck step), OR tighten Step 5's descent-lemma application (e.g. via importance-weighted descent, with an explicit numerical check that the new factor is ≤ 10 at the binding instance).
```

---

## Dry-run trace (manual evaluation, for the test harness)

This section walks through the numerical evaluations the agent must perform to reach the expected verdicts. It serves as both a sanity check and a teaching example for future agents.

### Frame 1 numerical evaluation

For the Cauchy-Schwarz step (★), at $T \in \{10^2, 10^4, 10^6\}$, with $\sigma = D = 1$:

| $T$ | $\mathbb{E}[\|B_T\|]$ (LHS, telescoping) | $\mathbb{E}[\text{RHS}]$ via Cauchy–Schwarz | ratio |
|---|---|---|---|
| 100 | $\sqrt{\log 100} \approx 2.15$ | $\sqrt{(\log 100) \cdot 100} \approx 21.5$ | 10 |
| 10⁴ | $\sqrt{\log 10^4} \approx 3.03$ | $\sqrt{(\log 10^4) \cdot 10^4} \approx 303$ | 100 |
| 10⁶ | $\sqrt{\log 10^6} \approx 3.71$ | $\sqrt{(\log 10^6) \cdot 10^6} \approx 3712$ | 1000 |

Rate exponents: $\hat\alpha_{\text{LHS}} = 0.06$ (the $\sqrt{\log T}$ growth), $\hat\alpha_{\text{RHS}} = 0.56$. Difference $\approx 0.50 \gg 0.05$ → **T1 CRITICAL**.

Sample variance (LHS) is computed via Monte-Carlo: 1000 samples of length-$T$ random-walk-like martingale-difference sequences (Rademacher noise scaled by $1/\sqrt{t}$), inner-producted against the running iterate position; mean of $|\sum_t \langle b_t, z_t-x^\star\rangle|$ matches the $\sqrt{\log T}$ scaling within Monte-Carlo error.

### Frame 2 metric-tracing trace

The proof references `GFJ2015 Thm 3`. Looking at the cited paper:

> Theorem 3 (Ghadimi-Feyzmahdavian-Johansson 2015). For deterministic Heavy Ball
> applied to a smooth convex function, the *averaged* iterate $\bar x_T = (1/T)\sum_t x_t$
> satisfies $f(\bar x_T) - f^\star \le \frac{2 L \|x_0-x^\star\|^2}{T}$.

Cited metric: **Cesàro average**.
Target metric (from `target_metric.txt`): **last iterate**.
Use: tightness witness (UB matched against the proof's Step 1 LB).

Mismatch at the metric level → **T2 CRITICAL**.

Additionally, GFJ2015 is a deterministic theorem; the surrounding proof is in a stochastic setting, so T5 fires a WARNING.

### Frame 3 constant-tracing trace

Chain: $C = c_1 \cdot c_2 \cdot c_3 \cdot c_4 \cdot c_5$, where $c_5 \approx 23$ at the binding instance $t=4$.

The proof claims $C^\star = \kappa/10$. By the trivial bound $C \ge c_5$ (with all other factors $\ge 1$), we have $C \ge 23$ relative to the per-step base, which exceeds the claimed $C^\star/\kappa^{-1} = 10$.

→ **T3 CRITICAL `tightness-claim-violated`**.

---

## Pass/fail criteria

The test passes iff Tightness Pre-Audit, run on the three input frames with the given target rate / metric / setting, emits:

- Frame `route_thm3`: at least one T1 CRITICAL on Step 3, an END-TO-END-RATE-DROP CRITICAL, and a T4 WARNING with `signed-structure-lost`.
- Frame `route_v5_421`: at least one T2 CRITICAL on the GFJ2015 citation labelled `metric-mismatch`.
- Frame `route_v4_const`: at least one T3 CRITICAL labelled `tightness-claim-violated`.
- All three frames receive verdict `REJECT_FRAME`.
- The top-level `frames/preaudit_summary.md` lists all three frames as REJECT_FRAME and triggers an extra Explorer round (since every frame is rejected, per §5.1 of the spec).

Any deviation (missed CRITICAL, downgraded severity, unexpected PROCEED verdict) is a regression.

---

## Why these three cases together

- Frame 1 isolates **T1 + T4** (rate-loss via Cauchy-Schwarz on a martingale sum).
- Frame 2 isolates **T2 + T5** (cross-metric and cross-setting citation).
- Frame 3 isolates **T3** (self-contradicting tightness claim).

Together they exercise four of the five checks (T1, T2, T3, T4) plus the stochastic-consistency T5 in a secondary role. T5 in isolation is exercised by the FP-ADAGRAD-COORDWISE-OFUL-AMGM-EXPONENT-MISMATCH reproducer (not included here; see `workspace/failure_patterns.md` entry dated 2026-04-27 for that case).
