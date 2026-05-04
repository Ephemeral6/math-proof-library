# Auditor Round 1 — Route D

**Date.** 2026-04-21.
**Target.** `explorer_3_route_D.md` (Route D, coherent-resolution surgery).
**Auditor brief.** Verify closedness modulo L2 citations. Flag any
unjustified steps.

## Step 0 — Proof skeleton rehearsed

1. **Base case.** $N = i(a,b) = 0 \Rightarrow a = b$ or $a \cap b = \emptyset$ (problem.md §7).
2. **Inductive step.** Given $N \ge 1$:
   - Take minimal-position representatives (L2: FM Prop 1.6).
   - Pick crossing $p$; form coherent resolution $a' \#_p b'$ (Step 2).
   - Claim: $|(a' \#_p b') \cap a'| = N - 1$ and same for $b'$.
   - Claim: some component $c'_j$ is essential (Step 3 + Subclaim D3.1).
   - $c = [c'_j]$ satisfies $i(c, a), i(c, b) \le N - 1$.
   - Apply IH twice; concatenate paths.

## Step 1 — Audit each step

### AT-1: Transverse-count preservation under resolution

**Statement (Route D Step 2).** "$|(a' \#_p b') \cap a'| = N - 1$."

**Audit.** The resolution replaces the crossing $\times_p$ with $)($.
- Before: $a' \cap a' = a'$ (self); $a' \cap b' = N$ points including $p$.
- After: $a' \#_p b'$ is (locally near $p$) a pair of arcs of $a' \cup b'$
  that don't cross; globally, outside $D_p$, $a' \#_p b'$ agrees with
  $a' \cup b'$.
- $(a' \#_p b') \cap a'$ (transverse intersections): outside $D_p$,
  these are the points of $(a' \cup b') \cap a' = a' \cup (a' \cap b' \setminus \{p\})$,
  which contributes $N - 1$ transverse points from $a' \cap b' \setminus \{p\}$
  (the self-intersections $a' \cap a'$ are not transverse). Inside $D_p$,
  the resolved arcs no longer cross $a'$ because the smoothing locally
  removes the crossing (the $)($ arcs are separated from $a'$'s arc
  through $D_p$).
  
  ⚠️ **Subtle issue.** The last sentence is slightly too quick. The
  coherent resolution at $p$ produces two arcs that go "the other way"
  — they locally stay on the same side of $a'$'s arc through $D_p$.
  More precisely: a coherent resolution $\times \to )($ smooths the
  crossing such that the two new arcs are disjoint from both the
  original $a'$-arc through $D_p$ and the original $b'$-arc through $D_p$
  (they bypass the crossing). So $|(a' \#_p b') \cap a'| = N - 1$ is
  indeed correct, but the reasoning is that **all of $a' \#_p b' \setminus D_p = (a' \cup b') \setminus D_p$**,
  and the new arcs inside $D_p$ do not cross $a'$'s arc.

  **Verdict:** **PASS** after this clarification. Fixer should include a
  one-line justification.

### AT-2: Essentiality of some component

**Statement (Route D Step 3 + subclaim D3.1).** At least one component
$c'_j$ of $a' \#_p b'$ is essential.

**Audit.** The argument is:
- $[a' \#_p b'] = [a'] + \epsilon [b']$ (band-sum homology).
- Case (D3a) $[a'] + \epsilon [b'] \ne 0$: some component has nonzero
  homology class; by D3.1, this component is essential.
- Case (D3b) $[a'] + \epsilon [b'] = 0$: flip resolution sign; get
  $[a'] - \epsilon [b'] = 2[a'] \ne 0$; apply D3a.

**Sub-audit of D3.1.** "Essential SCC on $S_{1,1}$ has nonzero homology."
- Proof structure: $[\gamma] = 0 \Rightarrow \gamma$ separates $S_{1,1}$
  into two pieces with $\chi$-sum $= -1$; enumerate: $\{-1, 0\}$ or
  $\{0, -1\}$; a $\chi = 0$ piece is annulus or once-punctured disk.
  - Once-punctured disk ⇒ $\gamma$ is puncture-parallel — excluded.
  - Annulus ⇒ $\gamma$ isotopic to the other boundary... but wait.
  
  ⚠️ **Gap in Subclaim D3.1 as written.** "Annulus case makes $\gamma$
  isotopic to a boundary of a disk-with-handle" — the Route D text here
  is slightly hand-wavy. Let me re-do it cleanly.
  
  **Clean re-statement of D3.1.** Let $\gamma$ be essential on $S_{1,1}$,
  and suppose for contradiction $[\gamma] = 0$. A simple closed curve
  bounds iff it separates (on an orientable surface). So $\gamma$ splits
  $S_{1,1}$ into two pieces $P_1, P_2$ with $\chi(P_1) + \chi(P_2) = \chi(S_{1,1}) = -1$.
  Each $P_i$ is a compact surface with one boundary (which is $\gamma$),
  possibly containing the puncture. Enumerate compact surfaces with one
  boundary and Euler characteristic $\chi \in \{0, -1, ...\}$:
  - $\chi = 1$: disk (possibly with puncture removed, making it $\chi = 0$).
  - $\chi = 0$: annulus (but annulus has 2 boundary components — exclude);
    or once-punctured disk (1 boundary, 1 puncture, $\chi = 0$). ✓
  - $\chi = -1$: pair of pants (3 boundaries — exclude); once-punctured
    annulus (2 boundaries + 1 puncture — exclude); torus minus disk
    (1 boundary, $\chi = -1$) ✓; twice-punctured disk (1 boundary,
    2 punctures, $\chi = -1$) ✓.
  
  For $S_{1,1}$ (genus 1, 1 puncture), $P_1 \sqcup_\gamma P_2$ must have
  genus 1 and 1 puncture. The $\chi$-sum $= -1$ with each $P_i$ allowed
  to have 1 boundary and genus $g_i$ and punctures $n_i$:
  $\chi(P_i) = 2 - 2g_i - 1 - n_i = 1 - 2g_i - n_i$. Sum:
  $2 - 2(g_1 + g_2) - (n_1 + n_2) = -1$, and $g_1 + g_2 = 1$,
  $n_1 + n_2 = 1$. So one $P_i$ has $(g, n) = (1, 0)$ (torus minus disk,
  $\chi = -1$) and the other has $(g, n) = (0, 1)$ (once-punctured disk,
  $\chi = 0$). The once-punctured-disk piece makes $\gamma$
  puncture-parallel — excluded. Contradiction. So $[\gamma] \ne 0$. ✓
  
  **Verdict:** PASS after this cleanup. Fixer should replace Route D's
  Step 3 subclaim proof with the above enumeration.

### AT-3: Well-foundedness of induction

**Statement.** Strong induction on $N = i(a, b) \in \mathbb{Z}_{\ge 0}$
terminates.

**Audit.** $\mathbb{Z}_{\ge 0}$ is well-ordered; $i(c, a), i(c, b) \le N - 1 < N$
gives strict decrease; induction closes at $N = 0$ base case.
**Verdict:** PASS.

### AT-4: Base case via problem.md §7

**Statement.** $N = 0 \Rightarrow a = b$ or $a \cap b = \emptyset$.

**Audit.** This is problem.md §7 verbatim (allowed without proof).
**Verdict:** PASS.

### AT-5: L2 citations well-sourced

- **Farb–Margalit Prop 1.6** (minimal-position representatives exist).
  This is equivalent to the "geodesic representative" theorem; standard,
  well-sourced. **Verdict:** PASS.
- **Farb–Margalit Prop 1.7** (bigon criterion). Standard, same source.
  Route D uses it **indirectly**: Route D invokes Prop 1.6 (existence of
  minimal-position reps) + Step 2 counting identity. The bigon criterion
  is not actually needed by Route D's argument as written! (It was
  needed by Route B's argument.)
  
  ⚠️ **Over-citation.** Route D's L2 list includes Prop 1.7 but doesn't
  actually use it. Fixer should remove.

**Updated L-profile after audit:** 3 I + 3 L1 + **1** L2 (just Prop 1.6).

## Step 2 — Fixer directives

**Fixer loop — Round 1 directives to apply to Route D:**

1. **D.Step2.clarify:** Add a one-line note that the coherent resolution
   locally bypasses the crossing, so the new arcs do not re-cross $a'$
   or $b'$ inside $D_p$. This makes the "$N-1$" count self-justifying.
   
2. **D.Step3.D3.1.rewrite:** Replace Subclaim D3.1's proof with the
   explicit Euler-characteristic enumeration (Audit AT-2 above). This
   removes the hand-wavy "annulus case makes $\gamma$ isotopic to a
   disk-with-handle boundary" line.

3. **D.Citations.trim:** Remove the Farb–Margalit Prop 1.7 citation;
   keep Prop 1.6 only. Update the L-depth table.

4. **Optional: sympy cross-check.** Route D's Step 7 proposed a sympy
   block `verify/sp_D_minimal_intersection.py` to cross-check the
   mediant / strict-decrease claim on coprime pairs. Auditor does NOT
   require this (the symbolic argument is complete). Fixer may include
   it for robustness but it is not blocking.

## Step 3 — Auditor verdict Round 1

**VERDICT: FIX REQUIRED (minor, 3 directives).**

All three directives are *local* rewrites (no change to proof skeleton,
no change to Judge's selected route, no change to induction frame).
Expected Fixer-round count: **1** (well under the cap of 3).

Forward to Fixer Round 1.
