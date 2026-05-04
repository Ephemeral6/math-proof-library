# Fixer Round 1 — response to Auditor Round 1

Two findings to address:
1. Step 2 (Markov-trace identification) — derive it, don't just cite.
2. Item F — tighten citations.

## Replacement Step 2 (expanded)

**Claim (restated)**: for any 2-braid $w \in B_2$, $\langle \hat{w} \rangle = \mathrm{tr}(\rho(w))$, where $\mathrm{tr}$ on $TL_2$ is defined by $\mathrm{tr}(1) = d$, $\mathrm{tr}(U) = 1$, extended $\mathbb{Z}[A,A^{-1}]$-linearly.

### Step 2a — The closure–trace map is well-defined

Every 2-braid $w$, regarded as a 2-tangle (two arcs in a rectangle with endpoints at top and bottom), can be expressed in $TL_2$ via the bracket skein: iteratively resolve each crossing of $w$ using
$$\langle \text{crossing} \rangle = A \langle \mathrm{id}_2 \rangle + A^{-1} \langle U \rangle$$
until only 2-tangles with no crossings remain. The only crossing-free 2-tangles are $\mathrm{id}_2$ (two vertical strands) and $U$ (cup–cap). So every bracket state of $w$ is a scalar multiple of $\mathrm{id}_2$ or $U$, and summing over states expresses $\langle w \rangle \in TL_2$ as $\rho(w) = \lambda \cdot 1 + \mu \cdot U$ for some $\lambda, \mu \in \mathbb{Z}[A,A^{-1}]$. This is exactly the bracket-at-tangle construction applied to 2-tangles.

### Step 2b — The closure of $\mathrm{id}_2$ is two disjoint unknots

Closing the identity 2-tangle (two vertical strands) yields two disjoint unknotted circles in $S^3$. By the Kauffman bracket axioms:
$$\langle O \sqcup O \rangle = (-A^2 - A^{-2}) \langle O \rangle = d \cdot 1 = d.$$
So $\langle \widehat{\mathrm{id}_2} \rangle = d$, i.e. $\mathrm{tr}(1) = d$. ✓

### Step 2c — The closure of $U$ is one unknot

Closing the cup–cap 2-tangle: the cup (bottom) joins strands 1 and 2 at the bottom of the rectangle, and the cap (top) joins them at the top; the closure identifies top-strand-1 with bottom-strand-1 and top-strand-2 with bottom-strand-2 via arcs outside the rectangle. Tracing the resulting curve: we get a single closed curve that bounds a disk (it is isotopic to a round circle in the plane). Hence one unknotted circle:
$$\langle \widehat{U} \rangle = \langle O \rangle = 1,$$
i.e. $\mathrm{tr}(U) = 1$. ✓

### Step 2d — Linearity of closure $\Rightarrow$ linearity of trace

The Kauffman bracket is, by construction, $\mathbb{Z}[A,A^{-1}]$-linear in each crossing resolution and (since a diagram's bracket is a polynomial in the resolution weights) linear in any $\mathbb{Z}[A,A^{-1}]$-linear combination of 2-tangles. In particular, if $\rho(w) = \lambda \cdot 1 + \mu \cdot U$, then by linearity
$$\langle \hat{w} \rangle = \lambda \langle \widehat{\mathrm{id}_2} \rangle + \mu \langle \widehat{U} \rangle = \lambda d + \mu \cdot 1 = \mathrm{tr}(\rho(w)).$$
This establishes the claim. ✓

[REF:external, Kauffman 1987, "State models and the Jones polynomial", Topology 26, §3 (bracket at a tangle) and §4 (closure); Jones 1985, "A polynomial invariant for knots via von Neumann algebras", Bull. AMS 12(1), §III.]

The Kauffman/Jones citations now point to specific sections; the derivation above is self-contained for the 2-braid case.

---

## Revised dependency of the proof on external citations

- Step 1 (assignment $\rho$): derived from bracket skein axiom (L: our library's `kauffman-bracket-axioms.md`).
- Step 2 (trace identification): derived above (2a–2d) from the bracket axioms; the external citation now only supplies the section reference for the general $n$-braid theory, which we do not need.
- Steps 3–8: pure algebra + numerical sanity check.

**Net change**: Step 2 is no longer a black-box external citation; it is a ~4-line derivation using only the Kauffman bracket axioms already in our library.

## Request to Auditor

Please re-audit with the expanded Step 2.
