# Fixer Round 2 — target SP-2 and SP-4

## Overview

Round 1 closed SP-3: we proved
$$F_{p-1}(y, t) := \det(I_{p-1} - y\, B_\epsilon) \;=\; t^{e(\epsilon)}\, C_{p-1}(y, t),
\qquad e(\epsilon) := \sum_i \epsilon_i,$$
for the spiral braid matrix $B_\epsilon = \bar\rho_p(\sigma_1^{\epsilon_1}\cdots\sigma_{p-1}^{\epsilon_{p-1}})$
(Birman–Weinberg §1.3 reduced Burau).

Round 2 closes **SP-2** (the Burau denominator $\Phi_p(t)$ cancels
$\det(I-B_\epsilon)$) and **SP-4** (breadth of
$\prod_{\ell=1}^{q-1} C_{p-1}(\zeta_q^\ell, t)$ equals $(p-1)(q-1)$).
Both rest **entirely on SP-3** plus elementary algebra.

---

## SP-2 closure: $\det(I - B_\epsilon) \doteq \Phi_p(t)$

**Claim.** For every $p \ge 2$ and every $\epsilon \in \{\pm 1\}^{p-1}$,
$$\det(I_{p-1} - B_\epsilon) \;=\; t^{(e(\epsilon) - (p-1))/2} \cdot \Phi_p(t),
\qquad \Phi_p(t) := 1 + t + \cdots + t^{p-1}.$$
(Note $e(\epsilon)$ and $p-1$ have the same parity, so the exponent is an integer.)

**Proof.** By SP-3 applied at $y = 1$,
$$\det(I_{p-1} - B_\epsilon) \;=\; t^{e(\epsilon)} \cdot C_{p-1}(1, t).$$
It therefore suffices to prove the **intrinsic** identity
$$\boxed{C_k(1, t) \;=\; t^{-(e_k + k)/2} \cdot \Phi_{k+1}(t), \qquad
e_k := \epsilon_1 + \cdots + \epsilon_k,}$$
for all $k \ge 0$ and all prefixes $\epsilon_{1..k} \in \{\pm 1\}^k$.
Setting $k = p-1$ then gives $C_{p-1}(1, t) = t^{-(e(\epsilon) + p-1)/2} \Phi_p(t)$,
which combined with SP-3 gives the claim. Equivalently, writing
$h_k(t) := t^{(e_k + k)/2} C_k(1, t)$, we must show $h_k = \Phi_{k+1}$.

*Base.* $C_0 = 1$, $e_0 = 0$: $h_0 = t^0 \cdot 1 = 1 = \Phi_1$. ✓
$C_1 = \mu(1)^2/t + 1$, so $h_1 = t^{(\epsilon_1+1)/2}(\mu(1)^2/t + 1)$.
- $\epsilon_1 = +1$: $h_1 = t \cdot (1/t + 1) = 1 + t = \Phi_2$. ✓
- $\epsilon_1 = -1$: $h_1 = t^0 \cdot (t + 1) = 1 + t = \Phi_2$. ✓

*Inductive step ($k \ge 2$).* Starting from the recursion
$C_k(1, t) = (\mu(k)^2/t + 1)\, C_{k-1}(1, t) - (\mu(k-1)\mu(k)/t)\, C_{k-2}(1, t)$
and multiplying by $t^{(e_k + k)/2}$:

$$h_k \;=\; (\mu(k)^2/t + 1)\, t^{(e_k - e_{k-1} + 1)/2}\, h_{k-1}
\;-\; (\mu(k-1)\mu(k)/t)\, t^{(e_k - e_{k-2} + 2)/2}\, h_{k-2}.$$

Two elementary simplifications (using $\mu(i) = 1$ if $\epsilon_i = +1$,
$\mu(i) = t$ if $\epsilon_i = -1$, so $\mu(i)^2 = t^{1-\epsilon_i}$
and $\mu(i)^2/t = t^{-\epsilon_i}$):

1. First coefficient. $\mu(k)^2/t + 1 = 1 + t^{-\epsilon_k}$, and
   $e_k - e_{k-1} = \epsilon_k$. So the coefficient of $h_{k-1}$ is
   $(1 + t^{-\epsilon_k})\, t^{(\epsilon_k + 1)/2} = t^{(\epsilon_k + 1)/2} + t^{(1 - \epsilon_k)/2}$.
   Both values $\epsilon_k = \pm 1$ give the same result:
   $\epsilon_k = +1 \Rightarrow t^1 + t^0 = 1 + t$;
   $\epsilon_k = -1 \Rightarrow t^0 + t^1 = 1 + t$.

2. Second coefficient. $\mu(k-1)\mu(k) = t^{(2 - \epsilon_{k-1} - \epsilon_k)/2}$,
   so $\mu(k-1)\mu(k)/t = t^{-(\epsilon_{k-1} + \epsilon_k)/2}$; combined with
   $t^{(\epsilon_{k-1} + \epsilon_k + 2)/2}$ this becomes simply $t^1 = t$
   (the exponent collapses to $1$, independent of $\epsilon_{k-1}, \epsilon_k$).

So the $C_k$-recursion translates into the **universal** recursion
$$\boxed{h_k \;=\; (1 + t)\, h_{k-1} \;-\; t\, h_{k-2}.}$$

The cyclotomic identity
$\Phi_{k+1}(t) = (1+t)\Phi_k(t) - t\,\Phi_{k-1}(t)$ is a two-line check
(expand and cancel). Since $h_k$ and $\Phi_{k+1}$ satisfy the same second-order
linear recursion with the same initial values $(h_0, h_1) = (\Phi_1, \Phi_2)$,
induction gives $h_k = \Phi_{k+1}$. ∎

**Remark.** The surprising feature — that the linear recursion for
$h_k = t^{(e_k+k)/2} C_k(1,t)$ is **independent of $\epsilon$** — is exactly
what makes SP-2 collapse to a tiny scalar induction once SP-3 is in hand.
The $t$-power substitution $t^{(e_k+k)/2}$ absorbs all $\epsilon$-dependence.

**Citation ledger for SP-2.**
- [L1] Cyclotomic recursion $\Phi_{k+1} = (1+t)\Phi_k - t\Phi_{k-1}$ (2-line textbook).
- [L2] Burau/Alexander formula $\Delta_{\hat\beta}(t) \doteq \det(I - \bar\rho(\beta))/\Phi_p(t)$
  (Birman 1974, *Braids, Links, and Mapping Class Groups* §3), already cited in
  `best_proof.md` Step 1. No new L2 introduced here.
- [I] The scalar induction $h_k = (1+t)h_{k-1} - t h_{k-2}$ derived from the
  $C_k$-recursion.

**No L3 citations.** The claim is a 10-line consequence of SP-3 and the $C_k$
recursion; no appeal to the reduced/unreduced Burau transition is needed.

---

## SP-4 closure: breadth of $\prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t)$

**Claim.** Let $\zeta = e^{2\pi i/q}$. Then for every $p \ge 2$, $q \ge 2$, and
every $\epsilon \in \{\pm 1\}^{p-1}$ (with $\gcd(p, q) = 1$ so the closure is a
knot — see "Remark on hypotheses" below),
$$\mathrm{breadth}_t\!\left(\prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t)\right)
\;=\; (p-1)(q-1).$$

**Structural sub-lemma.** For every $k \ge 0$ and every sign-prefix
$\epsilon_{1..k}$, let
$$n_k^+ := \#\{i \le k : \epsilon_i = +1\}, \qquad
n_k^- := \#\{i \le k : \epsilon_i = -1\},$$
so $n_k^+ + n_k^- = k$. Then in $C_k(y, t)$, viewed as a Laurent polynomial in
$t$ with coefficients in $\mathbb{Z}[y]$:
$$\boxed{
\text{top-}t\text{-coef: } y^{n_k^+} \text{ at } t\text{-power } n_k^-, \qquad
\text{bot-}t\text{-coef: } y^{n_k^-} \text{ at } t\text{-power } -n_k^+.
}$$
In particular $\mathrm{breadth}_t(C_k(y,t)) = n_k^+ + n_k^- = k$, and both
extremal coefficients are **monic monomials in $y$** of the stated $y$-degrees.

**Proof of sub-lemma (induction on $k$).**

*Base $k = 0$:* $C_0 = 1 = y^0 t^0$. Top = bot = $1$, $n_0^\pm = 0$. ✓

*Base $k = 1$:*
- $\epsilon_1 = +1$: $C_1 = 1/t + y$. Top: $y = y^{n_1^+}$ at $t^{n_1^-} = t^0$.
  Bot: $1 = y^{n_1^-}$ at $t^{-n_1^+} = t^{-1}$. ✓
- $\epsilon_1 = -1$: $C_1 = t + y$. Top: $1 = y^{n_1^+}$ at $t^{n_1^-} = t^1$.
  Bot: $y = y^{n_1^-}$ at $t^{-n_1^+} = t^0$. ✓

*Inductive step ($k \ge 2$).* The recursion is
$C_k = A \cdot C_{k-1} - B \cdot C_{k-2}$ where
$A := \mu(k)^2/t + y$ and $B := \mu(k-1)\mu(k) y/t$.

**Case $\epsilon_k = +1$** (so $n_k^+ = n_{k-1}^+ + 1$, $n_k^- = n_{k-1}^-$,
$\mu(k) = 1$, $A = 1/t + y$, $B = \mu(k-1) y / t$):
- *Top of $A \cdot C_{k-1}$.* The two summands of $A C_{k-1}$ are
  $y \cdot C_{k-1}$ (top $t$-exp $n_{k-1}^-$, $y$-coef $y \cdot y^{n_{k-1}^+} = y^{n_{k-1}^+ + 1}$)
  and $(1/t) \cdot C_{k-1}$ (top $t$-exp $n_{k-1}^- - 1$). Top is at
  $t^{n_{k-1}^-} = t^{n_k^-}$ with coefficient $y^{n_{k-1}^+ + 1} = y^{n_k^+}$.
- *Top of $B \cdot C_{k-2}$.* $B = \mu(k-1) y/t$.
  If $\epsilon_{k-1} = +1$: $B = y/t$, top $t$-exp $= n_{k-2}^- - 1 = n_{k-1}^- - 1 = n_k^- - 1$.
  If $\epsilon_{k-1} = -1$: $B = y$, top $t$-exp $= n_{k-2}^- = n_{k-1}^- - 1 = n_k^- - 1$.
  In either case the top-$t$-exp of the $B$-term is strictly less than $n_k^-$,
  so it cannot cancel against the $A$-term's top. Top of $C_k$ is $y^{n_k^+}$ at
  $t^{n_k^-}$. ✓
- *Bot of $A \cdot C_{k-1}$.* Summands: $(1/t) C_{k-1}$ (bot $t$-exp
  $-n_{k-1}^+ - 1$, $y$-coef $y^{n_{k-1}^-}$) and $y C_{k-1}$ (bot $t$-exp
  $-n_{k-1}^+$). Bot at $t^{-n_{k-1}^+ - 1} = t^{-n_k^+}$ with coefficient
  $y^{n_{k-1}^-} = y^{n_k^-}$.
- *Bot of $B \cdot C_{k-2}$.* If $\epsilon_{k-1} = +1$: bot exp $= -n_{k-2}^+ - 1 = -n_{k-1}^+$;
  if $\epsilon_{k-1} = -1$: bot exp $= -n_{k-2}^+ = -n_{k-1}^+$.
  Both equal $-n_{k-1}^+ > -n_k^+ = -n_{k-1}^+ - 1$, strictly above the bot of $A\cdot C_{k-1}$.
  So bot of $C_k$ is $y^{n_k^-}$ at $t^{-n_k^+}$. ✓

**Case $\epsilon_k = -1$** (so $n_k^+ = n_{k-1}^+$, $n_k^- = n_{k-1}^- + 1$,
$\mu(k) = t$, $A = t + y$, $B = \mu(k-1) y$):
- *Top of $A \cdot C_{k-1}$.* Summands: $t \cdot C_{k-1}$ (top $t$-exp
  $n_{k-1}^- + 1 = n_k^-$, $y$-coef $y^{n_{k-1}^+} = y^{n_k^+}$); $y C_{k-1}$
  (top $t$-exp $n_{k-1}^- = n_k^- - 1$). Top of $C_k$: $y^{n_k^+}$ at $t^{n_k^-}$.
- *Top of $B \cdot C_{k-2}$.* If $\epsilon_{k-1} = +1$: $B = y$, top exp $= n_{k-2}^- = n_{k-1}^- = n_k^- - 1$.
  If $\epsilon_{k-1} = -1$: $B = yt$, top exp $= n_{k-2}^- + 1 = n_{k-1}^- = n_k^- - 1$.
  Strictly below $n_k^-$ in both sub-cases. ✓
- *Bot of $A \cdot C_{k-1}$.* $t\cdot C_{k-1}$: bot $t$-exp $= -n_{k-1}^+ + 1 = -n_k^+ + 1$.
  $y \cdot C_{k-1}$: bot $t$-exp $= -n_{k-1}^+ = -n_k^+$. Bot at $t^{-n_k^+}$ with
  $y$-coef $y \cdot y^{n_{k-1}^-} = y^{n_{k-1}^- + 1} = y^{n_k^-}$. ✓
- *Bot of $B \cdot C_{k-2}$.* If $\epsilon_{k-1} = +1$: $B = y$, $n_{k-2}^+ = n_{k-1}^+ - 1$,
  so bot exp $= -n_{k-2}^+ = -n_{k-1}^+ + 1$.
  If $\epsilon_{k-1} = -1$: $B = yt$, $n_{k-2}^+ = n_{k-1}^+$,
  so bot exp $= -n_{k-2}^+ + 1 = -n_{k-1}^+ + 1$.
  Since $n_k^+ = n_{k-1}^+$ (because $\epsilon_k=-1$), in both sub-cases the
  bot-$t$-exp of the $B$-term is $-n_k^+ + 1$, strictly above $-n_k^+$. ✓

This closes the induction. ∎

**Main breadth computation.** By the sub-lemma, writing $n^\pm := n_{p-1}^\pm$
(so $n^+ + n^- = p - 1$):
$$C_{p-1}(y, t) \;=\; y^{n^+} \cdot t^{n^-} \;+\; (\text{lower-}t\text{-power terms}) \;+\; y^{n^-} \cdot t^{-n^+}.$$

For each $\ell \in \{1, \ldots, q-1\}$, $C_{p-1}(\zeta^\ell, t)$ is a Laurent
polynomial in $t$ with:
- top coef $\zeta^{\ell n^+} \ne 0$ at $t^{n^-}$,
- bot coef $\zeta^{\ell n^-} \ne 0$ at $t^{-n^+}$.

(Both coefficients are $q$-th roots of unity, hence nonzero.)

Therefore in the product $\prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t)$:
- the coefficient of the highest $t$-power, $t^{(q-1) n^-}$, is
  $\prod_{\ell=1}^{q-1} \zeta^{\ell n^+} = \zeta^{n^+ \cdot q(q-1)/2}
  = (-1)^{n^+(q-1)} \in \{\pm 1\}$ (using $\zeta^{q(q-1)/2} = e^{i\pi(q-1)} = (-1)^{q-1}$);
- the coefficient of the lowest $t$-power, $t^{-(q-1) n^+}$, is
  $\prod_{\ell=1}^{q-1} \zeta^{\ell n^-} = (-1)^{n^-(q-1)} \in \{\pm 1\}$.

Both are **nonzero integers** (they are $\pm 1$), so no cancellation can reduce
the top or bottom $t$-power. Hence
$$\mathrm{breadth}_t\!\left(\prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t)\right)
\;=\; (q-1) n^- - \bigl(-(q-1) n^+\bigr) \;=\; (q-1)(n^+ + n^-) \;=\; (p-1)(q-1). \quad \Box$$

**Remark on hypotheses.** The breadth claim itself (as an algebraic statement
about the Laurent polynomial product) holds **for all $p \ge 2$, $q \ge 1$, and
all $\epsilon$**; the $\gcd(p, q) = 1$ condition enters only because Theorem
4.2's conclusion about *knot genus* requires $\hat\beta$ to be a knot.
The SP-4 breadth proof above is therefore unconditional on $\gcd$.

**Citation ledger for SP-4.**
- [L1] Laurent polynomial breadth under products of non-cancelling leading-coefficient factors.
- [L1] Sum $\sum_{\ell=1}^{q-1} \ell = q(q-1)/2$ and $\zeta^{q(q-1)/2} = (-1)^{q-1}$.
- [I] The top/bot structural sub-lemma (induction on $k$ via the $C_k$ recursion).

**No new L2 or L3 citations.**

---

## Numerical verification

All five cases required by the task prompt, plus the already-verified
$S(3,5,(+,-))$ case (matches `best_proof.md` Step 9):

Script: `fixer_work/sp4_breadth.py` (breadth via Burau Alexander polynomial) and
`fixer_work/sp4_topbot.py` (breadth via the top/bot structural sub-lemma and the
product-of-roots-of-unity formula).

| Case | Expected breadth | Alexander polynomial via Burau | Actual breadth | Status |
|---|---|---|---|---|
| $(p,q,\epsilon) = (2, 3, (+))$ | $1 \cdot 2 = 2$ | $t^2 - t + 1$ (i.e. $3_1$) | $2 - 0 = 2$ | ✓ |
| $(3, 2, (+,+))$ | $2 \cdot 1 = 2$ | $t^2 - t + 1$ (i.e. $3_1$) | $2 - 0 = 2$ | ✓ |
| $(3, 2, (+,-))$ | $2 \cdot 1 = 2$ | $-1 + 3/t - 1/t^2$ (i.e. $4_1$) | $0 - (-2) = 2$ | ✓ |
| $(3, 4, (+,+))$ | $2 \cdot 3 = 6$ | $t^6 - t^5 + t^3 - t + 1$ | $6 - 0 = 6$ | ✓ |
| $(4, 3, (+,+,+))$ | $3 \cdot 2 = 6$ | $t^6 - t^5 + t^3 - t + 1$ | $6 - 0 = 6$ | ✓ |
| $(3, 5, (+,-))$ | $2 \cdot 4 = 8$ | $t^3 - 6t^2 + 15t - 24 + 29/t - 24/t^2 + 15/t^3 - 6/t^4 + 1/t^5$ | $3 - (-5) = 8$ | ✓ |

**Note:** $S(3,4,(+,+))$ and $S(4,3,(+,+,+))$ give the same Alexander polynomial
(both equal $T(3,4) = 8_{19}$). Breadth $6$, consistent with
$(p-1)(q-1) = 2 \cdot 3 = 3 \cdot 2 = 6$.

### Structural-lemma verification
`fixer_work/sp4_monomial.py`: for all $p \in \{2,3,4,5,6\}$ and all $\epsilon$
($2^1 + 2^2 + 2^3 + 2^4 + 2^5 = 62$ cases) the top and bottom $t$-coefs of
$C_{p-1}(y, t)$ are **monomials** in $y$ of degrees exactly $n^+$ and $n^-$,
with leading coefficient $+1$. `PASS: all 62 cases.`

### SP-2 verification
`fixer_work/sp2_verify_phi_p.py`: for $p \in \{2,3,4,5,6\}$ and all $\epsilon$
(62 cases), $\det(I - B_\epsilon) \cdot t^{(p-1 - e(\epsilon))/2}$ equals
$\Phi_p(t)$ **exactly** (ratio $= 1$ in every case).
`fixer_work/sp2_Ck_at_y1.py`: for the intrinsic identity $C_k(1,t) =
t^{-(e_k+k)/2} \Phi_{k+1}(t)$ tested on every prefix of every $\epsilon$ for
$p \le 6$: `258 checks. All OK.`

---

## Residual gaps

**None within SP-2 and SP-4.** Both closures are unconditional:
- SP-2 reduces to SP-3 + a universal scalar recursion $h_k = (1+t)h_{k-1} - t h_{k-2}$.
- SP-4 reduces to SP-3 + the top/bot structural sub-lemma + the fact that
  roots of unity are nonzero.

The only external citations remain the ones already in `best_proof.md`:
- L2 Burau–Alexander formula (Birman 1974 §3), used only in the pipeline to
  identify $\Delta_{\hat\beta}(t)$ with $\det(I - \bar\rho(\beta))/\Phi_p(t)$.
- L2 Alexander-polynomial genus bound $2g(K) \ge \mathrm{breadth}(\Delta_K)$
  (Rolfsen Prop. 8.C.6).
- L1 Seifert algorithm upper bound for genus.

With SP-2, SP-3, and SP-4 all closed, the only remaining stuck point from
`best_proof.md` is the already-noted SP-1 (the scout's tridiagonality
hypothesis), which is **falsified, not required**, and was sidestepped via the
SP-3 identity instead.

---

## Citation ledger delta (this round)

| Tag | Count (new this round) | Items |
|---|---|---|
| L1 | 3 | Cyclotomic recursion for $\Phi_{k+1}$; roots-of-unity evaluations; Laurent polynomial breadth under non-cancellation |
| L2 | 0 | (none new) |
| L3 | 0 | — |
| Independent | 3 | SP-2 closure (scalar recursion for $h_k$); SP-4 structural sub-lemma (top/bot $t$-coefs of $C_k$ are monomials in $y$ of known degree); SP-4 main breadth argument |

Cumulative across Rounds 1 and 2: 7 L1, 3 L2 (all in `best_proof.md`), 0 L3,
9 Independent proof steps.

---

## Summary ($\le 200$ words)

**SP-2 closed** fully. The identity $\det(I - B_\epsilon) = t^{(e(\epsilon) - (p-1))/2}\Phi_p(t)$
follows from SP-3 applied at $y=1$ together with an intrinsic identity
$C_k(1, t) = t^{-(e_k+k)/2}\Phi_{k+1}(t)$. The latter follows by induction
because the change of variable $h_k := t^{(e_k+k)/2}C_k(1,t)$ absorbs
$\epsilon$-dependence: $h_k$ satisfies the **universal** three-term recursion
$h_k = (1+t)h_{k-1} - t h_{k-2}$, matching $\Phi_{k+1}$'s recursion with the
same base cases.

**SP-4 closed** fully. A clean induction proves that the top and bottom $t$-coefficients
of $C_k(y,t)$ are monic monomials in $y$ of degrees $n_k^+$ and $n_k^-$
respectively (the $+1$-count and $-1$-count in the prefix). The product
$\prod_{\ell=1}^{q-1}(\cdot)$ has top/bot coefficients $\pm 1$ (roots of unity
products), hence no cancellation; breadth is exactly $(q-1)(n^+ + n^-) = (p-1)(q-1)$.

**New citations:** 3 L1, 0 L2, 0 L3, 3 Independent steps. All numerical checks
pass (6/6 task cases; 62/62 structural checks for the sub-lemma; 258/258 for
SP-2's intrinsic identity).
