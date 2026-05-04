# Integrator Report — Spiral Knots Stress Test

Date: 2026-04-21
Pipeline: v2.2 (P0 stage). Integrator invocation #1.
Work dir: `workspace/active/ldt_spiral_knots_stress_test/`

Inputs:
- `problem.md` (Theorems 3.5 and 4.2).
- `best_proof.md` (pre-rewrite; 214 lines, 22,340 bytes) — Explorer Route A
  winning candidate with minimal Fixer touches.
- `explorer_{1,2,3}.md` (three Explorer routes; Route 1 was the winning
  candidate).
- `fixer_round1.md` (23,845 bytes; SP-3 closure via intrinsic induction in
  $B_{k+1}$: Block Structure Lemma, Lemma Q, $c_k$-recursion, three-term
  $F_k$-recursion).
- `fixer_round2.md` (15,092 bytes; SP-2 closure via universal $h_k$ scalar
  recursion; SP-4 closure via top/bot monomial sub-lemma).
- `auditor_round{1,2,3}.md` (Round 3 emitted PASS).
- `fixer_work/` (14 sympy scripts; retained, inventoried in §5).

Outputs:
- `best_proof_pre_integrator.md` (preserved snapshot of pre-rewrite
  `best_proof.md`).
- `best_proof.md` (rewritten; 528 lines, 38,741 bytes).
- `integrator_report.md` (this file).

---

## §0. Target table of contents

```
0. Overview
1. Setup: notation and convention
   1.1 Notation
   1.2 Reduced Burau generator matrices (convention §1.3) [L2]
   1.3 Sample explicit matrices B_ε
2. Burau–Alexander formula
   Step 1 — Pipeline formula [L2]
3. Eigenvalue factorization of det(I - B^q)
   Step 2 — The q-fold factorization [I]
4. Block Structure Lemma and the central identity (was SP-3; closed)
   Step 3 — Reframing the induction variable [I]
   Step 4 — Block Structure Lemma [I]
   Step 5 — Central identity F_k = t^{e_k} C_k [I]
5. Denominator cancellation (was SP-2; closed)
   Step 6 — Intrinsic identity C_k(1,t) = t^{-(e_k+k)/2} Φ_{k+1}(t) [I]
6. Assembling Theorem 3.5
   Step 7 — Combining Steps 1–6 [I]
7. Seifert genus upper bound
   Step 8 — Seifert's algorithm on the braid closure [L1]
8. Breadth of the product — monomial sub-lemma (was SP-4; closed)
   Step 9 — Structural sub-lemma on top/bot t-coefficients [I]
   Step 10 — Breadth of the product [I]
9. Genus lower bound and Theorem 4.2
   Step 11 — Alexander-polynomial genus lower bound [L2]
   Step 12 — Combining for Theorem 4.2 [I]
10. TSV cross-checks (verification record)
    10.1 TSV ground-truth lookups
    10.2 Base-case Burau checks (3_1 via two routes, 4_1)
    10.3 Out-of-TSV check: 10_123
    10.4 Central identity verified across ε, p ≤ 5 (62 cases)
    10.5 SP-2 intrinsic identity verified, p ≤ 6 (258 prefix checks)
    10.6 SP-4 monomial sub-lemma verified, p ≤ 6 (62 cases)
    10.7 Breadth check, Theorem 4.2 target cases (6 cases)
11. Citation ledger (L1 / L2 / L3 / Independent)
12. Honest self-assessment
13. Numerical-verification script roster
```

Section count after rewrite: 13 top-level + subsections; 12 numbered
Steps (1–12).

---

## §1. Obsolete content removed

| Location in old proof | Nature of obsolescence | Replacement source |
|---|---|---|
| Old Step 5 — "Define $D_k(y) := \det(I_k - y B_\epsilon^{[k]})$ (principal minors of $B_\epsilon$ in $B_p$)" | Wrong induction variable: $D_k \ne t^{e_k} C_k$ at $p=4$, $\epsilon=(+,+,+)$ (computed $D_1 = D_2 = 1$ vs. $t^{e_1} C_1 = 1 + yt$). Replaced by intrinsic $F_k := \det(I_k - y A'_k)$ with $A'_k \in B_{k+1}$. | `fixer_round1.md` §"Correct induction variable" (Step 3 of rewrite); `fixer_round1.md` §"Block Structure Lemma" (Step 4 of rewrite). |
| Old Step 5 — "Induction on $k \le p-1$ using principal-minor expansion of $B_\epsilon$" | Whole induction mechanism is wrong (principal minors of the full $B_\epsilon$ don't yield the intrinsic $C_k$). | `fixer_round1.md` §"Three-term $F$-recursion" (Step 5 of rewrite). |
| Old Step 6 — "By Step 3, $\det(I - B) = \pm t^a \Phi_p(t)$ cancels the denominator" | Stale cross-reference: old Step 3 was the $q$-fold factorization (retained, renumbered Step 2 in rewrite), which does NOT prove $\det(I-B) \doteq \Phi_p$. After Fixer Round 2, the mechanism is the universal $h_k$ scalar recursion. | `fixer_round2.md` §"Universal scalar recursion" (Step 6 of rewrite). |
| Old Step 6 — "[STEP-STUCK SP-2]" tag | Stuck point closed by Fixer Round 2. | Inlined proof in rewrite Step 6. |
| Old Step 8 (breadth) — "[STEP-STUCK SP-4]" tag | Stuck point closed by Fixer Round 2 via top/bot monomial sub-lemma. | `fixer_round2.md` §"Top/bot monomial structural sub-lemma" (Step 9 of rewrite). |
| Old Step 8 — "breadth equals $(p-1)(q-1)$, proof deferred" | Proof was in `fixer_round2.md`, not `best_proof.md`. | Rewrite Step 10 inlines full proof with the extremal-coefficient product-of-roots-of-unity argument. |
| Old Step 5 — "[STEP-STUCK SP-3: central identity induction mechanism not yet reducible to a clean recursion]" | Closed by Fixer Round 1. | Rewrite Step 5 inlines Block Structure Lemma, Lemma Q, three-term recursion. |
| Old "What remains open" bullet — "central identity induction mechanism (SP-3)" | Resolved. | Rewrite §12 "What is closed" now lists SP-3 as resolved. |
| Old "What remains open" bullet — "denominator cancellation proof (SP-2)" | Resolved. | Rewrite §12 "What is closed" lists denominator cancellation as closed. |
| Old Step 10 — cross-reference "see fixer_round_2.md for breadth" | Inlining target moved to rewrite Step 10; external reference removed. | Full inlining in rewrite §8. |

Total obsolete fragments removed: 10.

---

## §2. New content integrated

| Source (file:location) | Kind | Target section in new proof |
|---|---|---|
| `explorer_1.md` §1–§2 (Overview, Setup) | Preserved | Rewrite §0–§1 (lightly edited — reframed to reference the intrinsic $A'_k$ notation). |
| `explorer_1.md` §3 (Burau–Alexander formula) | Preserved | Rewrite §2 (Step 1). |
| `explorer_1.md` §4 (eigenvalue factorization) | Preserved with Newton's-identities gloss | Rewrite §3 (Step 2). |
| `fixer_round1.md` §"Correct induction variable" | New full section | Rewrite §4 (Step 3): reframing, including counter-example $D_1 = D_2 = 1$ vs. $1 + yt$. |
| `fixer_round1.md` §"Block Structure Lemma" (parts i, ii, iii) | New lemma + full proof | Rewrite §4 (Step 4): stated with full block-matrix form and proof of each of (i) last row, (ii) top-left $A'_k$, (iii) $c_k$ recursion. |
| `fixer_round1.md` §"Lemma Q" ($Q_k = F_{k-1}/\mu(k)$) | New lemma + proof | Rewrite §4 (Step 5) as an interior lemma inside Step 5, with full cofactor-expansion argument showing $Q_{k-1}$ terms cancel regardless of $\epsilon_k$. |
| `fixer_round1.md` §"Three-term $F_k$ recursion" | New proof | Rewrite §4 (Step 5), equation (R). |
| `fixer_round1.md` §"$\tilde C_k = C_k$" | Closing argument | Rewrite §4 (Step 5 final paragraph). |
| `fixer_round2.md` §"Rescaling $h_k = t^{(e_k+k)/2} C_k(1,t)$" | New derivation | Rewrite §5 (Step 6) first half. |
| `fixer_round2.md` §"Universal $\epsilon$-independent recursion" | Boxed identity | Rewrite §5 (Step 6) boxed equation. |
| `fixer_round2.md` §"Cyclotomic recursion identification" | Closing step | Rewrite §5 (Step 6) final paragraph. |
| `fixer_round2.md` §"Top/bot monomial sub-lemma" (full induction) | New lemma + full proof | Rewrite §8 (Step 9), with case analysis for $\epsilon_k = +1$ and $\epsilon_k = -1$. |
| `fixer_round2.md` §"Main breadth argument" | Proof | Rewrite §8 (Step 10), with the $\prod_\ell \zeta^{\ell n^\pm}$ calculation. |
| `explorer_1.md` §"Seifert upper bound" | Preserved | Rewrite §7 (Step 8). |
| `explorer_1.md` §"Alexander genus bound" | Preserved | Rewrite §9 (Step 11). |
| `explorer_1.md` §"Final assembly" | Updated for renumbered cross-references | Rewrite §9 (Step 12). |
| `explorer_1.md` §"TSV cross-checks" | Preserved + extended with Fixer additions | Rewrite §10 (10.1–10.7). Added 10.4 (Fixer R1 62 cases), 10.5 (Fixer R2 258 prefix checks), 10.6 (Fixer R2 62 monomial cases). |
| `auditor_round3.md` — "verified PASS on combined artifact" | Meta | Noted in rewrite header. |
| `fixer_round{1,2}.md` script references → `fixer_work/` | Script roster | Rewrite §13: 8+ script names, cases-per-script counts. Tags to be added in P1 retroactive pass. |

Total new/integrated fragments: 17.

---

## §3. Citation ledger (before → after)

| Citation tier | Before (explorer) | After (integrated) | Notes |
|---|---|---|---|
| L1 | ~6 items | ~10 items | Added: cyclotomic recursion (Step 6); last-row-preservation of matrix product (Step 4 part (i)); column linearity (Steps 5, 6); sum $\sum \ell = q(q-1)/2$ + $\zeta^{q(q-1)/2} = (-1)^{q-1}$ (Step 10). |
| L2 | 3 items | 3 items | Unchanged: Burau–Alexander formula; Alexander genus bound; Birman–Weinberg reduced-Burau generator convention §1.3. |
| L3 | 0 items | 0 items | Unchanged. |
| Independent | 6 items | 12 items | Added: Block Structure Lemma (Step 4); $c_k$-recursion (Step 4); cofactor expansion of $F_{k+1}$ (Step 5); Lemma Q (Step 5); three-term $F_k$-recursion (Step 5); universal $h_k$ recursion (Step 6); top/bot monomial sub-lemma (Step 9); main breadth argument via roots-of-unity product (Step 10); reframing $D_k \to F_k$ (Step 3). |
| Independent/Citation ratio | ~6:9 | ~12:13 | Healthier ratio; STRUCTURAL-CITATION-WARNING does not fire (threshold at Independent ≤ L3 + ¼ L2). |

---

## §4. Cross-reference fixups

| Old pointer | Old target (in pre-integrator proof) | New pointer / target |
|---|---|---|
| "By Step 3" (in old Step 6) | $q$-fold factorization (old Step 3) — did NOT prove $\det(I - B) \doteq \Phi_p$ | Replaced by "By Step 5 at $y = 1$" and full inline proof (rewrite Step 6). |
| "By Step 5, $F_k = t^{e_k} C_k$" (in old Step 7) | Old Step 5 proved this via wrong $D_k$ induction | Retained pointer; new Step 5 now proves it correctly via intrinsic $A'_k$. |
| "By Step 7" (in old Step 9) | Old Step 7 = Theorem 3.5 assembly | Retained; renumbering stable. |
| "See fixer_round_2.md for breadth" (old Step 10) | External reference | Removed; full proof inlined as new Step 10. |
| "[STEP-STUCK SP-2]" (old Step 6) | Stuck-point tag | Removed; section retitled "Denominator cancellation (was SP-2; closed)". |
| "[STEP-STUCK SP-3]" (old Step 5) | Stuck-point tag | Removed; section retitled "Block Structure Lemma and the central identity (was SP-3; closed)". |
| "[STEP-STUCK SP-4]" (old Step 8) | Stuck-point tag | Removed; section retitled "Breadth of the product — monomial sub-lemma (was SP-4; closed)". |
| "Step 8" (as breadth section, old numbering) | Old Step 8 | Renumbered to Steps 9–10 in rewrite (sub-lemma + main breadth). |

Total cross-ref fixups: 8. All "By Step N" references in the rewrite
verified to point to extant steps with the cited content.

---

## §5. Verification-script roster

P1's Verified Sympy Block protocol is NOT yet in force at the time of
this Integrator invocation. Scripts are listed by filename and current
location; tags will be added in the P1 retroactive pass (Task #5).

| Script (in `fixer_work/`) | Origin | Cases claimed | Coverage |
|---|---|---|---|
| `verify_p5.py` | Fixer R1 | 16 | Central identity at $p = 5$ (all $\epsilon$). |
| `verify_Ek.py` | Fixer R1 | 62 | Central identity for every prefix $\epsilon_{1..k}$, $p \le 5$. |
| `check_recursion.py` | Fixer R1 | ~10 | Three-term $F_k$-recursion (R) for selected 5-prefix chains. |
| `find_Qk.py` | Fixer R1 | 11 | Lemma Q: $Q_k = F_{k-1}/\mu(k)$. |
| `sp2_verify_phi_p.py` | Fixer R2 | 62 | $\det(I - B_\epsilon) \cdot t^{(p-1-e)/2} = \Phi_p(t)$, $p \le 6$. |
| `sp2_Ck_at_y1.py` | Fixer R2 | 258 | Intrinsic identity $C_k(1,t) = t^{-(e_k+k)/2} \Phi_{k+1}$, all prefixes $p \le 6$. |
| `sp4_breadth.py` | Fixer R2 | 62 | Main breadth $(p-1)(q-1)$ check. |
| `sp4_monomial.py` | Fixer R2 | 62 | Top/bot monomial sub-lemma. |
| `sp4_topbot.py` | Fixer R2 | ≥ 62 | Same sub-lemma, cross-check script. |
| `characterize_structure.py` | Fixer R1 (exploration) | — | Exploratory; not a direct verification script. |
| `explore_embedding.py` | Fixer R1 (exploration) | — | Exploratory. |
| `explore_structure.py` | Fixer R1 (exploration) | — | Exploratory. |
| `find_ck.py` | Fixer R1 (exploration) | — | Found $c_k$-recursion empirically before proof. |
| `sp2_sp4_final.py` | Fixer R2 (integration check) | — | Final cross-check. |
| `sp2_unreduced_burau.py` | Fixer R2 (exploration) | — | Compared unreduced vs. reduced Burau. |

Total: 15 files in `fixer_work/`. Of these, 9 carry direct verification
claims; 6 are exploratory. P1 will triage and retain only the 9
protocol-compliant scripts under `verify/` with `[VERIFIED-SYMPY:...]`
tags; the exploratory 6 will remain in `fixer_work/` as historical
artifacts.

---

## §6. Residual gaps

None identified during integration. Specifically:

- No irreconcilable conflicts between Fixer Rounds 1 and 2 (they address
  disjoint stuck points: R1 → SP-3; R2 → SP-2 and SP-4).
- No Auditor correction left un-encoded: `auditor_round3.md` emitted PASS
  without demanding new patches, and `auditor_round{1,2}.md`'s minor
  corrections (notation tightening, indexing clarifications) were all
  already absorbed into `fixer_round{1,2}.md`.
- No undefined symbol introduced by the rewrite. Every new symbol
  ($A'_k$, $F_k$, $c_k$, $Q_k$, $h_k$, $\kappa$, $n_k^\pm$) is defined
  in §1 or introduced at first use with an explicit "Let ..." or
  "Define ...".
- No stuck-point tag `[STEP-STUCK SP-N]` remains in the rewrite body.
  (SP-1 "tridiagonality is false" is preserved as a *correction*, not a
  stuck point — see Overview and §1.3.)
- Final conclusion matches problem.md §Theorems 3.5 and 4.2 exactly
  (verified by direct textual comparison).

Honest caveat: the sub-lemma proofs (Block Structure, Lemma Q, monomial
sub-lemma) are transcribed from Fixer files rather than re-derived by
the Integrator; this is correct per Rule I (no invention) and the
earlier Auditor rounds have verified their correctness. The Integrator's
contribution is structural, not mathematical.

---

## Integrator rule-compliance log

- **Rule I (do not invent)**: every claim traces to a documented source
  (Explorer or Fixer file). No new mathematics introduced.
- **Rule II (preserve tags)**: [I], [L1], [L2] tags preserved on every
  corresponding step in the rewrite. [L3] tags: none exist. Stuck-point
  tags removed per §1 and §6.
- **Rule III (conflict resolution by recency)**: Fixer Round 2 > Fixer
  Round 1 > Explorer Route 1. Applied at Step 5 ($D_k \to F_k$ per R1)
  and Step 6 (stale "By Step 3" → $h_k$ mechanism per R2).
- **Rule IV (cross-refs)**: §4 above documents all 8 pointer updates.
- **Rule V (inline, don't footnote)**: Block Structure Lemma, Lemma Q,
  top/bot monomial sub-lemma all inlined as full statements with proofs.
  No "see fixer_round_N.md" references remain.
- **Rule VI (Explorer honesty preserved)**: non-tridiagonality of
  $B_\epsilon$ at $p = 4$ (SP-1 correction) retained as a standalone
  paragraph in the Overview and §1.3.
- **Rule VII (verification artifacts citable)**: §13 and §5 above list
  all scripts with cases counts; full `[VERIFIED-SYMPY:...]` tagging
  deferred to P1 retroactive pass.
- **Rule VIII (update honest self-assessment)**: §12 "What is closed"
  updated to list SP-2, SP-3, SP-4 as resolved; "What remains open"
  reduced to "Nothing within the scope of Theorems 3.5 and 4.2."

All reliability rules satisfied. Rewrite is ready for
`integration_check`.
