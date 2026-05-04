# RE-AUDIT (Opus, high-intensity) — Period-2 Attractor Claim, Direction 1

**Date:** 2026-04-28
**Re-auditor:** Opus, high-intensity verification before external peer review
**Subject:** Period-2 attractor claim in `direction_1_zero_momentum.md` §7 (L7 lemma) and the supporting bookkeeping in `summary.md` (cycling 8% + period-2 19% = 27% positive-measure subset).
**Verifier scripts:**
- `reaudit_period2_anchors.py` (mpmath dps=50, T=10000) — Tasks 3.1, 3.2, 3.3
- `reaudit_reclassify.py`     (mpmath dps=30, T=8000)  — Task 3.4
- prior `reaudit_task_1_4_grid.py` (dps=100, T=10000) — corroborating evidence
- prior `reaudit_long_horizon_other.py` (dps=70, T=100000) — corroborating evidence (single point)

---

## Executive verdict — CONDITIONAL PASS (3 corrections needed)

The qualitative content of the L7 claim survives, but with **important corrections**:

1. **The attractor at the audit-confirmed anchors is period-6, NOT period-2** in the Cartesian frame. It is period-2 *modulo the C₃ rotational symmetry* of the K=3 polytope, which Explorer 4's reduction document (`d1_explorer_4_reduction.md` §9) already anticipated ("period-6 = period-2 mod C₃"). This is a substantive *exposition* fix, not a load-bearing logical fix.
2. **The "0.37 µD²" bias-floor constant is numerically wrong**; the correct number is approximately **2.22 µD²** at (0.9, 3.78, 0.05) and **3.43 µD²** at (0.95, 3.85, 0.10). The audit's arithmetic in §7 ("$(\mu/2)\cdot 4 = 2\mu \approx 0.37\,\mu D^2$") is internally inconsistent: with D=1, $2\mu = 2\mu D^2 \neq 0.37\mu D^2$.
3. **The claim "another positive-measure subset $\mathcal F^{\mathrm{period-2}}$ ~19% measure" is misattributed.** The 19/100 grid points ARE the "other" category in the original grid scan, but **none of the 19 are TRUE period-2** at the resolution of the original grid (which uses κ ≈ 0.37–0.48, far from the audit's anchor κ values of 0.05 and 0.10). The 19 "other" points exhibit *bounded quasi-periodic / non-periodic* oscillation with norms in [~1.0, ~1.9], not period-2 at norm ~2.1.

The attractor at the *audit's two specific anchors* (κ=0.05, 0.10) IS a true period-6 (period-2 mod C₃) orbit with the claimed limit norms — this much is verified to 50 digits. But the original grid scan does not witness it, so the ~19% measure claim has no empirical support.

**Severity:** 0 HIGH, 3 MEDIUM (corrections 1, 2, 3 above), 1 LOW (audit's "$\|x_t\| \asymp 2.1\lambda$" should read "$\|x_t\| \asymp 3\lambda$" since the 2.107 is in absolute units, not in units of λ).

---

## Task 3.1 — Period-2 at (0.9, 3.78, 0.05): NEEDS_CORRECTION

**Setup.** SHB on rescaled Goujaud K=3 function $f_0$ with zero-momentum init $x_{-1}=x_0 = (D/\sqrt 2)e_0$, T=10000 steps, mpmath dps=50.

**Result (from `reaudit_period2_anchors.py`):**
- First 20 norms: $\|x_t\|$ oscillates between ~0.13 and ~1.94 during the transient (t ≤ 19).
- Last 20 norms (T=9981..10000): exactly two distinct values, **2.1065495059** and **2.2079530039**, alternating step by step.
- Distinct $\|x_t\|$ values in last 100 steps: **2** (not 6).
- Period detection: $\|x_T - x_{T-p}\| = $ 1.5e+0, 3.6e+0, 4.3e+0, 3.6e+0, 2.7e+0, **3.2e-50** for p=1..6. **Period in Cartesian frame is p=6**, not p=2.
- Six limit points (rotational orbit, with x = (a, b)):
  ```
  x⁰ = ( 1.9081,  0.8926),  ‖x⁰‖ = 2.1065495059
  x¹ = ( 2.1197, -0.6181),  ‖x¹‖ = 2.2079530039
  x² = (-0.1810, -2.0988),  ‖x²‖ = 2.1065495059
  x³ = (-1.5951, -1.5267),  ‖x³‖ = 2.2079530039
  x⁴ = (-1.7271,  1.2062),  ‖x⁴‖ = 2.1065495059
  x⁵ = (-0.5246,  2.1447),  ‖x⁵‖ = 2.2079530039
  ```
  These are three rotated copies of two base points $\{x^0, x^1\}$ under $R_{2\pi/3}$, i.e., a period-2-mod-C₃ orbit. Explorer 4 §9 anticipated this exactly.

**Audit's claim** (direction_1_audit.md Task 6, table row): "Period-2 ($\|x\|\in\{2.107, 2.208\}$)" at (0.9, 3.78, 0.05).

**Verdict — NEEDS_CORRECTION (cosmetic but substantive).** The two distinct norms 2.107, 2.208 are correct, but the geometry is a 6-cycle in Cartesian space, not a 2-cycle. The audit's wording "Period-2" should be "**period-2 modulo C₃ rotational symmetry**, equivalently a period-6 orbit in the Cartesian frame, with limit norms cycling between $\{2.107, 2.208\}$". This matters for the proof because:
- The Floquet eigenvalue analysis must use the iterated map $\Phi^6$ (not $\Phi^2$); however, the spectral radius computation of Explorer 4 §6 still gives $\rho(D\Phi^6) = \beta^3$ (well below 1), so attractiveness survives.
- The reflection-ansatz analysis in Explorer 4 §2 already correctly noted that no symmetric period-2 ansatz can produce the observed orbit; the rotational-mod-C₃ ansatz of §9 is the right structural picture.

---

## Task 3.2 — Period-2 at (0.95, 3.85, 0.10): NEEDS_CORRECTION

**Result (from `reaudit_period2_anchors.py`):**
- Last 20 norms: alternating between **2.6214959230** and **2.6847014681**.
- Distinct $\|x_t\|$ in last 100 steps: 2.
- Period detection: $\|x_T - x_{T-6}\| = $ **5.2e-50**; period in Cartesian frame is p=6.
- Six limit points (with norms in $\{2.621, 2.685\}$ alternating).

**Audit's claim:** "Period-2 ($\|x\|\in\{2.621, 2.685\}$)".

**Verdict — NEEDS_CORRECTION** (same as 3.1: orbit is period-6 = period-2 mod C₃; the two norms are correct but the period descriptor is wrong).

---

## Task 3.3 — Bias floor for the period-2(-mod-C₃) attractor: NEEDS_CORRECTION

**Setup.** With D=1 and the strong-convexity floor $f_0(x_T) - f_0^\star \geq (\mu/2)\|x_T\|^2$, in the limit set the worst-case (smallest) norm gives the floor. Compute in units of $\mu D^2$:

| Anchor | $\min \|x\|$ | $c = \min\|x\|/D$ | bias floor $/(\mu D^2) = c^2/2$ |
|---|---|---|---|
| (0.9,  3.78, 0.05) | 2.1065 | 2.1065 | **2.219** |
| (0.95, 3.85, 0.10) | 2.6215 | 2.6215 | **3.436** |

**Audit's claim** (direction_1_zero_momentum.md §7 and summary.md): "bias floor $\geq 0.37\mu D^2$".

**Inspection of the audit's arithmetic.** The L7 derivation reads:
> $f_0(x_T) - f_0^\star \geq (\mu/2)\|x_T\|^2 \geq (\mu/2)\cdot 4 = 2\mu \approx 0.37\mu D^2$
> "(since $D^2 = 2\lambda^2 = 1$, rescaled)"

This contains a **unit error**. With $D = 1$ in the experiment ($\lambda = D/\sqrt 2 \approx 0.707$, so $D^2 = 1$, not "$2\lambda^2 = 1$" — that would also give $D^2=1$ but the conclusion uses $D^2 \approx 5.4$ hidden somewhere). With $D=1$, $2\mu = 2 \cdot \mu \cdot 1 = 2\mu D^2$, so $2\mu \neq 0.37\mu D^2$. The correct floor for $\|x\| \geq 2$ is $(\mu/2)\cdot 4 = 2\mu D^2$, **roughly 5.4× larger** than the claimed 0.37.

**Verdict — NEEDS_CORRECTION (arithmetic).** The bias floor at the audit-confirmed period-6 anchor is **about $2.22\mu D^2$**, not $0.37\mu D^2$. The "0.37" appears nowhere in the actual computation; it is an error. If the intent was a conservative floor, one could honestly write "bias floor $\geq 2\mu D^2$" or "bias floor $\geq c\,\mu D^2$ for an explicit $c \in (2, 3.5)$ across $\beta \in [0.85, 0.95]$".

The qualitative direction of the claim is correct: the period-6 floor at (0.9, 3.78, 0.05) is **stronger** (by ~9×) than the OP-2 K=3 cycle floor of $\mu D^2/4 = 0.25\mu D^2$. The audit just under-reported the strength by a factor of 6.

---

## Task 3.4 — Period-2 measure (~19% claim): NEEDS_CORRECTION (claim is overstated)

**Setup.** Re-classify the 19 "other" grid points from `zero_momentum_grid_results.json` at T=8000 (vs. original T=2000). The 19 "other" points have $\beta \in \{0.9, 0.95\}$ and $\kappa \in [0.37, 0.48]$ — i.e., a different κ regime than the audit's anchors (κ ∈ {0.05, 0.10}).

**Result (from `reaudit_reclassify.py`, summarized below; full output in `reaudit_reclassify.json`):**

| Category at T=8000 | Count | Comment |
|---|---|---|
| period-2  | **0** | none of the 19 are true period-2 |
| period-3  | 0 | |
| period-6  | **0** | none are period-6 either |
| decay     | 1 | (β=0.95, ηL=2.998, κ=0.475) decays to ~10⁻⁷⁷ |
| other-bounded | 18 | norms in $[\sim 1.0, \sim 1.9]$, no clean periodicity at T=8000 |

**Corroborating prior re-audit** (`reaudit_task_1_4_output.txt`, T=10000, dps=100): same conclusion — "**period-2: claim 19/100, observed 0/100**" — and `reaudit_long_horizon_output.txt` at dps=70, T=100000 classifies the first "other" point (β=0.9, ηL=3.038, κ=0.4489) as **quasi_periodic** (residual 4.6e-2 over 100k steps).

**Verdict — NEEDS_CORRECTION (substantively misleading).** The summary.md claim
> "$\mathcal F^{\mathrm{period-2}}$ (~19% 测度)"

conflates the **size of the "other" category in the grid scan** with the **size of the period-2 region**. The 19% is empirically the "other" category, but the empirical period-2 fraction at the grid is **0%**. The grid scan simply does not sample the κ values where the period-6/period-2-mod-C₃ attractor lives — those κ ∈ [0.05, 0.10] are below the grid's effective minimum.

The honest restatement is:
- **Empirical period-2 measure on the existing 100-point grid (κ ∈ [0.37, 0.48]): 0%.**
- **Empirical "bounded non-cycling" (other) measure: 19/100.**
- **Period-2 (= period-2 mod C₃) attractor confirmed at two isolated (β, ηL, κ) anchors with κ << grid range, hence a separate non-empty open positive-measure region whose measure is NOT yet quantified.**

The L6/L7 dichotomy in `direction_1_zero_momentum.md` §7 is therefore valid as a non-emptiness statement (two confirmed anchors + open extension by IFT) but the "~19%" should be **dropped or replaced with "non-empty open"**. Without further numerical scanning at κ ≤ 0.1, no quantitative measure bound is justified.

---

## Task 3.5 — Locality of the period-2 attractor: external review framing

**Audit's caveat (Task 6):** at $(0.9, 3.7, 0.1)$ the orbit DECAYS, not period-2. The period-2 (period-6) anchor must be selected carefully. Two specific anchors are confirmed by direct simulation: (0.9, 3.78, 0.05) and (0.95, 3.85, 0.10).

**Closed-form characterization?**

Looking at `d1_explorer_4_reduction.md` §3–§4, the period-2-mod-C₃ fixed-point system is a $4 \times 4$ semi-algebraic system whose solutions form a 1-parameter family per edge of the K=3 polytope, with:
- $w \perp n_{ij}$ (chord parallel to edge),
- $\alpha\langle m, n_{ij}\rangle = \langle p, n_{ij}\rangle$ (mean at fixed normal-distance),
- $(1-\alpha)\langle m, \hat e\rangle = \tfrac{(1-\gamma)}{2}\langle w, \hat e\rangle$ (tangential balance),

where $\alpha = L/(L-\mu) = 1/(1-\kappa)$, $\gamma = \alpha + 2(1+\beta)/(\eta(L-\mu))$. These are *necessary* algebraic conditions; existence on a given edge is constrained by the *validity check* that both projection feet land in the interior of that edge (an open inequality). **Closed-form exists** for each edge in the sense that one obtains an explicit linear system in $(m, w)$, but **the basin condition** — that zero-momentum init $(v,v)$ converges to this fixed point — is **not closed-form** and is currently only established numerically.

For external peer review, the **honest characterization** is:
- *Existence + local attractiveness* of the period-2-mod-C₃ fixed point: closed-form (linear algebra + Floquet $\rho(D\Phi^6)=\beta^3<1$).
- *Basin contains the diagonal $\{(v,v) : v = \lambda e_0\}$*: numerical only; verified at two anchors, conjectured open by continuity of $\Phi^6$.
- *Quantitative measure of the attractor's domain in $(\beta, \eta L, \kappa)$*: open question. The current evidence is two interior witnesses + IFT-style local extension. A bona-fide measure lower bound would require an interval-arithmetic certificate or a Lyapunov function proof, neither of which is presented.

**Verdict — VALID with sharpening.** The audit is correct that the locality of period-2 is delicate: small perturbations of κ (0.10 → 0.05) in (0.9, 3.78, ·) flip behavior between cycle/decay/period-6. For external review, the proof should:
1. State the period-2-mod-C₃ structure explicitly (a corollary of Explorer 4's reduction).
2. Cite the two specific anchors (κ = 0.05 and 0.10) as the witnesses.
3. Replace "~19% measure" with "non-empty open by IFT" and provide an explicit IFT computation if a measure bound is needed.

---

## Cross-cutting findings

| Sub-claim under audit | Verdict | Note |
|---|---|---|
| Period-2 at (0.9, 3.78, 0.05) with norms {2.107, 2.208} | NEEDS_CORRECTION | Period is 6 (Cartesian) = 2 mod C₃; norms correct |
| Period-2 at (0.95, 3.85, 0.10) with norms {2.621, 2.685} | NEEDS_CORRECTION | Same as above; norms correct |
| Bias floor $\geq 0.37 \mu D^2$ | NEEDS_CORRECTION | Actual floor ≈ 2.22 µD² (anchor 1), 3.44 µD² (anchor 2) |
| Period-2 region ~19% of $\mathcal F_{K=3}$ | NEEDS_CORRECTION | True period-2 fraction on the existing grid is 0/100; the 19% is "other" (quasi-periodic/non-periodic bounded) and includes no period-2 |
| Period-2 region is non-empty open positive measure | VALID (direction) | Two anchors + IFT give a non-empty open neighborhood; quantitative measure not established |
| "Period-2 attractor lives at high β near upper stability boundary" | VALID | Both anchors lie at β ∈ [0.9, 0.95], ηL near 2(1+β) |
| Floquet attractiveness $\rho(D\Phi^k)<1$ for the period-k orbit | VALID | $\rho(D\Phi^6) = \beta^3 < 1$ for β<1 (even-index version of Explorer 4 §6) |

---

## Final verdict — CONDITIONAL PASS

The L7 lemma's *qualitative* content (a high-β period-2-mod-C₃ attractor exists on a non-empty open set, giving a stronger bias floor than the K=3 cycle component) survives external review. But three quantitative defects need to be patched in `direction_1_zero_momentum.md` §7 and `summary.md`:

1. Replace "Period-2" by "**period-2 modulo $C_3$ (a period-6 orbit in the Cartesian frame)**" everywhere.
2. Replace "bias floor $\geq 0.37\mu D^2$" by the **correctly computed value**: at (0.9, 3.78, 0.05), $\geq (\mu/2)(2.107)^2 \approx 2.22\,\mu D^2$; at (0.95, 3.85, 0.10), $\geq 3.44\,\mu D^2$. Or use a uniform conservative floor "$\geq 2\,\mu D^2$" valid across both anchors.
3. Drop the "**~19% measure**" claim and replace with "**non-empty open set established by IFT around two confirmed anchors**". The 19% is the "other" category in the original 100-point grid and is empirically *not* period-2 (verified at T=8000, T=10000, T=100000 in three independent re-audits).

With these three patches, the period-2 component of the Direction 1 main theorem is internally consistent, externally defensible, and not load-bearing on quantitative measure (only on non-emptiness and openness, which are both witnessed numerically and follow from the IFT once the local Floquet-type stability of the period-6 orbit is granted, which the verifier confirmed).

The **bias term in the main theorem statement** ($\kappa LD^2/(8T)$) does not depend on the period-2 floor; only the K=3 cycle component (Steps 1–6) carries it. Thus, if the period-2 component is dropped entirely (option 2 in the auditor's earlier recommendation), the main theorem is unaffected. Hence even under the strongest interpretation of the corrections above, the main theorem of Direction 1 still passes external review.

**Pass grade:** CONDITIONAL PASS — three exposition/arithmetic patches required before submission, no logical defects in the load-bearing path.

$\blacksquare$
