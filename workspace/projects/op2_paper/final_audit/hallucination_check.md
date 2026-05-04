# OP-2 Hallucination Detection Report

**Date:** 2026-04-28
**Auditor:** AI Hallucination Detector (final pre-peer-review pass for Prof. Li Xiao, SIOPT / CUHK Shenzhen)
**Scope:** All OP-2 manuscript files, the Direction-1 / Direction-2 li_xiao_directions deliverables, the SHB lower-bound proof folders under `proofs/research/optimization/lower-bounds/`, and the four `reaudit_*.md` reports.
**Method:** Grep across the workspace + WebSearch verification of every cited paper (authors, title, arXiv ID, venue, year).

---

## EXECUTIVE SUMMARY

**TWO classes of confirmed hallucinations:**

1. **CRITICAL author hallucination:** "Pedregosa" is repeatedly named as an author of arXiv:2307.11291 ("Provable non-accelerations of the heavy-ball method"). The actual paper has THREE authors: **Baptiste Goujaud, Adrien Taylor, Aymeric Dieuleveut**. The shorthand "GPT23" (Goujaud–Pedregosa–Taylor 2023) is therefore wrong; the correct shorthand should be "**GTD23**" (or simply "GTD" / "Goujaud–Taylor–Dieuleveut 2023"). This hallucination has propagated into:
   - The main OP-2 manuscript (`op2_downgraded_proof_v4.md`, `op2_downgraded_proof_v3.md`, `op2_downgraded_proof_v3_final.md`, `op2_downgraded_proof_v2.md`, `op2_downgraded_full_proof.md`, `op2_proof_submission.md`, `op2_clean.tex`, `op2_clean.aux`, `op2_clean.toc`)
   - Multiple SHB lower-bound proof folders (`shb-no-acceleration-restricted/{proof,problem,notes,report}.md`, `shb-no-acceleration-best-iterate/{proof,problem,notes}.md`, `shb-cycling-critical-momentum/{proof,problem,notes,report}.md`, `shb-cycling-lyapunov-nogo/proof.md`, `shb-coefficient-suboptimality/proof.md`)
   - The RESEARCH_INDEX (rows 24, 58, 59, 61)
   - Companion proofs (`polyak-ruppert-shb-defeats-cycling/{proof,problem}.md`)
   - Direction-1 explorer files (`d1_explorer_5_construction.md`, `direction_1_scout_routes.md`)

2. **Citation venue/title hallucinations:**
   - **Li–Liu–Orabona 2022** is cited in `op2_downgraded_proof_v4.md` line 39 and 694 as "ICML 2022" with title *"On the Last-Iterate Convergence of Stochastic Gradient Descent with Momentum"*. **Both wrong:** the actual venue is **ALT 2022 (PMLR v167)**, and the actual title is **"On the Last Iterate Convergence of Momentum Methods"**.
   - **Sebbouh–Gower–Defazio** is cited in `direction_2_last_iterate_ub.md` line 257 as *"On the convergence of the stochastic heavy ball method"* (2020). **Both partially wrong:** the actual title is **"Almost sure convergence rates for Stochastic Gradient Descent and Stochastic Heavy Ball"**, and the venue is **COLT 2021 (PMLR v134)** (the arXiv preprint is 2020, but the published version is 2021). There is a separate Semantic Scholar entry titled "On the convergence of the Stochastic Heavy Ball Method" (a 2020 workshop note) by Sebbouh–Gower; this is a DIFFERENT paper from arXiv:2006.07867. The OP-2 sister-document conflates them.

A previous round caught the "Pedregosa" hallucination in narrative comments but did NOT scrub it from the body of the OP-2 manuscript or proof folders. **Pedregosa appears at 50+ locations in the codebase** — every one is wrong as an attribution to arXiv:2307.11291.

Below is the file-by-file breakdown, the per-paper verification, the theorem-spelling table, and the recommended fix list.

---

## 1. CRITICAL HALLUCINATIONS FOUND

### 1.1 "Pedregosa" / "GPT23" / "Goujaud–Pedregosa–Taylor"

**Ground truth (verified via WebSearch + reading the actual paper PDF at `workspace/op2_li_review/D5_nesterov/gpt23.txt`, lines 4–6):**

> Mathematical Programming B manuscript
> *Provable non-accelerations of the heavy-ball method*
> **Baptiste Goujaud · Adrien Taylor · Aymeric Dieuleveut**
> arXiv:2307.11291v2 [math.OC] 9 Oct 2025

The paper has THREE authors. **Pedregosa is NOT one of them.** The correct shorthand is **GTD23** (or use full names).

The Pedregosa name comes from a *separate, related* paper that appears in GTD23's reference list (line 1698 of `gpt23.txt`):
> Goujaud B, Scieur D, Dieuleveut A, Taylor AB, Pedregosa F (2022b) Super-acceleration with cyclical step-sizes.

This is a 2022 cyclical-step-size paper (different topic, different authorship), and Pedregosa F. is a co-author *there*. The OP-2 documents have apparently confused the two papers and propagated the wrong author list throughout.

**File-by-file occurrence list (Pedregosa as a co-author of arXiv:2307.11291):**

#### Main OP-2 manuscripts (workspace/)
- `workspace/op2_downgraded_proof_v4.md`:17 — `[MOD v4-7] ... GPT23 Conjecture 7.1`
- `workspace/op2_downgraded_proof_v4.md`:86 — Definition: "the Goujaud–Pedregosa–Taylor cycling inequality (GPT-cyc)"
- `workspace/op2_downgraded_proof_v4.md`:152 — Section title: "1.3 Goujaud–Pedregosa–Taylor cycling theorem"
- `workspace/op2_downgraded_proof_v4.md`:154 — "Lemma 1.3 (GPT23, Theorem 3.5 of arXiv:2307.11291 + §3.4)"
- `workspace/op2_downgraded_proof_v4.md`:181 — "*Proof of (iii): see GPT23 §3.4 ...*"
- `workspace/op2_downgraded_proof_v4.md`:573 — "Independently confirms Lemma 1.3(iii) without relying on GPT23's KKT argument."
- `workspace/op2_downgraded_proof_v4.md`:655 — Section title: "## 4.1 Goujaud–Pedregosa–Taylor 2023 (GPT23)"
- `workspace/op2_downgraded_proof_v4.md`:659–664 — main GPT23 paragraph
- `workspace/op2_downgraded_proof_v4.md`:666 — "Remark 4.1.1 ... Goujaud–Pedregosa–Taylor (2023, Remark 6.1 and Conjecture 7.1)"
- `workspace/op2_downgraded_proof_v3.md`:70, 136, 628, 629, 633 — same hallucinations
- `workspace/op2_downgraded_proof_v3_final.md`:70, 136, 628 — same
- `workspace/op2_downgraded_proof_v2.md`:56, 120, 602, 603 — same
- `workspace/op2_downgraded_full_proof.md`:43, 99, 463, 464 — same; line 463 also says "Goujaud–Pedregosa–Taylor 2023 / Math. Prog. 2025"
- `workspace/op2_proof_submission.md`:43, 109, 596, 597 — same
- `workspace/op2_clean.tex`:103, 209, 1015, 1030 — LaTeX source has same errors
- `workspace/op2_clean.aux`:23, 79 — TOC entries with the wrong attribution
- `workspace/op2_clean.toc`:14, 43 — TOC entries
- `workspace/op2_audit_final.md`:86, 135, 181 — auditor report uses the wrong name
- `workspace/op2_audit_round3.md`:5, 220, 270 — auditor report uses the wrong name
- `workspace/op2_final_clearing_and_setup.md`:20, 158, 189, 239 — pre-OP2 setup doc
- `workspace/literature_crosscheck/summary.md`:29 — uses "Goujaud-Pedregosa-Taylor 2023's μ→0 cycling"
- `workspace/literature_crosscheck/proof_list.md`:61 — "Built on Goujaud-Pedregosa-Taylor 2023"
- `workspace/literature_crosscheck/group_A/A15_polyak_ruppert_shb.md`:8, 16 — same
- `workspace/literature_crosscheck/group_C/C1_shb_no_acceleration_restricted.md`:15 — section header "GPT 2023 (arXiv:2307.11291) — Goujaud–Pedregosa–Taylor"
- `workspace/op2_li_review/upgrade_report.md`:65 — "Goujaud–Pedregosa–Taylor 2023 (cycling on strongly-convex)"
- `workspace/op2_li_review/divergent_summary.md`:21 — same
- `workspace/op2_li_review/D5_nesterov/rerun_v2.md`:162 — "Goujaud–Pedregosa–Taylor (2023, Remark 6.1 and Conjecture 7.1)"
- `workspace/discovery_reports/agent_5.md`:3, 16 — uses GPT shorthand
- `workspace/discovery_reports/agent_2.md`:262, 283 — uses GPT shorthand
- `workspace/knowledge_reuse_validation.md`:151, 194 — uses "Goujaud-Pedregosa-Taylor polytope-Moreau function"
- `workspace/failure_triggers.md`:121, 590 — uses "Goujaud-Pedregosa-Taylor rotational K-cycling"
- `workspace/failure_patterns.md`:202 — "Goujaud-Pedregosa-Taylor 2023 cycling construction"
- `workspace/math_agent_full_scan_report.md`:40, 42 — uses GPT shorthand
- `workspace/structure_map.md`:21 — "Goujaud–Pedregosa–Taylor 2023 polytope-Moreau hard instance"

#### Direction-1/2 deliverables (workspace/active/li_xiao_directions/)
- `direction_1_scout_routes.md`:85 — "K \geq 3 in GPT23"
- `d1_explorer_5_construction.md`:11 — "(M as in (M-def) of GPT23)"

(`direction_1_zero_momentum.md`, `direction_2_last_iterate_ub.md`, `numerical_experiments.md`, and the four `reaudit_*.md` files do **not** themselves repeat "Pedregosa" — they only mention "Goujaud" alone, which is correct attribution shorthand for the lead author. So the Direction-1/2 final deliverables are clean of this specific error, except for `d1_explorer_5_construction.md` and `direction_1_scout_routes.md`.)

#### Proof folders (proofs/research/optimization/lower-bounds/)
- `shb-no-acceleration-restricted/proof.md`:30, 64, 210, 212, 226, 257, 494, 508 — Lemma 1 attribution to "GPT23"; references "Goujaud–Pedregosa–Taylor"
- `shb-no-acceleration-restricted/problem.md`:6, 63 — "Goujaud-Pedregosa-Taylor 2023 → Math. Prog. 2025"
- `shb-no-acceleration-restricted/notes.md`:14, 30 — same
- `shb-no-acceleration-restricted/report.md`:61, 77 — "Goujaud-Pedregosa-Taylor 2023/2025 (strongly-convex non-acceleration)"; "GPT23"
- `shb-no-acceleration-best-iterate/proof.md`:17, 55 — "Goujaud–Pedregosa–Taylor polytope-Moreau function"
- `shb-no-acceleration-best-iterate/problem.md`:4 — "Goujaud-Pedregosa-Taylor 2023 polytope-Moreau cycling"
- `shb-no-acceleration-best-iterate/notes.md`:27 — "Goujaud-Pedregosa-Taylor 2023 (arXiv:2307.11291)"
- `shb-cycling-critical-momentum/proof.md`:10 — "Goujaud–Pedregosa–Taylor 2023 cycling inequality"
- `shb-cycling-critical-momentum/problem.md`:4 — "meta-result on Goujaud–Pedregosa–Taylor 2023"
- `shb-cycling-critical-momentum/notes.md`:32 — "Goujaud–Pedregosa–Taylor 2023 (arXiv:2307.11291)"
- `shb-cycling-critical-momentum/report.md`:61 — "novel sharpness claim absent from the original GPT23 work"
- `shb-cycling-critical-momentum/audit.md`:89, 91 — "GPT23"
- `shb-cycling-lyapunov-nogo/proof.md`:20, 25 — "Goujaud–Pedregosa hard 2D quadratic"; "Goujaud–Pedregosa 2022, Thm 3"
- `shb-coefficient-suboptimality/proof.md`:49 — "Goujaud–Pedregosa's hard convex function"
- `shb-energy-tight-ub-nogo/proof.md`:55 — uses GPT shorthand

#### Other proofs/research/
- `proofs/research/optimization/convergence/polyak-ruppert-shb-defeats-cycling/proof.md`:13 — "Goujaud-Pedregosa-Taylor (GPT23) cycling region"
- `proofs/research/optimization/convergence/polyak-ruppert-shb-defeats-cycling/problem.md`:4 — "Goujaud-Pedregosa-Taylor 2023"

#### Top-level indices
- `RESEARCH_INDEX.md`:24, 58, 59, 61 — four rows attribute work to "Goujaud-Pedregosa-Taylor 2023"

#### Subsidiary references that USE the wrong shorthand internally
- `LeanAgent/lean_formalization_agent_architecture_v2.md`:754 — "Goujaud cycling"; uses "Goujaud" alone, OK
- `workspace/literature_crosscheck/group_A/A15_polyak_ruppert_shb.md`:16 — note about "Quadratic minimization: from conjugate gradients..." attributed to "Goujaud-Pedregosa-Taylor 2023" — actually that adaptive-Polyak paper IS by Goujaud, Scieur, Pedregosa, Dieuleveut, Taylor (arXiv:2305.17665 / hal-04832983). This *could* be a different paper conflation; needs separate cleanup.

**Total: 50+ distinct locations require correction.** Recommended global edit: replace "Goujaud–Pedregosa–Taylor" → "Goujaud–Taylor–Dieuleveut" and "GPT23" → "GTD23" project-wide. The Math. Prog. 2025 publication note (used in some files) is correct: arXiv:2307.11291v2 was accepted at Mathematical Programming Series B (2025).

### 1.2 Li–Liu–Orabona 2022 — venue and title both wrong

**Ground truth (verified via WebSearch):**

> *On the Last Iterate Convergence of Momentum Methods*
> **Xiaoyu Li, Mingrui Liu, Francesco Orabona**
> arXiv:2102.07002 (2021)
> Published: **Proceedings of the 33rd International Conference on Algorithmic Learning Theory (ALT 2022)**, PMLR vol. 167, pp. 699–717.

**Errors in OP-2:**

- `workspace/op2_downgraded_proof_v4.md`:39 — "Compare with Li–Liu–Orabona 2022 (arXiv:2102.07002, **ICML 2022**)" — venue wrong.
- `workspace/op2_downgraded_proof_v4.md`:694 — "**arXiv:2102.07002, ICML 2022, "On the Last-Iterate Convergence of Stochastic Gradient Descent with Momentum"**" — both venue and title wrong. The title is "On the Last Iterate Convergence of Momentum Methods" (no "Stochastic Gradient Descent" in the title; "with momentum" is not in the title).
- `workspace/op2_downgraded_proof_v4.md`:692 — section title "Li–Liu–Orabona 2022 (last-iterate SGDM in the non-smooth setting)" — descriptively OK but flag-worthy because pairs with the wrong venue.
- `workspace/op2_downgraded_proof_v4.md`:704, 711, 750, 796 — table rows refer back to "Li–Liu–Orabona 2022".

The mathematical content of the comparison (Ω(ln T/√T) lower bound for fixed-momentum SGDM in non-smooth Lipschitz setting) is correct and matches the paper. Only the venue label and the title need fixing.

### 1.3 Sebbouh–Gower–Defazio — title wrong; year ambiguous

**Ground truth (verified via WebSearch):**

> *Almost sure convergence rates for Stochastic Gradient Descent and Stochastic Heavy Ball*
> **Othmane Sebbouh, Robert M. Gower, Aaron Defazio**
> arXiv:2006.07867 (2020 preprint; published version June 2021)
> Venue: **Proceedings of the 34th Conference on Learning Theory (COLT 2021)**, PMLR vol. 134.

**Errors in OP-2 sister-doc:**

- `workspace/active/li_xiao_directions/direction_2_last_iterate_ub.md`:257 — "Sebbouh, Gower, Defazio (2020), **"On the convergence of the stochastic heavy ball method."**" — title wrong. The actual title contains "Almost sure convergence rates...". A different (earlier, shorter) note by Sebbouh & Gower from 2020 has the title "On the convergence of the Stochastic Heavy Ball Method"; the OP-2 document appears to conflate the two.
- The year "(2020)" is OK as the arXiv year, but if cited as the venue paper, it should read "(COLT 2021 / PMLR v134)".
- The Sebbouh et al. result IS almost-sure (a.s.) last-iterate $o(1/\sqrt k)$ for SHB with **time-varying** $\eta_t \downarrow 0$, $\beta_t \to 1$ — this is correctly described in the OP-2 sister-doc, lines 184–194.

### 1.4 No other CRITICAL hallucinations found

The remaining citations check out (see Section 2). Pinsker, Le Cam, Moreau, Bauschke–Combettes, Lan 2012, Polyak–Juditsky 1992, Ghadimi–Feyzmahdavian–Johansson 2015, Agarwal–Bartlett–Ravikumar–Wainwright 2012, Karimi–Nutini–Schmidt 2016, and Ball–Carlen–Lieb 1994 are all attributed correctly where they appear.

---

## 2. Per-paper verification

### 2.1 Goujaud–Taylor–Dieuleveut 2023 (arXiv:2307.11291)

- **WebSearch verified: VALID paper, but author list MIS-cited in OP-2.**
- **Authors:** Baptiste Goujaud, Adrien Taylor, Aymeric Dieuleveut (3 authors).
- **Title:** "Provable non-accelerations of the heavy-ball method"
- **Venue:** Mathematical Programming Series B (2025); arXiv:2307.11291v2 [math.OC] 9 Oct 2025.
- **Source:** Verified via paper PDF at `workspace/op2_li_review/D5_nesterov/gpt23.txt` (lines 4–6) and via WebSearch (multiple results: arXiv abstract, HAL, Springer link.springer.com/article/10.1007/s10107-025-02269-2, ResearchGate).
- **OP-2 status:** AUTHOR LIST WRONG everywhere; "Pedregosa" must be replaced by "Dieuleveut", and "GPT23" → "GTD23".

### 2.2 Li–Liu–Orabona 2022 (arXiv:2102.07002)

- **WebSearch verified: VALID, but VENUE and TITLE both mis-cited in OP-2 v4.**
- **Authors:** Xiaoyu Li, Mingrui Liu, Francesco Orabona.
- **Title:** "On the Last Iterate Convergence of Momentum Methods" (NOT "Stochastic Gradient Descent with Momentum").
- **Venue:** ALT 2022 / PMLR v167, pp. 699–717.
- **Mathematical content** (Ω(ln T/√T) LB for fixed-β SGDM in Lipschitz non-smooth setting): correct in OP-2.
- **OP-2 status:** v4 needs correction at lines 39, 694, and the table block in §4.2.5.

### 2.3 Sebbouh–Gower–Defazio (arXiv:2006.07867)

- **WebSearch verified: VALID, but TITLE mis-cited in direction_2_last_iterate_ub.md.**
- **Authors:** Othmane Sebbouh, Robert M. Gower, Aaron Defazio.
- **Title:** "Almost sure convergence rates for Stochastic Gradient Descent and Stochastic Heavy Ball"
- **Venue:** COLT 2021 / PMLR v134.
- **Math content** (a.s. last-iterate $o(1/\sqrt k)$ for SHB under time-varying schedule): correct in OP-2.
- **Status:** Cite correctly as "Sebbouh, Gower, Defazio (COLT 2021), 'Almost sure convergence rates for Stochastic Gradient Descent and Stochastic Heavy Ball'", arXiv:2006.07867.

### 2.4 Lan 2012 AC-SA

- **WebSearch verified: VALID.**
- **Authors:** Guanghui Lan.
- **Title:** "An optimal method for stochastic composite optimization"
- **Venue:** Mathematical Programming, vol. 133, pp. 365–397 (2012). DOI 10.1007/s10107-010-0434-y.
- **OP-2 citation (line 215, 217, 221, 740 of v4):** correctly attributed.

### 2.5 Polyak–Juditsky 1992

- **WebSearch verified: VALID.**
- **Authors:** B. T. Polyak and A. B. Juditsky.
- **Title:** "Acceleration of Stochastic Approximation by Averaging"
- **Venue:** SIAM Journal on Control and Optimization, vol. 30, no. 4, pp. 838–855 (1992). DOI 10.1137/0330046.
- **OP-2 citation (line 687 / Lemma 1.5 surrounds):** correctly attributed.

### 2.6 Ghadimi–Feyzmahdavian–Johansson 2015 (arXiv:1412.7457)

- **WebSearch verified: VALID and confirmed deterministic-only.**
- **Authors:** Euhanna Ghadimi, Hamid Reza Feyzmahdavian, Mikael Johansson.
- **Title:** "Global convergence of the Heavy-ball method for convex optimization"
- **Venue:** European Control Conference (ECC) 2015 / arXiv:1412.7457 (Dec 2014).
- **Confirmed:** The paper is deterministic-only; for $L$-smooth convex $f$, the **Cesàro average** of HB iterates converges at rate $O(1/k)$. There is NO stochastic oracle in the paper.
- **OP-2 status (after MOD v3-1):** correctly characterized as deterministic Cesàro UB; v3 fix is correct.

### 2.7 Agarwal–Bartlett–Ravikumar–Wainwright 2012 (arXiv:1009.0571)

- **WebSearch verified: VALID.**
- **Authors:** Alekh Agarwal, Peter L. Bartlett, Pradeep Ravikumar, Martin J. Wainwright.
- **Title:** "Information-theoretic lower bounds on the oracle complexity of stochastic convex optimization"
- **Venue:** IEEE Transactions on Information Theory, vol. 58, no. 5, pp. 3235–3249 (May 2012). [NeurIPS 2009 short version exists.]
- **OP-2 citation (line 725, 727):** correctly attributed.

### 2.8 Karimi–Nutini–Schmidt 2016 (PL inequality)

- **Not cited in OP-2 v4 or in any of the directions/reaudit files** (Grep returned no matches for "Karimi" or "Polyak-Lojasiewicz" in the OP-2 corpus).
- **WebSearch verified (for record):** authors H. Karimi, J. Nutini, M. Schmidt; title "Linear Convergence of Gradient and Proximal-Gradient Methods Under the Polyak-Łojasiewicz Condition"; venue ECML-PKDD 2016 (Springer LNCS 9851), arXiv:1608.04636.
- **OP-2 status:** No usage to flag; consistent.

### 2.9 Bach–Moulines (least-squares SGD)

- **Not cited in the audited OP-2 files.** Grep across the four target files (op2_downgraded_proof_v4.md, summary.md, direction_1_zero_momentum.md, direction_2_last_iterate_ub.md, numerical_experiments.md, the four reaudit_*.md, and the shb-* proof folders) returned zero matches for "Bach" or "Moulines".
- **OP-2 status:** Not in scope; not flagged.

### 2.10 Ball–Carlen–Lieb 1994 (Inventiones)

- **Not cited in OP-2 itself, only in `lp-lq-oracle-complexity/`** (a different proof folder).
- **WebSearch verified:** Ball, K., Carlen, E.A., Lieb, E.H., "Sharp uniform convexity and smoothness inequalities for trace norms", Invent. Math. 115, pp. 463–482 (1994). DOI 10.1007/BF01231769.
- **Status in `lp-lq-oracle-complexity/`:** correct attribution and venue (Inventiones 115:463-482, 1994).

### 2.11 Bauschke–Combettes "Convex Analysis and Monotone Operator Theory" (2011)

- **WebSearch confirmation:** Bauschke, H. H., Combettes, P. L., 1st ed. published 2011 by Springer. (2nd ed. 2017 also exists.)
- **OP-2 citation (line 143 of v4):** "*Textbook result; see e.g., Bauschke–Combettes 'Convex Analysis and Monotone Operator Theory' (2011), Prop. 12.27 & Thm. 12.15.*"
- The Moreau decomposition / projection-onto-convex-set facts cited (1-Lipschitz projection, $\Phi_C$ smooth, $\nabla \Phi_C = P_C$) are all standard and the chapter/proposition references are plausible — Prop. 12.27 in the 1st edition is the relevant Moreau decomposition statement. **Considered VALID** in the absence of a direct page check.

### 2.12 Yu "Assouad, Fano, Le Cam" 1997

- **OP-2 citation (line 206 of v4):** "Le Cam's two-point lemma (Yu 'Assouad, Fano, Le Cam' 1997, Ch. 24)."
- This is a reference to: Bin Yu (1997), *Assouad, Fano, and Le Cam*, in *Festschrift for Lucien Le Cam*, Springer, pp. 423–435 (chapter, not "Ch. 24" per se — it is a chapter in a Festschrift collection edited by Pollard, Torgersen, Yang).
- The chapter number "Ch. 24" is unusual — the canonical reference is to the chapter title, not a numerical chapter index. Status: **MINOR — fix to "Yu, B., 'Assouad, Fano, and Le Cam,' in *Festschrift for Lucien Le Cam*, Springer 1997, pp. 423–435"** to be safe.

### 2.13 Nemirovski–Yudin 1983

- **Cited at line 687 / 663 of v4** as the source of the $O(LD^2/T + \sigma D/\sqrt T)$ SGD upper bound.
- **Status:** Standard textbook reference, *Problem Complexity and Method Efficiency in Optimization*, Wiley 1983. Not flagged.

### 2.14 Shamir–Zhang 2013

- **Cited at line 687 of v4** alongside Polyak–Juditsky for the SGD rate.
- **Standard reference:** Shamir, O., Zhang, T., "Stochastic Gradient Descent for Non-smooth Optimization: Convergence Results and Optimal Averaging Schemes", ICML 2013. Not flagged (correct).

---

## 3. Theorem name verification

| Theorem | Spelling in OP-2 | Standard spelling | Status |
|---|---|---|---|
| Le Cam two-point method | "Le Cam" (with space, capital L, capital C in "Cam") | "Le Cam" | **VALID** — never spelled "LeCam", "Le-Cam", or "lecam" anywhere in the OP-2 corpus that I could find. |
| Pinsker's inequality | "Pinsker" / "Pinsker's inequality" | "Pinsker's inequality" | **VALID** — standard spelling; OP-2 uses TV ≤ √(KL/2), which is the standard form (constant 1/2 inside the square root, not 2). |
| Steinhaus theorem | not cited | "Steinhaus theorem" | N/A — not used in OP-2; no spelling to verify. |
| Fubini's theorem | not cited explicitly | "Fubini's theorem" | N/A — not used by name; product-measure factoring is invoked in Lemma 1.4 / 2.9 implicitly but no name attached. |
| Ball–Carlen–Lieb 1994 | only in `lp-lq-oracle-complexity/` | "Ball–Carlen–Lieb 1994" | **VALID** — correct attribution in the proof where used. |
| Moreau decomposition / Moreau identity | "Moreau decomposition" / "Moreau identity" | both standard | **VALID** — Lemma 1.1 of v4 states the projection-decomposition Φ_C(x) = ½‖x‖² − ½d_C(x)² and attributes to Bauschke–Combettes 2011 Prop. 12.27 / Thm. 12.15. |
| Goujaud function / GPT-cyc inequality | "Goujaud–Pedregosa–Taylor cycling inequality" | should be "Goujaud–Taylor–Dieuleveut cycling inequality" | **WRONG** — propagation of the Pedregosa hallucination; see §1.1. |
| Nemirovski–Yudin lower bound | "Nemirovski–Yudin" | "Nemirovski–Yudin" | **VALID** spelling; standard 1983 textbook attribution. |
| AC-SA (Lan 2012) | "Lan's AC-SA" / "AC-SA" | "AC-SA" (Accelerated Stochastic Approximation) | **VALID** — Lan 2012 Math. Prog. introduced AC-SA. |
| Hellinger TV (informal mention, line 464) | "Hellinger TV" | "Hellinger total variation" / "Hellinger affinity" | **STYLISTIC** — "Hellinger TV" is informal but understood; not a hallucination. |

**Summary: only the Goujaud cycling-theorem attribution carries a name hallucination.** Pinsker, Le Cam, Moreau, Nemirovski–Yudin, Polyak–Juditsky, Lan are all correctly named.

---

## 4. Year/venue corrections

| Citation | OP-2 says | Actually | Severity |
|---|---|---|---|
| arXiv:2307.11291 authors | Goujaud–**Pedregosa**–Taylor (3 wrong authors listed) | Goujaud–Taylor–**Dieuleveut** (Pedregosa is NOT an author) | **CRITICAL** |
| arXiv:2307.11291 venue | "Goujaud-Pedregosa-Taylor 2023→Math.Prog. 2025" (line 20 of `op2_final_clearing_and_setup.md`); "Goujaud-Pedregosa-Taylor 2023" elsewhere | arXiv 2023; published Math. Programming Series B 2025 (DOI 10.1007/s10107-025-02269-2) | Year/venue OK; only the author list is wrong |
| arXiv:2102.07002 (Li-Liu-Orabona) venue | "ICML 2022" (lines 39, 694 of v4) | **ALT 2022 / PMLR v167** | **MEDIUM** |
| arXiv:2102.07002 title | "On the Last-Iterate Convergence of Stochastic Gradient Descent with Momentum" (line 694 of v4) | "On the Last Iterate Convergence of Momentum Methods" | **MEDIUM** |
| arXiv:2006.07867 (Sebbouh et al.) title | "On the convergence of the stochastic heavy ball method" (line 257 of `direction_2_last_iterate_ub.md`) | "Almost sure convergence rates for Stochastic Gradient Descent and Stochastic Heavy Ball" | **MEDIUM** |
| arXiv:2006.07867 venue / year | "(2020)" only | COLT 2021 / PMLR v134 (arXiv 2020) | **LOW** (year is technically OK as arXiv year) |
| arXiv:1412.7457 (GFJ) status | v3 corrected to "deterministic only" | confirmed deterministic only | OK after MOD v3-1 |
| arXiv:1009.0571 (Agarwal et al.) | "IEEE Transactions on Information Theory 2012" | IEEE TIT, vol. 58, no. 5, pp. 3235–3249, May 2012 | OK |
| Lan 2012 AC-SA venue | "Math. Prog. 133" (line 221) | Math. Program. 133, pp. 365–397 (2012) | OK |
| Polyak–Juditsky 1992 | mentioned alongside Nemirovski-Yudin (line 687) | SIAM J. Control Optim. 30(4) 838–855 (1992) | OK (no explicit venue cited; cite is correct as is) |

---

## 5. Specific facts verification

### 5.1 Does GFJ15 (arXiv:1412.7457) treat ONLY deterministic HB?

- **WebSearch confirmation:** Yes. The paper analyzes the heavy-ball method for **convex optimization** (deterministic), proving Cesaro-average convergence at $O(1/k)$ for $L$-smooth convex objectives and linear convergence in the strongly-convex case. There is no stochastic oracle anywhere in the paper.
- **OP-2 status:** Lemma 1.6 in v3+ (after MOD v3-1) correctly characterizes this as deterministic. Status: **correctly fixed in v3**. The pre-v3 versions had this wrong; v4 inherits the v3 fix.

### 5.2 Does Li–Liu–Orabona prove a LOWER bound for fixed-momentum SGDM with rate $\Omega(\log T/\sqrt T)$?

- **WebSearch confirmation:** Yes. From the abstract: "for any constant momentum factor, there exists a Lipschitz and convex function for which the last iterate of SGDM suffers from a suboptimal convergence rate of Ω(ln T / √T) after T iterations."
- **OP-2 status (line 698 of v4):** correctly stated as "$\mathbb{E}[f(z_T) - f^\star] \geq \Omega(\ln T / \sqrt T)$". Status: **valid math; only venue and title metadata are wrong (see §1.2).**

### 5.3 Does Sebbouh–Gower–Defazio prove almost-sure or in-expectation rates? Does it require time-varying schedule?

- **WebSearch confirmation:** **Almost-sure** rates ($o(1/\sqrt k)$ for SGD averaged iterate, also for SHB last iterate). The schedule **is time-varying** ($\eta_t \downarrow 0$, $\beta_t \to 1$ at specific rates).
- **OP-2 sister-doc status (lines 184–194 of `direction_2_last_iterate_ub.md`):** correctly characterizes the result as a.s. with time-varying schedule, with the right caveats (a.s. vs $L^1$, $\varepsilon$-loss in $o(\cdot)$). Math is right. Only the **title** in line 257 needs fixing.

### 5.4 Does Pinsker's inequality have form TV ≤ √(KL/2)?

- **Standard form:** TV(P, Q) ≤ √(½ · KL(P‖Q)) = √(KL/2). Yes, correct.
- **OP-2 use (Lemmas 1.4, 2.9 of v4):** TV ≤ √(KL/2) = √(2/9 / 2) = √(1/9) = 1/3 — arithmetic checks out. Status: **VALID**.

### 5.5 Does AC-SA achieve $O(LD^2/T^2 + \sigma D/\sqrt T)$ minimax rate?

- **Confirmed via Lan 2012 abstract.** Yes — AC-SA matches the Nesterov-1985 bias rate $LD^2/T^2$ and the Nemirovski–Yudin variance rate $\sigma D/\sqrt T$ simultaneously.
- **OP-2 (line 731, 738 of v4):** correctly attributed.

### 5.6 Does Agarwal et al. 2012 prove a $\sigma D/\sqrt T$ minimax LB without a bias-term LB?

- **Standard interpretation:** Agarwal et al. prove $\Omega(\sigma D/\sqrt T)$ minimax LB for stochastic convex (smooth and Lipschitz cases), via Le Cam / Fano. They do NOT prove a $\Omega(LD^2/T^2)$ minimax bias LB; the deterministic minimax bias LB $\Omega(LD^2/T^2)$ for smooth convex is a separate Nesterov-1983 result.
- **OP-2 status (line 731 of v4):** correctly attributes only the $\sigma D/\sqrt T$ minimax LB to Agarwal et al. and says "no bias-term LB" from them. **VALID**.

---

## 6. Other minor observations

1. **`workspace/literature_crosscheck/group_A/A15_polyak_ruppert_shb.md`:16** says "Goujaud-Pedregosa-Taylor 2023 ('Quadratic minimization: from conjugate gradients to an adaptive Heavy-ball method with Polyak step sizes' & related works on SHB lower bounds, arXiv:2307.11291)". This conflates **two distinct papers**:
   - arXiv:2307.11291 — *Provable non-accelerations of the heavy-ball method* — Goujaud, Taylor, Dieuleveut (3 authors).
   - "Quadratic minimization: from conjugate gradient to an adaptive Polyak's momentum method with Polyak step-sizes" — short paper at HAL hal-04832983, **DIFFERENT authors and topic**.
   The literature_crosscheck file should be cleaned up.

2. **`shb-cycling-lyapunov-nogo/proof.md`:25** says "Goujaud–Pedregosa **2022**, Thm 3" — the year 2022 is also wrong (paper is 2023 / Math. Prog. 2025); the author list is the usual hallucination.

3. **The "Math. Prog. 2025" upgrade** in `op2_final_clearing_and_setup.md`:20 and elsewhere is correctly noted as the 2025 publication of arXiv:2307.11291, but pairs it with the wrong author triple.

4. **`workspace/op2_audit_round3.md`:5, 220, 270** uses "Goujaud, Pedregosa" as a stand-in for "expert reviewer in this subfield" — this is an editorial framing, not a citation, but still propagates the author misattribution.

---

## 7. Recommended global edits

### 7.1 Author-list fix (project-wide, search-and-replace candidates)

| Find | Replace |
|---|---|
| `Goujaud–Pedregosa–Taylor` (en-dash) | `Goujaud–Taylor–Dieuleveut` |
| `Goujaud-Pedregosa-Taylor` (hyphen) | `Goujaud-Taylor-Dieuleveut` |
| `Goujaud–Pedregosa` | `Goujaud–Taylor–Dieuleveut` (or `Goujaud–Taylor` if context demands two-author shorthand, which it usually does NOT) |
| `Goujaud-Pedregosa` | `Goujaud-Taylor-Dieuleveut` |
| `GPT23` | `GTD23` |
| `GPT 2023` | `GTD 2023` |
| `GPT-cyc` | `GTD-cyc` |

The "GPT-cyc" inequality label appears in equations (Definition in §0.4 of v4, line 87) and in many sub-results — these need a coordinated rename. The math is unaffected.

### 7.2 Specific OP-2 v4 fixes

- **Line 39** of `op2_downgraded_proof_v4.md`: `(arXiv:2102.07002, ICML 2022)` → `(arXiv:2102.07002, ALT 2022 / PMLR v167)`
- **Line 694** of `op2_downgraded_proof_v4.md`: `**arXiv:2102.07002, ICML 2022, "On the Last-Iterate Convergence of Stochastic Gradient Descent with Momentum".**` → `**arXiv:2102.07002, ALT 2022 / PMLR v167, "On the Last Iterate Convergence of Momentum Methods".**`

### 7.3 Direction-2 fix

- **Line 257** of `workspace/active/li_xiao_directions/direction_2_last_iterate_ub.md`: `Sebbouh, Gower, Defazio (2020), "On the convergence of the stochastic heavy ball method." [a.s. last-iterate $o(1/\sqrt k)$ with time-varying schedule].` → `Sebbouh, Gower, Defazio (COLT 2021 / arXiv:2006.07867), "Almost sure convergence rates for Stochastic Gradient Descent and Stochastic Heavy Ball." [a.s. last-iterate $o(1/\sqrt k)$ with time-varying schedule].`

### 7.4 RESEARCH_INDEX.md fix

- Rows 24, 58, 59, 61 currently say "Goujaud-Pedregosa-Taylor 2023" — replace with "Goujaud-Taylor-Dieuleveut 2023" (or simply "Goujaud et al. 2023, arXiv:2307.11291").

### 7.5 LaTeX source fix

`workspace/op2_clean.tex` is the LaTeX source; if regenerated to `op2_clean.aux` and `op2_clean.toc`, those will inherit the correction. Lines 103, 209, 1015, 1030 need the same `Goujaud--Pedregosa--Taylor` → `Goujaud--Taylor--Dieuleveut` replacement (note the LaTeX double-hyphen for en-dash).

### 7.6 Cleanup of subsidiary files

The 50+ secondary occurrences in `workspace/op2_audit_*.md`, `workspace/literature_crosscheck/`, `workspace/discovery_reports/`, `workspace/failure_*.md`, etc. all use the wrong author triple. These do not block the OP-2 submission per se, but should be mass-renamed for consistency before any future re-audit.

---

## 8. Final summary

**Hallucinations found (severity-ranked):**

1. **1 CRITICAL** — Author hallucination "Pedregosa" inserted as a co-author of arXiv:2307.11291 throughout the OP-2 corpus (50+ locations across the manuscript, proof folders, indices, LaTeX source, and subsidiary reports). The correct author triple is **Goujaud–Taylor–Dieuleveut**.

2. **1 MEDIUM** — Li–Liu–Orabona 2022 venue cited as "ICML 2022" — correct venue is **ALT 2022 / PMLR v167**. (`op2_downgraded_proof_v4.md` lines 39 and 694.)

3. **1 MEDIUM** — Li–Liu–Orabona 2022 title cited as "On the Last-Iterate Convergence of Stochastic Gradient Descent with Momentum" — actual title is "**On the Last Iterate Convergence of Momentum Methods**". (Same file, line 694.)

4. **1 MEDIUM** — Sebbouh–Gower–Defazio title cited as "On the convergence of the stochastic heavy ball method" — actual title is "**Almost sure convergence rates for Stochastic Gradient Descent and Stochastic Heavy Ball**", venue COLT 2021. (`direction_2_last_iterate_ub.md` line 257.)

5. **1 LOW** — `shb-cycling-lyapunov-nogo/proof.md`:25 cites "Goujaud–Pedregosa **2022**, Thm 3" — wrong year (paper is 2023) and wrong authorship.

6. **1 LOW** — `workspace/literature_crosscheck/group_A/A15_polyak_ruppert_shb.md`:16 conflates two distinct papers (arXiv:2307.11291 *Provable non-accelerations* vs. an adaptive-Polyak short paper at HAL hal-04832983).

**No hallucinations found in:**
- Lan 2012 AC-SA (Math. Programming, vol. 133)
- Polyak–Juditsky 1992 (SIAM J. Control Optim. 30(4))
- Ghadimi–Feyzmahdavian–Johansson 2015 (arXiv:1412.7457; v3 correctly fixed to "deterministic only")
- Agarwal–Bartlett–Ravikumar–Wainwright 2012 (IEEE TIT 58(5))
- Pinsker's inequality (correct form TV ≤ √(KL/2))
- Le Cam two-point method (correctly spelled "Le Cam" with space)
- Moreau decomposition / Bauschke–Combettes 2011
- Nemirovski–Yudin 1983
- Shamir–Zhang 2013

**What needs to happen before the manuscript is shown to Prof. Li Xiao or any external referee:**

1. **Mandatory:** Run a global search-and-replace of "Pedregosa" → "Dieuleveut" wherever it appears as a co-author of arXiv:2307.11291 (50+ locations); rename "GPT23" → "GTD23" and "GPT-cyc" → "GTD-cyc" in equations and labels for consistency. The math is unchanged.
2. **Mandatory:** Fix Li–Liu–Orabona venue ("ICML 2022" → "ALT 2022 / PMLR v167") and title in OP-2 v4 §4.2.5 (lines 39, 694).
3. **Recommended:** Fix Sebbouh–Gower–Defazio title and venue in `direction_2_last_iterate_ub.md` line 257.
4. **Recommended:** Sweep through the 50+ subsidiary occurrences (literature_crosscheck, discovery_reports, failure_patterns, op2_audit_*) and update for consistency, even though those files are not part of the submission packet.
5. **Recommended:** Spot-check `op2_clean.tex` line-by-line and recompile to refresh `op2_clean.aux` and `op2_clean.toc` with the corrected attribution.

A reviewer of Prof. Li Xiao's caliber will spot the "Pedregosa" misattribution **immediately** — it is the kind of error that reads as careless scholarship and undermines confidence in the rest of the paper. **This must be the first fix in the v5 revision.** All math is unaffected; only the prose attribution changes.

**Confidence:** HIGH on the Pedregosa → Dieuleveut correction (verified by reading the actual arXiv:2307.11291v2 PDF cached at `workspace/op2_li_review/D5_nesterov/gpt23.txt`). HIGH on the Li-Liu-Orabona venue (verified via WebSearch returning PMLR v167 as the canonical entry). HIGH on the Sebbouh-Gower-Defazio title (WebSearch returns the canonical arXiv abstract).

**Word count:** ~3050 words.
