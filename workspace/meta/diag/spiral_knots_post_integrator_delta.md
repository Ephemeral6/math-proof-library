# Spiral Knots — Post-Integrator Delta Report

Date: 2026-04-21
Stage: P0 test-case for pipeline v2.2 (Integrator extension).

## Context

External review of the 2026-04-20 spiral knots stress test
(arXiv:2506.17889, Blackwell et al.) returned verdict **B+** despite
Auditor `PASS`. The two main architectural complaints were:

1. **Step 5 used the wrong induction variable** ($D_k$ = principal minors
   of $B_\epsilon$ in $B_p$), whereas Fixer Round 1 had corrected this to
   $F_k = \det(I_k - y A'_k)$ with $A'_k$ the *intrinsic* image in the
   smaller braid group $B_{k+1}$. The archived `best_proof.md` still
   carried the wrong variable.
2. **Step 6 cited "By Step 3"** for denominator cancellation, but old
   Step 3 (the $q$-fold factorization) did not prove $\det(I - B_\epsilon)
   \doteq \Phi_p$. Fixer Round 2 replaced the mechanism with the universal
   scalar recursion $h_k = (1+t)h_{k-1} - t h_{k-2}$, which the archived
   proof did not contain.

Plus: the Block Structure Lemma, Lemma Q, and top/bot monomial sub-lemma
lived only in `fixer_round_{1,2}.md`, so a reader of `best_proof.md`
could not follow the proof end-to-end without opening 3+ files.

The P0 upgrade (Integrator role) was introduced to fix this class of
problem by rewriting `best_proof.md` for self-containment *after* the
Auditor PASSes the combined artifact.

## Size delta

| Metric | Pre-Integrator | Post-Integrator | Δ |
|---|---|---|---|
| Bytes | 22,340 | 38,741 | +16,401 (+73%) |
| Lines | 214 | 528 | +314 (+147%) |
| Words | 3,406 | 6,012 | +2,606 (+77%) |
| Top-level sections | ~9 | 13 | +4 |
| Numbered Steps | 12 | 12 | 0 (same skeleton; content per step rewritten) |
| Stuck-point tags in body | 3 ([SP-2], [SP-3], [SP-4]) | 0 | −3 |
| Inlined lemmas with full proofs | 0 | 3 (Block Structure, Q, monomial) | +3 |
| External "see fixer_round_N.md" refs | 2 | 0 | −2 |

## Section-by-section changes

| Section (rewrite) | Change type | Summary |
|---|---|---|
| §0 Overview | Lightly rewritten | Strategy bullets updated to reference the intrinsic induction $F_k$ and the $h_k$ mechanism. SP-1 (tridiagonality false) explicitly preserved. |
| §1 Setup | Expanded | §1.1 adds definitions for $A'_k, F_k, e_k, n_k^\pm$. §1.2 preserved verbatim. §1.3 now lists concrete $B_\epsilon$ matrices with the $p = 4$ counter-example to tridiagonality. |
| §2 Step 1 (Burau–Alexander) | Preserved | No change. |
| §3 Step 2 ($q$-fold factorization) | Preserved with tightening | Added explicit Newton's-identities argument for why the identity holds over $\mathbb{Z}[t, t^{-1}]$ despite being derived over an algebraic closure. |
| §4 Step 3 (reframe induction) | **NEW SECTION** | Explains why $D_k$ was wrong (concrete counter-example $D_1 = D_2 = 1$ at $p = 4$, $\epsilon = (+,+,+)$) and introduces $F_k$ as the correct variable. Not present in pre-integrator. |
| §4 Step 4 (Block Structure Lemma) | **NEW SECTION** | Inlined from Fixer R1 with full 3-part proof: (i) last row is $e_{k+1}^T$, (ii) top-left $k \times k$ block equals $A'_k$, (iii) $c_k$-recursion. Not present in pre-integrator. |
| §4 Step 5 (central identity) | **COMPLETE REWRITE** | Replaces the old $D_k$-induction (wrong) with the intrinsic $F_k$-induction. Includes Lemma Q ($Q_k = F_{k-1}/\mu(k)$) with full cofactor-expansion proof, three-term recursion (R), and the closing argument $\tilde C_k = C_k$ from initial values. |
| §5 Step 6 (denominator cancellation) | **COMPLETE REWRITE** | Old "By Step 3, ... cancels" replaced by: define $h_k = t^{(e_k+k)/2} C_k(1, t)$, prove $h_k = \Phi_{k+1}$ via the $\epsilon$-independent universal recursion $h_k = (1+t)h_{k-1} - t h_{k-2}$. |
| §6 Step 7 (Theorem 3.5 assembly) | Minor update | Cross-refs updated to new Step numbering. |
| §7 Step 8 (Seifert upper bound) | Preserved | No change. |
| §8 Step 9 (top/bot monomial sub-lemma) | **NEW SECTION** | Inlined from Fixer R2 with full induction (both $\epsilon_k = +1$ and $-1$ cases). Not present in pre-integrator. |
| §8 Step 10 (breadth of product) | **EXPANDED** | Pre-integrator had a one-paragraph "[STEP-STUCK SP-4]" placeholder. Post-integrator has the full argument using $\prod_\ell \zeta^{\ell n^\pm} = (-1)^{n^\pm(q-1)} \in \{\pm 1\}$. |
| §9 Steps 11–12 (genus lower bound, Theorem 4.2) | Preserved | No change. |
| §10 TSV cross-checks | **EXPANDED** | Pre-integrator had §§10.1–10.3 and a short breadth table. Post-integrator adds 10.4 (62 cases for central identity), 10.5 (258 prefix checks for SP-2 identity), 10.6 (62 cases for monomial sub-lemma). |
| §11 Citation ledger | **UPDATED** | Counts change from (L1=6, L2=3, L3=0, I=6) → (L1=10, L2=3, L3=0, I=12). STRUCTURAL-CITATION-WARNING status unchanged (does not fire). |
| §12 Honest self-assessment | **UPDATED** | "What is closed" now includes SP-2, SP-3, SP-4 resolutions. "What remains open" reduced to "Nothing". "Known corrections" section added explicitly documenting the tridiagonality falsification and the $D_k \to F_k$ change. |
| §13 Script roster | **NEW** | Lists 8+ verification scripts with cases counts. Not present in pre-integrator. |

## Integration check results

| Item | Verdict |
|---|---|
| C1 Source traceability | OK |
| C2 Cross-references | OK |
| C3 Citation definitions | OK |
| C4 VERIFIED-SYMPY tags | OK (trivial; P1 not yet in force) |
| C5 Definition discipline | OK |
| C6 Conclusion matches target | OK |
| C7 Stuck-point bookkeeping | OK |

**INTEGRATION-PASS on first try.** No corrective Integrator pass needed.

## Are the B+ reviewer's complaints addressed?

- **Complaint 1: Step 5 wrong induction variable ($D_k$).**
  ADDRESSED. The rewritten Step 3 now contains an explicit paragraph
  explaining why $D_k$ does not satisfy $D_k = t^{e_k} C_k$ (with a
  computed counter-example). The rewritten Step 5 uses the intrinsic
  $F_k = \det(I_k - y A'_k)$ with $A'_k \in B_{k+1}$. The full
  three-part Block Structure Lemma + Lemma Q + three-term recursion is
  present in the main body.

- **Complaint 2: Step 6 stale "By Step 3" citation.**
  ADDRESSED. The rewritten Step 6 no longer references any earlier step
  for the cancellation mechanism; it contains the full proof that
  $C_k(1, t) = t^{-(e_k + k)/2} \Phi_{k+1}(t)$ via the universal
  $\epsilon$-independent scalar recursion $h_k = (1 + t)h_{k-1} - t
  h_{k-2}$.

- **Complaint 3: self-containment.**
  ADDRESSED. The rewritten `best_proof.md` is readable end-to-end
  without opening any Fixer file. Block Structure Lemma, Lemma Q, and
  top/bot monomial sub-lemma are all inlined as numbered Steps with full
  proofs. External "see fixer_round_N.md" references have been removed
  (2 → 0).

## Residual notes

- The pre-integrator version is preserved at
  `workspace/active/ldt_spiral_knots_stress_test/best_proof_pre_integrator.md`
  as an audit trail.
- The Explorer's honest flagging of SP-1 ("tridiagonality hypothesis is
  false") is retained in the rewrite (not covered up), per Integrator
  Rule VI.
- VERIFIED-SYMPY tagging of the 9 protocol-eligible scripts in
  `fixer_work/` is deferred to the P1 retroactive pass (Task #5). After
  P1, a follow-up integration_check C4 run is expected to confirm the
  tags.

## P0 status

**P0 COMPLETE.** Integrator role introduced, applied to the spiral
knots stress test, produced a self-contained `best_proof.md` that
passes `integration_check` on first try, and addresses all three
architectural findings from the B+ external review.

Ready to proceed to P1 (Verified Sympy Block protocol).
