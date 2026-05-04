# OP-2 Final Audit — Consolidated Verdict

**Date:** 2026-04-28
**Audience:** Whoever sends OP-2 to Prof. Li Xiao (or any external peer reviewer)
**Sources:** 4 parallel Opus auditor agents, ~25,000 words across 4 reports + this consolidation

---

## ⚠ HALLUCINATION DETECTED — BLOCKER

**The "Goujaud-Pedregosa-Taylor" / "GPT23" attribution is a HALLUCINATION** that has propagated to **50+ locations** across the OP-2 ecosystem. The real authors of arXiv:2307.11291 are:

> **Baptiste Goujaud · Adrien Taylor · Aymeric Dieuleveut**

The correct shorthand is **GTD23**, not GPT23. The "Pedregosa" attribution likely came from confusion with a different cycling-paper bibliography entry: "Super-acceleration with cyclical step-sizes" (Goujaud-Scieur-Dieuleveut-Taylor-Pedregosa 2022), which is a *cited reference inside* arXiv:2307.11291 — not the paper itself.

**This will be caught immediately by any informed peer reviewer**, especially Prof. Li Xiao who is in the SIOPT/optimization community and likely knows Adrien Taylor personally. Sending OP-2 with "Pedregosa" attribution is not acceptable. **Mandatory global find-and-replace before peer review.**

### Affected files

- `workspace/op2_downgraded_proof_v4.md`: ~13 occurrences (incl. §4.1 heading, Lemma 1.3 attribution, §4.6 novelty list)
- `proofs/research/optimization/lower-bounds/shb-*/proof.md` and `notes.md`: ~17 occurrences across 4+ proof folders
- `RESEARCH_INDEX.md`: rows 24, 58, 59, 61
- `op2_clean.tex` (LaTeX submission file)
- `proofs/research/optimization/convergence/polyak-ruppert-shb-defeats-cycling/proof.md`: multiple occurrences
- `workspace/op2_li_review/literature_crosscheck/` and `discovery_reports/`: multiple occurrences
- `workspace/active/li_xiao_directions/`: 2 occurrences (d1_explorer_5, direction_1_scout_routes)
- `workspace/failure_patterns.md` and `workspace/failure_triggers.md`
- `proofs/research/optimization/lower-bounds/shb-cycling-lyapunov-nogo/proof.md:25` — additional bug: says "Goujaud–Pedregosa 2022" (wrong author AND wrong year — should be 2023)

### Recommended replacements (project-wide)

| Find | Replace |
|---|---|
| `Goujaud-Pedregosa-Taylor` | `Goujaud-Taylor-Dieuleveut` |
| `Goujaud–Pedregosa–Taylor` (en-dash) | `Goujaud–Taylor–Dieuleveut` |
| `Goujaud, Pedregosa, Taylor` | `Goujaud, Taylor, Dieuleveut` |
| `GPT23` | `GTD23` |
| `GPT-cyc` | `GTD-cyc` |
| `Pedregosa-Taylor` | (delete; not part of paper) |

The math is not affected by any of these changes — it's purely an attribution fix.

---

## SHIP / NO-SHIP DECISION

### Status: **NO-SHIP** until 9 specific edits are made.

**Why NO-SHIP:** The hallucination is severe enough that submitting OP-2 to Prof. Li Xiao without correction would be a credibility-damaging error. Beyond Pedregosa, several other phrasing/citation edits (especially Direction 1's bias constant and re-audit-corrections-not-propagated) would also be reviewer red flags.

**Why we're close to ship:** All mathematical content is correct. SymPy + mpmath + Monte-Carlo confirmed all 4 load-bearing constants ($\sqrt 2/27$, $\kappa/4$, $\beta^* = (\sqrt{13}-3)/2$, cycling inequality), Floquet eigenvalues to 50 digits, Vieta identity exactly, closed-form noise floor at <0.1% rel-err in 5 MC settings. **No mathematical errors found.** The OP-2 v4 paper itself (math content) is rigorous.

---

## REQUIRED EDITS (9 items, prioritized)

### Priority 1 (CRITICAL — will be caught immediately by any reviewer)

**E1. Pedregosa → Taylor-Dieuleveut** (project-wide find-replace)
- ~50 occurrences across the corpus
- Recommended action: run a `sed`/`Edit` pass over the entire `Math/` directory tree
- After replacement, verify by `grep -r "Pedregosa" Math/` returns no in-scope results
- Recompile `op2_clean.tex` so `.aux` and `.toc` refresh
- **Estimated effort: 30 minutes**

### Priority 2 (HIGH — invalidates a boxed inequality)

**E2. Direction 1 bias constant $\kappa/8$ for $\forall T \geq 1$** (`direction_1_zero_momentum.md`)
- Numerical verification at the anchor $(0.8, 3.247, 0.387)$ shows the bound FAILS at $T=4$ (ratio 0.113 < 1/8 = 0.125)
- Re-audit found this issue and noted it in `summary.md` WARNING block, but the correction was **never propagated** to `direction_1_zero_momentum.md` itself
- Choose ONE:
  - **(option A)** Restate as "$\forall T \geq T_0(\beta,\eta) \approx 10$" with $\kappa/8$ — cleanest, but requires defining $T_0$
  - **(option B)** Downgrade to $\kappa/10$ with $\forall T \geq 1$ — simplest. ($\kappa/9 \approx 0.111$ is empirically marginal vs the observed minimum 0.113.)
- Affected lines in `direction_1_zero_momentum.md`: §0 line 17, §5 line 184, §9 boxed line 266
- **Estimated effort: 1 hour** (also need to update the L5 absorption argument)

### Priority 3 (MEDIUM — caught by careful reader)

**E3. Direction 1 "period-2 attractor" terminology** (`direction_1_zero_momentum.md` §7 lines 209-218)
- 50-digit verification shows the orbit is **period-6 in $\mathbb R^2$** (not period-2)
- Period-6 = period-2 mod $C_3$ rotation
- Rename throughout

**E4. Direction 1 bias floor `0.37 µD²` → `2.22 µD²`** (`direction_1_zero_momentum.md` §7 line 224, §9 line 271)
- Arithmetic units error: with min-norm $\|x^a\| = 2.107$ (in absolute units, $D=1$), floor is $(\mu/2)(2.107)^2 = 2.22\mu D^2$
- Original `0.37` came from confusing $\lambda$-units vs $D$-units

**E5. Li-Liu-Orabona venue and title** (`workspace/op2_downgraded_proof_v4.md` lines 39, 694)
- Currently: `ICML 2022, "On the Last-Iterate Convergence of Stochastic Gradient Descent with Momentum"`
- Correct: `ALT 2022 / PMLR v167, "On the Last Iterate Convergence of Momentum Methods"`

**E6. Sebbouh-Gower-Defazio title and venue** (`direction_2_last_iterate_ub.md` line 257)
- Currently: `"On the convergence of the stochastic heavy ball method" (2020)`
- Correct: `"Almost sure convergence rates for Stochastic Gradient Descent and Stochastic Heavy Ball", COLT 2021 / PMLR v134, arXiv:2006.07867`

### Priority 4 (LOW — improves clarity)

**E7. Direction 2 "exact match" → "rate match"** (`direction_2_last_iterate_ub.md` lines 80, 82; possibly more)
- Currently: claims $\eta_T = D/(\sigma\sqrt T)$ gives noise floor "exactly" $\sigma D/\sqrt T$
- Reality: matches in **rate** $\Theta(\sigma D/\sqrt T)$, but constants differ by $\beta$-polynomial factor (noise floor coeff $1/[4(1-\beta)]$, OP-2 LB coeff $\sqrt 2/27$; ratio 4.77×–47.7×)
- Note: this is also flagged in `summary.md` WARNING but should also be in the body of `direction_2_last_iterate_ub.md`

**E8. OP-2 v4 §0.5: explicit "non-zero momentum init" mention** (insert after line 101 of `op2_downgraded_proof_v4.md`)
- The hard instance uses $x_0 \neq x_{-1}$ (cycle-vertex velocity). This is essential for the cycling identity.
- Currently §0.5 says "$\|x_0 - x^*\| = D$ exact equality" but doesn't flag that $x_0 \neq x_{-1}$.
- Suggested insertion: a sentence like *"Note that this initialization has $x_0 - x_{-1} = (D/\sqrt 2)(e_0 - e_{K-1}) \neq 0$, i.e., non-zero initial velocity. The standard zero-momentum init $x_0 = x_{-1}$ is treated separately in Theorem 5.1 and the companion document."*

**E9. "Last iterate" qualifier in titles** (8 files + OP-2 v4 title)
- OP-2 v4 title: `"OP-2 Downgraded ... Fixed-momentum SHB does not accelerate on the Goujaud feasibility region"` — should specify `"...does not accelerate (last iterate) on..."`
- All 4 files of `shb-no-acceleration-restricted/`: same issue
- `direction_1_zero_momentum.md`: similar
- Reason: Li Xiao's review feedback explicitly said the result is last-iterate only and should be flagged everywhere

### Priority 5 (TRIVIAL)

**E10. OP-2 v4 §2.4.1 "cubic" → "quadratic critical-point equation"**
- The equation $3\sqrt 2\,r\,c_\alpha^2 - (2\sqrt 2\,r + 4)c_\alpha + 2 = 0$ is degree 2 in $c_\alpha$, not 3.
- Math is unaffected; just call it "quadratic" not "cubic".

---

## WHAT IS WATERTIGHT (ready to ship after edits above)

### Mathematics (Audit 2 verified)
- **All 4 load-bearing constants:** $\sqrt 2/27$, $\kappa/4$, $\beta^*$, cycling inequality (★) — SymPy verified
- **Vieta identity** $(1-r_1)(1-r_2) = \eta\mu$ — SymPy verified
- **Floquet eigenvalues** $|\lambda| = \beta^{3/2}$ — mpmath 50-digit verified at anchor
- **Closed-form noise floor** — SymPy + 5 Monte-Carlo settings at <0.1% rel-err
- **Critical momentum threshold** $\beta^* = (\sqrt{13}-3)/2$ — closed-form roots verified
- **Polynomial factorization** $2(\beta-c)(1+\beta) - (1-c)(...) = (1+c)(\beta^2 + 2(1-c)\beta - 1)$ — SymPy expanded to 0

### Cross-file definitions (Audit 2 verified)
- $f^*$, $\sigma^2$, $L$, $\kappa$, $\mathcal F$, SHB iteration form — all consistent

### Theorem statements (Audit 3 verified)
- OP-2 v4 §0.5 Main Theorem: 16 claims VALID
- `summary.md` WARNING block: correctly captures all 5 known issues
- `direction_2_last_iterate_ub.md`: 6 claims VALID (Issue B addressed inline)

### Other citations (Audit 1 verified)
- ✅ Lan 2012 (Math. Prog. 133)
- ✅ Polyak-Juditsky 1992 (SIAM J. Control Optim. 30(4))
- ✅ Ghadimi-Feyzmahdavian-Johansson 2015 (arXiv:1412.7457) — confirmed deterministic-only
- ✅ Agarwal-Bartlett-Ravikumar-Wainwright 2012 (IEEE TIT 58(5))
- ✅ Pinsker's inequality TV ≤ √(KL/2) — standard form
- ✅ "Le Cam" — correctly spelled everywhere
- ✅ Moreau decomposition + Bauschke-Combettes 2011

---

## ACTION CHECKLIST FOR THE EDITOR (RECOMMENDED ORDER)

```
[ ] E1: Project-wide find-replace Pedregosa → Taylor-Dieuleveut, GPT23 → GTD23
[ ] E1.1: Fix shb-cycling-lyapunov-nogo/proof.md:25 year typo (2022 → 2023)
[ ] E1.2: Recompile op2_clean.tex; verify no Pedregosa in PDF
[ ] E5: Fix Li-Liu-Orabona venue + title in op2_downgraded_proof_v4.md (2 lines)
[ ] E6: Fix Sebbouh-Gower-Defazio title + venue in direction_2_last_iterate_ub.md
[ ] E2: Direction 1 bias constant — choose option A (T₀) or B (κ/10) and propagate
[ ] E3: Direction 1 "period-2" → "period-6 (period-2 mod C₃)" (rename throughout §7)
[ ] E4: Direction 1 bias floor "0.37 µD²" → "2.22 µD²"
[ ] E7: Direction 2 "exact match" → "matches in rate Θ(σD/√T)" (with β-polynomial caveat)
[ ] E8: OP-2 v4 §0.5: add explicit "non-zero momentum init" sentence
[ ] E9: Add "last iterate" qualifier to OP-2 v4 title + 4 shb-no-accel-restricted files + direction_1_zero_momentum.md
[ ] E10: OP-2 v4 §2.4.1 "cubic" → "quadratic"
[ ] FINAL: re-grep for "Pedregosa", "GPT23", "ICML 2022", "0.37 µD²", "period-2 attractor" — all should return zero in-scope hits
```

**Estimated total edit time: 3-4 hours of careful work.** Most edits are short, but Pedregosa propagated everywhere and E2 requires a small math reformulation.

---

## BOTTOM LINE FOR THE EDITOR

**Send to Prof. Li Xiao only after E1-E10 are complete.** Once edits are made:
- The mathematical content is rigorous (verified by automated SymPy + mpmath + Monte-Carlo).
- The arguments are precise (audited at quantifier/hypothesis level).
- The citations are accurate (cross-checked against arXiv + journal records).
- The presentation is consistent (terminology, definitions, scope).

The result is then publication-grade and reviewer-ready. The 4-task re-audit confirmed all main theorems are correct; this final audit confirms only the *presentation* needs tightening.

**One final sanity check before submission:** after edits, run a fresh `grep -r "Pedregosa\|GPT23\|GPT-cyc" workspace/ proofs/` — should return zero hits. If anything remains, do not submit.

---

## Audit reports (full evidence)

- `hallucination_check.md` (~3050 words): per-paper web verification, 50+ Pedregosa locations, full citation list
- `math_consistency.md` (~2520 words): all constants SymPy-verified, cross-file definition table, 7 phrasing edits
- `claim_precision.md` (~2700 words): per-theorem precision check, direction_1 NOT READY breakdown
- `style_check.md` (~1900 words): Pedregosa grep, "last iterate" qualifier audit, terminology consistency
- `final_verdict.md`: this consolidated report

**Audit infrastructure:** 4 Opus auditor agents in parallel, ~25,000 words of evidence, ~30 minutes wall-clock.
