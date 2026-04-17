# Differential Privacy Implies Generalization

## Source
- Paper: "Generalization in Adaptive Data Analysis and Holdout Reuse" (Dwork et al., 2015, NeurIPS) and "Algorithmic Stability for Adaptive Data Analysis" (Bassily et al., 2016, STOC)
- Context: A fundamental bridge between privacy and learning theory — (ε,δ)-differentially private algorithms automatically generalize

## Statement

Let $S = \{z_1, \ldots, z_n\}$ be a training set of $n$ i.i.d. samples from distribution $\mathcal{D}$ over domain $\mathcal{Z}$. Let $\mathcal{A}: \mathcal{Z}^n \to \mathcal{H}$ be a randomized algorithm that is $(\varepsilon, \delta)$-differentially private, meaning for all neighboring datasets $S, S'$ (differing in one element) and all measurable sets $E$:

$$\Pr[\mathcal{A}(S) \in E] \leq e^{\varepsilon} \Pr[\mathcal{A}(S') \in E] + \delta$$

Let $\ell: \mathcal{H} \times \mathcal{Z} \to [0, 1]$ be a bounded loss function.

**Prove:** For any $(\varepsilon, \delta)$-differentially private algorithm $\mathcal{A}$ with $\varepsilon \leq 1$:

$$\left|\mathbb{E}_S\left[\frac{1}{n}\sum_{i=1}^{n} \ell(\mathcal{A}(S), z_i) - \mathbb{E}_{z \sim \mathcal{D}}[\ell(\mathcal{A}(S), z)]\right]\right| \leq (e^{\varepsilon} - 1) + \delta$$

That is, the expected generalization gap is bounded by $(e^{\varepsilon} - 1) + \delta \leq 2\varepsilon + \delta$.

## Difficulty
research
