# Scout — $\mathcal{C}(S_{1,1})$ is connected

**Date.** 2026-04-21.
**Problem.** See `problem.md`. Prove the curve complex of the once-punctured
torus is connected (1-skeleton).

## Step 0 — Library / seed survey

Consulted:

- `proofs/library/low-dimensional-topology/simplicial-complexes/` — contains
  only `README.md`; **no curve-complex lemmas on disk**.
- `proofs/library/low-dimensional-topology/conventions.md` — convention
  registry for knot invariants; nothing directly applicable to
  $\mathcal{C}(S_{1,1})$.
- `workspace/proof_techniques_ldt.md` — seed technique dictionary. §3.3
  ("Finite-neighborhood argument (toy-but-useful)") notes that for small
  surfaces such as $\Sigma_{0,4}$ and $\Sigma_{1,1}$, $\mathcal{C}(S)$ is
  known to coincide with the Farey graph, with TSV ground-truth via
  `tsv_simplicial.verify_simplicial_distance_upper_bound`. §3.1–3.2
  (subsurface projection, hierarchies) are labelled reference-only / global.
- `workspace/failure_patterns.md` filtered by
  `domain: low-dimensional-topology`: **all** recorded LDT failures are in
  `subdomain: knot-invariants` (TSV Kauffman-bracket regression;
  spiral-knot Seifert-matrix attempt; spiral-knot skein induction;
  spiral-knot key identity). **No `subdomain: curve-complex` failures
  recorded**, so no pattern to avoid.

Conclusion of library / seed survey:
- Library is **empty of curve-complex lemmas** — any lemma Fixer needs will
  have to be derived from first principles, not looked up.
- Seed dictionary §3.3 **names the Farey-graph identification** as a known
  technique for $S_{1,1}$. This is the pipeline's pre-existing knowledge —
  Scout treats it as a route candidate, not as a given.

## Step 1 — Candidate route enumeration

Five candidate routes follow. They are not rank-ordered; ranking is Judge's
job.

### Route A — Farey-graph identification

**Technique class:** explicit combinatorial model. Identify isotopy classes
of essential simple closed curves on $S_{1,1}$ with a discrete set of
rational invariants, show adjacency in $\mathcal{C}(S_{1,1})$ is an explicit
arithmetic condition, and conclude by connectedness of the resulting
combinatorial graph.

**Sketch.** Lift the once-punctured torus to its universal cover (or to
$\mathbb{R}^2 \setminus \mathbb{Z}^2$). Essential simple closed curves on
$T^2$ are known to biject with primitive homology classes, parametrized
by coprime pairs $(p, q) \in \mathbb{Z}^2$ modulo $\pm 1$. The puncture
converts "essential on $T^2$" to "essential on $S_{1,1}$" without changing
this bijection (the puncture cannot be surrounded by a simple closed curve
other than a puncture-parallel loop, which is explicitly excluded as
non-essential). Adjacency (disjointness, $i = 0$) then becomes an explicit
arithmetic condition on the pairs $(p_1, q_1)$, $(p_2, q_2)$. Connectedness
of the resulting graph is a classical finite-arithmetic statement
(mediants / continued fractions).

Risk: the bijection step and the adjacency-equals-arithmetic step are both
nontrivial and need clean statements. Library currently has zero relevant
entries — this route depends on Explorer deriving the bijection from
scratch.

Cost estimate: medium-high derivation, low combinatorics once set up.

### Route B — Direct intersection-number induction

**Technique class:** well-founded induction on a nonnegative integer
invariant.

**Sketch.** Induct on $N = i(a, b)$. Base case $N = 0$: then either $a = b$
(distance 0) or $a \cap b = \emptyset$ (distance 1), so $a$ and $b$ are
connected. Inductive step: given $a, b$ with $i(a, b) = N > 0$, exhibit an
essential simple closed curve $c$ with $i(a, c) + i(c, b) < 2N$ and
$i(a, c), i(c, b) < N$ (or directly $i(c, a) + i(c, b)$ smaller). Then by
two applications of the IH, $c$ connects to both $a$ and $b$, chaining to
the desired sequence.

The existence of such a $c$ comes from a "surgery" operation: take any
intersection point $p \in a \cap b$ and resolve $a \cup b$ locally to
produce a new simple closed curve with strictly fewer intersections with
each of $a$ and $b$ (and verify it is essential).

Risk: the surgery-and-essentiality step is the load-bearing piece.
Showing strict decrease of intersection number is a textbook lemma in
surface topology ("bigon criterion" is one formulation); this route must
either import that lemma as an L2 citation or redo the intersection-
decrease argument from first principles. Without library support, this
will need a careful diagrammatic argument.

Cost estimate: moderate — the induction frame is short; the surgery
lemma is the work.

### Route C — $\pi_1$-translation and algebraic adjacency

**Technique class:** identify curves with primitive conjugacy classes in
$\pi_1(S_{1,1}) = F_2$, the free group on two generators. Essential
simple closed curves correspond to primitive elements (up to inversion /
conjugacy). Adjacency becomes an algebraic condition on the words.

**Sketch.** Fix generators $x, y$ of $\pi_1(S_{1,1}, *) \cong F_2$
(with the puncture not in the base loop), corresponding respectively to
the meridian $\mu$ and longitude $\lambda$. An essential simple closed
curve $c$ determines a primitive conjugacy class $[w_c] \subset F_2$.
Conversely, a well-known characterization (cyclic words that are "simple")
classifies which primitive elements are represented by simple curves.
Disjointness is then an algebraic condition on pairs of cyclic words.
Connectedness becomes a statement about the combinatorics of primitive
elements in $F_2$.

Risk: "which primitive conjugacy classes are simple on $S_{1,1}$?"
is itself a theorem (due to Cohen–Metzler–Zupan or Goldman's work on
the $\pi_1$ model); a self-contained proof risks recapitulating it.

Cost estimate: high; significant algebraic preparation.

### Route D — Minimal-position / bigon-criterion surgery

**Technique class:** put $(a, b)$ in minimal position, then do an explicit
annular/bigon surgery to produce $c$.

**Sketch.** Every pair of isotopy classes has representatives $a', b'$ in
"minimal position" (no bigons, $|a' \cap b'| = i(a, b)$). When $i(a, b) > 0$,
take an intersection point $p$ and the two arcs $a' \cap N, b' \cap N$
where $N$ is a small bigon or annular neighborhood; perform an oriented
resolution to produce a simple closed curve $c$ that (i) has strictly
smaller intersection with $a$ *or* with $b$, and (ii) is essential. Induct
on $i(a, b)$.

This is a variant / geometric specialization of Route B. Difference from
B: B's induction chooses $c$ abstractly; D specifies the surgery explicitly
using minimal-position representatives.

Risk: "minimal-position" and "no bigons" are technical lemmas in their own
right. Without library, the Explorer must state and use them, which might
require `[L2: Farb-Margalit, §1.2]` citation.

Cost estimate: moderate; leans on standard surface-topology lemmas.

### Route E — Enumeration over small genus / direct topological argument

**Technique class:** exploit the smallness of $S_{1,1}$ (genus 1, one
puncture) directly. Possibly: the mapping class group $\mathrm{Mod}(S_{1,1})$
acts transitively on essential simple closed curves (classical fact); if
we can show a single explicit adjacency at a specific "reference" curve,
and show the action sends adjacencies to adjacencies, connectedness of the
orbit plus a connecting edge suffices.

**Sketch.** $\mathrm{Mod}(S_{1,1}) \cong SL(2, \mathbb{Z})$ (classical
fact, but would be a heavy citation). It acts on isotopy classes of
essential simple closed curves *transitively* because every such curve is
equivalent to the meridian $\mu$ by a homeomorphism. Pick an edge $\mu \to
\lambda$ in $\mathcal{C}(S_{1,1})$ (they are disjoint). If we can show the
MCG-orbit of any vertex hits every vertex (transitivity of the action on
vertices), plus the action preserves edges, connectedness follows from
connectedness of $\mathrm{Mod}(S_{1,1})$-word-reachability from any curve
to $\mu$.

Risk: significant: depends on $\mathrm{Mod}(S_{1,1}) \cong SL(2, \mathbb{Z})$
(L2 citation), and on the "connectedness of word-reachability" step being
less work than Route A or B.

Cost estimate: high (two deep background citations).

## Step 2 — Route summary table

| Route | Technique | L-depth | TSV use | Library fit | Risk |
|-------|-----------|---------|---------|-------------|------|
| A | Combinatorial-model identification | Moderate (1-2 L2) | possible (tsv_simplicial finite neighborhood) | none; all from scratch | bijection step is work |
| B | Intersection-number induction | Moderate (1 L2 for surgery) | none | none | surgery-strict-decrease is load-bearing |
| C | $\pi_1$ / primitive-conjugacy model | Heavy (deep L2) | none | none | recapitulates an external theorem |
| D | Minimal-position bigon surgery | Moderate (1-2 L2) | none | none | minimal-position technical |
| E | MCG action transitivity | Heavy (2 L2: $\mathrm{Mod} \cong SL_2\mathbb{Z}$, transitivity) | none | none | heavy background |

## Step 3 — Routing decision

Forward three candidates to Explorer in parallel:

- **Explorer 1: Route B (intersection-number induction).** Lowest-depth
  route; produces a direct symbolic proof. A candidate "honest" proof that
  does not appeal to heavy background.
- **Explorer 2: Route A (Farey-graph / combinatorial-model
  identification).** Best-studied route for this specific surface; the
  seed dictionary §3.3 flags it as the known technique; the pipeline should
  see whether it can actually derive the required bijection and adjacency
  rule from first principles.
- **Explorer 3: Route D (minimal-position surgery).** Geometric variant of
  B; proceeds by an explicit surgery rather than an abstract strict-
  decrease. If B gets stuck on the surgery lemma, D may exhibit the same
  surgery concretely.

Routes C and E are parked. Both require deep $F_2$-primitive or
$\mathrm{Mod}(S_{1,1}) \cong SL(2, \mathbb{Z})$ citations; if all three
forwarded routes fail, Judge can decide to resurrect one of them.

## Step 4 — Flags for downstream

- `[TECHNIQUE-NEW]` on whatever the winning technique turns out to be,
  for the LDT dictionary growth log — nothing in `proof_techniques_ldt.md`
  currently records a *finished* curve-complex proof technique (only
  reference-level mentions).
- `[LIBRARY-EMPTY]` warning: `simplicial-complexes/` is essentially empty;
  any lemma Fixer needs in this area must be derived in-line and may
  later be promoted to a library entry.

Route suggestions to Explorers are **hints only**. Each Explorer may
re-route mid-execution if their chosen approach stalls.
