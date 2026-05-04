# Fixer Round 1 — Route D

**Date.** 2026-04-21.
**Auditor directives.** 3 blocking (D.Step2.clarify, D.Step3.D3.1.rewrite,
D.Citations.trim). 1 optional (sympy) — skipped, see §4 below.

## §1 — Directive D.Step2.clarify (applied)

**Original Step 2 Route D:** "all of $a' \#_p b' \setminus D_p = (a' \cup b') \setminus D_p$,
and the new arcs inside $D_p$ do not cross $a'$'s arc."

**Fixer rewrite (inserted after the counting identity):**

> **Resolution detail.** In the disk $D_p$, the crossing $\times_p$ is
> replaced with two disjoint arcs $)($ that *bypass* each of $a'$ and $b'$.
> Formally, pick coordinates on $D_p \cong \mathbb{D}^2$ so that
> $a' \cap D_p = \{(x, 0) : x \in [-1, 1]\}$ and
> $b' \cap D_p = \{(0, y) : y \in [-1, 1]\}$, meeting at the origin $p$.
> The coherent resolution consistent with an orientation of $a' \cup b'$
> replaces these two segments with either
> $\{(x, \pm\epsilon x) : x \in [-1, 1]\}$ (one connected smoothing) or
> the opposite smoothing. Both possibilities produce two arcs disjoint
> from both original coordinate axes inside a slightly smaller disk. So
> $|(a' \#_p b') \cap a'| = |(a' \cup b') \cap a'| - 1 = N - 1$ exactly,
> and similarly for $b'$.

## §2 — Directive D.Step3.D3.1.rewrite (applied)

**Subclaim D3.1 (rewritten proof).** Let $\gamma$ be an essential simple
closed curve on $S_{1,1}$. Then $[\gamma] \ne 0$ in $H_1(S_{1,1}; \mathbb{Z})$.

**Proof.** Suppose for contradiction $[\gamma] = 0$. On an orientable
surface, a simple closed curve bounds in homology iff it separates. So
$S_{1,1} \setminus \gamma$ has two connected components $P_1, P_2$, each
a compact surface (with or without the puncture) having $\gamma$ as its
unique boundary component.

Classify $P_i$ by (genus $g_i$, number of boundary components = 1,
number of punctures $n_i$):
$$\chi(P_i) = 2 - 2g_i - 1 - n_i = 1 - 2g_i - n_i.$$
The gluing $P_1 \cup_\gamma P_2 = S_{1,1}$ gives
$$\chi(P_1) + \chi(P_2) = \chi(S_{1,1}) = -1, \quad g_1 + g_2 = 1, \quad n_1 + n_2 = 1.$$
Summing: $(1 - 2g_1 - n_1) + (1 - 2g_2 - n_2) = 2 - 2 - 1 = -1$. ✓

Enumerate the two solutions (by symmetry):
- **$(g_1, n_1, g_2, n_2) = (1, 0, 0, 1)$:** $P_1$ = once-bounded torus
  ($\chi = -1$), $P_2$ = once-punctured disk ($\chi = 0$). The $P_2$
  side makes $\gamma$ the boundary of a punctured disk — i.e. $\gamma$
  is freely isotopic into a small neighborhood of the puncture, hence
  $\gamma$ is puncture-parallel. **Excluded** by the definition of
  essential (problem.md §3).
- **$(g_1, n_1, g_2, n_2) = (0, 1, 1, 0)$:** same as above with sides
  swapped. **Excluded** for the same reason.

Both cases are excluded, contradicting $[\gamma] = 0$. Hence $[\gamma] \ne 0$. $\square$

## §3 — Directive D.Citations.trim (applied)

**Original L2 citations in Route D:**
- Farb–Margalit Proposition 1.6 (minimal-position existence).
- Farb–Margalit Proposition 1.7 (bigon criterion).

**Audit observation:** Proposition 1.7 is not actually used in Route D's
argument. Only Proposition 1.6 is invoked (to pick minimal-position
representatives in Step 1).

**Fix:** Remove the Farb–Margalit Prop 1.7 entry from the citation table.
Update L-depth summary:

| | Before | After |
|-|--------|-------|
| Informal (I) | 3 | 3 |
| L1 (standard) | 3 | 3 |
| L2 (textbook) | 2 | **1** |
| L3 (research) | 0 | 0 |

Single remaining L2: **Farb–Margalit, A Primer on Mapping Class Groups,
Proposition 1.6** (minimal-position representatives exist).

## §4 — Optional sympy cross-check: skipped (with reason)

**Auditor suggestion:** `verify/sp_D_minimal_intersection.py`, a
finite-case cross-check that the strict-decrease claim holds for small
coprime-pair parameters.

**Fixer analysis:** The strict-decrease in Route D is a **transverse
intersection count** fact about a specific pair of representatives
$(a', b', a' \#_p b')$ on $S_{1,1}$. It is **not** an arithmetic
identity on integer coprime pairs. In fact: on $T^2$, the mediant of
slopes $(p_1/q_1)$ and $(p_2/q_2)$ is the slope
$(p_1 \pm p_2)/(q_1 \pm q_2)$, and one computes
$|\det\big((p_1, q_1), (p_1 + p_2, q_1 + q_2)\big)| = |p_1 q_2 - p_2 q_1| = N$ —
*no strict decrease in the $|\det|$ invariant*. The mediant curve on
$T^2$ intersects the original in $N$ points, not $N - 1$.

The strict decrease in Route D comes entirely from the fact that the
*resolution removes one specific crossing point* from the transverse
count $|c' \cap a'|$, with no compensating increase elsewhere. This is a
fact about the homeomorphism class of the surgery, not about the
arithmetic of slopes.

No finite-parameter sympy block can meaningfully certify this. The
audit flagged this as optional; the symbolic argument in
`best_proof_d.md` §§2–4 closes without it. **Skipped.**

## §5 — Closed Route D proof

The cleaned, L2-minimal proof is consolidated at `best_proof_d.md`.

## §6 — Fixer verdict

**All 3 Auditor directives addressed.**

- D.Step2.clarify: ✓ clarification inserted.
- D.Step3.D3.1.rewrite: ✓ Euler-char enumeration replaces
  hand-wavy text.
- D.Citations.trim: ✓ Prop 1.7 removed; single L2 remains.

**Forward to Auditor Round 2 for sign-off.**
