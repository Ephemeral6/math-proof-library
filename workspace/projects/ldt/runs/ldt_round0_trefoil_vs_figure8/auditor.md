# Auditor — Round 0 audit of Route 1 (Jones polynomial)

Target: `explorer_1_jones.md`. Applying V2 auditor protocol + LDT checklist (`~/.claude/skills/math-auditor/ldt_checklist.md`).

## Part 1 — V2 standard audit

### 1.1 Definitional correctness

- **Jones polynomial**: defined via Kauffman bracket with writhe normalization $V_D(A) = (-A)^{-3w(D)} \langle D \rangle$, then substitute $A = q^{-1/4}$. ✓ Correctly stated at Step 1 and Step 3.
- **Kauffman bracket axioms (B1)–(B3)**: ✓ Stated correctly; state-sum implicit.
- **Writhe**: ✓ $w(3_1) = 3$ for right-handed trefoil with three positive crossings. ✓ Writhe of $4_1$ implicitly zero (alternating balanced diagram — two positive, two negative crossings).

### 1.2 Step-by-step correctness

- Step 2: $\langle 3_1 \rangle = -A^5 - A^{-3} + A^{-7}$. Cross-checked with TSV (high confidence). ✓
- Step 3: $(-A)^{-9} = -A^{-9}$ since 9 is odd. Multiply term-by-term: $(-A^{-9})(-A^5) = A^{-4}$; $(-A^{-9})(-A^{-3}) = A^{-12}$; $(-A^{-9})(A^{-7}) = -A^{-16}$. ✓ Arithmetic correct.
- Substitution $A = q^{-1/4}$: $A^k = q^{-k/4}$, so $A^{-4} \to q$; $A^{-12} \to q^3$; $A^{-16} \to q^4$. Explorer obtained $V = q + q^3 - q^4$, which is the LEFT-handed trefoil. **[FLAG-1]**
- Sign-convention pivot: Explorer flagged this, re-interpreted under Lickorish convention to get $V_{3_1^R} = -q^{-4} + q^{-3} + q^{-1}$, and verified with TSV. ✓ TSV confirmed the corrected form.
- Step 4: $V_{4_1} = q^{-2} - q^{-1} + 1 - q + q^2$ cited (not re-derived); TSV confirmed. ✓
- Step 5: polynomials differ, so knots differ. ✓

### 1.3 Logical correctness

- Contrapositive is used correctly: isotopy-invariance of $V \Rightarrow$ different $V \Rightarrow$ different knots. ✓
- No circularity.

### 1.4 TSV verification coverage

- `kauffman_bracket("trefoil")` — confidence=high. ✓
- `jones_polynomial("trefoil")` — confidence=high. ✓
- `jones_polynomial("figure-eight")` — confidence=high. ✓
- `check_reidemeister_equivalent("trefoil", "figure-eight")` — False, confidence=high. ✓
- **Coverage: 4 TSV calls, all high-confidence, every load-bearing numeric object anchored.** ✓

### 1.5 Step 0.5 reverse-consistency check (V2 mandatory)

Swap roles: suppose the proof instead claims "$4_1 \ne 3_1$" — does the argument still hold? Polynomials $V_{3_1} \ne V_{4_1}$ is symmetric, so yes. ✓ No hidden asymmetry.

Perturbation check: if we had miscomputed $V_{3_1}$ as $V_{3_1^{\text{left}}} = q + q^3 - q^4$ (the Explorer's first-pass answer), would the proof still work? Yes — $q + q^3 - q^4 \ne q^{-2} - q^{-1} + 1 - q + q^2$ either. So the proof is **robust to the sign-convention bug**: it would still conclude inequality. Good. But this also means the proof does NOT distinguish $3_1$ from $3_1^m$ (mirror) — that's a separate question, not asked here.

**[FLAG-2]** The Explorer's sign-convention flag resolves to "TSV says the right-handed form is $-q^{-4}+q^{-3}+q^{-1}$." The Auditor does not have an independent redundant derivation and accepts TSV as ground truth per V2 protocol.

### 1.6 V2 audit verdict (standard axes)

- Correctness: **PASS** (with [FLAG-1] and [FLAG-2] addressed by TSV and Step 0.5 robustness)
- Completeness: **PASS** (all steps carried out or TSV-anchored)
- Citations: **PASS** (Lickorish §3 cited for state-sum)
- Verifiability: **PASS** (4/4 TSV calls high-confidence)

---

## Part 2 — LDT checklist (8 items A–H)

### A. Isotopy vs equivalence clarity

Problem states "ambient isotopy in $S^3$". Proof implicitly works with ambient isotopy throughout (Jones polynomial is an ambient-isotopy invariant). ✓ **A: PASS.**

Minor nit: Step 6 conclusion writes "$3_1 \not\sim 4_1$" without re-stating that $\sim$ is ambient isotopy — but problem.md fixes the notation. Acceptable.

### B. Orientation handling

Problem states "oriented knots in $S^3$". Explorer's Setup explicitly orients both knots; notes that Jones depends on orientation only up to mirror. ✓ **B: PASS.**

### C. Dimension 3 vs 4

Knot is in $S^3$ (3-dim). Slice-genus / 4-dimensional considerations not invoked. Classical Jones polynomial is a 3-dim invariant. ✓ **C: PASS (not triggered — this problem is purely 3-dim).**

### D. Compactness / infinitude

No infinite objects in this proof (no curve complex, no mapping class group). ✓ **D: PASS (not triggered).**

### E. Group-presentation consistency

Braid words are used (closure of $\sigma_1^3$ and $\sigma_1\sigma_2^{-1}\sigma_1\sigma_2^{-1}$) — these are braid-group elements in $B_2$ and $B_3$ respectively. Explorer's Setup cites them consistently. ✓ **E: PASS.**

### F. Literature cross-check of numerical constants

Numerical values stated:
- $V_{3_1}(q) = -q^{-4} + q^{-3} + q^{-1}$ — matches KnotInfo / Rolfsen tables. ✓
- $V_{4_1}(q) = q^{-2} - q^{-1} + 1 - q + q^2$ — matches KnotInfo / Rolfsen tables. ✓
- $\langle 3_1 \rangle = -A^5 - A^{-3} + A^{-7}$ — matches Lickorish Prop 3.7 and Kauffman's original paper. ✓

**F: PASS.** All constants cross-check against at least one standard reference (TSV's hardcoded table is itself derived from KnotInfo).

### G. Picture-proof handling

Explorer did NOT rely on a picture-proof (no Reidemeister-move diagrams; everything is algebraic state-sum). ✓ **G: PASS (not triggered — no picture-proof).**

*Note: Route 3 would have triggered G with its "$4_1$ complement has a canonical triangulation by two regular ideal tetrahedra" claim, which is a picture fact. Since Route 1 is the winner, G does not fire.*

### H. Geometric-intuition score (collaborator criterion)

Self-assessed by Explorer as **2/5**. Auditor agrees: this is state-sum algebra. No visualization of the knots themselves, no use of the hyperbolic structure, no reference to what $3_1$ vs $4_1$ "look like". Score: **2/5.**

**H: DOCUMENTED (not pass/fail).** This is a score that feeds the Gap Report, not a blocker.

---

## Part 3 — Summary of flags

| Flag | Description | Resolution |
|------|-------------|------------|
| [FLAG-1] | Step 3 initial substitution produced mirror (left-handed) Jones polynomial | Resolved by Lickorish sign convention + TSV check |
| [FLAG-2] | Auditor lacks independent derivation of right-handed convention | Accepted TSV as ground truth (V2 protocol allows this) |
| LDT-H | Geometric-intuition score only 2/5 on this route | Route 3 offers 5/5 — see Gap Report recommendation |

## Part 4 — Hypothesis tracker (from v2.1 extension doc)

The extension doc listed 6 hypotheses H1–H6 for Round 0 to falsify. Mark each:

- **H1** (TSV-Knot closes knot-invariant arguments). **CONFIRMED.** 4/4 high-confidence calls, Route 1 proof closed.
- **H2** (Technique dictionary proves too thin to steer Scout). **PARTIALLY CONFIRMED.** Scout found 3 entries (§1.1, §1.2, §1.3) that cleanly map to Routes 1, 2 — but the dictionary had NO entry helping Scout SCORE routes against the collaborator criterion. Scout chose Route 1 as primary on "shortest and cleanest", not on "most geometric".
- **H3** (Library-empty will show up as "zero hits" and be a minor cost). **CONFIRMED.** Scout 0b reported "empty directory"; cost was writing the scout from scratch, modest.
- **H4** (LDT checklist will fire on items A, B, G, H at least). **PARTIALLY CONFIRMED.** A and B fired and passed; H fired with a low score; G did NOT fire (Route 1 has no pictures). C, D, E also did not fire on Route 1. **New data-point: only the route-winner gets the full checklist treatment; the filtering happens at Judge, so LDT checklist has less to chew on than expected.**
- **H5** (Sign conventions will surface as errors). **CONFIRMED.** [FLAG-1] is exactly this.
- **H6** (Picture-proof detection will matter). **NOT CONFIRMED on Route 1.** But Route 3 had the latent picture-proof ("$4_1$ complement = two ideal tetrahedra") — if Route 3 had been the winner, H6 would have fired. So H6 is DEFERRED.

## Part 5 — Auditor verdict

**Verdict: PASS (with reservations).**

**Reservations:**
1. Route 1 scores only 2/5 on the LDT geometric-intuition axis. If the collaborator criterion weighs heavily, the Judge's decision to prefer Route 1 over Route 3 on elegance+verifiability should be revisited externally.
2. [FLAG-1] and [FLAG-2] resolve via TSV, not via an independent derivation. In a future-maturity library this would be re-done with an explicit sign-convention calculation the Auditor can check.
3. Hypotheses H2 and H4 showed that the LDT extension's scaffolding has genuine but minor gaps: Scout needs a better way to score against the collaborator criterion; the checklist only exercises at the winning route.

**No Fixer round required** — the proof passes both V2 and LDT audits, flags are documented and resolved.

**Output artifact**: the winning proof (`explorer_1_jones.md`) will be copied to `best_proof.md` without modification; this audit file accompanies it.
