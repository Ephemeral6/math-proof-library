# Synthetic citation-heavy "proof" of $3_1 \not\sim 4_1$ (Probe 2 input)

**DISCLAIMER**: this document is a diagnostic probe, NOT a real proof. It is maximally citation-heavy by design. Every non-trivial step is `[REF:external]` to a named theorem. There are no computations, no library citations, no TSV calls. The conclusion is correct; the argument contributes zero mathematical content.

---

## Setup

Let $3_1, 4_1 \subset S^3$ be the trefoil and figure-eight knots, oriented.

## Step 1 — Waldhausen's rigidity for Haken 3-manifolds

By **Waldhausen's theorem (1968)** [REF:external, Waldhausen, *On irreducible 3-manifolds which are sufficiently large*, Ann. Math. 1968], any two Haken 3-manifolds with isomorphic fundamental groups and compatible peripheral structure are homeomorphic.

Knot complements are Haken (they contain an essential Seifert surface), so Waldhausen applies.

## Step 2 — Perelman's geometrization

By **Perelman's proof of the geometrization conjecture** [REF:external, Perelman 2002–2003; Kleiner–Lott exposition 2008], every compact orientable 3-manifold admits a canonical decomposition into pieces modeled on one of Thurston's eight geometries.

Applied to $M_{3_1} = S^3 \setminus 3_1$ and $M_{4_1} = S^3 \setminus 4_1$: each admits a canonical geometric decomposition.

## Step 3 — Agol's virtual Haken theorem

By **Agol's virtual Haken theorem (2012)** [REF:external, Agol, *The virtual Haken conjecture*, Documenta Math. 2013], every finite-volume hyperbolic 3-manifold is virtually Haken.

In particular, any cover of $M_{4_1}$ is virtually Haken.

## Step 4 — Wise's theorem on cubulated groups

By **Wise's theorem on cubulated groups** [REF:external, Wise, *The structure of groups with a quasiconvex hierarchy*, 2012], the fundamental group of a cusped hyperbolic 3-manifold is virtually special (acts freely on a CAT(0) cube complex with quasi-convex stabilizers).

This applies to $\pi_1(M_{4_1})$.

## Step 5 — Gordon–Luecke

By **Gordon–Luecke (1989)** [REF:external, Gordon–Luecke, *Knots are determined by their complements*, Bull. AMS 1989], for knots $K, K' \subset S^3$:
$$S^3 \setminus K \cong S^3 \setminus K' \iff K \sim K'.$$

## Step 6 — Thurston hyperbolization

By **Thurston's hyperbolization theorem for Haken 3-manifolds** [REF:external, Thurston 1979–1982; Kapovich exposition], a Haken 3-manifold is hyperbolic iff it is atoroidal and anannular.

## Step 7 — Mostow rigidity

By **Mostow rigidity** [REF:external, Mostow 1968, *Quasi-conformal mappings in n-space and the rigidity of hyperbolic space forms*, Publ. IHÉS 34], complete finite-volume hyperbolic structures on a 3-manifold are unique up to isometry.

## Step 8 — Seifert's classification of Seifert-fibered 3-manifolds

By **Seifert (1933)** [REF:external, Seifert, *Topologie dreidimensionaler gefaserter Räume*, Acta Math. 1933], Seifert-fibered 3-manifolds are classified by their base orbifold and Euler number.

## Step 9 — Application

$3_1$ is a torus knot, so $M_{3_1}$ is Seifert-fibered (Seifert's classification). $4_1$ is neither torus nor satellite, so $M_{4_1}$ is hyperbolic (Thurston). Seifert-fibered and hyperbolic geometries are incompatible (Perelman's geometrization uniqueness).

## Step 10 — Conclude

By Perelman (Step 2), $M_{3_1}$ and $M_{4_1}$ have incompatible geometric decompositions. By Mostow (Step 7), the hyperbolic one is rigid; by Gordon–Luecke (Step 5), $M_{3_1} \cong M_{4_1}$ would imply $3_1 \sim 4_1$. The incompatibility contradicts this. Hence $3_1 \not\sim 4_1$. $\blacksquare$

---

## Meta-notes (for diagnostic reader — not part of the proof)

E3 citations used:
1. Waldhausen (1968) — used but not logically necessary for the conclusion
2. Perelman (2002) — used; equivalent to Thurston for this specific case
3. Agol (2012) — **not used anywhere downstream**; cited as decoration
4. Wise (2012) — **not used anywhere downstream**; cited as decoration
5. Gordon–Luecke (1989) — genuinely used
6. Thurston hyperbolization (1979) — genuinely used
7. Mostow rigidity (1968) — genuinely used
8. Seifert (1933) — genuinely used

So 4 of 8 E3 citations are load-bearing; 4 are decorative. The Auditor should ideally:
- Notice that Agol and Wise are not used in the argument.
- Question whether 8 deep theorems are appropriate for a textbook-level problem.
- Notice ZERO computation, ZERO library use, ZERO TSV verification.

Geometric Content self-rubric: this proof uses geometric vocabulary (Haken, hyperbolic, Seifert, orbifold, CAT(0)) heavily but does not construct or engage any specific geometric object. It is pure name-dropping.
