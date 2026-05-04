# Auditor — Round 1 (Route A / best_proof.md)

## Step 0.5 — Reverse-consistency (problem vs. proof conclusion)

**Problem claims**:
1. Theorem 3.5: $\Delta_{S(p,q,\epsilon)}(t) \doteq \prod_{\ell=1}^{q-1} C_{p-1}(e^{2\pi i \ell/q}, t)$.
2. Theorem 4.2: $g(S(p,q,\epsilon)) = (p-1)(q-1)/2$.

**Proof's quantitative conclusion**: Theorem 3.5 reached **modulo SP-2, SP-3,
SP-4** (general-$p$ induction of the key identity; Burau-denominator
cancellation; breadth-no-cancellation). Theorem 4.2 upper bound closed;
lower bound closed modulo SP-4. Formula exhaustively verified for $p \le 4$
(14 cases) and for one $p=3, q=5$ case ($10_{123}$).

**Consistency**: Proof conclusion is a **strict subset** of the problem's
claim (conditional on three named gaps). No overreach. **PASS Step 0.5**
at the "partial with stated gaps" level.

---

## Audit Report (V2 items)

### V2 Pattern 1 — Missing quantifiers / universal claims
- OK. All claims quantified: "for every $p \ge 2$, $q \ge 1$, $\epsilon \in
  \{\pm 1\}^{p-1}$ with closure a knot".
- The exhaustive verification at $p \le 4$ is correctly flagged as "not a
  proof for general $p$"; the Explorer did not claim universality from the
  14 cases.

### V2 Pattern 2 — Constant tracking
- L1 citation "$\chi(F) = p - (p-1)q$" traced explicitly. Euler char →
  genus conversion verified against the problem's $(p-1)(q-1)/2$.
- $t^{e(\epsilon)}$ unit factor in Step 5 is a concrete constant
  (element of $\mathbb{Z}$), tracked through the assembly in Step 6.

### V2 Pattern 3 — Convention mismatch (Fix-1 domain)
- Burau convention §1.3 (Birman–Weinberg) cited and applied consistently.
- $\mu(i) \in \{1, t\}$ from problem statement is NOT explicitly
  related to the Burau generator sign — the proof treats them
  independently. The identity $\det(I - yB) = t^{e(\epsilon)} C_{p-1}(y,t)$
  *computationally* ties them together, but the conceptual bridge is
  absent. **FLAG: MEDIUM** — the proof is correct (verified in 14 cases)
  but the exact origin of the $\mu$-convention in the Burau matrix is
  not derived; it's observed post hoc.

### V2 Pattern 4 — Literature cross-check
- Citations to Birman (1974) and Rolfsen / Lickorish are standard.
- Burau-denominator cancellation (SP-2) cites "standard consequence of
  reduced/unreduced Burau" without naming a specific textbook section.
  **FLAG: LOW** — attributable to a 10-minute textbook search, not a
  research-program fetch.

### V2 Cross-Verification (TSV)
- 3/3 in-scope base cases verified via `tsv_knot.alexander_polynomial`
  (Fix-1-post). All matches.
- $10_{123}$ (out-of-scope): tagged `method=none, confidence=low,
  reason=out-of-TSV-scope` correctly. Explorer did NOT attempt to bluff
  a TSV result. **PASS** — model TSV discipline.

---

## LDT-Specific Audit

| Item | Verdict | Note |
|------|---------|------|
| A. Isotopy vs. equivalence | OK | Only uses "closure is a knot" and $\Delta$-equivalence up to $\pm t^k$. No ambient/regular isotopy ambiguity. |
| B. Orientation | OK | Braid $\sigma_i$ positive crossings per convention §1.2; no mirror invoked. |
| C. Dimension | OK | 3-dim throughout (Seifert surface in $S^3$, no 4-ball genus). |
| D. Compactness / infinitude | OK | Uses algebraic closure $\bar{\mathbb{Q}(t)}$ for Jordan form; no topological compactness claim. |
| E. Group presentation | OK | Standard Artin presentation of $B_p$. |
| F. Literature cross-check | FLAG-LOW | SP-2 attribution to "standard Burau consequence" is vague; see V2 Pattern 4. |
| F2. Citation-depth (L1/L2/L3) | OK | 0 L3, 4 L2, 3 L1, ≥ 6 Independent. STRUCTURAL-CITATION-WARNING does NOT fire. |
| G. Picture-proof handling | OK | Step 7a's "braid-closure Seifert-circle" count is a picture argument but verifiable by direct oriented-smoothing enumeration; it is a 30-s verify per problem.md §8. Step 5's "multiplication by $\sigma_k^{\pm 1}$ modifies only last two columns" is an algebraic argument on matrix entries, verified in 14 cases. 0 unverifiable picture steps. |

### Geometric Intuition Assessment

**Score: 3/5**

Rationale: Route A is *primarily algebraic* — Burau matrices, eigenvalue
factorization, characteristic polynomials, polynomial breadth. The
geometric content is concentrated in Step 7 (Seifert surface from
Seifert's algorithm, Euler-char count → genus). The Explorer's honest
detection and correction of the Scout's falsified tridiagonality claim
(SP-1) shows attention to the actual matrix-structural geometry, which
nudges the score up from 2 to 3, but the proof does not lean on
hyperbolic structure, Seifert-form geometry, or any non-algebraic tool
beyond the genus upper bound. A proof scoring 4-5 would have used the
Seifert-matrix linking-number calculation (Route B's territory) or a
direct surface-theoretic argument; Route A uses Burau as a black box,
which is a valid but not-especially-geometric path.

### L3 citations used

**None.**

The proof avoids deep machinery entirely. No Heegaard Floer, no
Khovanov, no virtual-fibering, no Thurston hyperbolization, no Mostow
rigidity, no Agol/Wise, no Masur–Minsky, no 8-geometry classification.
Every external citation is L1 (textbook lookup) or L2 (single theorem
from a named source). This is a **strictly low-depth** citation profile,
and the STRUCTURAL-CITATION-WARNING is not triggered.

Citation-depth breakdown:

| Tag | Count | Examples |
|-----|-------|----------|
| L1 | 3 | Polynomial factorization $1-x^q$; Seifert's algorithm + Euler-char count; $t^k$ is a unit |
| L2 | 4 | Burau → Alexander formula; $2g \ge \deg \Delta$; reduced-Burau generator matrices (convention §1.3); Burau-denominator divisibility (SP-2 asserted from this) |
| L3 | 0 | — |
| Independent | ≥ 6 | Eigenvalue factorization (Step 2); Burau matrix computation + non-tridiagonality (Step 4); key identity discovery (Step 5, partial); assembly (Step 6); Seifert-circle count for braid closure (Step 7a); breadth argument (Step 9) |

---

### LDT-specific issues found

- **[HIGH] SP-3 general-$p$ induction incomplete.** The identity
  $\det(I - yB_\epsilon) = t^{e(\epsilon)} C_{p-1}(y,t)$ is verified
  exhaustively for $p \le 4$ (all 14 sign-vectors) but the general
  inductive proof is only sketched. The Explorer has set up the mechanism
  (last-two-column right-multiplication by $\bar\rho(\sigma_k^{\pm})$),
  but has not written out the $2 \times 2$ block-recursion explicitly.
  This is the central remaining technical gap.

- **[MEDIUM] SP-2 Burau denominator divisibility asserted, not derived.**
  $\det(I - \bar\rho(\beta)) \doteq \Phi_p(t)$ for braid-closure knots is
  a known identity (follows from the kernel of the permutation action on
  strands) but is cited without derivation. Fixable via a 5-line
  cofactor / determinant-expansion argument.

- **[MEDIUM] SP-4 breadth-no-cancellation asserted.** The claim
  "$\prod_{\ell=1}^{q-1} C_{p-1}(\zeta_q^\ell, t)$ has breadth exactly
  $(p-1)(q-1)$ in $t$" is supported by "top/bottom $t$-coefficient doesn't
  cancel" but not rigorously proved. Required for Theorem 4.2's lower
  bound. Fixable via explicit coefficient extraction from the recursion.

- **[LOW] SP-1 handled correctly.** The falsification of the Scout's
  tridiagonality claim is a positive event (Explorer honesty), not a
  remaining issue.

- **[LOW] Micro-convention drift between $\mu(i) \in \{1, t\}$ (problem
  statement) and the Burau-matrix computation.** The $t$-factor in $\mu$
  arises from the Burau convention only after right-multiplication by
  $\sigma_k^{-1}$; the proof observes this computationally but does not
  surface a conceptual bridge. Fixable with one paragraph.

### Verdict

**FIX** (not FAIL, not PASS).

The proof is substantive, TSV-grounded on all in-scope base cases, honest
about its gaps, and has zero L3 citations. However, three flagged gaps
(SP-2, SP-3, SP-4) are actual incomplete steps rather than citations,
and at least one of them (SP-3) carries the central identity connecting
Burau to $C_{p-1}$.

**Fixer instruction**: attempt to close **SP-3** via the outlined
block-cofactor induction. If the induction closes, SP-2 and SP-4 can be
deferred (they are small, localized lemmas). If SP-3 cannot be closed
within one Fixer round, downgrade to PARTIAL with honest acknowledgment;
do not force convergence.

No `[WARN: STRUCTURAL-CITATION-WARNING]` emitted. No
`[WARN: VOCABULARY-BLUFF]` emitted. The post-Fix-3 Axis-5 cap (6/10)
triggered correctly for algebraic-body-plus-one-removable-geometric-step;
the post-Fix-2 L-depth mechanism registered a healthy proof (0 L3,
plenty of Independent steps).

**Overall quality signal**: this is a genuine partial proof of a research
result, produced without access to the target paper, with the
diagnostic machinery (Fix 1, 2, 3) operating as designed. Cleanly
audited.
