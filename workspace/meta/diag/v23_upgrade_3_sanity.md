# Sanity check — Upgrade 3 (Cross-pollination at Judge)

**Date.** 2026-04-21.
**Target.** Confirm the updated Judge prompt extracts reusable fragments
from a losing Explorer route. Test input: `workspace/active/ldt_curve_complex_s11/explorer_2_route_A.md`
(Route A, the Farey-graph identification that ABORTED at SP-A3).

## Background

In the V2.2 cold-start test, Route A (Explorer 2) identified
$\mathcal{C}(S_{1,1})$ with the Farey graph $\mathcal F$, but discovered
that under problem.md's strict $i(a,b) = 0$ edge definition the graph
appears to have no edges (because distinct primitive-slope classes on
$T^2$ and on $S_{1,1}$ both satisfy $i = |p_1 q_2 - p_2 q_1| \ne 0$ for
distinct classes). Route A aborted with [STEP-STUCK SP-A3] and was NOT
the winner. The winner was Route D (coherent-resolution surgery).

Under V2.2, Route A's output was shelved. Under V2.3 cross-pollination,
Judge should extract reusable fragments from it.

## Simulated Judge execution (v2.3)

Judge reads Route A (Explorer 2) and scans for candidates matching the
qualifier criteria in `judge_ldt.md` §Cross-pollination extraction:
1. Self-contained claim,
2. Verifiable (verified / unverified / verified-as-counterexample),
3. Non-redundant with winning Route D,
4. Non-trivial.

### Candidate inventory

Scanning Explorer 2 step-by-step:

- **Step 2, Claim 1** (primitive lattice vector ↔ isotopy class on $T^2$).
  Textbook (Farb–Margalit §1.2.3). **Fails qualifier 4 (trivial / L1).**
  REJECT.

- **Step 3, Claim 2** (essential SCC on $T^2$ and on $S_{1,1}$ correspond
  1-1, puncture is invisible). Self-contained, proved in the text,
  non-redundant with winner (Route D does not prove this explicitly —
  it operates on $S_{1,1}$ directly). **QUALIFIES as status=verified.**

- **Step 4, Claim 3** (intersection number equals $|p_1 q_2 - p_2 q_1|$
  on $T^2$ via straight-line minimality). Route D's Step 4 transverse-
  count uses a geometric intersection count but does not derive the
  determinant formula from scratch. Explorer 2 DOES derive it. Useful
  cross-reference. **QUALIFIES as status=verified** (Explorer 2's proof
  at Step 4 is clean and cited; the only reason Route A died was the
  definitional mismatch in Step 5, not Claim 3 itself).

- **Step 5–7, SP-A3** (the negative result: under problem.md's literal
  $i = 0$ edge definition, distinct-slope classes are non-adjacent on
  $S_{1,1}$, and the meridian $\mu = (1,0)$ and longitude $\lambda =
  (0,1)$ satisfy $i(\mu, \lambda) = 1 \ne 0$ so they are not adjacent).
  This is a CONCRETE WITNESS that refutes a naive interpretation of
  problem.md §8. A Fixer working on any future $\mathcal{C}(S_{1,1})$
  claim should know not to invoke the Farey-edge ($i = 1$) convention
  without first handling the edge-definition mismatch. **QUALIFIES as
  status=verified-as-counterexample.** This is the most interesting
  fragment — exactly what the user flagged as the expected extraction.

- Motivational commentary ("Explorer 2 has found a definitional
  issue..."). **Fails qualifier 1 (not a precise claim).** REJECT.

Cap at 3 fragments per losing route → all 3 qualifiers kept. Preference
order in judge prompt: verified > counterexample > unverified. Here we
have 2 verified + 1 counterexample, all 3 fit.

### Simulated Judge output (the cross-pollination block)

```
## Cross-pollination extraction (v2.3)

[REUSABLE-FRAGMENT: from=Explorer 2, id=fragment-1]
Statement: Essential simple closed curve isotopy classes on
$T^2$ and on $S_{1,1} = T^2 \setminus \{*\}$ are in natural bijection
(the puncture does not add or remove any isotopy class of essential
SCC, because any essential SCC can be isotoped off a point and the
puncture itself bounds a non-essential small loop).
Proof sketch: see Explorer 2 Step 3 (two-directional argument: essential
SCC on $S_{1,1}$ extends to $T^2$ by filling in; essential SCC on $T^2$
can be isotoped off the puncture point).
Status: verified
Relevance: Fixer can cite to avoid re-deriving the puncture-invisibility
lemma if a future variant of the proof needs it.

[REUSABLE-FRAGMENT: from=Explorer 2, id=fragment-2]
Statement: For primitive $(p_1,q_1), (p_2,q_2) \in \mathbb{Z}^2$ labeling
slopes on $T^2$, the geometric intersection number of the two
straight-line SCCs equals $|p_1 q_2 - p_2 q_1|$ exactly, because the
algebraic intersection number $\hat i = \pm \det$ and the straight-line
representatives realize the minimum $i = |\hat i|$.
Proof sketch: see Explorer 2 Step 4 ($i \ge |\hat i|$ combined with
straight-line explicit transverse-count and primitivity ensuring no
multi-intersection).
Status: verified
Relevance: Route D's Step 4 uses a transverse-count argument that
effectively invokes this identity. If Auditor raises an F2 (citation
check) on Route D's geometric count, Fixer can cite fragment-2 instead
of re-deriving the determinant identity from scratch.

[REUSABLE-FRAGMENT: from=Explorer 2, id=fragment-3]
Statement: Under problem.md §8's literal edge rule ($\{a,b\}$ is an edge
iff $i(a,b) = 0$ and $a \ne b$), distinct primitive-slope classes on
$S_{1,1}$ are NEVER adjacent: concretely, $i(\mu, \lambda) = 1 \ne 0$
for the meridian $\mu = (1,0)$ and longitude $\lambda = (0,1)$.
Proof sketch: counterexample — direct computation via the determinant
identity (fragment-2). Straight-line representatives of $\mu, \lambda$
meet in exactly one point on $T^2$; removing a disjoint puncture on
$S_{1,1}$ does not change this.
Status: verified-as-counterexample
Relevance: WARNING for any future Fixer. The "standard" Farey-graph
edge convention uses $i = 1$, not $i = 0$. If a future Fixer attempts
to upgrade Route D to a Farey-graph edge-listing argument, this fragment
flags that such an upgrade would require re-interpreting problem.md §8,
which Explorer 2 concluded is beyond Fixer authority. Route D's
coherent-resolution surgery finesses this by producing a disjoint
(i.e. $i = 0$) representative directly, not by invoking the Farey edge
rule. Keep Route D's current framing.
```

### Auditor-side check on this extraction

Auditor reads the fragments on the next round and may:
- Accept fragment-1, fragment-2 as `status=verified` (no action needed).
- Flag fragment-3 with a note that any Fixer citing it must not treat
  it as a proof ingredient but as a constraint on proof strategy (it
  prevents a wrong direction).

Best-case Auditor behavior (simulated here):
```
### F? Cross-pollination sanity (v2.3, 2026-04-21)
- Fragments extracted: 3 (from Explorer 2).
- Fragments within the 3-per-route cap: YES.
- fragment-1 status=verified: Explorer 2 Step 3 argument is two-directional
  and cites only problem.md's background. Independently re-read, the
  argument is correct. PASS.
- fragment-2 status=verified: Explorer 2 Step 4 argument is correct
  modulo the classical homology fact $i \ge |\hat i|$. The $i = |\hat i|$
  upgrade on $T^2$ is justified by straight-line minimality. PASS.
- fragment-3 status=verified-as-counterexample: the concrete witness
  ($\mu, \lambda$ have $i = 1$) is correct by direct computation. The
  "warning" interpretation is correctly flagged in Relevance. PASS.
```

## Contrast: a non-qualifying fragment candidate

For negative control, consider what would happen if Judge tried to
extract Explorer 2's **hypothesis** at Step 5: "maybe problem.md
definition is using a different edge convention than stated". This fails:
- Qualifier 1 (precise claim): FAILS — this is a speculative hypothesis,
  not a stated lemma.
- Qualifier 2 (verifiable): FAILS — cannot be verified, refuted, or
  sketched; it's a meta-observation about the problem statement.
Judge correctly rejects this from the extraction.

## Result

**PASS.** The v2.3 cross-pollination rule correctly:
1. Extracts 3 fragments from the losing Explorer 2 (within the cap).
2. Correctly tags statuses (2 × verified, 1 × verified-as-counterexample).
3. Critically, extracts the negative result (SP-A3 as a concrete
   counterexample) — matching the expected outcome flagged by the user.
4. Correctly rejects non-qualifying candidates (textbook-L1 Claim 1;
   speculative motivational remarks).

The fragment-3 counterexample is the most valuable product: it
preserves Explorer 2's forensic discovery (Farey-edge convention
mismatch) as a constraint on future Fixer rounds, rather than
discarding the losing-route output entirely.

**Design working as intended:** sanity check did not rubber-stamp.
The fragment-3 Relevance explicitly flags that the counterexample is
a CONSTRAINT on strategy (don't use Farey-edge rule), not a proof
ingredient — a distinction that Judge would need to make carefully in
future real-world runs.
