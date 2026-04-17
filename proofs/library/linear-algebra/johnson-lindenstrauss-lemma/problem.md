# Johnson-Lindenstrauss Lemma

## Source
- Paper: Johnson & Lindenstrauss 1984; simplified proof via Dasgupta & Gupta 2003
- Context: Fundamental dimensionality reduction result; foundation for random projections, compressed sensing, nearest-neighbor search, and streaming algorithms

## Statement

**Theorem (Johnson-Lindenstrauss).** For any $0 < \varepsilon < 1$ and any finite set $\mathcal{X} \subset \mathbb{R}^d$ of $n$ points, there exists a map $f: \mathbb{R}^d \to \mathbb{R}^k$ with

$$k = O\!\left(\frac{\log n}{\varepsilon^2}\right)$$

such that for all $u, v \in \mathcal{X}$:

$$(1 - \varepsilon)\|u - v\|_2^2 \;\le\; \|f(u) - f(v)\|_2^2 \;\le\; (1 + \varepsilon)\|u - v\|_2^2.$$

Moreover, $f$ can be taken as a random linear map $f(x) = \frac{1}{\sqrt{k}} A x$ where $A \in \mathbb{R}^{k \times d}$ has i.i.d. $\mathcal{N}(0, 1)$ entries, and the above holds with probability at least $1 - 1/n$.

## Difficulty
research
