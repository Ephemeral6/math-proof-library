# Proof Report: NTK Gram Matrix Positive Definiteness

## 1. Problem Statement
Prove that the infinite-width NTK Gram matrix $H^\infty_{ij} = \mathbb{E}_{w \sim N(0,I)}[x_i^T x_j \cdot \mathbf{1}\{w^T x_i \geq 0, w^T x_j \geq 0\}]$ is positive definite when $\|x_i\| = 1$ and $x_i \neq \pm x_j$ for $i \neq j$.

**Source**: Du, Zhai, Poczos, Singh (2019), ICML 2019.
**Difficulty**: research

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 4 routes proposed |
| Explorer | Opus | 4 proofs attempted, all succeeded with varying quality |
| Judge | Sonnet | Route 4 selected (score 38/40) |
| Audit | Opus | PASS — 7/7 steps VALID |
| Fix | — | Not needed |

## 3. Proof Routes Explored
1. **Arc-Cosine Kernel** (27/40): Schoenberg + Gegenbauer. Elegant but gaps in linearization.
2. **Quadratic Form / Halfspace** (34/40): Direct probability argument. Clean.
3. **Spherical Harmonics** (26/40): Hit obstacle with odd coefficients, rescued via Stone-Weierstrass.
4. **Du et al. / Adjacent Cells** (38/40): Cleanest. Won.

## 4. Final Proof
For any $c \neq 0$: $c^T H^\infty c = \mathbb{E}_w[\|\sum_i c_i \mathbf{1}\{w^T x_i \geq 0\} x_i\|^2] \geq 0$ (PSD). If $= 0$, then on each sign-pattern cell $C_S$: $\sum_{i \in S} c_i x_i = 0$. For each $k$, since $x_k \neq \pm x_j$ means $\Pi_k$ is distinct from all $\Pi_j$, adjacent cells $S$ and $S \setminus \{k\}$ both exist with positive measure. Subtracting: $c_k x_k = 0$, so $c_k = 0$ for all $k$, contradicting $c \neq 0$. Q.E.D.

## 5. Audit Result
**PASS**. All 7 steps valid. Minor notes: dimensional assumption implicit (works for all $d \geq 2$), antipodal necessity case could be elaborated.

## 6. Fix History
No fixes needed.
