# Problem — Kauffman bracket recursion for $B_2$ torus braid closures

## Statement

Let $\sigma_1 \in B_2$ be the standard generator of the 2-strand braid group, and for each $n \geq 0$ let $\widehat{\sigma_1^n} \subset S^3$ denote the plat/standard closure of $\sigma_1^n$. Let $B_n := \langle \widehat{\sigma_1^n} \rangle \in \mathbb{Z}[A, A^{-1}]$ denote the Kauffman bracket in the convention $\langle O \rangle = 1$, $\langle L \sqcup O \rangle = (-A^2 - A^{-2}) \langle L \rangle$.

**Prove**: for all $n \geq 0$,
$$B_{n+2} = (A - A^{-3}) \, B_{n+1} + A^{-2} \, B_n,$$
with base cases $B_0 = -A^2 - A^{-2}$ and $B_1 = -A^3$.

## Context

- This is a standard consequence of Temperley–Lieb $TL_2$ representation theory + Markov trace.
- Included in the diagnostic suite (Probe 4) to stress the V2 + LDT pipeline on an induction-requiring, beyond-TSV-table-coverage problem.
- Expected difficulty for the system: medium-high. Auditor should flag at least one gap if Explorer does not independently derive the TL presentation.

## Difficulty

Advanced (research-library level; beyond textbook problem-set standard).
