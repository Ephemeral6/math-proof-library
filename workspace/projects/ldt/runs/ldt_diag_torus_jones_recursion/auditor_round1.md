# Auditor Round 1 — explorer_1_tl_markov.md

Applying `auditor.md` (V2) + `ldt_checklist.md`.

## Part 1 — V2 step-by-step

### Step 0.5 Reverse Consistency
No UB/LB/tightness. **N/A.**

### Step-by-step validity

| Step | Verdict | Comment |
|------|---------|---------|
| Setup | VALID | Ring, $d$, $TL_2$ definition correct. |
| 1 (Kauffman assignment) | VALID | Correct application of bracket skein to $\sigma_1$; $A$ coefficient on the "vertical smoothing" and $A^{-1}$ on the "horizontal smoothing" is the standard convention. |
| 2 (Markov trace identification) | **FLAG** | The Explorer asserts $\langle \hat{w} \rangle = \mathrm{tr}(\rho(w))$ without derivation, pointing to Kauffman/Jones. This is the load-bearing step — the entire reduction to algebra depends on it. Audit needs: either (a) Explorer supplies a short self-contained derivation for the 2-braid case (which is easy: $\mathrm{tr}(1) = d$ comes from closing the identity 2-tangle to two disjoint unknotted circles; $\mathrm{tr}(U) = 1$ from closing the cup–cap to a single unknotted circle); or (b) the citation is acceptable but needs to be more specific (page/section in Kauffman 1987). |
| 3 ($x^2$ computation) | VALID | Symbolic arithmetic checks: $(A + A^{-1}U)^2 = A^2 + 2U + A^{-2}U^2$, and $A^{-2} \cdot dU = (-1 - A^{-4})U$. |
| 4 (minimal polynomial) | VALID | System $\alpha A^{-1} = 1 - A^{-4}$, $\alpha A + \beta = A^2$ has unique solution $\alpha = A - A^{-3}$, $\beta = A^{-2}$.  Verified. |
| 5 (propagate recursion) | VALID | Multiplying $x^2 = \alpha x + \beta$ by $x^n$ on both sides (which is valid in any associative ring) yields $x^{n+2} = \alpha x^{n+1} + \beta x^n$. |
| 6 (apply trace) | VALID | Markov trace is $\mathbb{Z}[A,A^{-1}]$-linear, so applying to both sides of Step 5 gives the $B_n$ recursion. |
| 7 (base cases) | VALID | $B_0 = d$ and $B_1 = -A^3$ computed correctly. |
| 8 (sanity check) | VALID | $B_2 = -A^4 - A^{-4}$ matches TSV for Hopf link; $B_3 = -A^5 - A^{-3} + A^{-7}$ matches TSV for right trefoil. |

**V2 verdict**: 7 VALID, 1 FLAG (Step 2).

### Constants Tracing
Constants in the proof: $d = -A^2 - A^{-2}$, $\alpha = A - A^{-3}$, $\beta = A^{-2}$.
- $d$: traced through Steps 3, 7, 8 consistently.
- $\alpha, \beta$: introduced in Step 4, used in Steps 5, 6, 8 consistently.
- No contradiction. ✓

### Numerical Verification
The proof contains no inequalities. The recursion is a polynomial identity, not an inequality. **Rule is vacuous here.**

Secondary numerical check: Step 8's $B_2$ and $B_3$ computations match TSV. This is the one concrete numerical-consistency check, and it passes. ✓

### Cross-Verification
- `proofs/library/low-dimensional-topology/knot-invariants/kauffman-bracket-axioms.md`: compatible (Explorer uses axioms correctly).
- `proofs/library/low-dimensional-topology/knot-invariants/jones-trefoil-right.md`: $B_3$ matches this entry's $\langle 3_1 \rangle$. ✓
- `proofs/library/low-dimensional-topology/knot-invariants/jones-figure-eight.md`: irrelevant (figure-eight is not of the form $\widehat{\sigma_1^n}$ for any $n$).

No contradictions. ✓

## Part 2 — LDT Checklist

| Item | Verdict | Note |
|------|---------|------|
| A. Isotopy vs. equivalence | **OK** | "Plat closure" / "standard closure" clarified in Setup. |
| B. Orientation | **OK** (mild) | Explorer does not explicitly orient $\widehat{\sigma_1^n}$. Kauffman bracket is framing-dependent but not orientation-dependent, so this is fine, but the Explorer could state it. Sub-flag, not failing. |
| C. Dimension | **OK** (N/A) | Purely 3-dim. |
| D. Compactness | **OK** | No limits or non-compact objects. |
| E. Group presentation | **OK** | $B_2 = \langle \sigma_1 \rangle$ implicitly used; no presentation change. |
| F. Literature cross-check | **FLAG** | Step 2 cites "Kauffman 1987" and "Jones 1985" without specific theorem numbers or page references. `ldt_checklist.md` item F: "every quoted citation must cite a specific paper/theorem. If the citation is vague, flag for source verification." **This IS a vague citation.** |
| G. Picture-proof | **OK** (N/A) | No pictures. |
| H. Geometric intuition | **Score 3/5** | The proof invokes braid closure (geometric) and the Kauffman bracket (geometric), but the core derivation (Steps 3–6) is algebraic. Not name-dropping; the algebra IS load-bearing. But the Explorer does not, e.g., draw out the $\sigma_1$ crossing and its two smoothings; the assignment $(\star)$ is presented symbolically. 3/5 seems right. |

## Part 3 — Auditor summary

### Verdict: **FIX NEEDED**

Two findings:

1. **Primary (Step 2)**: the Markov-trace identification $\langle \hat{w} \rangle = \mathrm{tr}(\rho(w))$ is asserted as a black-box citation but is load-bearing and (for the 2-braid case) derivable in a few lines. Request Explorer to supply the derivation or at least a specific-theorem citation.

2. **Secondary (Item F)**: even granting the citation route, the citations lack specific theorem/page references.

### Severity
Step 2 is **not mathematically wrong** — the identification IS correct, and the base cases + numerical sanity checks in Steps 7–8 pin it down empirically. But as a self-contained proof, Step 2 is a gap: the reader must either trust the citation or look it up externally.

### Action
Send to Fixer with request: "Expand Step 2 to (a) derive $\mathrm{tr}(1) = d$ and $\mathrm{tr}(U) = 1$ from the closure pictures, and (b) justify linearity by stating that the Kauffman bracket is $\mathbb{Z}[A,A^{-1}]$-linear in each crossing resolution and hence in elements of $TL_2$. Cite Kauffman 1987, §3 specifically."
