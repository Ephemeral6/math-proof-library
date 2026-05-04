# OP-2 Style + Residual Audit

**Date:** 2026-04-28
**Auditor:** Style + Residual-Hallucination Auditor (final pre-peer-review check)
**Scope:** `workspace/op2_downgraded_proof_v4.md`, `workspace/active/li_xiao_directions/{summary,direction_1_zero_momentum,direction_2_last_iterate_ub,numerical_experiments,reaudit_*,d1_explorer_*,d2_explorer_*}.md`, `proofs/research/optimization/lower-bounds/shb-*/*.md`.

---

## Task 4.1 — GPT23 / Pedregosa residuals

**FINDING: The "Goujaud-Pedregosa-Taylor" / "GPT23" attribution is HALLUCINATED.** Per the brief, the actual authors are Goujaud-Taylor-Dieuleveut (2023, arXiv:2307.11291). Every occurrence of "Pedregosa" in connection with this paper is wrong and must be replaced.

### Occurrences found in the in-scope files

**`workspace/op2_downgraded_proof_v4.md`** (12 hits — all critical):
- L17: "[MOD v4-7] New Remark 4.1.1 in §4.1: explicit Nesterov-cycling matrix … partially answering GPT23 Conjecture 7.1."
- L86: "the **Goujaud–Pedregosa–Taylor cycling inequality** (GPT-cyc) with parameter …"
- L152: "## 1.3 Goujaud–Pedregosa–Taylor cycling theorem"
- L154: "**Lemma 1.3 (GPT23, Theorem 3.5 of arXiv:2307.11291 + §3.4).**"
- L181: "*Proof of (iii): see GPT23 §3.4 for the KKT verification.*"
- L573: "Independently confirms Lemma 1.3(iii) without relying on GPT23's KKT argument."
- L655: "## 4.1 Goujaud–Pedregosa–Taylor 2023 (GPT23)"
- L659: "GPT23 Theorem 3.5 = our Lemma 1.3."
- L661: "**How v2 extends GPT23:**"
- L662: "1. **Non-strongly-convex setting.** GPT23 requires $\mu > 0$. …"
- L663: "2. **Stochastic oracle and variance term.** GPT23 is deterministic. …"
- L664: "3. **$T$-uniform formulation.** GPT23's cycling is …"
- L666: "**Remark 4.1.1 (Nesterov's accelerated method, partial answer to GPT23 Conjecture 7.1).** **[MOD v4: NEW]** Goujaud–Pedregosa–Taylor (2023, Remark 6.1 and Conjecture 7.1) state …"
- L670: "Whenever the KKT-projection identity … (a NAG-analogue of GPT23's $(\star)$) holds …"

**`workspace/active/li_xiao_directions/`** (2 hits):
- `d1_explorer_5_construction.md:11`: "vertices $\{\lambda M e_t\}_{t=0}^{K-1}$ ($M$ as in (M-def) of GPT23). The OP-2 cycling identity …"
- `direction_1_scout_routes.md:85`: "K=2 is excluded ($K \geq 3$ in GPT23). Partial rescue: use the K=2 analog informally."

**`proofs/research/optimization/lower-bounds/shb-*/`** (17 hits — all critical):
- `shb-no-acceleration-restricted/proof.md:30`: "write the **Goujaud–Pedregosa–Taylor (GPT23) cycling inequality** as"
- `shb-no-acceleration-restricted/proof.md:64`: "Goujaud–Pedregosa–Taylor (2025) is strictly strongly-convex; …"
- `shb-no-acceleration-restricted/proof.md:210`: "key black-box input, from Goujaud–Pedregosa–Taylor 2023, arXiv:2307.11291, Theorem 3.5 + §3.4."
- `shb-no-acceleration-restricted/proof.md:212`: "**Lemma 1 (GPT23).** …"
- `shb-no-acceleration-restricted/proof.md:226`: "We reproduce the key steps from GPT23; …"
- `shb-no-acceleration-restricted/proof.md:257`: "**Sublemma $P_C(e_t) = M e_t$.** This is the crux of GPT23 …; A full proof … is in GPT23 §3; …"
- `shb-no-acceleration-restricted/proof.md:494`: "**Goujaud–Pedregosa–Taylor 2023/2025** (arXiv:2307.11291) …"
- `shb-no-acceleration-restricted/proof.md:508`: "Lemma 1 (cycling from GPT23) (§4) | Black box + sketch | Full proof in GPT23; …"
- `shb-no-acceleration-restricted/report.md:61`: "**Goujaud-Pedregosa-Taylor 2023/2025** (strongly-convex non-acceleration): …"
- `shb-no-acceleration-restricted/report.md:77`: "**Class: A** (2015+ research paper template, novel non-SC extension of GPT23, …)"
- `shb-no-acceleration-restricted/notes.md:14`: "**Construct $f_{\beta,\eta}$** via Goujaud-Pedregosa-Taylor 2023 polytope-Moreau envelope $\psi_P$ …"
- `shb-no-acceleration-restricted/notes.md:30`: "**Goujaud-Pedregosa-Taylor 2023/2025** (arXiv:2307.11291): strongly-convex non-acceleration. …"
- `shb-no-acceleration-restricted/problem.md:6`: "Primary technical template: **Goujaud-Pedregosa-Taylor 2023 → Math. Prog. 2025** (arXiv:2307.11291) …"
- `shb-no-acceleration-restricted/problem.md:63`: "**Goujaud-Pedregosa-Taylor 2023/2025** (arXiv:2307.11291): constructs, …"
- `shb-no-acceleration-best-iterate/problem.md:4`: "Extension of OP-2 (Goujaud-Pedregosa-Taylor 2023 polytope-Moreau cycling)."
- `shb-no-acceleration-best-iterate/notes.md:27`: "**Goujaud-Pedregosa-Taylor 2023** (arXiv:2307.11291): cycling theorem on $\mathcal{F}$ with $\mu > 0$."
- `shb-no-acceleration-best-iterate/proof.md:17`: "the (rescaled) Goujaud–Pedregosa–Taylor polytope-Moreau function with cycle radius $D/\sqrt 2$ …"
- `shb-no-acceleration-best-iterate/proof.md:55`: "the Goujaud–Pedregosa–Taylor polytope-Moreau function $\psi$ (OP-2 §3.1) …"
- `shb-cycling-critical-momentum/audit.md:91`: "$K = 2$ exclusion is consistent with GPT23 …"
- `shb-cycling-critical-momentum/notes.md:32`: "**Goujaud–Pedregosa–Taylor 2023** (arXiv:2307.11291): The original cycling construction. …"
- `shb-cycling-critical-momentum/problem.md:4`: "Paper: meta-result on Goujaud–Pedregosa–Taylor 2023 (arXiv:2307.11291)."
- `shb-cycling-critical-momentum/proof.md:10`: "small-$\kappa$ limit of the Goujaud–Pedregosa–Taylor 2023 cycling inequality (GPT-cyc), …"
- `shb-cycling-critical-momentum/report.md:61`: "Class: A (research-level meta-result on a 2023 paper's construction; novel sharpness claim absent from the original GPT23 work)."
- `shb-cycling-lyapunov-nogo/proof.md:20`: "On the Goujaud–Pedregosa hard 2D quadratic at $(\beta,\eta)\in\mathcal F$, …"
- `shb-cycling-lyapunov-nogo/proof.md:25`: "Existence of such an orbit … (Goujaud–Pedregosa 2022, Thm 3)."
- `shb-coefficient-suboptimality/proof.md:49`: "Take Goujaud–Pedregosa's hard convex function $f^{(s)}$ used in OP-2 cycling lower bound."

Total in scope: **~31 occurrences** — every single one is a hallucination.

Note: a separate "GPT23.txt" file exists at `workspace/op2_li_review/D5_nesterov/gpt23.txt` containing the actual paper text — auditor should re-read its title page to confirm the authors of record (Goujaud-Taylor-Dieuleveut). Outside the scope, additional hits live in `RESEARCH_INDEX.md`, `workspace/literature_crosscheck/*`, `workspace/op2_clean.tex`, and `polyak-ruppert-shb-defeats-cycling/{problem,proof}.md` — they all need the same global replacement.

### Recommended replacement
- "Goujaud–Pedregosa–Taylor" / "Goujaud-Pedregosa-Taylor" → "Goujaud–Taylor–Dieuleveut" (en-dash form preferred for prose)
- "GPT23" → "GTD23"
- "(GPT-cyc)" lemma label can stay only if explicitly redefined as "GTD-cyc" or just "(cyc)"
- "Goujaud–Pedregosa" alone (in `shb-cycling-lyapunov-nogo/proof.md:20,25` and `shb-coefficient-suboptimality/proof.md:49`) → "Goujaud–Taylor–Dieuleveut" (the year shift "2022" in the no-go proof line 25 is also wrong; arXiv ID 2307.11291 is 2023)

### Action required: GLOBAL FIND-AND-REPLACE before peer review

---

## Task 4.2 — iterate type terminology

### Vague claims (need "last iterate" qualifier)

The phrase "SHB does not accelerate" appears in OP-2 v4 / dependent files **without** an iterate qualifier in the headline; the Main Theorem inequality (line 105) is on $f(x_T)$ — a last-iterate quantity — but the surrounding prose calls it simply "SHB does not accelerate". Specific occurrences:

- `op2_downgraded_proof_v4.md:1` (TITLE): "Fixed-momentum SHB does not accelerate on the Goujaud feasibility region — Complete, Self-Contained Proof (v4)" — **NO iterate qualifier in title.**
- `op2_downgraded_proof_v4.md:40` (MOD v3-3 changelog): "the precise 'non-acceleration' statement: SHB cannot achieve AC-SA's optimal $LD^2/T^2$ bias rate on $\mathcal{F}$." — **vague.**
- `op2_downgraded_proof_v4.md:111` (Main-Theorem tightness footnote): "the $\sigma D/\sqrt T$ variance term matches the classical SGD stochastic upper bound … This is the non-acceleration conclusion." — implicit on $x_T$, not stated.
- `op2_downgraded_proof_v4.md:736`: "fixed-momentum SHB, restricted to $\mathcal{F}$, cannot attain the optimal bias rate of AC-SA" — vague.
- `proofs/.../shb-no-acceleration-restricted/notes.md:1` (TITLE): "Fixed-momentum SHB does not accelerate on $\mathcal{F} \subset$ stability region" — vague.
- `proofs/.../shb-no-acceleration-restricted/proof.md:2` (TITLE): "Stochastic Heavy Ball does not accelerate on smooth convex functions" — vague.
- `proofs/.../shb-no-acceleration-restricted/problem.md:1` (TITLE): "Stochastic Heavy Ball does not accelerate on smooth convex functions (∀-∃ downgraded version)" — vague.
- `proofs/.../shb-no-acceleration-restricted/report.md:1` (TITLE): "Fixed-momentum SHB does not accelerate on a substantial subregion of its stability region" — vague.
- `proofs/.../shb-no-acceleration-restricted/proof.md:63`: "this establishes the 'SHB does not accelerate' conclusion on the restricted region." — vague.
- `proofs/.../shb-no-acceleration-restricted/proof.md:476`: "SHB does NOT accelerate on $\mathcal{F}$." — vague.
- `proofs/.../shb-no-acceleration-restricted/proof.md:496`: "Our lower bound on SHB + their upper bound on AC-SA $\Rightarrow$ 'SHB does not accelerate' rigorously, on $\mathcal{F}$." — vague (Lan AC-SA upper bound is best-iterate / averaged; mixing iterate types in a separation argument is exactly what Li Xiao flagged).
- `proofs/.../shb-no-acceleration-best-iterate/notes.md:29`: "confirming 'SHB does not accelerate' on $\mathcal{F}$ even for best iterate." — OK because qualifier is there.

`direction_1_zero_momentum.md` (FINAL DELIVERABLE) does NOT contain the words "last iterate" anywhere, even though its theorem statement (L17) is $\mathbb{E}[f(x_T) - f^\star] \geq c\kappa LD^2/T + c'\sigma D/\sqrt T$ — that IS a last-iterate bound but the document does not say so.

### "$\sigma D/\sqrt T$" / "cannot achieve $\sigma D/\sqrt T$"

- `op2_downgraded_proof_v3.md:24`, `v3_final.md:24`, `op2_downgraded_proof_v4.md:40`: "SHB cannot achieve AC-SA's optimal $LD^2/T^2$ bias rate on $\mathcal{F}$" — this is technically a *bias-term* claim about $\mathbb{E}[f(x_T) - f^\star]$, but neither line states "last iterate". OK if read with §0.5, but a reviewer skimming the changelog would not see the qualifier.

### "non-convergence" misuse
None found in OP-2 v4 or `li_xiao_directions/`. The only hits in `proofs/` are in `heavy-ball-instability/` (legitimately about divergence — different theorem), `minimax/first-order-local-minimax-convergence/` (unrelated), and `proposer/` heuristic files. **No misuse in scope.** (The actual full text of GTD23 itself uses "non-convergence" — that's their term for cycling, but we should not mirror it without context.)

### "non-acceleration"
Used in OP-2 v4 lines 40, 111, 661, 736, 750 and `shb-no-acceleration-restricted/` (multiple). All are preceded by enough context (Lan/AC-SA comparison) that the meaning "bias-term cannot reach $LD^2/T^2$" is clear. **OK.** Inside `li_xiao_directions/` the word does NOT appear (search returned 0 files). Consider adding it back into Direction 1's theorem statement for terminological alignment with OP-2.

---

## Task 4.3 — Li Xiao feedback reflection

### (a) Last-iterate only — **NEEDS_CORRECTION**

Li Xiao said "OP-2 only proves a last-iterate LB; check this is consistent throughout." The Main Theorem (`op2_downgraded_proof_v4.md:104-105`) is correctly stated on $f(x_T)$, and Claim 2.5 (L337) and Lemma 2.9 (L398) explicitly use the last iterate. **However:**

1. The TITLE of OP-2 v4 ("Fixed-momentum SHB does not accelerate on the Goujaud feasibility region") omits "last iterate".
2. The title/abstract of `shb-no-acceleration-restricted/{problem,proof,notes,report}.md` (all 4 files) all say "SHB does not accelerate" with NO iterate qualifier — exactly the residual that Li Xiao asked to scrub.
3. `direction_1_zero_momentum.md` Theorem (L1, L11–L17) does not contain "last iterate" anywhere even though the bound is on $f(x_T)$.
4. `summary.md` Direction 1 row in the TL;DR table (L62) says "OP-2 cycling requires non-zero initial momentum" — does not say "last-iterate cycling". Subsequent text correctly clarifies, so OK.
5. `shb-no-acceleration-restricted/proof.md:496`: "Our lower bound on SHB + their upper bound on AC-SA ⇒ 'SHB does not accelerate' rigorously." — Lan's AC-SA UB is best-iterate / Cesàro; mixing iterate types in a separation argument is exactly the *original* Li Xiao concern in Direction 2 about GFJ15.

**Recommended fix:** insert "last iterate of" before "SHB" in all the section/file titles listed above; explicitly state in §0.5 of OP-2 v4 that the bound is on the last iterate $x_T$.

### (b) Initialization sensitivity — **VALID** (with one ambiguity)

`summary.md` distinguishes the two regimes:
- L72 (verbatim Li Xiao quote): "$x_0 = x_{-1}$ 的设定" identified as the standard practice.
- L62 (TL;DR Direction 1): "OP-2 cycling requires non-zero initial momentum; standard practice is $x_0 = x_{-1}$"
- L80–81 (numerical experiment table): "OP-2 (non-zero momentum)" vs "Zero-momentum" rows clearly separated.
- L89 (Direction 1 boxed theorem): explicitly under $x_0 = x_{-1} = \lambda e_0$ within the positive-measure subset $\mathcal F^{\mathrm{zero}}_{K=3}$.
- `direction_1_zero_momentum.md` L15 cleanly states "the **zero-momentum initialization** $x_0 = x_{-1} = \lambda e_0$".

Ambiguity: `op2_downgraded_proof_v4.md:101` says "an initial pair $(x_0, x_{-1}) \in \mathbb{R}^3 \times \mathbb{R}^3$ with $\|x_0 - x^\star\| = D$ — exact equality." This permits $x_0 \neq x_{-1}$ (cycle init). It does NOT make the velocity-laden nature explicit, although it is hidden in §2.1's construction. **Recommended:** add a single sentence after L101 saying "Note: the initial pair satisfies $x_0 \neq x_{-1}$ (the cycle is velocity-laden); the case $x_0 = x_{-1}$ is treated separately in Direction 1, see `direction_1_zero_momentum.md`."

### (c) Non-strong-convexity — **VALID**

`op2_downgraded_proof_v4.md` carefully states the construction is "globally 0-strongly-convex" via Claim 2.12:
- L31 (changelog): "**[MOD v2-5]** New Claim 2.12 verifying that $f_{\beta,\eta}^{(s)}$ is **globally 0-strongly-convex** (i.e., convex but not strongly convex), matching the non-SC hypothesis of `problem.md`."
- L100 (Main Theorem statement): "convex and $L$-smooth (globally 0-strongly-convex; see Claim 2.12)"
- L499–501 (§2.6 with Claim 2.12 verification): "global strong-convexity constant 0; i.e., it is convex but not $\mu'$-SC for any $\mu' > 0$."
- L662 (extension narrative): "GPT23 requires $\mu > 0$. We embed into `problem.md`'s $\mathcal{F}_L$ class … Claim 2.12 shows the 3-D function has global SC constant exactly $0$."

Language is correct. No issue.

---

## Task 4.4 — Misc terminology consistency

| Item | Status | Detail |
|------|--------|--------|
| **Cesàro vs Cesaro** | INCONSISTENT (mostly Cesàro, two stragglers) | OP-2 v4 uses "Cesàro" (7×), zero "Cesaro" — clean. But `summary.md:129` quotes Li Xiao's verbatim Chinese feedback containing "Cesaro average" (no accent) — acceptable because it is a quotation. `d2_explorer_6_compositional.md:59` says "the Vieta identity of Cesaro-kappa-separation §1" — should be "Cesàro" or rendered via the `\`{a}` LaTeX accent. **Pick "Cesàro" globally**. The 47 hits inside `proofs/.../shb-pr-cesaro-kappa-separation/` are folder names — those are fine (kebab-case ASCII). |
| **smooth convex non-SC** vs **non-strongly-convex smooth** | INCONSISTENT but fine | OP-2 v4 uses both: "smooth convex non-SC" (L750), "non-strongly-convex smooth" (L31, L662, L706, L723), "smooth convex (non-SC)" (L499). Either is OK; recommend standardizing on "smooth convex non-strongly-convex" (full words) for the abstract / theorem, and "non-SC" (abbreviation) for body once defined. |
| **SHB vs Stochastic Heavy Ball** | CONSISTENT | OP-2 v4 has the formal definition at L70 ("Fixed-momentum Stochastic Heavy Ball, SHB") and uses "SHB" everywhere thereafter. `shb-no-acceleration-restricted/{proof,problem}.md` titles use "Stochastic Heavy Ball" (full form, capitalized). `direction_2_last_iterate_ub.md:14` uses "Stochastic Heavy Ball (SHB)". `summary.md` uses "stochastic heavy-ball (SHB)" (lowercase, hyphenated). **Recommend pick one.** Best practice: "Stochastic Heavy Ball (SHB)" capitalized, no hyphen, on first use; "SHB" thereafter. The `direction_1_zero_momentum.md:11` "stochastic heavy-ball (SHB)" should be "Stochastic Heavy Ball (SHB)". |
| **$\eta_T$ vs $\eta(T)$** | INCONSISTENT | `summary.md:149,161,177` and `direction_2_last_iterate_ub.md` use $\eta_T$ (subscript). `d2_explorer_4_reduction.md:156` uses $\eta(T)$ (function notation). Pick one. **Recommend $\eta_T$** (matches OP-2 v4 stylistic convention for $T$-indexed quantities like $f^{(T)}$, $x_T$). |
| **dimension-free** | NOT USED in scope | Not present in OP-2 v4 or `li_xiao_directions/`. Used heavily in `lp-lq-oracle-complexity/` (different proof). No conflict, no action. |

---

## Task 4.5 — Other hallucination indicators

### "PEP" / "SDP"
Both confined to Direction 2 / `d2_explorer_*` (95 hits across 11 files):
- `direction_2_last_iterate_ub.md`, `direction_2_audit.md`, `direction_2_judge.md`, `direction_2_scout_routes.md`: PEP = Performance Estimation Problem (Drori-Teboulle 2014, Taylor et al. 2017).
- `d2_e5_pep_*.py`: PEP/SDP scripts.

**Confirmed: PEP only used in Direction 2.** No leakage into OP-2 v4 or Direction 1. Spelling consistent ("PEP", "SDP" — no variant forms found). **OK.**

### "AI Agent" / "AI agent"
**Zero occurrences in any in-scope file.** OK.

### "I" / "we" usage
- `op2_downgraded_proof_v4.md`: zero "I" or "I'm/I've/I'll", uses "we" throughout. OK.
- `direction_1_zero_momentum.md`, `direction_2_last_iterate_ub.md`, `summary.md`: spot-checked — all "we", no first-person singular. OK.

### "obviously" / "clearly" / "trivially"
- **OP-2 v4**: zero hits. Excellent.
- **`li_xiao_directions/`**: 5 hits, all in Explorer working docs (not the deliverables). Each is technically justified or appropriately hedged:
  - `d2_explorer_1_orthodox.md:103`: "$\|\nabla f(x_t)\|^2 \geq 0$ trivially" — yes, trivial. OK in a working doc.
  - `d2_explorer_5_construction.md:78`: "the joint PEP UB is clearly *below*" — describing a numerical plot. OK.
  - `d2_explorer_6_compositional.md:94`: "**trivially** weak" — justified by the inequality chain shown. OK.
  - `direction_2_scout_routes.md:144`: "does not trivially transfer to SHB" — correct usage (negating triviality).
  - `audit_d2_verifier.py:222`: code comment — not in published prose.
- **`proofs/.../shb-*/`**: 6 hits, all justified:
  - `shb-no-acceleration-restricted/notes.md:9`, `proof.md:288`, `report.md:44`: "trivially dominates" — referring to the constant-vs-decreasing comparison $\kappa LD^2/2 \geq \kappa LD^2/(4T)$ for $T \geq 1$. Valid.
  - `shb-interpolation-regime-lb/proof.md:80`: "$\mathbb{E}[\xi_t \mid x_t] = 0$ (trivially)" — valid by definition of unbiased oracle.
  - `shb-no-acceleration-best-iterate/notes.md:5`: "min over $t$ inherits the bound trivially" — valid because the cycle has constant function-value gap.

**No flag.** `obviously` is never used; `clearly` / `trivially` are all defensible.

### Other red flags found

1. **Year ambiguity for GTD23.** `shb-cycling-lyapunov-nogo/proof.md:25` says "Goujaud–Pedregosa 2022, Thm 3" — the year **2022** appears nowhere else; arXiv:2307.11291 is **2023**. Combined with the Pedregosa hallucination this is a *double error* on a single line. Replace with "Goujaud–Taylor–Dieuleveut 2023, Thm 3".

2. **Authors/year inconsistency**: OP-2 v4 mixes "Goujaud–Pedregosa–Taylor 2023" (L154, L666) and "Goujaud–Pedregosa–Taylor (2023, Remark 6.1)" (L666). The "2025" suffix in `shb-no-acceleration-restricted/{problem,report}.md` ("Goujaud-Pedregosa-Taylor 2023/2025") refers to the journal (Math. Prog.) version of the same arXiv paper — NOT a separate paper. This is OK once authors are corrected, but could confuse a referee. Recommend writing it as "Goujaud–Taylor–Dieuleveut 2023 (Math. Prog. 2025)".

3. **Title-case drift**: `shb-no-acceleration-restricted/{proof,problem}.md` titles say "Stochastic Heavy Ball" (Title Case); `direction_1_zero_momentum.md:11` says "stochastic heavy-ball" (lowercase, hyphenated). Pick one.

4. **`direction_1_zero_momentum.md:11`** writes "Goujaud K=3 cycling function" without attribution. Any technical reader would expect the GTD23 reference at first appearance — add the citation.

5. **Hyphen vs en-dash**: OP-2 v4 mixes "Goujaud–Pedregosa–Taylor" (en-dash, L86, L152) and "Goujaud-Pedregosa-Taylor" (hyphen, used in `shb-no-acceleration-restricted/{problem,notes,report}.md`). Standardize when doing the global replace — recommend en-dash form in prose (TeX `--`), kebab-case in folder names.

---

## Final verdict

| Category | Count | Severity |
|---|---|---|
| Pedregosa / GPT23 hallucinations to fix | **~31 occurrences across ~9 files** in scope (more outside scope: RESEARCH_INDEX.md, op2_clean.tex, polyak-ruppert/, literature_crosscheck/, discovery_reports/, failure_*) | **CRITICAL — show-stopper** |
| Title/headline "last iterate" qualifier missing | **8 file titles + 1 OP-2 v4 title + abstract** | **HIGH — Li Xiao feedback (a) not fully reflected** |
| Initialization-sensitivity ambiguity in OP-2 v4 §0.5 | 1 line (L101) | **MEDIUM — add 1-sentence note** |
| Non-SC explanation via Claim 2.12 | OK, no fix | — |
| Cesaro vs Cesàro stragglers | 1 quotation (intentional) + 1 stray | LOW |
| SHB capitalization drift | 2 distinct conventions | LOW |
| $\eta_T$ vs $\eta(T)$ | 1 stray ($\eta(T)$ in `d2_explorer_4`) | LOW |
| Year typo "2022" in `shb-cycling-lyapunov-nogo/proof.md:25` | 1 occurrence | MEDIUM (double error with author hallucination) |
| Title case drift "Stochastic Heavy Ball" vs "stochastic heavy-ball" | 2 conventions | LOW |
| obviously/clearly/trivially red flags | 11 hits, all justified | OK |
| AI-Agent / first-person / PEP-leak | 0 issues | OK |

### Summary numbers
- **N hallucinations / residuals to fix: ~31 Pedregosa occurrences + 1 year typo (2022→2023) + 1 missing GTD23 attribution in `direction_1_zero_momentum.md:11` = 33 critical residuals**
- **N terminology fixes: ~10** (Cesàro, SHB caps, η_T notation, title-case drift, hyphen/en-dash)
- **N quantifier ambiguities: ~10** ("last iterate" missing in 8 file titles + OP-2 v4 title + 1 OP-2 §0.5 init clarification)

### Pre-peer-review action list (in priority order)
1. **GLOBAL FIND-AND-REPLACE**: "Goujaud-Pedregosa-Taylor" → "Goujaud-Taylor-Dieuleveut", "Goujaud–Pedregosa–Taylor" → "Goujaud–Taylor–Dieuleveut", "Goujaud–Pedregosa" → "Goujaud–Taylor–Dieuleveut", "GPT23" → "GTD23". Run across **all** files (scope + RESEARCH_INDEX.md + op2_clean.tex + polyak-ruppert + literature_crosscheck + discovery_reports + failure_patterns + failure_triggers + workspace/op2_*).
2. Fix `shb-cycling-lyapunov-nogo/proof.md:25` "2022" → "2023" while doing the rename.
3. Insert "last iterate of" or "(last-iterate)" qualifier into:
   - `op2_downgraded_proof_v4.md` title (L1).
   - `op2_downgraded_proof_v4.md` §0.5 right after the Main Theorem boxed inequality (L105).
   - `shb-no-acceleration-restricted/{problem,proof,notes,report}.md` titles (L1).
   - `direction_1_zero_momentum.md` title (L1) and theorem (L11–17).
4. Add a 1-sentence note in `op2_downgraded_proof_v4.md` after L101: "Note: the initial pair satisfies $x_0 \neq x_{-1}$ (velocity-laden cycle init); the alternative $x_0 = x_{-1}$ is treated in Direction 1."
5. Standardize "Cesàro" everywhere except verbatim quotations; fix `d2_explorer_6_compositional.md:59`.
6. Standardize "Stochastic Heavy Ball (SHB)" capitalization on first use; "SHB" thereafter.
7. Standardize $\eta_T$ subscript form (fix `d2_explorer_4_reduction.md:156`).
8. Add GTD23 citation at first mention of "Goujaud K=3 cycling function" in `direction_1_zero_momentum.md:11`.

Once these are applied, the OP-2 v4 + Direction 1/2 deliverables are **defensible against expert peer-review scrutiny** (including Goujaud or Taylor or Dieuleveut themselves, who should not see their co-author misattributed, nor see Pedregosa misattributed in their stead).
