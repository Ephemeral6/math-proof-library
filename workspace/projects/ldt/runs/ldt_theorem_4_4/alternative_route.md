# Explorer 1 — Route 1: Alexander-polynomial + uniqueness (cite-chain)

**Route.** Use [REF:level1:corollary_3_10] to reduce knot-equivalence
to Alexander-polynomial equality, then split into uniform (torus) vs
mixed cases and close via [REF:level1:proposition_4_3].

## Step 0 — Backward direction
If $S(p,q,\epsilon)$ is a torus knot, then $\epsilon = (+1,\ldots,+1)$
(or all $-1$, handled by mirror; WLOG $+1$). So
$S(p,q,\epsilon) = T(p,q)$. Classically, $T(p,q) \cong T(q,p)$ (see
Lickorish §7 or Kauffman §3); this is $S(q,p,(+1,\ldots,+1))$, so take
$\epsilon' = (+1,\ldots,+1)$. DONE.

## Step 1 — Forward direction setup
Assume $S(p,q,\epsilon) \cong S(q,p,\epsilon')$. By [REF:level1:corollary_3_10],
$$
\Delta_{S(p,q,\epsilon)}(t) \doteq \Delta_{S(q,p,\epsilon')}(t). \tag{*}
$$

Goal: show $\epsilon = (+1,\ldots,+1)$ (WLOG positive).

## Step 2 — Case split on $\epsilon$

**Case A: $\epsilon$ all equal (uniform).**
WLOG $\epsilon = (+1,\ldots,+1)$, so $S(p,q,\epsilon) = T(p,q)$.
By the torus-knot Alexander polynomial from [REF:level1:proposition_4_3],
$$
\Delta_{T(p,q)}(t) = \frac{(t^{pq}-1)(t-1)}{(t^p-1)(t^q-1)}
= \frac{(t^{qp}-1)(t-1)}{(t^q-1)(t^p-1)} = \Delta_{T(q,p)}(t).
$$
So (*) gives $\Delta_{S(q,p,\epsilon')}(t) \doteq \Delta_{T(q,p)}(t)$.
By [REF:level1:proposition_4_3] uniqueness at $(q,p)$, 
$S(q,p,\epsilon') = T(q,p)$, so $\epsilon' = (+1,\ldots,+1)$. DONE.

**Case B: $\epsilon$ mixed (i.e., contains both $+1$ and $-1$).**
By [REF:level1:theorem_3_5](i), the Seifert genus of $S(p,q,\epsilon)$ is
strictly less than $(p-1)(q-1)/2$. So $\Delta_{S(p,q,\epsilon)}(t)$ has
degree (as a Laurent polynomial) at most $p q - p - q + 1 - 2 = pq-p-q-1$
instead of $pq-p-q+1$. Wait, degree of Δ = $2g$, so
$\deg \Delta_{S(p,q,\epsilon)} \le 2g \le (p-1)(q-1) - 2 = pq - p - q - 1$.

By (*), $\Delta_{S(q,p,\epsilon')}$ has the same (low) degree.
Equivalently, by Theorem 3.5(i) applied at parameters $(q,p)$,
$\epsilon'$ must also be mixed, and the genus of $S(q,p,\epsilon')$ is
strictly below $(p-1)(q-1)/2$.

**So in Case B, both are mixed spiral knots of equal sub-maximal
genus with equal Alexander polynomials.**

## Step 3 — The mixed-case collapse attempt

We want a contradiction: no mixed $\epsilon$ and mixed $\epsilon'$ can
produce a valid pair satisfying $S(p,q,\epsilon) \cong S(q,p,\epsilon')$.

**Attempt 1: Alexander polynomial enough?**
[REF:level1:proposition_4_3] asserts torus is the UNIQUE realization
at fixed $(p,q)$ with torus-polynomial. It does NOT assert that
mixed spiral knots are distinguished by their Alexander polynomials
across $(p,q)$-swap. In general, two distinct knots can share an
Alexander polynomial (classical non-triviality).

**Attempt 2: Augment with Seifert form.**
The Seifert matrix $V$ carries more information than $\Delta = \det(V - tV^T)$.
Specifically, the S-equivalence class of $V$ is a knot invariant.
By [REF:level1:theorem_3_5](ii), $V$ is block-cyclic with $q$ blocks
at parameters $(p,q)$ and $p$ blocks at $(q,p)$. These block structures
are different (different block count); reconciling them would require
showing that two S-equivalent Seifert matrices with different block
counts force a specific $\epsilon, \epsilon'$ relationship.

**Obstacle.** The level1 library does NOT provide:
- A refined Alexander-polynomial classification for mixed spiral
  knots.
- An S-equivalence argument specific to block-cyclic Seifert matrices
  with $(p,q)$-swap.
- A signature/determinant-style argument that distinguishes mixed
  pairs.

[STEP-STUCK SP-1] — Cannot close the mixed case using ONLY the three
registered level1 lemmas. The paper almost certainly uses Lemma 4.1
or Lemma 4.2 (not registered in level1) for this step.

## Step 4 — Sub-problem delegation attempt (v2.3 U2)

Per `prompts/explorer.md` §Sub-problem recursion (v2.3), I consider
emitting a `[SUB-PROBLEM:...]` marker for the missing classification:

Candidate: `[SUB-PROBLEM: For coprime $p,q \ge 2$ and mixed
$\epsilon \in \{\pm 1\}^{p-1}$ not uniformly + or $-$, no
$\epsilon' \in \{\pm 1\}^{q-1}$ satisfies $\Delta_{S(p,q,\epsilon)} =
\Delta_{S(q,p,\epsilon')}$.]
Strictly smaller because: strictly less general statement — reduces the
theorem to a pure Alexander-polynomial question, avoiding knot
equivalence.
Scope: parent Step 3 cites this as [REF:sub-problem-1].`

**Self-check.** Is this sub-problem STRICTLY smaller than the parent?
- Parent: knot-equivalence implies torus.
- Sub: Alexander-polynomial equality across $(p,q)$-swap implies
  uniform $\epsilon$.
- The sub-problem's conclusion is "uniform $\epsilon$" (same as parent's
  torus conclusion), but the hypothesis is WEAKER (Δ-equality vs
  knot-equivalence). So the sub-problem is NOT strictly smaller —
  it is strictly MORE general (weaker hypothesis = harder).

Per U2 admissibility, this would be REJECTED by Auditor.

**Alternative sub-problem candidate:**
`[SUB-PROBLEM: For the specific case $p = 2$ and any mixed
$\epsilon$, no $\epsilon'$ at $(q,2)$ satisfies $S(p,q,\epsilon) \cong
S(q,p,\epsilon')$.]
Strictly smaller because: strictly smaller parameter range — only
$p = 2$ instead of all coprime pairs.
Scope: base case for an induction on $p$.`

Self-check: YES, strictly smaller parameter range. Admissible under U2.

But $p = 2$ is degenerate: $\epsilon \in \{+1, -1\}^{p-1} = \{\pm 1\}$
is length 1, so there are only 2 spiral knots at $(2, q)$: the torus
$T(2,q)$ and its mirror $T(2,q)^*$. The "mixed" case is empty at
$p = 2$ (can't mix a singleton). So the base case is vacuously true
and gives no traction for the general case.

**Escalation.** Even a non-trivial base case ($p = 3$, $\epsilon \in
\{\pm 1\}^2$ with at least one of each sign) would be a concrete
check, but proving "no $\epsilon'$ at $(q,3)$ matches" for ALL coprime
$q$ and mixed 2-element $\epsilon$ remains a research problem, not
a lemma.

## Step 5 — Verdict on Route 1

**STRATEGIC FAILURE on the mixed case.** Route 1's architecture
(Alexander polynomial + level1 uniqueness at torus) handles Case A
cleanly but has no traction in Case B. The level1 library is
insufficient for Case B; the paper's §4 certainly contains Lemma 4.1
or similar that we do NOT have registered.

## Step 6 — Citation profile (partial)

- **[REF:level1:corollary_3_10]**: Step 1.
- **[REF:level1:proposition_4_3]**: Case A (the clean closure).
- **[REF:level1:theorem_3_5]**(i): Case B genus bound; Case B stall.
- **L2 (textbook)**: $T(p,q) \cong T(q,p)$ (Step 0).
- **L1**: Alexander-polynomial degree / Seifert-genus relation.

## Step 7 — Stuck points / SPs (candidate)

- **SP-1** [severity=HIGH] [type=STRATEGIC]: Case B cannot be closed
  with the registered level1 lemmas. A paper-specific refinement of
  Alexander-polynomial classification (likely the paper's Lemma 4.1
  or Proposition 4.2) is needed. Route 1 has no local fix; orchestrator
  must decide (a) add a new level1 lemma from the paper, (b) re-Scout
  with alternative strategy, or (c) accept PARTIAL.

## Post-hoc reflection

Route 1 closes the uniform / torus case of Theorem 4.4 but cannot
handle the mixed case. The level1 library is honestly reflecting that
the paper uses MORE than the three lemmas we registered — a research
theorem typically leans on 5–10 internal lemmas, and we only indexed
the three most salient. This is a healthy negative signal: the v2.3
pipeline surfaces the knowledge gap clearly rather than hallucinating
a fake proof of Case B.

**Forwarding to Judge with PARTIAL result on Route 1:** Case A proved,
Case B strategic-stuck.
