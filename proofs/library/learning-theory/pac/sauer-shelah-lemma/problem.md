# Sauer-Shelah Lemma

## Source
- Paper: Sauer 1972, Shelah 1972 (independently)
- Context: Cornerstone of VC theory, bounds the growth function by a polynomial in the VC dimension

## Statement

**Lemma (Sauer-Shelah).** Let $\mathcal{H}$ be a hypothesis class of binary functions $h: \mathcal{X} \to \{0, 1\}$ with VC dimension $\text{VCdim}(\mathcal{H}) = d < \infty$. The growth function (shattering coefficient) is defined as:

$$\Pi_{\mathcal{H}}(n) = \max_{x_1, \ldots, x_n \in \mathcal{X}} |\{(h(x_1), \ldots, h(x_n)) : h \in \mathcal{H}\}|.$$

Then for all $n \geq d$:

$$\Pi_{\mathcal{H}}(n) \leq \sum_{i=0}^{d} \binom{n}{i} \leq \left(\frac{en}{d}\right)^d.$$

## Difficulty
research
