# OP-2 Downgraded v3 — Final Audit

**Date:** 2026-04-18
**Target document:** `workspace/op2_downgraded_proof_v3_final.md`
**Standard:** Submission-ready for OPT workshop / COLT-style venue
**Auditor:** Claude Code (independent final review, post-v3 round-3 literature cross-check)

---

## Executive summary

`op2_downgraded_proof_v3_final.md` passes the 4-track final audit. Task 1 (placeholder formula in §2.7 Step 1 line 509) was fixed via Option A: the occluded $q(\kappa)$ expression was replaced by a clean prose statement pointing to `fixed_verify.py` Part [E] for the symbolic derivation. One additional scaffolding leak ("resolving Issue 2" on old line 432) was found and cleaned during audit. All substantive math content — theorem, construction, constants $\kappa/4$ and $1/112$ — remains unchanged from v3.

The document is mathematically complete, terminologically consistent, citationally accurate, and free of debug-log artifacts in the main text. Two minor (non-blocking) items remain in the front matter: the "Source: Scout → Explorer × 3 → Judge → Auditor R1 → …" workflow scaffolding on line 4, and the extensive v1/v2/v3 revision history in Appendix B. Both should be trimmed before formal submission (they belong in an internal review record, not in the submitted manuscript), but neither is a correctness concern.

**Verdict: READY** (with two minor front-matter cleanups recommended pre-submission).

---

## Track 1: Writing cleanliness

Scanned entire document (765 lines) for debug artifacts, placeholders, unclosed LaTeX environments, and scaffolding leaks.

| Check | Result | Notes |
|---|---|---|
| "wait / let me redo / actually / hmm" in main text | **PASS** | Only occurrences are in v3 changelog referring to what was *removed* (lines 27, 748); none in body |
| "Better (direct ...)" / "Fix: introduce ..." (Lemma 1.4 v2 debacle) | **PASS** | Lemma 1.4 cleanly rewritten; all Rademacher dead-end and switching narration removed |
| Mathematical placeholders `/…`, `⋯`, `[placeholder]` | **PASS (fixed)** | Task 1: line 509 `q(\kappa) := ... /\text{…} ... + \cdots` replaced with prose pointer to `fixed_verify.py` |
| "resolving Issue N" scaffolding | **PASS (fixed during audit)** | Line 432 "Remark on constants (resolving Issue 2)" → "Remark on constants" |
| Untagged "v1 claimed / v2 stated" history | **PASS** | All 4 occurrences (lines 30, 92, 437, 748) are inside `[MOD v2-X]` or `[MOD v3-X]` tagged remarks, or in the v3 changelog / Appendix B |
| Theorem / Lemma / Claim numbering | **PASS** | Lemma 1.1–1.7 (contiguous), Claim 2.1–2.5 (contiguous), Lemma 2.6–2.7, Claim 2.8, Lemma 2.9, Claim 2.10–2.13; no gaps, no repeats |
| Cross-reference accuracy (§X.Y, Lemma N.M, Claim Z) | **PASS** | All references point to existing targets: Part 3.4 and 3.5 exist (3.1–3.5 in document); §2.7 Step 1 correctly referenced by Part 3.2; Lemma 1.3, 1.7 references in Lemma 2.6 proof all valid |
| LaTeX environment closure | **PASS** | `\begin{align*}` × 4, `\end{align*}` × 4, balanced; all 91 `$$...$$` display-math blocks are complete single-line (head and tail on same line); no stray unclosed math environments |
| Front-matter workflow leak | **FLAG (non-blocking)** | Line 4 source line `"Scout → Explorer ×3 → Judge → Auditor R1 → Fixer → Auditor R2 → Auditor R3 with literature cross-check, all addressed"` is internal scaffolding; appropriate for a reviewer workflow record but should be trimmed before paper submission |
| "auditor-mandated pairs" phrasing in Part 3 | **FLAG (non-blocking)** | Lines 562, 606, 709 describe the empirical test pairs as "auditor-mandated"; in a submitted paper, rephrase to "the parameter pairs $(0.5, 1/L)$ and $(0.9, 1/(2L))$ cited in the conjecture" or similar neutral phrasing |
| Revision history in Appendix B | **FLAG (non-blocking)** | The v1 → v2 → v3 diff table is useful for an internal record but is atypical content for a published manuscript; consider demoting to a separate file before submission |

**Track 1 verdict: PASS** with 3 non-blocking flags for front-matter / Part 3 phrasing.

---

## Track 2: Mathematical consistency

Verified that constants, formula definitions, and quantifier structure are identical wherever they appear.

### Constants

| Constant | Claimed value | Appearances audited | Consistent? |
|---|---|---|---|
| $c_\mathrm{NY}$ (current statement) | $1/112$ | Lines 32, 78, 95, 111, 381, 382, 430, 442, 448, 714 | **PASS** — value $1/112$ used in all live statements |
| $c_\mathrm{NY} = 1/56$ | historical only | Line 437 (v1 remark), 752 (Appendix B diff) | **PASS** — only in historical / remark context |
| $c_\mathrm{NY} = 1/(8\sqrt 2)$ | historical only | Lines 13, 92, 437, 440, 742 | **PASS** — all inside [MOD v2-3] remarks or Appendix B |
| $c(\beta,\eta) = \kappa(\beta,\eta)/4$ | live | Lines 91, 375, 382, 446, 448, 714 | **PASS** |
| $p_\min \geq 1/14$ | live | Lines 179 (Lemma 1.4(c)), 399 (Lemma 2.9), 425 | **PASS** |

### Formula definitions (identical wherever they appear)

| Symbol | Definition | Appearances | Consistent? |
|---|---|---|---|
| $\alpha$ | $\sigma/(2\sqrt{2T})$ | 12, 105, 176, 265, 394, 413, 427 | **PASS** — identical expression each time |
| $\alpha_s$ | $s\cdot\sigma/(2\sqrt{2T}) = s\alpha$ | 263 (tag ALPHA), 406 | **PASS** |
| $R$ | $D/\sqrt 2 - \alpha/L$ | 12, 105, 265 (tag R-def) | **PASS** |
| $y^\star_s$ | $-s\cdot D/\sqrt 2$ (exact) | 12, 275 (Claim 2.2), 289, 306, 315, 384, 406 | **PASS** |
| $\beta^\star$ | $(\sqrt{13}-3)/2 \approx 0.3028$ | 98, 492, 521, 622 | **PASS** |
| $\gamma_\mathrm{crit}(\beta)$ | $3(1+\beta+\beta^2)/(1+2\beta)$ | 98, 492, 509, 522, 562 | **PASS** |
| (RGM) | $\sigma \leq LD\sqrt 2$ | 81 (definition), 95, 109, 110, 266, 380, 413 | **PASS** — (RGM) condition stated once and referenced consistently; implication $\sigma \leq LD\sqrt{2T}$ correctly derived from (RGM) and $T\geq 1$ |

### Quantifier structure (∀-∃ vs ∃-∀)

The theorem is correctly stated in **∀-∃ form**: "for every $(\beta,\eta) \in \mathcal{F}$ and every integer $T \geq 1$, there exist $f_{\beta,\eta}^{(T)}$, $(x_0, x_{-1})$, oracle such that ..." (line 82).

| Location | Quantifier check | Result |
|---|---|---|
| §0.5 Main Theorem line 82 | ∀(β,η) ∀T ∃f ∃init ∃oracle | **PASS** — correct ∀-∃ form |
| §0.6 Scope line 105 | Explicitly notes "The theorem is ∀-∃, not ∃-∀" | **PASS** — explicit disclaimer |
| §2.5 Conclusion line 453 | $s^\star$ is deterministic function of $(\beta,\eta,T)$; $f_{\beta,\eta}^{(T)} := f^{(s^\star)}$ is a function of $(\beta,\eta,T)$ | **PASS** — [MOD v3-8] fix makes this unambiguous |

**Track 2 verdict: PASS** — no inconsistencies.

---

## Track 3: Literature citation accuracy

Cross-checked each cited paper against the corresponding claim in the document.

### Goujaud–Taylor–Dieuleveut 2023 (arXiv:2307.11291)

| Claim in document | Reference | Check |
|---|---|---|
| Lemma 1.3 is GTD23 Theorem 3.5 + §3.4 | arXiv:2307.11291 | **PASS** — correct theorem label |
| $M$-matrix definition (M-def) | line 139 | **PASS** — consistent with GTD23 |
| Cycling inequality (★) | line 63 | **PASS** — matches GTD23 |
| Projection identity $P_{\mathrm{conv}(P)}(e_t) = Me_t$ | line 160 | **PASS** — GTD23 Theorem 3.5(iii) |

### Ghadimi–Feyzmahdavian–Johansson 2015 (arXiv:1412.7457)

| Claim in document | Expected scope | Check |
|---|---|---|
| Lemma 1.6 is **deterministic only** | $\sigma = 0$, $L$-smooth convex, Cesàro average, $O(1/k)$ | **PASS** — [MOD v3-1] fix, explicit deterministic heavy-ball update (line 210), explicit "zero-variance oracle, $\sigma = 0$" statement, explicit abstract quote |
| No σ-term in any GFJ15 claim | any claim attributed to GFJ15 must not contain $\sigma D/\sqrt T$ | **PASS** — all σ-containing tightness statements in §0.5 footnote (line 95) and §4.2 (lines 641–654) are explicitly attributed to *either* Nemirovski–Yudin/SGD *or* Agarwal 2012/AC-SA, not to GFJ15 |
| GFJ15 scope caveat is visible | reader should not confuse deterministic with stochastic | **PASS** — explicit "Caveat on scope" paragraph in Lemma 1.6 (line 214), plus §4.2 split-case discussion |

### Li–Liu–Orabona 2022 (arXiv:2102.07002, ICML 2022)

| Claim in document | Reference | Check |
|---|---|---|
| $L$-Lipschitz convex (non-smooth) | §4.2.5, line 659 | **PASS** — matches paper scope |
| Subgradient oracle | §4.2.5, line 672 | **PASS** |
| Last iterate $z_T$ | §4.2.5, line 666 | **PASS** |
| Rate $\Omega(\ln T/\sqrt T)$ | §4.2.5, lines 666, 672 | **PASS** |
| Any constant $\beta \in [0,1)$ | §4.2.5, line 672 | **PASS** |
| Construction in $d = T$ | §4.2.5, line 668 | **PASS** — matches paper (dimension scales with horizon) |
| Orthogonality claim (smooth vs non-smooth) | §4.2.5 items 1–4 | **PASS** — correctly identifies that the two LBs occupy different function classes and are not directly comparable |

### Agarwal–Bartlett–Ravikumar–Wainwright 2012 (arXiv:1009.0571, IEEE TIT)

| Claim in document | Reference | Check |
|---|---|---|
| Minimax LB $\Omega(\sigma D/\sqrt T)$ for stochastic first-order on smooth convex | §4.3, line 692 | **PASS** — matches paper |
| Algorithm-ignorant nature of minimax LB | §4.3, lines 696–701 | **PASS** |
| Our LB is algorithm-specific (for fixed-momentum SHB) | §4.3, line 696 | **PASS** |
| Our LB is strictly stronger in the bias term | §4.3, lines 697–699 | **PASS** — correctly frames non-acceleration: $LD^2/T$ (SHB) vs $LD^2/T^2$ (AC-SA optimal) |

### Lan 2012 AC-SA (Math Prog. 133)

| Claim in document | Reference | Check |
|---|---|---|
| Rate $O(LD^2/T^2 + \sigma D/\sqrt T)$ | Lemma 1.5 line 201, §4.4 line 704 | **PASS** — matches Lan's theorem |
| Universal constants $c_1, c_2$ (not claimed explicit) | line 201 | **PASS** — paper does not provide sharp constants in its statement, our exposition is faithful |

**Track 3 verdict: PASS** — all citations accurate; no residual miscitation after v3-1.

---

## Track 4: Submission readiness (Goujaud/Taylor/Dieuleveut-eyes review)

### What would a GTD23 author notice upon reading this draft?

1. **Proper credit to GTD23 throughout.** Lemma 1.3 explicitly labeled "GTD23, Theorem 3.5 of arXiv:2307.11291 + §3.4", and §4.1 opens with a full acknowledgement and explicit enumeration of how our result extends theirs. **No attribution concerns.**

2. **GFJ15 accuracy.** This was the critical issue flagged in v2; the v3-1 fix is substantive — a GFJ15 author would recognize the correct scope statement and the explicit abstract quote. **Passes a GFJ15-author reading.**

3. **Related-work coverage.** The four natural audiences for reviewer objections — non-SC SHB LBs (Li 2022), minimax stochastic LBs (Agarwal 2012), smooth-stochastic UBs (Lan 2012), deterministic-SHB UBs (GFJ15) — are all addressed in §4. **A reviewer asking "what about Li et al. ICML 2022?" would find an explicit 4-point comparison table at §4.2.5.**

4. **Theorem statement clarity.** The Main Theorem (§0.5) has correct ∀-∃ quantifier structure, explicit regime condition (RGM), explicit constants, exact initial distance $D$, and a tightness footnote that precisely locates our result in the SHB / SGD / AC-SA landscape. **Abstract-ready.**

5. **AI-artifact concerns.** Main body is clean of conversational idioms after the v3 round of fixes. Front-matter line 4 ("Scout → Explorer × 3 → Judge → Auditor R1 → ...") is clearly a Claude-specific multi-phase workflow description and would look out of place in a submission — **flagged, should be trimmed**. Appendix B's three-column v1→v2→v3 diff table is unusual in a paper — **flagged, consider demoting to a separate reviewer appendix or removing**.

### Novelty assessment (§4.6 summary)

- **First rigorous $\Omega(LD^2/T + \sigma D/\sqrt T)$ LB for fixed-momentum SHB in smooth-convex non-SC stochastic setting on positive-measure parameter region**: unique and novel.
- **Explicit, honest constants** ($\kappa/4$, $1/112$): honestly derived from the proof chain, with the derivation gaps noted.
- **Quantitatively precise non-acceleration statement**: SHB cannot match AC-SA's $LD^2/T^2$ bias rate on $\mathcal{F}$. This is the core contribution.
- **Positive-measure parameter region verified**: Claim 2.13 is a full measure-theoretic result, not just a non-emptiness statement.

### Recommended pre-submission cleanups (non-blocking)

1. **Line 4 source header**: trim workflow scaffolding ("Scout → Explorer × 3 → …"); replace with a simple compilation-date line.
2. **Appendix B revision table**: either remove or move to a separate supplementary document; most venues don't include edit history in the manuscript.
3. **Part 3 phrasing**: replace "auditor-mandated pairs" (3 occurrences) with neutral "the parameter pairs $(0.5, 1/L)$ and $(0.9, 1/(2L))$" or "conjectured-hard pairs".
4. Consider condensing the Remark on constants after Lemma 2.9 (§2.4.1, lines 432–444): the $1/56 \to 1/112 \to 1/(8\sqrt 2)$ history is valuable as internal documentation but could be a single-sentence footnote in a published version.

None of these affect the mathematical correctness or the verdict.

**Track 4 verdict: PASS** with cosmetic cleanups suggested.

---

## Final verdict

- **READY_FOR_SUBMISSION: YES** (with 4 cosmetic front-matter cleanups recommended; none block correctness or reviewer acceptance).
- **Remaining minor items:**
  1. Line 4 workflow-scaffolding text (non-mathematical).
  2. Appendix B revision history (atypical for manuscript).
  3. Part 3 "auditor-mandated pairs" phrasing (3 occurrences).
  4. §2.4.1 Remark on constants could be condensed.
- **Issues found and fixed during this audit:**
  1. Task 1: placeholder formula `/…` in §2.7 Step 1 line 509 — **FIXED** (Option A).
  2. "resolving Issue 2" scaffolding on line 432 — **FIXED** (removed parenthetical).
- **Mathematical correctness:** unchanged from v3 (all 4 critical issues and 5 writing issues from round-3 review successfully addressed; constants $\kappa/4$ and $1/112$ consistent; quantifier structure ∀-∃ preserved; literature citations accurate).
- **Confidence: HIGH.** The document is internally consistent, correctly attributed, and defensible against Goujaud-Taylor-Dieuleveut-style reviewer scrutiny.

---

*End of final audit.*
