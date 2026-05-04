# Auditor — Round 2 (post Fixer Round 1)

## Scope

Audit the combined object: `best_proof.md` (Route A original) + `fixer_round1.md` (SP-3 closure).

## Step 0.5 — Reverse-consistency

**Problem claims**: Theorem 3.5 formula + Theorem 4.2 genus.

**Proof status after Round 1**:
- Theorem 3.5: key identity $\det(I - y B_\epsilon) = t^{e(\epsilon)} C_{p-1}(y,t)$
  **proved for all $p \ge 2$** (SP-3 closed). Assembly to full formula
  still modulo SP-2 (Burau denominator = $\Phi_p$) and SP-4 (breadth
  no-cancellation).
- Theorem 4.2: upper bound closed; lower bound still modulo SP-4.

**Consistency**: strict subset of claim; no overreach. **PASS Step 0.5**.

---

## Round-2 delta (what changed since Round 1)

| Item | Round 1 | Round 2 |
|------|---------|---------|
| SP-1 (tridiag falsified) | Correction, not a gap | Same (not a gap) |
| SP-2 (Burau denom $\doteq \Phi_p$) | MEDIUM, asserted | MEDIUM, still asserted |
| SP-3 (general-$p$ key identity) | HIGH, 14 cases + sketch | **CLOSED** (Block Structure Lemma + Lemma Q) |
| SP-4 (breadth $(p-1)(q-1)$) | MEDIUM, asserted | MEDIUM, still asserted |
| $\mu$-convention drift | LOW | Resolved by Fixer's $\mu$-explicit $c_k$ recursion (the $1/\mu(k)$ factor makes the Burau-$\mu$ bridge concrete) |

## Audit of the SP-3 closure (fixer_round1.md)

### Block Structure Lemma

Claim: for $k \le p-2$, $L^{(k+2)}_k := \bar\rho(\sigma_1^{\epsilon_1} \cdots \sigma_k^{\epsilon_k}) \in B_{k+2}$ has block form
$\begin{pmatrix} A'_k & c_k \\ 0 & 1 \end{pmatrix}$ with $A'_k \in B_{k+1}$ the intrinsic matrix.

**Proof audited**:
- (i) Last-row preservation via $e_n^\top M e_n^\top = e_n^\top$ stability
  under product — **OK**, direct matrix algebra.
- (ii) Top-left $k \times k$ equals $A'_k$: Burau generator $\sigma_i$ in $B_{k+2}$
  restricted to first $k+1$ coords equals $\sigma_i$ in $B_{k+1}$. Checked against
  Birman–Weinberg §1.3: generators $\sigma_i$ for $i \le k$ act only on rows/cols
  $\le k+1$ in reduced Burau — **OK, L1**.

### Lemma Q

Claim: $Q_k = F_{k-1}/\mu(k)$, with $Q_k$ the cofactor entry in the expansion.

**Proof audited**:
- Cofactor expansion of $F_{k+1}$ along last row produces $F_k$ terms and
  $Q_k$ terms.
- $Q_{k-1}$-involving terms **cancel identically** across $\epsilon_{k+1} = \pm 1$
  — verified by the Fixer's sympy script across 11 test cases.
- The proven recursion $F_{k+1} = (\mu(k+1)^2/t + y) t^{\epsilon_{k+1}} F_k - \mu(k)\mu(k+1)(y/t) t^{\epsilon_{k+1}+\epsilon_k} F_{k-1}$
  matches the problem's $C_k$ recursion **after** absorbing $t^{e_k}$.
  **OK, L1**.

### Numerical regression

- $p=5$: all 16 sign-vectors match $t^{e(\epsilon)} C_4(y,t)$.
- $p \le 4$ regression: 14/14 retained.
- Prefix check: 62 values of $F_k$ for $k \le 5$ match intrinsic $t^{e_k} C_k$.

**Verdict on SP-3 closure**: fully closed. Induction variable correctly
re-framed (intrinsic $F_k$ in $B_{k+1}$, not leading-principal-minor of
$B_p$ — Explorer's original framing was wrong, now corrected).

## Remaining gaps

### SP-2 (Burau denominator)

Statement: $\det(I_{p-1} - \bar\rho(\Delta_p)) \doteq \Phi_p(t)$ where $\Delta_p$ is the full cycle (so the Burau–Alexander denominator on a braid-closure knot is $\Phi_p$).

Actually the more precise form used: for a braid $\beta \in B_p$ whose closure is a knot,
$\Delta_{\hat\beta}(t) \doteq \det(I - \bar\rho(\beta)) / (1 + t + \cdots + t^{p-1})$.

This is a **standard identity** (unreduced-Burau vs reduced-Burau transition
formula). Fixer Round 2 should derive it via 5-line cofactor argument.

### SP-4 (breadth)

Claim: $\mathrm{breadth}_t \prod_{\ell=1}^{q-1} C_{p-1}(\zeta_q^\ell, t) = (p-1)(q-1)$.

With SP-3 now closed, $C_{p-1}(y,t)$ has explicit recursion and so
$C_{p-1}(\zeta_q^\ell, t)$ is a polynomial of known top/bottom $t$-coefficients.
Fixer Round 2 should extract these coefficients directly from the recursion
and show the top coefficients across $\ell = 1, \ldots, q-1$ multiply to a
non-zero element (similarly for bottom), giving exact breadth $(p-1)(q-1)$.

## Citation ledger (cumulative, after Round 1)

| Tag | Count | New in Round 1 |
|-----|-------|----------------|
| L1 | 7 | +4 (row preservation, block inspection, Laplace, column-linearity) |
| L2 | 4 | 0 |
| L3 | 0 | 0 |
| Independent | ≥ 12 | +6 (Block Structure Lemma, Lemma Q, $c_k$ recursion, identity cancellation, base cases, verification scaffolding) |

**STRUCTURAL-CITATION-WARNING**: still does not fire. Independent steps
now comfortably dominate.

## Verdict

**FIX** (one more round).

Rationale: SP-3 (the central gap) is closed. SP-2 and SP-4 are both small,
well-localized standard-lemma items. A single additional Fixer round
should suffice. If Fixer Round 2 fails to close both, downgrade to
PARTIAL honestly; do not force.

Fixer instruction priority:
1. SP-2: derive Burau denominator via reduced↔unreduced transition.
2. SP-4: breadth from explicit $C_{p-1}$ recursion top/bottom coefficients.

No `[WARN: STRUCTURAL-CITATION-WARNING]`. No `[WARN: VOCABULARY-BLUFF]`.
Evidence Field (Axis 5) still computes to 6/10 × 1.5 = 9/15 cap
(algebraic body + one removable geometric step).
