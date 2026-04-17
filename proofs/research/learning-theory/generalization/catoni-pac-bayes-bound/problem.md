# PAC-Bayes Oracle Inequality: Catoni's Bound with KL Regularization

## Source
- **Paper**: O. Catoni, *"PAC-Bayesian Supervised Classification: The Thermodynamics of Statistical Learning"*, IMS Lecture Notes 2007; refined in P. Alquier, J. Ridgway, N. Chopin, *"On the properties of variational approximations of Gibbs posteriors"*, JMLR 2016.
- **Context**: PAC-Bayes bounds provide a fundamental framework for analyzing randomized predictors via KL divergence regularization. Catoni's bound is tighter than McAllester's because it interpolates between fast (1/n) and slow (1/√n) rates via a single inverse KL inequality, and forms the theoretical basis for modern PAC-Bayesian generalization analyses (Dziugaite-Roy 2017, Germain et al. 2016).

## Statement

**Setting.** Let $\mathcal{Z}$ be a sample space, $\mathcal{H}$ a hypothesis class, and $\ell: \mathcal{H} \times \mathcal{Z} \to [0, 1]$ a bounded loss. Let $P$ be a data-independent **prior** distribution on $\mathcal{H}$. Given i.i.d. sample $S = (Z_1, \dots, Z_n)$ from unknown distribution $\mathcal{D}$ on $\mathcal{Z}$, define for any posterior $Q$ on $\mathcal{H}$:

- **Empirical risk**: $\hat R_S(Q) := \mathbb{E}_{h \sim Q} \frac{1}{n}\sum_{i=1}^n \ell(h, Z_i)$.
- **Population risk**: $R(Q) := \mathbb{E}_{h \sim Q} \mathbb{E}_{Z \sim \mathcal{D}} \ell(h, Z)$.

**Target theorem (Catoni's PAC-Bayes bound).** For any $\delta \in (0, 1)$, with probability at least $1 - \delta$ over the sample $S$, **for all posteriors** $Q$ simultaneously:

$$\boxed{\;R(Q) \;\le\; \frac{1}{1 - e^{-\lambda/n}}\cdot\frac{\lambda}{n}\cdot\left[\hat R_S(Q) + \frac{\mathrm{KL}(Q \| P) + \log(1/\delta)}{\lambda}\right]\;}$$

for every fixed $\lambda > 0$ (chosen before seeing data). Equivalently, for every fixed $\lambda > 0$,
$$R(Q) \le \frac{\lambda/n}{1 - e^{-\lambda/n}}\cdot\hat R_S(Q) + \frac{1}{1-e^{-\lambda/n}}\cdot\frac{\mathrm{KL}(Q\|P) + \log(1/\delta)}{n}.$$

**Interpretation.**
- When $\lambda = \sqrt{n\log(1/\delta)}$: interpolates the $1/\sqrt{n}$ rate (slow regime, any loss).
- When $\lambda = n$: achieves the $1/n$ "fast rate" when $\hat R_S(Q)$ is small (interpolation).
- The "inverse KL" form is self-bounding: $R(Q)$ appears on both sides.

**Alternative form (McAllester-Catoni blend).** As $\lambda \to 0^+$, the bound reduces to McAllester's bound:
$$R(Q) \le \hat R_S(Q) + \sqrt{\frac{\mathrm{KL}(Q\|P) + \log(1/\delta)}{2n}} + O(1/n).$$

## Difficulty
**research**

## Key intermediate results to prove

1. **Donsker-Varadhan variational formula**: For any measurable $\phi: \mathcal{H} \to \mathbb{R}$ and any probability $Q \ll P$,
$$\mathbb{E}_{h \sim Q}[\phi(h)] \le \log \mathbb{E}_{h \sim P}[e^{\phi(h)}] + \mathrm{KL}(Q\|P).$$

2. **Log-moment generating function via Hoeffding's inequality**: For any fixed $h \in \mathcal{H}$ and loss $\ell(h, \cdot) \in [0,1]$, the MGF of the centered empirical average satisfies
$$\mathbb{E}_{S}\exp\left(\lambda[R(h) - \hat R_S(h)]\right) \le \exp\left(\frac{\lambda^2}{8n}\right)$$
by Hoeffding's lemma applied to the bounded i.i.d. sum.

3. **Markov's inequality for the PAC-Bayes "inner sup"**: Applying Markov's inequality to the exponential:
$$\mathbb{P}_S\left(\mathbb{E}_{h \sim P}\exp(\lambda[R(h) - \hat R_S(h)]) > \frac{e^{\lambda^2/(8n)}}{\delta}\right) \le \delta.$$

4. **Sharper MGF via Bernstein**: For tighter bounds, replace the Hoeffding $\lambda^2/8n$ term with the Bernstein-style $(e^{\lambda/n} - 1 - \lambda/n) \cdot (\text{variance proxy})$, which is what gives Catoni's "inverse KL" form. The key inequality:
$$\mathbb{E}_S\exp(\lambda \hat R_S(h) - \lambda \bar R(h)) \le \exp\left((e^{\lambda/n}-1-\lambda/n)\cdot n\cdot\bar R(h)\right)$$
where $\bar R(h) = R(h)$ is the population risk (for $\ell \in [0,1]$, using sub-Bernstein MGF for Bernoulli-like tails).

5. **Combination via Donsker-Varadhan + Markov**: Combine steps 1, 2 (or 4), and 3 to obtain the "for all $Q$" PAC-Bayes bound — the uniformity over $Q$ is automatic from the variational formula.

6. **Rearrangement to inverse-KL form**: The $\lambda^2/(8n)$ factor (or sub-Bernstein analog) combined with the exponential from Step 4 yields the $\lambda/(1-e^{-\lambda/n})$ coefficient after rearrangement. Verify the algebra.
