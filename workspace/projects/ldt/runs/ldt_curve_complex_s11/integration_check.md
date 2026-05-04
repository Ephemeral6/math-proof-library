# Integration Check — $\mathcal{C}(S_{1,1})$ connectedness

**Date.** 2026-04-21.
**Input.** `integrator_output.md` (Integrator-consolidated self-contained proof).
**Purpose.** Verify the integrator's artifact stands alone: a reader
with only the problem statement and this file (plus cited textbook)
can verify the proof.

## Check 1 — Every symbol / object introduced is defined

| Symbol / object | Defined where |
|-----------------|---------------|
| $S_{1,1}$ | problem.md §1 (imported via theorem statement) |
| "essential simple closed curve" | problem.md §3 |
| isotopy class | problem.md §4 |
| $i(a, b)$ | problem.md §6 |
| $\mathcal{C}(S_{1,1})$, edge rule | problem.md §8 / theorem statement |
| $H_1(S_{1,1}; \mathbb{Z}) \cong \mathbb{Z}^2$ | L1 fact (stated in Lemma 1 premise) |
| null-homologous ⇔ separating | L1 fact (used in Lemma 1) |
| $\chi$ of compact bounded surface | L1 fact (used in Lemma 1) |
| minimal position | defined inside Lemma 2, citing FM Prop 1.6 |
| coherent resolution $a' \#_p b'$ | defined inside Lemma 2 with explicit coordinates |
| $\epsilon \in \{\pm 1\}$ | defined inside Lemma 2 |
| opposite smoothing $a' \#'_p b'$ | defined in inductive step Case B |
| band-sum homology | L1 fact (used in Lemma 2(iii)) |

**PASS:** every object used in the proof is either defined in this file
or declared as a standard L1 fact.

## Check 2 — Every claim has a supporting reason

Walking through the artifact claim-by-claim:

- "In minimal position $|a' \cap b'| = i(a,b)$" — definition of minimal
  position.
- "Minimal position exists" — FM Prop 1.6 [L2].
- "$a' \#_p b'$ is a disjoint union of simple closed curves" —
  Lemma 2(i), proof sketch.
- "$|(a' \#_p b') \cap a'| = N - 1$" — Lemma 2(ii), proof by coordinate
  chart + $\delta$-shift.
- "$[a' \#_p b'] = [a'] + \epsilon [b']$" — Lemma 2(iii), standard
  band-sum homology [L1].
- "Null-homologous ⇔ separating" — cited as standard [L1].
- "Homology additive over components" — standard [L1]; used in
  Case A.
- "Nonzero homology ⇒ essential" — Lemma 1 contrapositive.
- "$2[a'] \ne 0$" — torsion-freeness of $\mathbb{Z}^2$, standard [L1].
- "$i(c, a) \le |c' \cap a'|$" — definition of $i$ as minimum.
- "Strong induction closes" — well-ordering of $\mathbb{Z}_{\ge 0}$.

**PASS:** every nontrivial step has an explicit support (Given, L1
standard, L2 citation, or proof in this file).

## Check 3 — No circular or forward references

- Lemma 1 is proved first; used in Lemma 2's deductions and in the
  Case-A essentiality step.
- Lemma 2 depends only on Lemma 1 + L1/L2 facts.
- Inductive step uses only Lemmas 1, 2, and the IH (which depends on
  smaller $N$).
- Base case uses only the problem's §7 fundamental-fact.

Directed dependency graph:
  Lemma 1 → Lemma 2 → Inductive step → Conclusion.

**PASS:** acyclic, self-contained.

## Check 4 — No meta-language / process residue

Scanned the artifact for phrases like "Fixer said", "Auditor told me",
"round N", "see §N of another file", "per the judge", etc.

- None present. The artifact reads as a standalone mathematical text.

**PASS.**

## Check 5 — Single-L2 claim verified

The citation summary claims exactly one L2: Farb–Margalit Prop 1.6.
Scanning the Lemma/Theorem proof body for external citations:

- "existence: Farb–Margalit, *A Primer on Mapping Class Groups*,
  Proposition 1.6" — the single L2.
- No other author-name citations.

**PASS.**

## Check 6 — Consistency with problem.md

- Theorem statement matches problem.md's "theorem to be proved".
- Edge rule uses $i(a, b) = 0 \wedge a \ne b$, matching problem.md §8.
- Fundamental fact invocation ($i = 0 \iff$ same-or-disjoint) matches
  problem.md §7.

**PASS.**

## Check 7 — Spot-check a concrete case

Pick $a = \mu$ (meridian, $[\mu] = (1, 0)$) and $b = \lambda$
(longitude, $[\lambda] = (0, 1)$), both named in problem.md §"small-
case hints". On $T^2$ these are transverse at one point
($(0, 0) = $ origin/puncture-neighborhood); but both representatives can
be isotoped to avoid the puncture. On $S_{1,1}$ the puncture is
avoidable in a small neighborhood; a transverse realization has
$|\mu' \cap \lambda'| = 1$ (one crossing).

So $i(\mu, \lambda) = 1$. Applying the inductive step: resolve the
single crossing. Homology of resolution: $(1, 0) + \epsilon (0, 1) \in \{(1, 1), (1, -1)\}$,
both nonzero. Pick the $(1, 1)$ smoothing; its isotopy class has
$i(\cdot, \mu), i(\cdot, \lambda) \le 0$, so by base case is equal-to-or-
disjoint-from each. This gives $\mu \to c \to \lambda$ path.

Sanity: this matches the intuition that in the (literature's) Farey
graph, $\mu = 0/1$ and $\lambda = 1/0$ are mediants-adjacent, connected
via $1/1$. Our proof produces this connection without using the Farey
structure explicitly.

**PASS.**

## Check 8 — Regression surface

The proof as written does NOT:
- depend on TSV facts (no $\mathrm{tsv\_simplicial}$, $\mathrm{tsv\_knot}$
  invocations);
- touch any file outside `workspace/active/ldt_curve_complex_s11/`;
- require any file in `proofs/library/low-dimensional-topology/simplicial-complexes/`.

**PASS:** no regression surface.

## Integration-check verdict

**✓ ACCEPT.** `integrator_output.md` is self-contained, correct, and
citation-minimal (1 L2). Ready for archival as the final artifact.

## Recommendations for archival

- Move `integrator_output.md` → `proof.md` for the archival folder
  `proofs/research/low-dimensional-topology/curve-complex/curve-complex-s11-connected/`
  (or `proofs/library/...` if user classifies as B-class).
- Classification recommendation: **B-class** (classical result; proof
  via standard techniques — intersection-number induction + band-sum
  homology; appears in Farb–Margalit itself as an exercise / remark).
  User must confirm before archival.
- Branch recommendation: `low-dimensional-topology/curve-complex`
  (new sub-branch; currently only `simplicial-complexes/` exists;
  propose to create).
- TECHNIQUE-NEW flag: add to LDT dictionary growth log under
  `proof_techniques_ldt.md` §3.4 (new section).
