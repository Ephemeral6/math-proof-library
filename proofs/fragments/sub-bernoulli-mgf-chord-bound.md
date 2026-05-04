# Fragment: sub-bernoulli-mgf-chord-bound

## Statement
Let $X$ be a random variable with $X \in [0, 1]$ a.s. and $\mathbb{E}[X] = \mu$. Then for every $u > 0$:
$$\mathbb{E}[e^{-uX}] \;\le\; 1 - \mu(1 - e^{-u}),$$
and consequently
$$\log \mathbb{E}[e^{-uX}] \;\le\; -\mu(1 - e^{-u}).$$

In particular, taking $\mu = R(h)$ and $X = \ell(h, Z)$ for a $[0,1]$-loss gives the **sub-Bernoulli MGF bound** that drives Catoni's PAC-Bayes inequality.

## Proof
The map $x \mapsto e^{-ux}$ is convex on $\mathbb{R}$. The chord between $(0, 1)$ and $(1, e^{-u})$ gives
$$e^{-ux} \le (1-x) \cdot 1 + x \cdot e^{-u} = 1 - x(1 - e^{-u}), \quad x \in [0, 1].$$
Apply pointwise with $x = X$ and take expectation:
$$\mathbb{E}[e^{-uX}] \le 1 - \mu(1 - e^{-u}).$$
For the log form, use the elementary sub-lemma $\log(1 - z) \le -z$ for $z \in [0, 1)$ (verify: $f(z) := \log(1-z) + z$ has $f(0) = 0$ and $f'(z) = -z/(1-z) \le 0$). Apply with $z = \mu(1 - e^{-u}) \in [0, 1)$. $\square$

## Source
- `proofs/research/learning-theory/generalization/catoni-pac-bayes-bound/proof.md` — Lemma 1 + Sub-lemma.

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (drives Catoni's PAC-Bayes bound; tighter than Hoeffding for bounded losses)
- **Potential applications**:
  - Catoni-style PAC-Bayes bounds for $[0,1]$-losses
  - kl-PAC-Bayes (Maurer-Langford) and related sharp bounds
  - Sharper concentration than Hoeffding when the mean is small (interpolation regime)
  - Online learning regret bounds for $[0,1]$-bounded losses
  - Anytime concentration via mixture supermartingales

## Tags
sub-bernoulli, mgf, chord-bound, PAC-Bayes, catoni
