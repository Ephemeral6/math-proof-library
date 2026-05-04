# Auditor Round 2 — Route D (post Fixer R1)

**Date.** 2026-04-21.
**Target.** `best_proof_d.md`.
**Prior round:** `auditor_round1.md` issued 3 blocking directives.

## Directive verification

| Directive | Status |
|-----------|--------|
| D.Step2.clarify | ✓ Step 2 now includes coordinate-chart description + explicit $\delta$-shift to make the transverse count $N-1$ rigorous. |
| D.Step3.D3.1.rewrite | ✓ Subclaim D3.1 now proceeds by explicit Euler-characteristic enumeration of separating-surface splittings; both allowed $(g_i, n_i)$ solutions yield once-punctured-disk side ⇒ puncture-parallel ⇒ contradiction. |
| D.Citations.trim | ✓ FM Prop 1.7 removed; only FM Prop 1.6 remains. L-profile: 3I + 3L1 + **1**L2. |

All 3 directives cleanly addressed.

## Fresh audit of `best_proof_d.md`

### Step 1 (minimal-position)
Single L2: Farb–Margalit Prop 1.6. Standard.
**Verdict:** PASS.

### Step 2 (coherent resolution)
Coordinate-chart description is explicit. The $\delta$-shift trick to
displace the resolved arcs from the original $a'$-axis is a clean way
to avoid the "is $(0,0)$ on $a'$ or not" ambiguity.
**Verdict:** PASS.

### Step 3 (transverse-count identity)
Outside $D_p$: $a' \#_p b' = a' \cup b'$ ⇒ intersection with $a'$ is
$(a' \cap b') \setminus \{p\}$ = $N - 1$ points. Inside $D_p$:
displaced arcs don't meet $a'$-axis ⇒ 0 intersection points. Total
$N - 1$.
**Verdict:** PASS.

### Step 4 (essential component exists)
Case analysis on sign of $[a'] + \epsilon[b']$; either sign of
smoothing provides a nonzero-homology component. Uses Subclaim D3.1.
**Verdict:** PASS.

### Subclaim D3.1 (essential ⇒ nonzero homology)
Explicit enumeration: two solutions $(1,0,0,1)$ and $(0,1,1,0)$,
both yielding one puncture-disk side. Tight, no hand-waving.
**Verdict:** PASS.

### Step 5 (intersection count of $c$)
$i(c, a) \le |c'_j \cap a'| \le N - 1$ by minimum-over-representatives
definition of $i$. Clean.
**Verdict:** PASS.

### Step 6 (IH assembly)
Strong induction on $N$; base case at $N = 0$; strict decrease. Paths
concatenate.
**Verdict:** PASS.

### L-depth summary
1 L2, 3 L1, 3 I. Single external citation is FM Prop 1.6, well-sourced.
**Verdict:** PASS.

## Edge-case double-check (spot audit of the inductive step)

**Spot case:** $a = $ class of meridian $\mu$, $b = $ class of diagonal
$\delta$ on $S_{1,1}$. Homology classes $[\mu] = (1, 0)$, $[\delta] = (1, 1)$
in $\mathbb{Z}^2$ (with $\{[\mu], [\lambda]\}$ basis). $|\det| = 1$; by
Explorer 2's Claim 3 (on $T^2$), $i_{T^2}(\mu, \delta) = 1$. On
$S_{1,1}$, $i(\mu, \delta)$ is at most $1$; let us assume $N = 1$ for
this spot-check.

Route D inductive step: resolve the single crossing. Get
$a' \#_p b'$ with homology $[\mu] + \epsilon[\delta] \in \{(2, 1), (0, -1)\}$.
Either sign is nonzero. Pick $(2, 1)$: this is a primitive class (gcd=1),
so corresponds to a homology-nontrivial simple closed curve. Its
isotopy class $c$ satisfies $i(c, \mu) \le 0$ and $i(c, \delta) \le 0$,
i.e. $c$ is disjoint from (or equal to) both $\mu$ and $\delta$. Base
case applies.

So the induction correctly delivers $\mu \to c \to \delta$: $\mu$ and
$\delta$ are at distance $\le 2$ in $\mathcal{C}(S_{1,1})$. ✓

(A more careful analysis: one can show $c$ is genuinely disjoint from
both $\mu$ and $\delta$ since its homology class is distinct from each;
so distance $= 2$ if $\mu \ne c \ne \delta$.)

**Verdict:** spot case consistent.

## Discrepancies / remaining concerns

**None.** All 3 R1 directives addressed; fresh audit passes on all
steps; spot-check on $(\mu, \delta)$ pair works.

## Final audit verdict

**✓ ACCEPT.**

Forward to Integrator for final consolidation.
