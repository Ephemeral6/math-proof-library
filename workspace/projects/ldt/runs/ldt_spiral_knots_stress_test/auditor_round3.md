# Auditor — Round 3 (post Fixer Round 2) — FINAL

## Scope

Audit of combined artifact: `best_proof.md` + `fixer_round1.md` (SP-3) + `fixer_round2.md` (SP-2, SP-4).

## Step 0.5 — Reverse-consistency

**Problem claims**: Theorem 3.5 formula + Theorem 4.2 genus $(p-1)(q-1)/2$.

**Proof status**: both claims closed unconditionally (modulo standard L1/L2
citations — Burau–Alexander formula, Rolfsen breadth bound, Seifert algorithm).

**Consistency**: PASS. No overreach; quantifiers match.

## Round-3 delta

| Stuck point | Round 1 | Round 2 | Round 3 |
|---|---|---|---|
| SP-1 (tridiag falsified) | Correction | — | Not a gap |
| SP-2 (Burau denom $\doteq \Phi_p$) | MEDIUM open | **CLOSED** via $h_k = (1+t)h_{k-1} - t h_{k-2}$ | Audited — OK |
| SP-3 (general-$p$ identity) | **CLOSED** via Block Structure + Lemma Q | — | Audited — OK |
| SP-4 (breadth $(p-1)(q-1)$) | MEDIUM open | **CLOSED** via top/bot monomial sub-lemma + root-of-unity non-cancellation | Audited — OK |

## Audit of Fixer Round 2

### SP-2 closure

Claim: $C_k(1,t) = t^{-(e_k+k)/2}\Phi_{k+1}(t)$ (intrinsic, so SP-2 follows by $k=p-1$).

**Proof audited**:
- Change of variable $h_k := t^{(e_k+k)/2} C_k(1,t)$.
- $C_k$-recursion at $y=1$ transforms to **$\epsilon$-independent** $h_k = (1+t)h_{k-1} - t h_{k-2}$.
  Verified: $\mu(k)^2/t + 1 = 1 + t^{-\epsilon_k}$ and the $t$-power prefactor
  cancels the $\epsilon_k$-dependence; $\mu(k-1)\mu(k)/t$ combined with its
  prefactor collapses to $t$ regardless of signs. Algebraic step-by-step
  check is correct.
- Cyclotomic recursion $\Phi_{k+1} = (1+t)\Phi_k - t\Phi_{k-1}$ is a 2-line
  textbook identity. **OK, L1**.
- Base cases $h_0 = \Phi_1 = 1$, $h_1 = \Phi_2 = 1+t$ for both signs — verified.
- Numerical: 258 prefix checks for $p \le 6$ — **OK**.

### SP-4 closure

Structural sub-lemma: top/bot $t$-coefs of $C_k(y,t)$ are monic monomials
$y^{n_k^+}$ at $t^{n_k^-}$ and $y^{n_k^-}$ at $t^{-n_k^+}$.

**Proof audited**:
- Induction on $k$ with $C_k = A \cdot C_{k-1} - B \cdot C_{k-2}$.
- Careful case-split on $\epsilon_k = \pm$ and $\epsilon_{k-1} = \pm$.
- Key check: in each case, the $B \cdot C_{k-2}$ term's top (resp. bot) $t$-power
  is **strictly less** (resp. **strictly greater**) than $A \cdot C_{k-1}$'s,
  so no cancellation at extremes. Arithmetic verified.
- Numerical: 62/62 sign-patterns for $p \le 6$ — **OK**.

Main breadth argument:
- $\prod_{\ell=1}^{q-1} \zeta^{\ell n^\pm} = \zeta^{n^\pm q(q-1)/2} = (-1)^{n^\pm(q-1)} \in \{\pm 1\}$.
- Top-coef product and bot-coef product are both $\pm 1 \ne 0$, so no cancellation.
- breadth $= (q-1)(n^+ + n^-) = (p-1)(q-1)$. **OK**.

## Citation ledger (cumulative, all rounds)

| Tag | Count | Break-out |
|---|---|---|
| L1 | 10 | Seifert alg; $\chi \to g$; unit $t^k$; polynomial factorization; row-preservation; block inspection; Laplace; column-linearity; cyclotomic recursion; Laurent breadth |
| L2 | 4 | Burau–Alexander formula; $2g \ge \deg\Delta$; reduced Burau generator matrices; Burau → Alexander on closure |
| L3 | **0** | — |
| Independent | ≥ 12 | Eigenvalue factorization; non-tridiagonality discovery; Block Structure Lemma; Lemma Q; $c_k$ recursion; identity cancellation; base-case anchoring; SP-2 scalar recursion; SP-4 top/bot sub-lemma; main breadth; breadth → lower genus; full assembly |

**STRUCTURAL-CITATION-WARNING**: does NOT fire. Ratio Independent : L1+L2 is
~12 : 14 ≈ 0.86, with 0 L3.

## LDT-specific audit items

| Item | Verdict | Note |
|---|---|---|
| A. Isotopy | OK | Δ-equivalence up to $\pm t^k$ throughout. |
| B. Orientation | OK | Positive-crossing Artin convention applied consistently. |
| C. Dimension | OK | 3-dim throughout; no 4-ball or $n$-manifold mixing. |
| D. Compactness | OK | Algebraic closure for Jordan form only. |
| E. Group pres. | OK | Standard Artin. |
| F. Literature | OK | All citations at L1/L2; both L2's are Birman 1974 / Rolfsen. |
| F2. Citation depth | OK | 0 L3. |
| G. Picture-proof | OK | Step 7 Seifert-circle count: verifiable by direct enumeration, 30-s check. |

## Geometric Intuition Assessment

**Score: 3/5** (unchanged from Round 1). Proof is algebraic-primary with one
load-bearing geometric step (Seifert's algorithm → $\chi \to g$ upper bound).
Not 4/5 — no hyperbolic structure, no linking-form geometry. Not 2/5 — the
Seifert surface construction is real work even though citable.

## Evidence Field (Axis 5, Fix-3)

Unchanged: 6/10 × 1.5 = 9/15 cap.
- Load-bearing step: Step 7 (Seifert's algorithm on braid closure).
- Operation: $s = p$ circles + $c = (p-1)q$ bands → $\chi = p - (p-1)q$ → $g = (p-1)(q-1)/2$.
- If removed: YES — replaceable by "closure of positive braid on $p$ strands
  with $c$ crossings has Seifert genus $(c-p+1)/2$" (L1 textbook).

## Verdict

**PASS**.

Both theorems closed unconditionally modulo standard L1/L2 citations. Zero L3
citations. No VOCABULARY-BLUFF, no STRUCTURAL-CITATION-WARNING. TSV discipline
clean (3/3 in-scope verified; $10_{123}$ out-of-scope tagged honestly).

The proof now stands as: **Theorem 3.5 and Theorem 4.2 are proved for all
$p \ge 2$, $q \ge 1$, $\epsilon \in \{\pm 1\}^{p-1}$ with $\gcd(p,q) = 1$
(the braid-closure-is-a-knot condition), using only textbook-level external
facts (Burau–Alexander formula, Rolfsen breadth bound, Seifert's algorithm),
plus ≥12 independent reasoning steps including the central identity
$\det(I - yB_\epsilon) = t^{e(\epsilon)} C_{p-1}(y,t)$ (Block Structure
Lemma + Lemma Q), the intrinsic $C_k(1,t) = t^{-(e_k+k)/2}\Phi_{k+1}(t)$,
and the top/bot monomial breadth sub-lemma.**

Pipeline converged in 2 Fixer rounds (of 3 allowed). No forced convergence.
